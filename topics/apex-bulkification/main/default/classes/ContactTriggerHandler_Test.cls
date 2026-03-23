/**
 * ContactTriggerHandler_Test
 *
 * Validates the CQAW bulkification pattern at scale.
 * Tests cover: single insert, bulk insert (200), and Account reparenting.
 *
 * Key rule: always assert field values — not just that DML succeeded.
 * NOTE: Use Test data factoriesto create test data.
 */
@isTest
private class ContactTriggerHandler_Test {

    private static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    private static List<Contact> buildContacts(Integer count, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(
                LastName = 'Test ' + i,
                AccountId = accountId
            ));
        }
        return contacts;
    }

    @isTest
    static void testSingleInsert() {
        Account acc = createAccount('Single Test Account');

        Test.startTest();
        insert new Contact(LastName = 'Solo', AccountId = acc.Id);
        Test.stopTest();

        Account result = [SELECT Total_Contacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, result.Total_Contacts__c, 'Should count 1 contact');
    }

    @isTest
    static void testBulkInsert() {
        Account acc = createAccount('Bulk Test Account');
        List<Contact> contacts = buildContacts(200, acc.Id);

        Test.startTest();
        insert contacts;
        Test.stopTest();

        Account result = [SELECT Total_Contacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(200, result.Total_Contacts__c, 'Should count all 200 contacts');
    }

    @isTest
    static void testBulkInsertMultipleAccounts() {
        Account acc1 = createAccount('Account One');
        Account acc2 = createAccount('Account Two');

        List<Contact> contacts = new List<Contact>();
        contacts.addAll(buildContacts(100, acc1.Id));
        contacts.addAll(buildContacts(100, acc2.Id));

        Test.startTest();
        insert contacts;
        Test.stopTest();

        Map<Id, Account> results = new Map<Id, Account>(
            [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :new Set<Id>{acc1.Id, acc2.Id}]
        );

        System.assertEquals(100, results.get(acc1.Id).Total_Contacts__c, 'Account 1 should have 100');
        System.assertEquals(100, results.get(acc2.Id).Total_Contacts__c, 'Account 2 should have 100');
    }

    @isTest
    static void testAccountReparenting() {
        Account acc1 = createAccount('Original Account');
        Account acc2 = createAccount('New Account');

        Contact con = new Contact(LastName = 'Mover', AccountId = acc1.Id);
        insert con;

        Test.startTest();
        con.AccountId = acc2.Id;
        update con;
        Test.stopTest();

        Map<Id, Account> results = new Map<Id, Account>(
            [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :new Set<Id>{acc1.Id, acc2.Id}]
        );

        System.assertEquals(0, results.get(acc1.Id).Total_Contacts__c, 'Original Account should be 0');
        System.assertEquals(1, results.get(acc2.Id).Total_Contacts__c, 'New Account should be 1');
    }


    @isTest
    static void testContactWithNoAccount() {
        Test.startTest();
        insert new Contact(LastName = 'Orphan');
        Test.stopTest();

        // No exception = null guard is working correctly
        System.assert(true, 'Should handle null AccountId without throwing');
    }
}
