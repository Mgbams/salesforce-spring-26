public with sharing class AccountJobWithFinalizer implements Queueable, Finalizer {

    private SyncPayload payload;
    private static final Integer MAX_RETRIES = 3;

    public AccountJobWithFinalizer(SyncPayload payload) {
        this.payload = payload;
    }

    public void execute(QueueableContext context) {

        System.attachFinalizer(this);

        for (Account acc : payload.accounts) {
            acc.Description = 'Processed via: ' + payload.source;
        }
        update payload.accounts;
    }

    public void execute(FinalizerContext context) {

        if (context.getResult() == ParentJobResult.SUCCESS) {
            System.debug('Job completed successfully.');
        } else {
            System.debug(
                'Job failed: ' + context.getException().getMessage()
            );

            if (payload.retryCount < MAX_RETRIES) {
                payload.retryCount++;
                System.enqueueJob(new AccountJobWithFinalizer(payload));
            } else {
                System.debug('Max retries reached. Escalating.');
            }
        }
    }
}

