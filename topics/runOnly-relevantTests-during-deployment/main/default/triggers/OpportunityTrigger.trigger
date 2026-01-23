trigger OpportunityTrigger on Opportunity (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        OpportunityDiscountService.enforceApproval(Trigger.new, Trigger.oldMap);
        //OpportunityDiscountService.updateCustomerType(Trigger.new, Trigger.oldMap);
    }
}