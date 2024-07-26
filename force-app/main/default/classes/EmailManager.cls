public with sharing class EmailManager
{
    public static void sendMessage(String subject, String body)
    {
        List<String> recipients = new List<String> { 'Przemyslaw.Dudek@ventionteams.com' };

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        mails.add(createSingleEmail(recipients, body, subject));

        Messaging.sendEmail(mails);
    }

    public static Messaging.SingleEmailMessage createSingleEmail(List<String> recipients, String emailTextBody, String emailSubject)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(recipients);
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(emailTextBody);
        mail.setSenderDisplayName(Consts.EMAIL_SENDER_NAME);

        return mail;
    }
}