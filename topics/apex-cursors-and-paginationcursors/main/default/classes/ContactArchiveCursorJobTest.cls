@IsTest
private class ContactArchiveCursorJobTest {

    @TestSetup
    static void setupData() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 25; i++) {
            contacts.add(new Contact(LastName = 'CursorTest ' + i));
        }
        insert contacts;

        /* Make them “old” by updating LastModifiedDate in test context isn’t possible directly,
          so for demo purposes we’ll relax the filter in the test by launching with daysOld = 0.
         (In real org validation, use a test-specific query filter or a configurable WHERE clause.) */
    }

    @IsTest
    static void archivesContactsInChunks() {
        Test.startTest();
        Id jobId = ContactArchiveJobLauncher.start(0, 10);
        Test.stopTest();

        // Assert: at least some records were marked as archived
        List<Contact> updated = [
            SELECT Id, Description
            FROM Contact
            LIMIT 200
        ];

        Integer archivedCount = 0;
        for (Contact c : updated) {
            if (c.Description != null && c.Description.contains('[ARCHIVED]')) {
                archivedCount++;
            }
        }
        System.assert(archivedCount > 0, 'Expected some contacts to be archived.');

    }
}
