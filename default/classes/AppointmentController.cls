public with sharing class AppointmentController {

    @AuraEnabled(cacheable=true)
    public static List<User> getDoctors() {
        // Return a small list of Users who are doctors.
        // Modify filter to match your org (Profile.Name or Role or Permission).
        // Example: users with 'Doctor' in their title or a specific profile name.
        return [
            SELECT Id, Name
            FROM User
            WHERE IsActive = true
            AND (Title LIKE '%Doctor%' OR Profile.Name = 'Doctor')
            ORDER BY Name
            LIMIT 200
        ];
    }

    /**
     * Create Appointment record.
     * @param patientId - Id of Patient__c
     * @param doctorId - Id of User
     * @param appointmentDateTimeLocal - string from LWC datetime-local input, e.g. "2025-09-29T12:00"
     * @param reason - appointment reason text
     * @return Id of created Appointment__c
     */
    @AuraEnabled
    public static Id createAppointment(String patientId, String doctorId, String appointmentDateTimeLocal, String reason) {
        if (String.isBlank(patientId)) {
            throw new AuraHandledException('Patient is required.');
        }
        if (String.isBlank(appointmentDateTimeLocal)) {
            throw new AuraHandledException('Appointment date/time is required.');
        }

        // Convert incoming "YYYY-MM-DDTHH:MM" (HTML input) into DateTime string "YYYY-MM-DD HH:MM:SS"
        String dtString = appointmentDateTimeLocal;
        // If value contains 'T', replace with space and add seconds if missing
        if (dtString.contains('T')) {
            dtString = dtString.replace('T', ' ');
        }
        if (!dtString.contains(':')) {
            throw new AuraHandledException('Invalid date/time format.');
        }
        // Add seconds if not present (ensure "YYYY-MM-DD HH:MM:SS")
        // If currently "YYYY-MM-DD HH:MM" -> append ":00"
        if (dtString.length() == 16) {
            dtString = dtString + ':00';
        }
        Datetime dt;
        try {
            dt = Datetime.valueOf(dtString);
        } catch (Exception ex) {
            // Try parsing assuming local timezone may need adjustment.
            // As fallback create Date/Time by splitting:
            try {
                String[] leftRight = dtString.split('\\s');
                String[] ymd = leftRight[0].split('-');
                String[] hm = leftRight[1].split(':');
                Integer y = Integer.valueOf(ymd[0]);
                Integer m = Integer.valueOf(ymd[1]);
                Integer d = Integer.valueOf(ymd[2]);
                Integer hh = Integer.valueOf(hm[0]);
                Integer mm = Integer.valueOf(hm[1]);
                dt = Datetime.newInstance(y, m, d, hh, mm, 0);
            } catch (Exception e2) {
                throw new AuraHandledException('Failed to parse appointment date/time: ' + e2.getMessage());
            }
        }

        Appointment__c appt = new Appointment__c();
        appt.Patient__c = patientId;
        appt.Doctor__c = doctorId;
        appt.Appointment_Date_Time__c = dt;
        appt.Status__c = 'Scheduled';

        insert appt;
        return appt.Id;
    }
}
