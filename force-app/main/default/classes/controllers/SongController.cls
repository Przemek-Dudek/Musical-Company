public with sharing class SongController
{
    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByIds(List<Id> musicList)
    {
        List<Song__c> res = [SELECT Id, Name, Genre__c, Length__c, Artist__c FROM Song__c WHERE Id IN :musicList];
        System.debug(res);

        return res
    }
}
