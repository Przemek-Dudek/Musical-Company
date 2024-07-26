public with sharing class TrackSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField>(Track__c.SObjectType.getDescribe().fields.getMap().values());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Track__c.SObjectType;
    }

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

    public static List<Track__c> getTracksBySongIds(Set<Id> songIds)
    {
        TrackSelector selector = new TrackSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Track__c>) Database.query(queryFactory.setCondition('Song__c IN :songIds').toSOQL());
    }

    public static List<Track__c> selectByMixId(Set<Id> mixIds)
    {
        TrackSelector selector = new TrackSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Track__c>) Database.query(queryFactory.setCondition('Mix__c = :mixIds').toSOQL());
    }

    public static List<Track__c> selectByIds(Set<Id> trackIds)
    {
        TrackSelector selector = new TrackSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Track__c>) Database.query(queryFactory.setCondition('Id IN :trackIds').toSOQL());
    }
}