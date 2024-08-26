@isTest
private class ContactSelectorTest
{
    @TestSetup
    static void makeData(){
        TestHelper.insertContacts();
    }

    @isTest
    static void selectById()
    {
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT :TestHelper.CONTACT_AMOUNT];
        Set<Id> contactIds = Utils.getIdFieldValue(contacts, Consts.FIELD_ID);

        Test.startTest();
        List<Contact> selectedContacts = ContactSelector.selectById(contactIds);
        Test.stopTest();

        System.assertEquals(TestHelper.CONTACT_AMOUNT, selectedContacts.size());
    }
}