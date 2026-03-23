/**
 * ContactTriggerHandler
 *
 * Handles all business logic for the Contact trigger.
 * Implements the CQAW pattern (Collect → Query → Aggregate → Write)
 * to stay within Salesforce governor limits at any batch size.
 *
 * Reusable from Batch Apex, Queueables, and service classes.
 */
public with sharing class ContactTriggerHandler {

    // ─────────────────────────────────────────────
    // Public Entry Points (called from trigger)
    // ─────────────────────────────────────────────

    /**
     * Handles after insert context.
     * Increments Total_Contacts__c on all related Accounts.
     */
    public static void afterInsert(List<Contact> newContacts) {
        updateAccountContactCount(newContacts, null);
    }

    /**
     * Handles after update context.
     * Only processes Contacts where AccountId has changed.
     */
    public static void afterUpdate(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        List<Contact> changed = new List<Contact>();

        for (Contact con : newContacts) {
            Contact oldCon = oldMap.get(con.Id);
            if (con.AccountId != oldCon.AccountId) {
                changed.add(con);
            }
        }

        if (!changed.isEmpty()) {
            updateAccountContactCount(changed, oldMap);
        }
    }

    // ─────────────────────────────────────────────
    // Private CQAW Implementation
    // ─────────────────────────────────────────────

    /**
     * Core CQAW method — updates Total_Contacts__c on related Accounts.
     *
     * Step 1 — Collect:  gather unique Account IDs from the batch
     * Step 2 — Query:    fetch related Accounts in a single SOQL call
     * Step 3 — Aggregate: count new Contacts per Account in memory
     * Step 4 — Write:    update all Accounts in a single DML call
     */
    private static void updateAccountContactCount(
        List<Contact> contacts,
        Map<Id, Contact> oldMap
    ) {

        // ── Step 1: Collect ──────────────────────────────────────────────
        // Gather unique Account IDs — Set<Id> deduplicates automatically.
        // Always guard against null AccountId before adding to the Set.

        Set<Id> accountIds = new Set<Id>();

        for (Contact con : contacts) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
            // On update: also collect the old Account so we can decrement it
            if (oldMap != null) {
                Contact oldCon = oldMap.get(con.Id);
                if (oldCon.AccountId != null) {
                    accountIds.add(oldCon.AccountId);
                }
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // ── Step 2: Query ────────────────────────────────────────────────
        // Single SOQL query. Map<Id, SObject> gives O(1) lookup by ID.

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :accountIds]
        );

        // ── Step 3: Aggregate ────────────────────────────────────────────
        // Count new Contacts per Account entirely in memory.
        // On update, also count decrements for the old Account.

        Map<Id, Integer> deltas = new Map<Id, Integer>();

        for (Contact con : contacts) {
            // Increment new Account
            if (con.AccountId != null) {
                Integer current = deltas.containsKey(con.AccountId)
                    ? deltas.get(con.AccountId) : 0;
                deltas.put(con.AccountId, current + 1);
            }
            // Decrement old Account on reparent
            if (oldMap != null) {
                Contact oldCon = oldMap.get(con.Id);
                if (oldCon.AccountId != null && oldCon.AccountId != con.AccountId) {
                    Integer current = deltas.containsKey(oldCon.AccountId)
                        ? deltas.get(oldCon.AccountId) : 0;
                    deltas.put(oldCon.AccountId, current - 1);
                }
            }
        }

        // ── Step 4: Write ────────────────────────────────────────────────
        // One DML call for all updates regardless of batch size.

        List<Account> toUpdate = new List<Account>();

        for (Id accId : deltas.keySet()) {
            Account acc = accountMap.get(accId);
            if (acc != null) {
                Decimal existing = acc.Total_Contacts__c == null
                    ? 0 : acc.Total_Contacts__c;
                acc.Total_Contacts__c = existing + deltas.get(accId);
                toUpdate.add(acc);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}
