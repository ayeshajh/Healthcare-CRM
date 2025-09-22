# Link for Phases Doc
https://docs.google.com/document/d/1tYoArg2U0jjB3NE3d9Em9Am2fgXYiXGxRmdRSl6DEpM/edit?usp=sharing
# Project Title:   Smart Healthcare CRM – Patient Appointment & Care Management System
Industry:  Healthcare  
Project Type: B2C Salesforce CRM implementation  
Target Users: Clinic Administrators, Doctors, and Patients  
## Problem Statement:
A mid-sized healthcare clinic faces challenges in managing patient appointments, follow-ups, and doctor availability. Manual scheduling leads to double bookings, missed follow-ups, and poor communication with patients. Doctors do not have centralized access to patient records, and the management lacks visibility into clinic performance.
To overcome these issues, the clinic wants to implement a **Salesforce-based Healthcare CRM** to:
* Automate patient appointment booking and reminders
* Maintain centralized patient health records
* Improve doctor–patient communication with alerts and notifications
* Provide dashboards for clinic performance monitoring

## Use Cases:
### 1. Appointment Management
* Patients book appointments online through a portal (LWC).
* Automatic email alerts confirm appointments.
* Doctors receive custom notifications inside Salesforce when new appointments are scheduled or cancelled.
* Tasks are created for clinic staff (e.g., “Prepare Room for Consultation”).
### 2. Patient Records
* Centralized patient profiles store medical history, prescriptions, and lab reports.
* Secure access based on role (Doctor, Admin, Patient).
* Doctors can view patient history in real-time before appointments.
### 3. Follow-up Automation
* System automatically creates follow-up appointments post-consultation.
* Email alerts remind patients of upcoming follow-ups.
* Tasks are generated for staff to call patients for lab results or medication updates.
### 4. Notifications & Communication
* Custom Notifications notify doctors instantly about rescheduled/cancelled appointments.
* Patients receive appointment updates via SMS/Email.
### 5. Smart Triage Chatbot (LWC + Einstein Bot)
* An LWC chatbot powered by Einstein Bot guides patients through symptoms.
* Based on answers, it either books an appointment or sends automated self-care instructions.
* Data flows into the patient record for doctors to review before the consultation.

### 6. Asynchronous Processing
* Bulk SMS/WhatsApp reminders sent using Future Methods / Queueable Apex (to avoid governor limits).
* Asynchronous jobs update patient records when integrating with external EHR systems.
* Large-scale data (e.g., 1,000+ patients follow-up schedule) processed in the background.
### 7. Reporting & Dashboards
* Dashboards show doctor utilization (appointments per doctor).
* Patient volume trends and clinic revenue reports.
* Funnel view of new vs. returning patients.
