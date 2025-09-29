@isTest
private class SendAppointmentRemindersQueueableTest {
    // Mock for HTTP Callouts (Twilio)
    private class MockTwilioResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"sid":"SM123"}');
            res.setStatusCode(201);
            return res;
        }
    }

    @isTest static void testQueueableWithCalloutAndEmail() {
        // Prepare test data: Patient and Appointment
        Patient__c p = new Patient__c(Name = 'Test Patient', Email_Address__c = 'test@example.com', Phone_Number__c = '+15551234567');
        insert p;

        Appointment__c a = new Appointment__c(
            Patient__c = p.Id,
            Appointment_Date_Time__c = System.now().addDays(1),
            Status__c = 'Scheduled',
            Doctor__c = UserInfo.getUserId()
        );
        insert a;

        // Register mock for callouts
        Test.setMock(HttpCalloutMock.class, new MockTwilioResponse());

        Test.startTest();
            // enqueue the queueable
            System.enqueueJob(new SendAppointmentRemindersQueueable(new List<Id>{ a.Id }));
        Test.stopTest();

        // Assert no errors logged
        Integer errors = [SELECT count() FROM Automation_Error__c];
        System.assertEquals(0, errors, 'Expected no automation errors');
    }
}
