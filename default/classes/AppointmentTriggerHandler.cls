public with sharing class AppointmentTriggerHandler {
    public static void afterInsert(List<Appointment__c> newList) {
        List<Id> apptIds = new List<Id>();
        for (Appointment__c a : newList) {
            if (a.Status__c == 'Scheduled') apptIds.add(a.Id);
        }
        if (!apptIds.isEmpty()) {
            System.enqueueJob(new SendAppointmentRemindersQueueable(apptIds));
        }
    }

    public static void afterUpdate(Map<Id,Appointment__c> newMap, Map<Id,Appointment__c> oldMap) {
        List<Appointment__c> toCreateFollowups = new List<Appointment__c>();
        for (Id idKey : newMap.keySet()) {
            Appointment__c oldA = oldMap.get(idKey);
            Appointment__c newA = newMap.get(idKey);
            if (oldA.Status__c != 'Completed' && newA.Status__c == 'Completed') {
                    Appointment__c follow = new Appointment__c(
                        Patient__c = newA.Patient__c,
                        Doctor__c = newA.Doctor__c,
                        Appointment_Date_Time__c = newA.Appointment_Date_Time__c.addDays(7),
                        Status__c = 'Scheduled'
                    );
                toCreateFollowups.add(follow);
            }

        }
        if (!toCreateFollowups.isEmpty()) {
            insert toCreateFollowups;
        }
    }
}
