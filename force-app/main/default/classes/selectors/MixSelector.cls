public with sharing class MixSelector
{
    //Didnt know whether to put this in TrackSelector or MixSelector or somewhere else. Put it here as it returns data about mixes mapped to mix ids.
    public static Map<Id, Map<String, Integer>> getMixGenreCount(Set<Id> mixIds)
    {
        List<AggregateResult> res = [
            SELECT COUNT(Id) recordCount, Song__r.Genre__c genre, Mix__c mix
            FROM Track__c
            WHERE Mix__c IN :mixIds
            GROUP BY Song__r.Genre__c, Mix__c];

        Map<Id, Map<String, Integer>> mixGenreCount = new Map<Id, Map<String, Integer>>();

        for (AggregateResult r : res)
        {
            Id mixId = (Id)r.get('mix');

            String genre = (String)r.get('genre');
            Integer count = (Integer)r.get('recordCount');

            if (!mixGenreCount.containsKey(mixId))
            {
                mixGenreCount.put(mixId, new Map<String, Integer>());
            }

            Map<String, Integer> genreCount = mixGenreCount.get(mixId);

            genreCount.put(genre, count);
        }

        return mixGenreCount;
    }

    //Same here. Returns Mix Ids but queries Track__c object.
    public static Set<Id> selectFullMixIds(Set<Id> mixIds)
    {
        List<AggregateResult> queryRes = [
            SELECT Mix__c
            FROM Track__c 
            GROUP BY Mix__c
            HAVING COUNT(Id) > :Consts.MAX_TRACKS_PER_MIX
            AND Mix__c IN :mixIds];
        
        Set<Id> fullMixesIds = new Set<Id>();

        for (AggregateResult res : queryRes)
        {
            fullMixesIds.add((Id)res.get('Mix__c'));
        }

        return fullMixesIds;
    }
}