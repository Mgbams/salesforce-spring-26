@IsTest
private class AccountJobWithFinalizerTest {

    @IsTest
    static void testFinalizerExecution() {
        Account acc = new Account(Name = 'Test Finalizer');
        insert acc;

        SyncPayload payload = new SyncPayload(
            new List<Account>{ acc },
            'Test',
            false
        );

        Test.startTest();
        System.enqueueJob(new AccountJobWithFinalizer(payload));
        Test.stopTest();

        Account result = [SELECT Description FROM Account WHERE Id = :acc.Id];

        Assert.areEqual(
            'Processed via: Test',
            result.Description,
            'Expected job execution to update description.'
        );
    }

    @IsTest
    static void testRetryTriggeredOnFailure() {
        Account valid = new Account(Name = 'Test');
        insert valid;

        SyncPayload payload = new SyncPayload(
            new List<Account>{ valid },
            'Test',
            false
        );

        valid.Name = null;

        Test.startTest();
        System.enqueueJob(new AccountJobWithFinalizer(payload));
        Test.stopTest();

        Integer jobCount = [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE JobType = 'Queueable'
        ];

        Assert.isTrue(
            jobCount > 1,
            'Expected retry job to be enqueued after failure.'
        );
    }
}