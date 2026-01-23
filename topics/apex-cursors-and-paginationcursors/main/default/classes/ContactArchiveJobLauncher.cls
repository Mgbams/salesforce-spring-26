public with sharing class ContactArchiveJobLauncher {

    /**
     * @description Starts a chained Queueable job that processes a large Contact dataset using an Apex Cursor.
     *
     * @param daysOld Only contacts not modified in the last N days are processed.
     * @param chunkSize Records per Queueable transaction (ex: 200).
     */
    public static Id start(Integer daysOld, Integer chunkSize) {
        if (daysOld == null || daysOld <= 0) {
            daysOld = 400;
        }
        if (chunkSize == null || chunkSize <= 0) {
            chunkSize = 200;
        }
        if (chunkSize > 2000) {
            chunkSize = 2000; // guardrail
        }

        String soql =
            'SELECT Id, Description, LastModifiedDate ' +
            'FROM Contact ' +
            'WHERE LastModifiedDate < LAST_N_DAYS :daysOld ' +
            'ORDER BY LastModifiedDate ASC';

        // Use binds so the query stays safe and readable
        Map<String, Object> binds = new Map<String, Object>{ 'daysOld' => daysOld };

        Database.Cursor cursor = Database.getCursorWithBinds(soql, binds, AccessLevel.USER_MODE);

        // Start at position 0
        return System.enqueueJob(new ContactArchiveCursorJob(cursor, 0, chunkSize));
    }
}
