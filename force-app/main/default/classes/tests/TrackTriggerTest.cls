@isTest
public with sharing class TrackTriggerTest 
{
    @TestSetup
    static void makeData(){
        TestHelper.insertTestMixes();
    }

    @isTest
    static void testInsertTooManyTracks()
    {
        Mix__c mix = [SELECT Id FROM Mix__c LIMIT 1];

        List<Track__c> tracks = new List<Track__c>();
        for(Integer i = 0; i < 11; i++)
        {
            Track__c track = new Track__c();
            track.Mix__c = mix.Id;
            track.Song__c = null;
            track.Index__c = i;

            tracks.add(track);
        }

        Boolean caughtException = false;

        Test.startTest();
        try {
            insert tracks;
        } catch (DmlException e) {
            caughtException = true;
        }
        Test.stopTest();

        System.assertEquals(true, caughtException);
    }

    @isTest
    static void testUpdateSongOnTrack()
    {
        List<Track__c> tracks = [SELECT Id, Song__c FROM Track__c];
        for(Track__c track : tracks)
        {
            track.Song__c = null;
        }

        Test.startTest();
        update tracks;
        Test.stopTest();

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(null, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }

    @isTest
    static void testDeleteTracks()
    {
        List<Track__c> tracks = [SELECT Id FROM Track__c];

        Test.startTest();
        delete tracks;
        Test.stopTest();

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(null, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }

    @isTest
    static void testUndeleteTracks()
    {
        List<Track__c> tracks = [SELECT Id FROM Track__c];

        delete tracks;

        Test.startTest();
        undelete tracks;
        Test.stopTest();

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(TestHelper.GENRE_ROCK, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }
}