public with sharing class AccountJobWithFinalizer implements Queueable, Finalizer {

    private SyncPayload payload;
    private static final Integer MAX_RETRIES = 3;

    @TestVisible
    private static Boolean simulateFailure = false;

    @TestVisible
    private static Integer retryInvocationCount = 0;

    public AccountJobWithFinalizer(SyncPayload payload) {
        this.payload = payload;
    }

    public void execute(QueueableContext context) {
        // Attach finalizer FIRST
        System.attachFinalizer(this);

        // Simulated failure for testing
        if (simulateFailure) {
            throw new CalloutException('Simulated failure for testing');
        }

        for (Account acc : payload.accounts) {
            acc.Description = 'Processed via: ' + payload.source;
        }
        update payload.accounts;
    }

    public void execute(FinalizerContext context) {

        if (context.getResult() == ParentJobResult.SUCCESS) {
            System.debug('Job completed successfully.');
        } else {
            System.debug('Job failed: ' + context.getException().getMessage());

            if (payload.retryCount < MAX_RETRIES) {
                payload.retryCount++;
                retryInvocationCount++;

                System.enqueueJob(new AccountJobWithFinalizer(payload));
            } else {
                System.debug('Max retries reached. Escalating.');
            }
        }
    }
}