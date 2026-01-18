/*
 * Dependency-driven test:
 * Automatically selected by RunRelevantTests when changes impact
 * OpportunityDiscountService or OpportunityTrigger.
*/
@IsTest
private class OpportunityDiscountServiceTest {
    @IsTest
    static void blocksHighDiscountWithoutApproval() {
        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(10),
            Amount=1000,
            Discount__c=50,
            Manager_Approved__c=false
        );

        Test.startTest();
        Database.SaveResult sr = Database.insert(opp, false);
        Test.stopTest();

        System.assert(!sr.isSuccess(), 'Insert should fail due to missing approval.');
        System.assert(sr.getErrors()[0].getMessage().contains('require manager approval'));
    }

    @IsTest
    static void allowsHighDiscountWithApproval() {
        Opportunity opp = new Opportunity(
            Name='Approved Opp',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(10),
            Amount=1000,
            Discount__c=50,
            Manager_Approved__c=true
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        System.assertNotEquals(null, opp.Id);
    }
}