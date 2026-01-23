public class OpportunityDiscountService {

    @TestVisible
    private static Boolean requiresManagerApproval(Decimal discount, Boolean managerApproved) {
        return (discount != null && discount > 40 && managerApproved != true);
    }

    public static void enforceApproval(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
            Decimal newDiscount = opp.Discount__c;
            Decimal oldDiscount = (oldMap != null && oldMap.containsKey(opp.Id))
                ? oldMap.get(opp.Id).Discount__c
                : null;

            Boolean discountChanged = (oldMap == null) || (newDiscount != oldDiscount);
            if (!discountChanged) continue;

            if (requiresManagerApproval(newDiscount, opp.Manager_Approved__c)) {
                opp.addError('Discounts over 40% require manager approval.');
            }
        }
    }

    /*public static void updateCustomerType(List<Opportunity> newList, Map<Id, Opportunity> oldMap) { 
        for (Opportunity opp : newList) { 
            if (oldMap == null) { 
                opp.Type = 'New Customer'; 
            } 
        } 
    }*/
}

