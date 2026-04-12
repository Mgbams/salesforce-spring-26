public with sharing class OpportunityDataController {
    public class OpportunityRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String stageName;
        @AuraEnabled public Date closeDate;
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;

        public OpportunityRow(Opportunity opp) {
            this.id = opp.Id;
            this.name = opp.Name;
            this.amount = opp.Amount;
            this.stageName = opp.StageName;
            this.closeDate = opp.CloseDate;
            this.accountId = opp.AccountId;
            this.accountName = opp.Account != null ? opp.Account.Name : null;
        }
    }

    public class OpportunitiesResponse {
        @AuraEnabled public List<OpportunityRow> records;
        @AuraEnabled public Integer pageNumber;
        @AuraEnabled public Integer pageSize;
        @AuraEnabled public Boolean hasMore;
        @AuraEnabled public Integer returnedCount;

        public OpportunitiesResponse() {
            records = new List<OpportunityRow>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static OpportunitiesResponse getOpenOpportunities(Decimal minAmount, Integer pageSize, Integer pageNumber) {
        Integer safePageSize = normalizePageSize(pageSize);
        Integer safePageNumber = normalizePageNumber(pageNumber);
        Integer offsetRows = (safePageNumber - 1) * safePageSize;

        OpportunitiesResponse response = new OpportunitiesResponse();
        response.pageNumber = safePageNumber;
        response.pageSize = safePageSize;

        List<Opportunity> opps = [
            SELECT Id, Name, Amount, StageName, CloseDate, AccountId, Account.Name
            FROM Opportunity
            WHERE IsClosed = false
              AND Amount >= :minAmount
            ORDER BY Amount DESC, CloseDate ASC, Name ASC
            LIMIT :safePageSize + 1
            OFFSET :offsetRows
        ];

        response.hasMore = opps.size() > safePageSize;

        if (response.hasMore) {
            opps.remove(opps.size() - 1);
        }

        for (Opportunity opp : opps) {
            response.records.add(new OpportunityRow(opp));
        }

        response.returnedCount = response.records.size();
        return response;
    }

    @AuraEnabled
    public static Integer markWon(List<Id> opportunityIds) {

        if (opportunityIds == null || opportunityIds.isEmpty()) {
            throw new AuraHandledException('Select at least one opportunity');
        }

        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, CloseDate
            FROM Opportunity
            WHERE Id IN :opportunityIds
            FOR UPDATE
        ];

        if (oppsToUpdate.isEmpty()) {
            throw new AuraHandledException('No matching opportunities were found');
        }

        for (Opportunity opp : oppsToUpdate) {
            opp.StageName = 'Closed Won';
            opp.CloseDate = Date.today();
        }

        update oppsToUpdate;

        return oppsToUpdate.size();
    }

    private static Integer normalizePageSize(Integer pageSize) {
        if (pageSize == null || pageSize <= 0) {
            return 10;
        }
        return Math.min(pageSize, 50);
    }

    private static Integer normalizePageNumber(Integer pageNumber) {
        if (pageNumber == null || pageNumber <= 0) {
            return 1;
        }
        return pageNumber;
    }
}