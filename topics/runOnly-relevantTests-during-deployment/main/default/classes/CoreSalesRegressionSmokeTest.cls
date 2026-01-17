@IsTest(critical=true)
private class CoreSalesRegressionSmokeTest {
    @IsTest
    static void smoke() {
        System.assertEquals(true, Schema.sObjectType.Opportunity.isAccessible());
    }
}