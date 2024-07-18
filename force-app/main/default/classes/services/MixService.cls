public with sharing class MixService
{
    public static void updateMixFields(Set<Id> mixIds)
    {
        Map<Id, Map<String, Integer>> mixGenreCount = getMixGenreCountMap(mixIds);

        List<Mix__c> mixesToUpdate = new List<Mix__c>();

        for (Id mixId : mixIds)
        {
            Mix__c mix = new Mix__c(Id = mixId);

            
            Map<String, Integer> genreCount = mixGenreCount.get(mixId);

            String primaryGenre = null;
            String secondaryGenre = null;

            for(String genre : genreCount.keySet())
            {
                if(primaryGenre == null || genreCount.get(genre) > genreCount.get(primaryGenre))
                {
                    secondaryGenre = primaryGenre;
                    primaryGenre = genre;
                }
                else if(secondaryGenre == null || genreCount.get(genre) > genreCount.get(secondaryGenre))
                {
                    secondaryGenre = genre;
                }
            }

            mix.Primary_Genre__c = primaryGenre;
            mix.Secondary_Genre__c = secondaryGenre;
            

            mixesToUpdate.add(mix);
        }

        update mixesToUpdate;
    }

    public static Map<Id, Map<String, Integer>> getMixGenreCountMap(Set<Id> mixIds)
    {
        List<AggregateResult> queryRes = TrackSelector.getGenresByMixes(mixIds);

        Map<Id, Map<String, Integer>> mixGenreCount = new Map<Id, Map<String, Integer>>();

        for (AggregateResult r : queryRes)
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

    public static Set<Id> getFullMixIds(Set<Id> mixIds)
    {
        List<AggregateResult> queryRes = TrackSelector.getFullMixes(mixIds);
        
        Set<Id> fullMixesIds = new Set<Id>();

        for (AggregateResult res : queryRes)
        {
            fullMixesIds.add((Id)res.get('Mix__c'));
        }

        return fullMixesIds;
    }
}