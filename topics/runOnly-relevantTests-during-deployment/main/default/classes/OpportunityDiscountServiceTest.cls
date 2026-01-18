/*
 * Dependency-driven test:
 * Automatically selected by RunRelevantTests when changes impact
 * OpportunityDiscountService or OpportunityTrigger.
*/
@IsTest
private class OpportunityDiscountServiceTest {

    @IsTest
    static void requiresApproval_whenDiscountOver40_andNotApproved() {
        Boolean needsApproval = OpportunityDiscountService.requiresManagerApproval(50, false);
        System.assertEquals(true, needsApproval);
    }

    @IsTest
    static void noApproval_whenDiscountOver40_andApproved() {
        Boolean needsApproval = OpportunityDiscountService.requiresManagerApproval(50, true);
        System.assertEquals(false, needsApproval);
    }

    @IsTest
    static void blocksHighDiscountWithoutApproval_viaTriggerPath() {
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
}
