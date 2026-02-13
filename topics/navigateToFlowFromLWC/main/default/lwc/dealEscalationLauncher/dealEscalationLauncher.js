import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DealEscalationLauncher extends NavigationMixin(LightningElement) {

    @api recordId;

    reason = '';
    discountPercent;
    returnUrl;
    screenFlowApiName = 'Opportunity_Deal_Escalation_Request';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference?.state?.c__escalated === 'true') {
            this.showToast(
                'Escalation Submitted',
                'Your deal escalation request was successfully submitted.',
                'success'
            );

            // Remove URL parameter so refresh does not re-trigger toast
            const newState = { ...currentPageReference.state };
            delete newState.c__escalated;

            this[NavigationMixin.Navigate](
                {
                    type: currentPageReference.type,
                    attributes: currentPageReference.attributes,
                    state: newState
                },
                true // replace history entry
            );
        }
    }

    connectedCallback() {
        this.generateReturnUrl();
    }

    async generateReturnUrl() {
        if (!this.recordId) {
            throw new Error('Missing recordId. Cannot generate return URL.');
        }

        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        };

        this.returnUrl = await this[NavigationMixin.GenerateUrl](pageRef);
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleDiscountChange(event) {
        this.discountPercent = event.target.value;
    }

    async handleLaunchFlow() {
        try {
            // Ensure return URL is generated before navigating
            if (!this.returnUrl) {
                await this.generateReturnUrl();
            }

            this.navigateToFlow();

        } catch (error) {
            this.showToast(
                'Navigation Error',
                error.message || 'Unable to launch escalation flow.',
                'error'
            );
        }
    }

    navigateToFlow() {
        this[NavigationMixin.Navigate]({
            type: 'standard__flow',
            attributes: {
                devName: this.screenFlowApiName
            },
            state: {
                flow__recordId: this.recordId,
                flow__reason: this.reason,
                flow__discountPercent: this.discountPercent,
                retURL: this.returnUrl + '?c__escalated=true'
            }
        });
    }

    ///lightning/r/Opportunity/006Ws00000KiKKrIAN/view = this.returnUrl
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

}
