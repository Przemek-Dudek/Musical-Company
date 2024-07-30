@isTest
private class MixBuilderControllerTest 
{
    @TestSetup
    static void makeData(){
        TestHelper.insertTestMixes();
    }

    @isTest
    static void testGetMix()
    {
        Mix__c mix = [SELECT Id, Name, Customer__c FROM Mix__c LIMIT 1];

        Test.startTest();
        String mixJson = MixBuilderController.getMix(mix.Id);
        Test.stopTest();

        MixWrapper wrapper = (MixWrapper)JSON.deserialize(mixJson, MixWrapper.class);

        System.assertEquals(mix.Id, wrapper.mixId);
        System.assertEquals(mix.Name, wrapper.mixName);
        System.assertEquals(mix.Customer__c, wrapper.contactId);
        System.assertEquals(10, wrapper.selectedSongs.size());
    }

    @isTest
    static void testHandleMixUpsertNew()
    {
        List<Mix__c> mixes = [SELECT Id, Name FROM Mix__c];

        delete mixes;

        MixWrapper wrapper = new MixWrapper(
            null, 'Name', null,
            [SELECT Id, Name FROM Song__c LIMIT 10]
        );

        Test.startTest();
        MixBuilderController.handleMixUpsert(JSON.serialize(wrapper));
        Test.stopTest();

        List<Mix__c> newMixes = [SELECT Id, Name, Customer__c FROM Mix__c];

        List<Track__c> mixTracks = [SELECT Id, Song__c FROM Track__c WHERE Mix__c = :newMixes[0].Id];

        System.assertEquals(1, newMixes.size());
        Mix__c newMix = newMixes[0];
        System.assertEquals(wrapper.mixName, newMix.Name);
        System.assertEquals(wrapper.contactId, newMix.Customer__c);
        System.assertEquals(10, mixTracks.size());
    }

    @isTest
    static void updateExistingMixLessSongs()
    {
        Mix__c mix = [SELECT Id, Name FROM Mix__c LIMIT 1];
        List<Track__c> tracks = [SELECT Id, Song__c FROM Track__c WHERE Mix__c = :mix.Id];

        MixWrapper wrapper = new MixWrapper(
            mix.Id, mix.Name, null,
            [SELECT Id, Name FROM Song__c LIMIT 5]
        );

        Test.startTest();
        MixBuilderController.handleMixUpsert(JSON.serialize(wrapper));
        Test.stopTest();

        List<Track__c> updatedTracks = [SELECT Id, Index__c FROM Track__c WHERE Mix__c = :mix.Id];

        System.assertEquals(5, updatedTracks.size());
    }
}