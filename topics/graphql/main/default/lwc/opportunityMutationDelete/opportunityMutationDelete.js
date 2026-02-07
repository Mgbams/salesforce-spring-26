import { LightningElement, wire } from 'lwc';
import { gql, graphql, executeMutation } from 'lightning/graphql';
import { subscribe, MessageContext } from 'lightning/messageService';
import OPPORTUNITY_REFRESH from '@salesforce/messageChannel/opportunityRefresh__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityMutationDelete extends LightningElement {
    opportunities;
    errors;
    isLoading = true;
    refreshGraphQL;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            OPPORTUNITY_REFRESH,
            () => {
                this.refreshGraphQL?.();
            }
        );
    }


    @wire(graphql, {
        query: gql`
            query getOpportunities {
                uiapi {
                    query {
                        Opportunity(first: 5, orderBy: { CreatedDate: { order: DESC } }) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    StageName {
                                        value
                                    }
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
        this.errors = undefined;
        this.opportunities = undefined;

        const { errors, data, refresh } = result;

        if (refresh) {
            this.refreshGraphQL = refresh;
        }

        if (data) {
            this.opportunities = data.uiapi.query.Opportunity.edges.map((edge) => ({
                Id: edge.node.Id,
                Name: edge.node.Name.value,
                Stage: edge.node.StageName?.value
            }));
        }

        if (errors) {
            this.errors = errors;
        }
    }

    get noOpportunities() {
        return !this.opportunities || this.opportunities.length === 0;
    }

    getDeleteQuery(opportunityId) {
        return gql`
            mutation DeleteOpportunity {
                uiapi {
                    OpportunityDelete(input: { Id: "${opportunityId}" }) {
                        Id
                    }
                }
            }
        `;
    }

    async handleDeleteOpportunity(event) {
        const opportunityId = event.target.dataset.id;
        const opportunityName = event.target.dataset.name;

        this.isLoading = true;
        this.errors = undefined;

        try {
            const result = await executeMutation({
                query: this.getDeleteQuery(opportunityId)
            });

            if (result.errors) {
                this.errors = result.errors;
            } else {
                this.showToast(
                    'Deleted',
                    `Opportunity "${opportunityName}" deleted successfully`,
                    'success'
                );

                await this.refreshGraphQL?.();
            }
        } catch (error) {
            this.errors = error;
        } finally {
            this.isLoading = false;
        }
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
