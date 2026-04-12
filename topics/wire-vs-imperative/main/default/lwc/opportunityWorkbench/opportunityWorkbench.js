import { LightningElement, wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOpenOpportunities from '@salesforce/apex/OpportunityDataController.getOpenOpportunities';
import markWon from '@salesforce/apex/OpportunityDataController.markWon';

const COLUMNS = [
    { label: 'Opportunity', fieldName: 'name', type: 'text' },
    { label: 'Account', fieldName: 'accountName', type: 'text' },
    { label: 'Amount', fieldName: 'amount', type: 'currency' },
    { label: 'Stage', fieldName: 'stageName', type: 'text' },
    { label: 'Close Date', fieldName: 'closeDate', type: 'date' }
];

export default class OpportunityWorkbench extends LightningElement {
    columns = COLUMNS;

    rows = [];
    selectedRowIds = [];

    minAmount = 5000;
    pageSize = 10;
    pageNumber = 1;

    isLoading = false;
    hasLoaded = false;
    hasMore = false;

    errorMessage;
    successMessage;

    wiredResponse;

    @wire(getOpenOpportunities, {
        minAmount: '$minAmount',
        pageSize: '$pageSize',
        pageNumber: '$pageNumber'
    })
    wiredOpportunities(value) {
        this.wiredResponse = value;
        const { data, error } = value;

        this.isLoading = false;
        this.successMessage = undefined;

        if (data) {
            this.rows = data.records || [];
            this.hasMore = data.hasMore;
            this.hasLoaded = true;
            this.errorMessage = undefined;
            this.selectedRowIds = [];
        } else if (error) {
            this.rows = [];
            this.hasMore = false;
            this.hasLoaded = true;
            this.errorMessage = this.reduceError(error);
        }
    }

    handleMinAmountChange(event) {
        const value = Number(event.target.value);
        this.minAmount = Number.isFinite(value) && value >= 0 ? value : 0;
        this.pageNumber = 1;
        this.isLoading = true;
        this.errorMessage = undefined;
        this.successMessage = undefined;
    }

    handleRowSelection(event) {
        this.selectedRowIds = event.detail.selectedRows.map((row) => row.id);
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.isLoading = true;
            this.errorMessage = undefined;
            this.successMessage = undefined;
        }
    }

    handleNext() {
        if (this.hasMore) {
            this.pageNumber += 1;
            this.isLoading = true;
            this.errorMessage = undefined;
            this.successMessage = undefined;
        }
    }

    async handleRefresh() {
        if (!this.wiredResponse) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = undefined;
        this.successMessage = undefined;

        try {
            await refreshApex(this.wiredResponse);
        } catch (error) {
            this.errorMessage = this.reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleMarkWon() {
        if (this.selectedRowIds.length === 0) {
            this.errorMessage = 'Select at least one opportunity before updating.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = undefined;
        this.successMessage = undefined;

        try {
            const updatedCount = await markWon({ opportunityIds: this.selectedRowIds });
            this.successMessage = `${updatedCount} opportunity record(s) updated.`;
            await refreshApex(this.wiredResponse);
        } catch (error) {
            this.errorMessage = this.reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    reduceError(error) {
        if (!error) {
            return 'Unknown error';
        }

        if (Array.isArray(error.body)) {
            return error.body.map((e) => e.message).join(', ');
        }

        if (typeof error.body?.message === 'string') {
            return error.body.message;
        }

        if (typeof error.message === 'string') {
            return error.message;
        }

        return 'An unexpected error occurred.';
    }

    get disablePrevious() {
        return this.isLoading || this.pageNumber === 1;
    }

    get disableNext() {
        return this.isLoading || !this.hasMore;
    }

    get disableMarkWon() {
        return this.isLoading || this.selectedRowIds.length === 0;
    }

    get hideCheckboxColumn() {
        return this.rows.length === 0 || this.isLoading;
    }
}