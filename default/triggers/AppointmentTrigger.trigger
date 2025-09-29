trigger AppointmentTrigger on Appointment__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AppointmentTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AppointmentTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}
