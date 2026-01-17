@IsTest(testFor='ApexClass:OpportunityDiscountService,ApexTrigger:OpportunityTrigger')
private class DiscountFlowIntegrationTest {
    @IsTest
    static void integrationPath() {
        Opportunity opp = new Opportunity(
            Name='Integration Opp Test1',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(10),
            Amount=1000,
            Discount__c=10,
            Manager_Approved__c=false
        );
        insert opp;

        opp.Discount__c = 45;
        Database.SaveResult sr = Database.update(opp, false);
        System.assert(!sr.isSuccess(), 'Update should fail when discount jumps > 40 without approval.');
    }
}