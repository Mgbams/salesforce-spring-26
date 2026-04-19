public with sharing class AccountSyncJob implements Queueable {

    private SyncPayload payload;

    public AccountSyncJob(SyncPayload payload) {
        this.payload = payload;
    }

    public void execute(QueueableContext context) {
        for (Account acc : payload.accounts) {
            acc.Description = 'Processed via: ' + payload.source;
        }
        update payload.accounts;
    }
}
