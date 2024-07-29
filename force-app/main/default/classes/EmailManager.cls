public with sharing class EmailManager
{
    public static void sendMessage(List<String> recipients, String subject, String body, Messaging.EmailFileAttachment attachment)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        mails.add(createSingleEmail(recipients, body, subject, attachment));

        Messaging.sendEmail(mails);
    }

    public static Messaging.SingleEmailMessage createSingleEmail(List<String> recipients, String emailTextBody, String emailSubject, Messaging.EmailFileAttachment attachment)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(recipients);
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(emailTextBody);
        mail.setSenderDisplayName(Consts.EMAIL_SENDER_NAME);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        return mail;
    }

    @AuraEnabled
    public static void sendEmailWithPdf(String contactId, String pdfBase64, String fileName)
    {
        Contact contact = [SELECT Email FROM Contact WHERE Id = :contactId LIMIT 1];

        if (contact.Email == null)
        {
            throw new AuraHandledException('The selected contact does not have an email address.');
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(fileName + '.pdf');
        attachment.setBody(EncodingUtil.base64Decode(pdfBase64));
        attachment.setContentType('application/pdf');

        sendMessage(new List<String> { contact.Email }, 'Your Vinyl Mix', 'Please find the attached PDF file for detailed mix report', attachment);
    }
}