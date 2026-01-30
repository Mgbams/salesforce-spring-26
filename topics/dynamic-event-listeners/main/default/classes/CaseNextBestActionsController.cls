public with sharing class CaseNextBestActionsController {
    public class ActionDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String category;
        @AuraEnabled public String iconName;

        public ActionDTO(String id, String label, String description, String category, String iconName) {
            this.id = id;
            this.label = label;
            this.description = description;
            this.category = category;
            this.iconName = iconName;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ActionDTO> getRecommendedActions(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('caseId is required.');
        }

        return new List<ActionDTO>{
            new ActionDTO('assign',   'Assign to Me', 'Take ownership of this Case and start investigating.', 'Ownership', 'utility:user'),
            new ActionDTO('escalate', 'Escalate',     'Escalate to Tier 2 with full context and recent activity.', 'Process',   'utility:arrowup'),
            new ActionDTO('email',    'Email Customer','Send a status update email using a standard template.',  'Customer',  'utility:email')
        };
    }

    // Assign the Case to the running user
    @AuraEnabled
    public static void assignCaseToMe(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('caseId is required.');
        }

        // Minimal fields; respects org-wide defaults + sharing due to "with sharing"
        Case caseToBeUpdated = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
        caseToBeUpdated.OwnerId = UserInfo.getUserId();
        update caseToBeUpdated;
    }

    // Escalate the Case by setting Status = 'Escalated'
    @AuraEnabled
    public static void escalateCase(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('caseId is required.');
        }

        // NOTE: Your org must have a valid Case Status value named 'Escalated'
        Case caseToBeUpdated = [SELECT Id, Status, Priority FROM Case WHERE Id = :caseId LIMIT 1];
        caseToBeUpdated.Status = 'Escalated';
        caseToBeUpdated.Priority = 'High';
        update caseToBeUpdated;
    }

    // Send an escalation email to the customer
    @AuraEnabled
    public static void emailCustomerEscalationNotice(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('caseId is required.');
        }

        // Pull Contact email if present; otherwise use SuppliedEmail (Web-to-Case)
        Case caseToBeUpdated = [
            SELECT Id, CaseNumber, Subject, Status,
                Contact.Email,
                SuppliedEmail, SuppliedName
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        //  Ensure the case is escalated so the email is truthful
        // IMPORTANT: 'Escalated' must be a valid Case Status in your org.
        if (caseToBeUpdated.Status != 'Escalated') {
            caseToBeUpdated.Status = 'Escalated';
            update caseToBeUpdated;
        }

        String toAddress = (caseToBeUpdated.Contact != null && String.isNotBlank(caseToBeUpdated.Contact.Email))
            ? caseToBeUpdated.Contact.Email
            : caseToBeUpdated.SuppliedEmail;

        if (String.isBlank(toAddress)) {
            throw new AuraHandledException(
                'No customer email found. Populate Case Contact Email or Supplied Email.'
            );
        }

        String greetingName = String.isNotBlank(caseToBeUpdated.SuppliedName) ? caseToBeUpdated.SuppliedName : 'Customer';

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[] { toAddress });
        msg.setSubject('Update: Your Case Has Been Escalated (Case ' + caseToBeUpdated.CaseNumber + ')');

        // Keep the content simple and professional
        String body =
            'Hello ' + greetingName + ',' + '\n\n' +
            'We wanted to let you know that your case (Case ' + caseToBeUpdated.CaseNumber + ') has been escalated ' +
            'to ensure it receives the appropriate attention.' + '\n\n' +
            'We will follow up with you as soon as we have an update.' + '\n\n' +
            'Thank you,' + '\n' +
            'Support Team';

        msg.setPlainTextBody(body);

        // Send email (returns result; throwing an exception if it fails keeps UI honest)
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
        if (results == null || results.isEmpty() || !results[0].isSuccess()) {
            String errorMsg = 'Email send failed.';
            if (results != null && !results.isEmpty() && results[0].getErrors() != null && results[0].getErrors().size() > 0) {
                errorMsg += ' ' + results[0].getErrors()[0].getMessage();
            }
            throw new AuraHandledException(errorMsg);
        }
    }

}