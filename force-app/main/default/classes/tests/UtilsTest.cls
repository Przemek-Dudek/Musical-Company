@isTest
public with sharing class UtilsTest
{
    @TestSetup
    static void makeData()
    {
        List<Song__c> songs = new List<Song__c>();

        for(Integer i = 0; i < 200; i++)
        {
            Song__c song = new Song__c();
            song.Name = 'Test' + i;
            song.Length__c = 180;
            song.Artist__c = 'Test Artist' + i;
            song.Track_Count__c = 0;
            song.Track_Licenses__c = 10;

            if(i < 100)
            {
                song.Genre__c = TestHelper.GENRE_ROCK;
            }
            else
            {
                song.Genre__c = TestHelper.GENRE_POP;
            }

            songs.add(song);
        }

        insert songs;
    }

    @isTest
    static void getIdFieldValue()
    {
        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 50];

        Test.startTest();
        Set<Id> songIds = Utils.getIdFieldValue(songs, 'Id');
        Test.stopTest();

        System.assertEquals(50, songIds.size());
    }
}