@IsTest
private class AccountAccessibleTest {
    @IsTest
    static void smoke() {
        System.assertEquals(true, Schema.sObjectType.Account.isAccessible());
    }
}