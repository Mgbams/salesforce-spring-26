public with sharing class ContactArchiveCursorJob implements Queueable {

    private Database.Cursor cursor;
    private Integer position;
    private Integer chunkSize;

    public ContactArchiveCursorJob(Database.Cursor cursor, Integer position, Integer chunkSize) {
        this.cursor = cursor;
        this.position = (position == null || position < 0) ? 0 : position;
        this.chunkSize = (chunkSize == null || chunkSize <= 0) ? 200 : chunkSize;
    }

    public void execute(QueueableContext ctx) {
        try {
            // STEP 1: Fetch the next chunk
            List<SObject> scopeSObjects = cursor.fetch(position, chunkSize);
            if (scopeSObjects.isEmpty()) {
                return; // Stop unnecessary jobs
            }

            List<Contact> scope = new List<Contact>();
            for (SObject sOb : scopeSObjects) {
                scope.add((Contact) sOb); // Cast to Contact
            }

            // STEP 2: Apply "archive" logic
            for (Contact con : scope) {
                String existing = (con.Description == null) ? '' : con.Description;
                if (!existing.contains('[ARCHIVED]')) {
                    con.Description = (existing + ' [ARCHIVED]').trim(); // Add [ARCHIVED] to description
                }
            }

            // STEP 3: Update chunk
            update scope;

            // STEP 4: Move forward
            position += scope.size();

            // STEP 5: Chain next job if records remain
            if (position < cursor.getNumRecords()) {
                System.enqueueJob(new ContactArchiveCursorJob(cursor, position, chunkSize));
            }

        } catch (System.TransientCursorException ex) {
            // Transient cursor issues are retryable.
            // In production: add retry counters + logging to avoid infinite loops.
            System.enqueueJob(new ContactArchiveCursorJob(cursor, position, chunkSize));

        } catch (System.FatalCursorException ex) {
            // Fatal cursor issues should stop the chain and be investigated
            throw ex;
        }
    }
}
