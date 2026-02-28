// caseDashboardCard.js
import { LightningElement, api } from 'lwc';

export default class CaseDashboardCard extends LightningElement {
    // Contact fields
    @api firstName = 'Sarah';
    @api lastName = 'Connor';

    // Case fields
    @api daysOpen = 17;         // Integer: days since case was opened
    @api priority = 9;          // Integer: 1–10 scale
    @api totalBillableHours;    // May be null if no hours are logged
    @api slaExpirationDate;     // May be null if no SLA is set
    @api hourlyRate = 150;      // Billing rate in USD

    get daysOpenClass() {
        let caseStatus;

        if (this.daysOpen > 14) {
            caseStatus = 'case-overdue';
        } else {
            caseStatus = 'case-on-track';
        }
        
        return caseStatus;
    }

    get priorityClass() {
        let priorityBadge = 'badge badge-normal';

        if (this.priority > 8) {
           priorityBadge = 'badge badge-critical';
        } else if (this.priority > 5) {
            priorityBadge = 'badge badge-high';
        } 

        return priorityBadge;
    }
}