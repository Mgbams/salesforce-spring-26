import { LightningElement, wire } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCases';

const BASE_COLUMNS = [
    {
        label: 'Case Number',
        fieldName: 'caseUrl',       // points to computed URL field
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' },  // display text
            target: '_blank'                      // opens in new tab
        },
        sortable: true
    },
    { label: 'Subject',  fieldName: 'Subject', type: 'text' },
    { label: 'Status',   fieldName: 'Status',  type: 'text' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: getRowActions,
            menuAlignment: 'right'
        }
    }
];

function getRowActions(row, doneCallback) {
    const actions = [];

    if (row.Status !== 'Closed') {
        actions.push({ label: 'Close Case', name: 'close', iconName: 'utility:close' });
    } else {
        actions.push({ label: 'Reopen Case', name: 'reopen', iconName: 'utility:refresh' });
    }

    doneCallback(actions);
}

export default class CaseList extends LightningElement {

    cases = [];
    filterStatus = 'New';
    isLoading = false;
    errorMessage = '';
    columns = BASE_COLUMNS;

    statusOptions = [
        { label: 'New',       value: 'New' },
        { label: 'Working',   value: 'Working' },
        { label: 'Escalated', value: 'Escalated' },
        { label: 'Closed',    value: 'Closed' }
    ];

    @wire(getCases, { statusFilter: '$filterStatus' })
    wiredCases({ data, error }) {
        if (data) {
            // Map each case to add a computed caseUrl field
            this.cases = data.map(c => ({
                ...c,
                caseUrl: `/${c.Id}`   // standard Salesforce record URL
            }));
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = error.body.message;
            this.cases = [];
        }
    }

    handleFilterChange(event) {
        this.filterStatus = event.target.value;
    }

   handleRowAction(event) {
        const action = event.detail.action;
        const row    = event.detail.row;

        if (action.name === 'close') {
            this.updateCaseStatus(row.Id, 'Closed');
        } else if (action.name === 'reopen') {
            this.updateCaseStatus(row.Id, 'New');
        }
    }

    updateCaseStatus(caseId, newStatus) {
        this.cases = this.cases.map(c =>
            c.Id === caseId
                ? { ...c, Status: newStatus }
                : c
        );
    }
}