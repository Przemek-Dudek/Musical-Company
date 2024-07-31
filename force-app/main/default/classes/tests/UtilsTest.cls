@isTest
public with sharing class UtilsTest
{
    @TestSetup
    static void makeData()
    {
        TestHelper.insertSongs();
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