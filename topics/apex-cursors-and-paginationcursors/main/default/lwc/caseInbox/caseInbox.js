import { LightningElement, track } from 'lwc';
import getPage from '@salesforce/apex/CaseInboxCursorController.getPage';

export default class CaseInbox extends LightningElement {
    @track records = [];
    @track error;

    cursorJson;
    currentPage = 1;
    totalPages = 1;
    totalRecords = 0;
    pageSize = 20;

    columns = [
        { label: 'Case #', fieldName: 'CaseNumber', type: 'text' },
        { label: 'Subject', fieldName: 'Subject', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Priority', fieldName: 'Priority', type: 'text' },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        }
    ];

    get isFirst() {
        return this.currentPage <= 1;
    }

    get isLast() {
        return this.currentPage >= this.totalPages;
    }

    connectedCallback() {
        this.loadPage(1);
    }

    async loadPage(page) {
        this.error = null;

        try {
            const res = await getPage({
                cursorJson: this.cursorJson,
                page,
                size: this.pageSize
            });

            this.cursorJson = res.cursorJson;
            this.records = res.records || [];
            this.currentPage = res.currentPage;
            this.totalPages = res.totalPages;
            this.totalRecords = res.totalRecords;
            this.pageSize = res.pageSize;
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error(e);
            this.error = e?.body?.message || 'Unexpected error while loading cases.';
            this.records = [];
        }
    }

    next() {
        if (!this.isLast) {
            this.loadPage(this.currentPage + 1);
        }
    }

    prev() {
        if (!this.isFirst) {
            this.loadPage(this.currentPage - 1);
        }
    }
}
