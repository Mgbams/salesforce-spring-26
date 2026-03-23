/**
 * ContactTrigger
 *
 * Entry point for all Contact trigger events.
 * This trigger routes ONLY — no business logic lives here.
 * All logic is delegated to ContactTriggerHandler.
 *
 * Pattern: CQAW (Collect → Query → Aggregate → Write)
 */
trigger ContactTrigger on Contact (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
