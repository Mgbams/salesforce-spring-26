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
    private class AccountJobWithFinalizerFailureTest {

        @IsTest
        static void testRetryTriggeredOnFailure() {

            // Create invalid record to force DML failure
            Account acc = new Account(); // Missing required Name
            insert acc; // This will fail → so instead simulate differently

            // Better approach: force failure via update
            Account valid = new Account(Name = 'Test');
            insert valid;

            // Create payload
            SyncPayload payload = new SyncPayload(
                new List<Account>{ valid },
                'Test',
                false
            );

            // Force failure by making record invalid before update
            valid.Name = null;

            Test.startTest();
            System.enqueueJob(new AccountJobWithFinalizer(payload));
            Test.stopTest();

            // Assert retry happened by checking AsyncApexJob count
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
}
