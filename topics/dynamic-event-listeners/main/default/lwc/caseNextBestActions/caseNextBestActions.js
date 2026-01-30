import { LightningElement, api, wire } from 'lwc';
import getRecommendedActions from '@salesforce/apex/CaseNextBestActionsController.getRecommendedActions';

import assignCaseToMe from '@salesforce/apex/CaseNextBestActionsController.assignCaseToMe';
import escalateCase from '@salesforce/apex/CaseNextBestActionsController.escalateCase';

import emailCustomerEscalationNotice from '@salesforce/apex/CaseNextBestActionsController.emailCustomerEscalationNotice';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class CaseNextBestActions extends LightningElement {
    @api recordId;

    interactionMode = 'both';
    preview = null;
    errorMessage = null;
    actions;

    modeOptions = [
        { label: 'Preview on Hover/Focus', value: 'preview' },
        { label: 'Execute on Click', value: 'execute' },
        { label: 'Both (Preview + Execute)', value: 'both' }
    ];

    @wire(getRecommendedActions, { caseId: '$recordId' })
    wiredActions({ data, error }) {
        if (data) {
            this.actions = data;
            this.errorMessage = null;
        } else if (error) {
            this.actions = null;
            this.preview = null;
            this.errorMessage =
                error?.body?.message || 'Could not load recommended actions.';
        }
    }

    handleModeChange(event) {
        this.interactionMode = event.detail.value;
        if (this.interactionMode === 'execute') {
            this.preview = null;
        }
    }

    get tileListeners() {
        if (this.interactionMode === 'preview') {
            return { preview: this.handlePreview };
        }
        if (this.interactionMode === 'execute') {
            return { execute: this.handleExecute };
        }
        return { preview: this.handlePreview, execute: this.handleExecute };
    }

    handlePreview = (event) => {
        this.preview = event.detail;
    };

    handleExecute = async (event) => {
        const { actionId, actionLabel } = event.detail;

        try {
            if (!this.recordId) {
                throw new Error(
                    'No Case recordId found. Add this component to a Case Record Page.'
                );
            }

            if (actionId === 'assign') {
                await assignCaseToMe({ caseId: this.recordId });

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Case assigned',
                        message: 'You are now the Case owner.',
                        variant: 'success'
                    })
                );
            } else if (actionId === 'escalate') {
                await escalateCase({ caseId: this.recordId });

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Case escalated',
                        message: 'Case Status updated to Escalated.',
                        variant: 'success'
                    })
                );
            } else if (actionId === 'email') {
                // Send escalation email to customer
                await emailCustomerEscalationNotice({ caseId: this.recordId });

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Email sent',
                        message: 'Customer notified that the case has been escalated.',
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Action executed',
                        message: `${actionLabel} (${actionId})`,
                        variant: 'success'
                    })
                );
            }

            // Refresh record page UI so Owner/Status updates appear
            getRecordNotifyChange([{ recordId: this.recordId }]);
        } catch (e) {
            const msg =
                e?.body?.message ||
                e?.message ||
                'Something went wrong executing the action.';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Action failed',
                    message: msg,
                    variant: 'error'
                })
            );
        }
    };
}
