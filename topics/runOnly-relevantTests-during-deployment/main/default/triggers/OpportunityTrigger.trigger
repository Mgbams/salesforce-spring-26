trigger OpportunityTrigger on Opportunity (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        OpportunityDiscountService.enforceApproval(Trigger.new, Trigger.oldMap);
         OpportunityDiscountService.test3(Trigger.new, Trigger.oldMap);
    }
}