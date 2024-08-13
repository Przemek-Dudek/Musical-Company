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

    public static void sendEmailWithPdf(List<Contact> contacts, String pdfBase64, String fileName)
    {
        List<String> recipients = new List<String>();
        for (Contact contact : contacts)
        {
            if (contact.Email != null)
            {
                recipients.add(contact.Email);
            }
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(fileName + '.pdf');
        attachment.setBody(EncodingUtil.base64Decode(pdfBase64));
        attachment.setContentType('application/pdf');

        sendMessage(recipients, 'Your Vinyl Mix', 'Please find the attached PDF file for detailed mix report', attachment);
    }
}