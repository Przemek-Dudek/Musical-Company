@isTest
private class MixSelectorTest
{
    @TestSetup
    static void makeData(){
        TestHelper.insertEmptyMixes();
    }

    @isTest
    static void selectById()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c LIMIT :TestHelper.MIX_AMOUNT];
        Set<Id> mixIds = Utils.getIdFieldValue(mixes, Consts.FIELD_ID);

        Test.startTest();
        List<Mix__c> selectedMixes = MixSelector.selectById(mixIds);
        Test.stopTest();

        System.assertEquals(TestHelper.MIX_AMOUNT, selectedMixes.size());
    }
}