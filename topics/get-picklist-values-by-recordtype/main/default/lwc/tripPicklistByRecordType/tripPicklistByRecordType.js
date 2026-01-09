import { LightningElement, wire, track } from 'lwc';
import getRecordTypes from '@salesforce/apex/TripPicklistController.getRecordTypes';
import getPicklistValues from '@salesforce/apex/TripPicklistController.getPicklistValues';

export default class TripPicklistByRecordType extends LightningElement {
    @track recordTypes = [];
    @track selectedRecordTypeId = '';
    @track selectedRecordTypeName = '';
    @track picklistHierarchy = [];
    @track isLoading = false;
    @track error;

    // Wire method to get record types
    @wire(getRecordTypes)
    wiredRecordTypes({ error, data }) {
        if (data) {
            this.recordTypes = data.map(rt => ({
                label: rt.Name,
                value: rt.Id,
                developerName: rt.DeveloperName
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.recordTypes = [];
            console.error('Error loading record types:', error);
        }
    }

    // Handle record type selection
    handleRecordTypeChange(event) {
        this.selectedRecordTypeId = event.detail.value;
        const selectedRt = this.recordTypes.find(rt => rt.value === this.selectedRecordTypeId);
        this.selectedRecordTypeName = selectedRt ? selectedRt.label : '';
        
        if (this.selectedRecordTypeId) {
            this.loadPicklistValues();
        } else {
            this.picklistHierarchy = [];
        }
    }

    // Load picklist values for selected record type
    async loadPicklistValues() {
        this.isLoading = true;
        try {
            const result = await getPicklistValues({ 
                recordTypeId: this.selectedRecordTypeId 
            });
            
            if (result && result.length > 0) {
                this.picklistHierarchy = result;
            } else {
                this.picklistHierarchy = [];
                this.error = 'No picklist values found for this record type.';
            }
        } catch (error) {
            console.error('Error loading picklist values:', error);
            this.error = 'Error loading picklist values: ' + error.body?.message || error.message;
            this.picklistHierarchy = [];
        } finally {
            this.isLoading = false;
        }
    }

    // Getter for display control
    get hasRecordTypes() {
        return this.recordTypes && this.recordTypes.length > 0;
    }

    get hasPicklistData() {
        return this.picklistHierarchy && this.picklistHierarchy.length > 0;
    }

    get picklistCount() {
        return this.picklistHierarchy.reduce((total, continent) => {
            return total + continent.countries.reduce((countryTotal, country) => {
                return countryTotal + country.cities.length;
            }, 0);
        }, 0);
    }
}