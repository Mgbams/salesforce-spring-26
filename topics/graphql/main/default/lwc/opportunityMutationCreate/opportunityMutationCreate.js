import { LightningElement, wire } from 'lwc';
import { gql, executeMutation } from 'lightning/graphql';
import { publish, MessageContext } from 'lightning/messageService';
import OPPORTUNITY_REFRESH from '@salesforce/messageChannel/opportunityRefresh__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityMutationCreate extends LightningElement {
    opportunityName = '';
    amount;
    errors;
    isLoading = false;

    @wire(MessageContext)
    messageContext;


    getCreateQuery(name, amount) {
        return gql`
            mutation CreateOpportunity {
                uiapi {
                    OpportunityCreate(input: {
                        Opportunity: {
                            Name: "${name}"
                            Amount: ${amount || 0}
                            StageName: "Prospecting"
                            CloseDate: "2026-12-31"
                        }
                    }) {
                        Record {
                            Id
                            Name { value }
                            Amount { value }
                        }
                    }
                }
            }
        `;
    }

    handleNameChange(event) {
        this.opportunityName = event.target.value;
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }

    async handleCreate() {
        if (!this.opportunityName) {
            this.errors = 'Opportunity Name is required';
            return;
        }

        this.isLoading = true;
        this.errors = undefined;

        try {
            const result = await executeMutation({
                query: this.getCreateQuery(this.opportunityName, this.amount)
            });

            if (result.errors) {
                this.errors = JSON.stringify(result.errors);
            } else {
                const created = result.data.uiapi.OpportunityCreate.Record;
                this.showToast(
                    'Success',
                    `Opportunity "${created.Name.value}" created successfully`,
                    'success'
                );

                publish(this.messageContext, OPPORTUNITY_REFRESH, {
                    refresh: true
                });

                this.opportunityName = '';
                this.amount = undefined;
            }
        } catch (error) {
            this.errors = JSON.stringify(error);
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
