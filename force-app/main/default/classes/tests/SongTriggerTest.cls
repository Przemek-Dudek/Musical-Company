@isTest
public with sharing class SongTriggerTest
{
    @TestSetup
    static void makeData(){
        TestHelper.insertTestMixes();
    }

    @isTest
    static void testChangeSongGenre()
    {
        List<Song__c> songs = [SELECT Id, Genre__c FROM Song__c];

        for(Song__c song : songs)
        {
            song.Genre__c = TestHelper.GENRE_POP;
        }

        update songs;

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(TestHelper.GENRE_POP, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }

    @isTest
    static void testDeleteSongs()
    {
        List<Song__c> songs = [SELECT Id FROM Song__c];

        Test.startTest();
        delete songs;
        Test.stopTest();

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(null, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }

    @isTest
    static void UndeleteSongs()
    {
        List<Song__c> songs = [SELECT Id FROM Song__c];

        delete songs;

        Test.startTest();
        undelete songs;
        Test.stopTest();

        List<Mix__c> mixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        for(Mix__c mix : mixes)
        {
            System.assertEquals(TestHelper.GENRE_ROCK, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }
}