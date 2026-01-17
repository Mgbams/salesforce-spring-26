public class OpportunityDiscountService {
    public static void enforceApproval(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
            // Only enforce when Discount__c changes (or on insert)
            Decimal newDiscount = opp.Discount__c;
            Decimal oldDiscount = (oldMap != null && oldMap.containsKey(opp.Id)) ? oldMap.get(opp.Id).Discount__c : null;

            Boolean discountChanged = (oldMap == null) || (newDiscount != oldDiscount);
            /*if (oldMap == null) {
                opp.Type = 'New Customer';
            }*/
            
            if (!discountChanged) {
                continue;
            }

            if (newDiscount != null && newDiscount > 40 && opp.Manager_Approved__c != true) {
                opp.addError('Discounts over 40% require manager approval.');
            }
        }
    }

    public static void test3(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
           
            if (oldMap == null) {
                opp.Type = 'New Customer';
            }
        }
    }
}
