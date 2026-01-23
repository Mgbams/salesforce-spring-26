public with sharing class CaseInboxCursorController {

    public class PaginationResult {
        @AuraEnabled public String cursorJson { get; set; }     // PaginationCursor serialized
        @AuraEnabled public List<Case> records { get; set; }
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer totalPages { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer totalRecords { get; set; }
    }

    @AuraEnabled(cacheable=false)
    public static PaginationResult getPage(String cursorJson, Integer page, Integer size) {
        if (page == null || page < 1) {
            page = 1;
        }
        if (size == null || size < 1) {
            size = 5; // 20 also looks good here (Small values used for testing)
        }
        if (size > 8) { // 200 looks good here (Small values used for testing)
            size = 8; // 200 looks good here (Small values used for testing)
        }

        Database.PaginationCursor cursor;
        Map<String, Object> binds = new Map<String, Object>{'ownerId' => UserInfo.getUserId()};

        // Create cursor on first call
        if (String.isBlank(cursorJson)) {
            String soql =
                'SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate ' +
                'FROM Case ' +
                'WHERE OwnerId = :ownerId ' +
                'AND IsClosed = false ' +
                'ORDER BY CreatedDate DESC';

            cursor = Database.getPaginationCursorWithBinds(soql, binds, AccessLevel.USER_MODE);
        } else {
            cursor = (Database.PaginationCursor) JSON.deserialize(cursorJson, Database.PaginationCursor.class);
        }

        Integer start = (page - 1) * size;

        Database.CursorFetchResult fr = cursor.fetchPage(start, size);

        List<Case> cases = new List<Case>();
        for (SObject sob : fr.getRecords()) {
            cases.add((Case)sob); // Cast to Case
        }

        // Optional defense-in-depth
        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.READABLE, cases);

        Integer total = cursor.getNumRecords();
        Integer pages = (Integer) Math.ceil((Decimal) total / size);

        PaginationResult result = new PaginationResult();
        result.records = (List<Case>) dec.getRecords();
        result.currentPage = page;
        result.pageSize = size;
        result.totalRecords = total;
        result.totalPages = pages;

        // Send back cursor for next page request
        result.cursorJson = JSON.serialize(cursor);

        return result;
    }
}
