public with sharing class SongController
{
    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByIds(List<Id> musicList)
    {
        return SongSelector.selectById(new Set<Id>(musicList));
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
        return SongSelector.selectByGenre(genre);
    }
}
