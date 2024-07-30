@isTest
private class ContactSelectorTest
{
    @isTest
    static void selectById()
    {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 200; i++)
        {
            Contact contact = new Contact();
            contact.LastName = 'Test' + i;
            contacts.add(contact);
        }

        insert contacts;

        Set<Id> contactIds = new Set<Id>();
        
        for(Contact contact : contacts)
        {
            contactIds.add(contact.Id);
        }

        Test.startTest();
        List<Contact> selectedContacts = ContactSelector.selectById(contactIds);
        Test.stopTest();

        System.assertEquals(200, selectedContacts.size());
    }
}