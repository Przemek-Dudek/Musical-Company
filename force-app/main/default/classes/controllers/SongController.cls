public with sharing class SongController
{
    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByIds(List<Id> musicList)
    {
        List<Song__c> res = [SELECT Id, Name, Genre__c, Length__c, Artist__c FROM Song__c WHERE Id IN :musicList];
        System.debug(res);

        return res;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenres()
    {
        List<String> genres = new List<String>();
        Schema.DescribeFieldResult fieldResult = Song__c.Genre__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            genres.add(entry.getLabel());
        }
        
        return genres;
    }

    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByGenre(String genre)
    {
        List<Song__c> res = new List<Song__c>();

        String query = 'SELECT Id, Name, Genre__c, Length__c, Artist__c FROM Song__c';

        if(genre != 'all')
        {
            query += ' WHERE Genre__c = \'' + genre + '\'';
        }

        query += ' ORDER BY Name ASC';

        res = Database.query(query);

        return res;
    }
}
