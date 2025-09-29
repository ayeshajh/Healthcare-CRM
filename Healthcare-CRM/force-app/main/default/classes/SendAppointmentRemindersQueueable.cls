public class SendAppointmentRemindersQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> appointmentIds;

    public SendAppointmentRemindersQueueable(List<Id> apptIds) {
        this.appointmentIds = apptIds != null ? new List<Id>(apptIds) : new List<Id>();
    }

    public void execute(QueueableContext ctx) {
        try {
            if (appointmentIds.isEmpty()) return;

            List<Appointment__c> appts = [
                SELECT Id, Appointment_Date_Time__c, Patient__c,
                       Patient__r.Phone_Number__c, Patient__r.Email_Address__c
                FROM Appointment__c
                WHERE Id IN :appointmentIds
            ];

            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

            for (Appointment__c a : appts) {
                String phone = a.Patient__r != null ? a.Patient__r.Phone_Number__c : null;
                String email = a.Patient__r != null ? a.Patient__r.Email_Address__c : null;
                String whenText = String.valueOf(a.Appointment_Date_Time__c);
                String msg = 'Reminder: your appointment is scheduled for ' + whenText + '.';

                if (phone != null && phone.trim() != '') {
                    // Example callout using Named Credential "Wellness_Oasis".
                    // Replace the endpoint path after the named-credential prefix if you use a different provider.
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:Wellness_Oasis/2010-04-01/Accounts/ACACCOUNT/Messages.json');
                    req.setMethod('POST');
                    req.setHeader('Content-Type','application/x-www-form-urlencoded');
                    String body = 'To=' + EncodingUtil.urlEncode(phone, 'UTF-8')
                                + '&From=' + EncodingUtil.urlEncode('+15551234567','UTF-8')
                                + '&Body=' + EncodingUtil.urlEncode(msg, 'UTF-8');
                    req.setBody(body);

                    Http http = new Http();
                    HttpResponse res = http.send(req);

                    if (res.getStatusCode() >= 400) {
                        insertError('Callout failed: ' + res.getStatus() + ' ' + res.getBody(), 'SendAppointmentRemindersQueueable', a.Id);
                    }
                } else if (email != null && email.trim() != '') {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ email });
                    mail.setSubject('Appointment Reminder');
                    mail.setPlainTextBody(msg);
                    emailsToSend.add(mail);
                } else {
                    insertError('No contact method for patient on appointment', 'SendAppointmentRemindersQueueable', a.Id);
                }
            }

            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }

        } catch (Exception e) {
            insertError('Exception in Queueable: ' + e.getMessage(), 'SendAppointmentRemindersQueueable', null);
        }
    }

    private static void insertError(String message, String context, Id relatedId) {
        try {
            Automation_Error__c e = new Automation_Error__c(
                Name = 'AsyncError ' + Datetime.now().getTime(),
                Message__c = message,
                Context__c = context,
                Related_Record_Id__c = relatedId == null ? null : String.valueOf(relatedId)
            );
            insert e;
        } catch (Exception ignored) {
            // Avoid recursive errors
            System.debug('Failed to log automation error: ' + ignored.getMessage());
        }
    }
}
