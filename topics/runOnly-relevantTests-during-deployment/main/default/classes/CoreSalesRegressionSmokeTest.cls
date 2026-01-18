/*
 * Always-run test:
 * Annotated with @IsTest(critical=true) so it executes on every deployment,
 * regardless of which Apex components are included in the deployment payload.
*/
@IsTest(critical=true)
private class CoreSalesRegressionSmokeTest {
    @IsTest
    static void smoke() {
        System.assertEquals(true, Schema.sObjectType.Opportunity.isAccessible());
    }
}