public with sharing class TrackSelector
{
    public static List<AggregateResult> countTracksOnSongs(Set<Id> songIds)
    {
        return [
            SELECT Song__c songId, COUNT(Id) trackCount
            FROM Track__c
            WHERE Song__c IN :songIds
            GROUP BY Song__c];
    }

    public static List<AggregateResult> getGenresByMixes(Set<Id> mixIds)
    {
        return [
            SELECT COUNT(Id) recordCount, Song__r.Genre__c genre, Mix__c mix
            FROM Track__c
            WHERE Mix__c IN :mixIds
            GROUP BY Song__r.Genre__c, Mix__c];
    }

    public static List<AggregateResult> getFullMixes(Set<Id> mixIds)
    {
        return [
            SELECT Mix__c
            FROM Track__c 
            GROUP BY Mix__c
            HAVING COUNT(Id) > :Consts.MAX_TRACKS_PER_MIX
            AND Mix__c IN :mixIds];
    }
}