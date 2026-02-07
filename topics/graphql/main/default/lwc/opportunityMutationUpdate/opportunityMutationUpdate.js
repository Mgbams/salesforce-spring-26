import { LightningElement, wire } from 'lwc';
import { gql, graphql, executeMutation } from 'lightning/graphql';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityMutationUpdate extends LightningElement {
    opportunities = [];
    opportunityOptions = [];
    selectedOpportunityId;
    selectedStage;
    errors;
    isLoading = true;
    refreshGraphQL;

    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    @wire(graphql, {
        query: gql`
            query getOpportunities {
                uiapi {
                    query {
                        Opportunity(first: 5, orderBy: { CreatedDate: { order: DESC } }) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    StageName { value }
                                }
                            }
                        }
                    }
                }
            }
        `
    })
    wiredOpportunities(result) {
        this.isLoading = false;
        const { data, errors, refresh } = result;

        if (refresh) {
            this.refreshGraphQL = refresh;
        }

        if (data) {
            this.opportunities = data.uiapi.query.Opportunity.edges.map(edge => ({
                Id: edge.node.Id,
                Name: edge.node.Name.value,
                Stage: edge.node.StageName.value
            }));

            this.opportunityOptions = this.opportunities.map(opp => ({
                label: `${opp.Name} (Current: ${opp.Stage})`,
                value: opp.Id
            }));
        }

        if (errors) {
            this.errors = JSON.stringify(errors);
        }
    }

    handleOpportunityChange(event) {
        this.selectedOpportunityId = event.target.value;
    }

    handleStageChange(event) {
        this.selectedStage = event.target.value;
    }

    getUpdateQuery(opportunityId, stage) {
        return gql`
            mutation UpdateOpportunity {
                uiapi {
                    OpportunityUpdate(input: {
                        Id: "${opportunityId}",
                        Opportunity: {
                            StageName: "${stage}"
                        }
                    }) {
                        Record {
                            Id
                            Name { value }
                            StageName { value }
                        }
                    }
                }
            }
        `;
    }

    async handleUpdate() {
        if (!this.selectedOpportunityId || !this.selectedStage) {
            this.errors = 'Please select both Opportunity and Stage';
            return;
        }

        this.isLoading = true;
        this.errors = undefined;

        try {
            const result = await executeMutation({
                query: this.getUpdateQuery(
                    this.selectedOpportunityId,
                    this.selectedStage
                )
            });

            if (result.errors) {
                this.errors = JSON.stringify(result.errors);
            } else {
                const updated = result.data.uiapi.OpportunityUpdate.Record;
                this.showToast(
                    'Stage Updated',
                    `Opportunity "${updated.Name.value}" moved to "${updated.StageName.value}"`,
                    'success'
                );

                await this.refreshGraphQL?.();
            }
        } catch (error) {
            this.errors = JSON.stringify(error);
        } finally {
            this.isLoading = false;
        }
    }

    get isUpdateDisabled() {
        return this.isLoading || !this.selectedOpportunityId;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }


}
