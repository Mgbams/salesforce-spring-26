@IsTest
private class CaseInboxCursorControllerTest {

    @TestSetup
    static void setupData() {
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < 45; i++) {
            casesToInsert.add(new Case(
                Subject = 'CURSOR_UI_TEST_' + i,
                Status = 'New',
                Origin = 'Phone',
                Priority = 'Medium'
            ));
        }
        insert casesToInsert;

        Id me = UserInfo.getUserId();
        List<Case> created = [
            SELECT Id, OwnerId
            FROM Case
            WHERE Subject LIKE 'CURSOR_UI_TEST_%'
        ];
        for (Case c : created) c.OwnerId = me;
        update created;

        System.assertEquals(45, created.size());
    }

    @IsTest
    static void page1_returns20_andCursorJson() {
        Test.startTest();
        CaseInboxCursorController.PaginationResult page1 =
            CaseInboxCursorController.getPage(null, 1, 20);
        Test.stopTest();

        System.assertNotEquals(null, page1.cursorJson);
        System.assertEquals(20, page1.records.size());
        System.assertEquals(1, page1.currentPage);
        System.assertEquals(45, page1.totalRecords);
        System.assertEquals(3, page1.totalPages);
    }

    @IsTest
    static void page3_returnsRemaining5_usingCursorJson() {
        CaseInboxCursorController.PaginationResult page1 =
            CaseInboxCursorController.getPage(null, 1, 20);

        Test.startTest();
        CaseInboxCursorController.PaginationResult page3 =
            CaseInboxCursorController.getPage(page1.cursorJson, 3, 20);
        Test.stopTest();

        System.assertEquals(5, page3.records.size());
        System.assertEquals(3, page3.currentPage);
        System.assertEquals(3, page3.totalPages);
        System.assertNotEquals(null, page3.cursorJson);
    }
}
