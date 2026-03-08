import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCases from '@salesforce/apex/CaseQueueController.getCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Case Number', fieldName: 'CaseNumber' },
    { label: 'Subject',     fieldName: 'Subject' },
    { label: 'Priority',    fieldName: 'Priority' },
    { label: 'Region',      fieldName: 'Region__c' },
    { label: 'Status',      fieldName: 'Status' }
];

const REGION_OPTIONS = [
    { label: 'All Regions', value: '' },
    { label: 'EMEA',        value: 'EMEA' },
    { label: 'APAC',        value: 'APAC' },
    { label: 'Americas',    value: 'Americas' }
];

const PRIORITY_OPTIONS = [
    { label: 'All Priorities', value: '' },
    { label: 'High',           value: 'High' },
    { label: 'Medium',         value: 'Medium' },
    { label: 'Low',            value: 'Low' }
];

export default class CaseQueueBrowser extends NavigationMixin(LightningElement) {

    columns         = COLUMNS;
    regionOptions   = REGION_OPTIONS;
    priorityOptions = PRIORITY_OPTIONS;

    selectedRegion   = '';
    selectedPriority = '';
    allCases         = [];

    // Wire service fetches all open cases once on load
    @wire(getCases)
    wiredCases({ data, error }) {
        if (data) {
            this.allCases = data;
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    showErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading cases',
                message: error?.body?.message || 'An unexpected error occurred while retrieving cases.',
                variant: 'error'
            })
        );
    }


    // Returns cases filtered by current selections
    get filteredCases() {
        return this.allCases.filter(c => {
            const regionMatch   = !this.selectedRegion   || c.Region__c === this.selectedRegion;
            const priorityMatch = !this.selectedPriority || c.Priority  === this.selectedPriority;
            return regionMatch && priorityMatch;
        });
    }

    // True when filtered results contain at least one record
    get hasCases() {
        return this.filteredCases.length > 0;
    }

    // True when at least one filter is active (drives noresults vs empty queue state)
    get isFiltered() {
        return this.selectedRegion !== '' || this.selectedPriority !== '';
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
    }

    handlePriorityChange(event) {
        this.selectedPriority = event.detail.value;
    }

    handleClearFilters() {
        this.selectedRegion   = '';
        this.selectedPriority = '';
    }

    handleNewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            }
        });
    }
}