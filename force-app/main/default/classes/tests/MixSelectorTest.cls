@isTest
private class MixSelectorTest
{

    @isTest
    static void selectById()
    {
        List<Mix__c> mixes = new List<Mix__c>();
        for(Integer i = 0; i < 200; i++)
        {
            Mix__c mix = new Mix__c();
            mix.Name = 'Test' + i;
            mixes.add(mix);
        }

        insert mixes;

        Set<Id> mixIds = new Set<Id>();
        
        for(Mix__c mix : mixes)
        {
            mixIds.add(mix.Id);
        }

        Test.startTest();
        List<Mix__c> selectedMixes = MixSelector.selectById(mixIds);
        Test.stopTest();

        System.assertEquals(200, selectedMixes.size());
    }
}