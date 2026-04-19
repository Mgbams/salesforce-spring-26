@IsTest
private class AccountQueueableTest {

    @IsTest
    static void testQueueable() {
        Account acc = new Account(Name = 'Test Corp');
        insert acc;

        Test.startTest();
        System.enqueueJob(new AccountQueueable(new List<Account>{ acc }));
        Test.stopTest();

        Account result = [SELECT Name FROM Account WHERE Id = :acc.Id];

        Assert.isTrue(
            result.Name.contains('Updated'),
            'Expected account name to be updated.'
        );
    }
}
