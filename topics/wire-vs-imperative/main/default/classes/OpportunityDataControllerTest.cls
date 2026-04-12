@IsTest
private class OpportunityDataControllerTest {

    @TestSetup
    static void setupData() {
        Account acct1 = new Account(Name = 'Acme Corp');
        Account acct2 = new Account(Name = 'Global Media');
        insert new List<Account>{ acct1, acct2 };

        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 1; i <= 15; i++) {
            Id accountId = (Math.mod(i, 2) == 0) ? acct1.Id : acct2.Id;

            opps.add(new Opportunity(
                Name = 'Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(i),
                Amount = 1000 * i,
                AccountId = accountId
            ));
        }

        insert opps;
    }

    @IsTest
    static void getOpenOpportunities_returnsPagedResults() {
        Test.startTest();
        OpportunityDataController.OpportunitiesResponse response =
            OpportunityDataController.getOpenOpportunities(5000, 5, 1);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should be returned.');
        System.assertEquals(5, response.records.size(), 'Should return the requested page size.');
        System.assertEquals(1, response.pageNumber, 'Page number should be preserved.');
        System.assertEquals(5, response.pageSize, 'Page size should be preserved.');
        System.assertEquals(true, response.hasMore, 'There should be more records after page 1.');
        System.assertEquals(5, response.returnedCount, 'Returned count should match records size.');

        for (OpportunityDataController.OpportunityRow row : response.records) {
            System.assert(row.amount >= 5000, 'Only records meeting the amount filter should be returned.');
            System.assertNotEquals(null, row.name, 'Each row should include a name.');
        }
    }

    @IsTest
    static void getOpenOpportunities_normalizesInvalidPagingInputs() {
        Test.startTest();
        OpportunityDataController.OpportunitiesResponse response =
            OpportunityDataController.getOpenOpportunities(0, -1, 0);
        Test.stopTest();

        System.assertEquals(1, response.pageNumber, 'Invalid page number should default to 1.');
        System.assertEquals(10, response.pageSize, 'Invalid page size should default to 10.');
        System.assert(response.records.size() <= 10, 'Response should respect the normalized page size.');
    }

    @IsTest
    static void getOpenOpportunities_returnsEmptyWhenNoMatch() {
        Test.startTest();
        OpportunityDataController.OpportunitiesResponse response =
            OpportunityDataController.getOpenOpportunities(999999, 10, 1);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assertEquals(0, response.records.size(), 'No records should match the high amount filter.');
        System.assertEquals(false, response.hasMore, 'hasMore should be false when no records returned.');
        System.assertEquals(0, response.returnedCount, 'Returned count should be 0.');
    }

    @IsTest
    static void getOpenOpportunities_lastPageHasNoMore() {
        Test.startTest();
        OpportunityDataController.OpportunitiesResponse response =
            OpportunityDataController.getOpenOpportunities(0, 10, 2);
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assertEquals(false, response.hasMore, 'Last page should have hasMore as false.');
        System.assertEquals(2, response.pageNumber, 'Page number should be 2.');
    }

    @IsTest
    static void markWon_updatesSelectedRecords() {
        List<Opportunity> opps = [
            SELECT Id, StageName, CloseDate
            FROM Opportunity
            WHERE StageName = 'Prospecting'
            ORDER BY Name ASC
            LIMIT 3
        ];

        List<Id> idsToUpdate = new List<Id>();
        for (Opportunity opp : opps) {
            idsToUpdate.add(opp.Id);
        }

        Test.startTest();
        Integer updatedCount = OpportunityDataController.markWon(idsToUpdate);
        Test.stopTest();

        System.assertEquals(3, updatedCount, 'All selected records should be updated.');

        List<Opportunity> updatedOpps = [
            SELECT Id, StageName, CloseDate
            FROM Opportunity
            WHERE Id IN :idsToUpdate
        ];

        for (Opportunity opp : updatedOpps) {
            System.assertEquals('Closed Won', opp.StageName, 'StageName should be updated to Closed Won.');
            System.assertEquals(Date.today(), opp.CloseDate, 'CloseDate should be set to today.');
        }
    }

    @IsTest
    static void markWon_throwsWhenEmptyListPassed() {
        try {
            Test.startTest();
            OpportunityDataController.markWon(new List<Id>());
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException for empty input.');
        } catch (AuraHandledException ex) {
            System.assertEquals(
                'Select at least one opportunity',
                ex.getMessage(),
                'Should return exact validation message.'
            );
        }
    }

    @IsTest
    static void markWon_throwsWhenNullPassed() {
        try {
            Test.startTest();
            OpportunityDataController.markWon(null);
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException for null input.');
        } catch (AuraHandledException ex) {
            System.assertEquals(
                'Select at least one opportunity',
                ex.getMessage(),
                'Should return exact validation message for null input.'
            );
        }
    }

    @IsTest
    static void markWon_throwsWhenIdsDoNotMatchRecords() {
        Id fakeOppId = Id.valueOf('006000000000000AAA');

        try {
            Test.startTest();
            OpportunityDataController.markWon(new List<Id>{ fakeOppId });
            Test.stopTest();
            System.assert(false, 'Expected an AuraHandledException for missing records.');
        } catch (AuraHandledException ex) {
            System.assert(
                ex.getMessage().contains('No matching opportunities were found'),
                'Should return a meaningful message for missing records.'
            );
        }
    }
}