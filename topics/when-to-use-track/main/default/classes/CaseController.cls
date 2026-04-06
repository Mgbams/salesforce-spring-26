public with sharing class CaseController {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(String statusFilter) {
        if (String.isBlank(statusFilter)) {
            return new List<Case>();
        }
        return [
            SELECT Id, CaseNumber, Status, Subject
            FROM Case
            WHERE Status = :statusFilter
            ORDER BY CaseNumber ASC
            LIMIT 200
        ];
    }
}