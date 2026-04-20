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

        Account result = [
            SELECT Description 
            FROM Account 
            WHERE Id = :acc.Id
        ];

        Assert.areEqual(
            'Processed via: Test',
            result.Description,
            'Expected job execution to update description.'
        );
    }

    @IsTest
    static void testRetryTriggeredOnFailure() {

        Account acc = new Account(Name = 'Test Retry');
        insert acc;

        SyncPayload payload = new SyncPayload(
            new List<Account>{ acc },
            'Test',
            false
        );

        // Reset test-visible controls
        AccountJobWithFinalizer.simulateFailure = true;
        AccountJobWithFinalizer.retryInvocationCount = 0;

        Test.startTest();
        System.enqueueJob(new AccountJobWithFinalizer(payload));

        try {
            Test.stopTest();
        } catch (CalloutException e) {
            // Expected exception from async execution
            Assert.isTrue(
                e.getMessage().contains('Simulated failure for testing'),
                'Expected simulated failure exception.'
            );
        }

        // Assert retry logic triggered
        Assert.isTrue(
            AccountJobWithFinalizer.retryInvocationCount > 0,
            'Expected retry logic to enqueue a new job.'
        );

        // Cleanup static state
        AccountJobWithFinalizer.simulateFailure = false;
    }
}