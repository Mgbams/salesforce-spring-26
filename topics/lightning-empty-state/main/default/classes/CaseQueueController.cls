public with sharing class CaseQueueController {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [
            SELECT Id, CaseNumber, Subject, Priority, Status, Region__c
            FROM Case
            WHERE Status != 'Closed'
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];
    }
}