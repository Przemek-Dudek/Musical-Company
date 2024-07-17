public with sharing class MixService
{
    public static void updateMixFields(Set<Id> mixIds)
    {
        List<AggregateResult> res = [
            SELECT COUNT(Id) recordCount, Song__r.Genre__c genre, Mix__c mix
            FROM Track__c
            WHERE Mix__c IN :mixIds
            GROUP BY Song__r.Genre__c, Mix__c];

        //Create a map with mix_c as key and a map of genre(key) and count(value) as value
        Map<Id, Map<String, Integer>> mixGenreCount = new Map<Id, Map<String, Integer>>();
        //iterate over the map and update mixes with 2 most popular genres
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
            //will never contain duplicate genres
            genreCount.put(genre, count);
        }


        List<Mix__c> mixesToUpdate = new List<Mix__c>();

        for (Id mixId : mixIds)
        {
            Mix__c mix = new Mix__c(Id = mixId);

            
            Map<String, Integer> genreCount = mixGenreCount.get(mixId);

            List<String> genres = new List<String>();
            genres.addAll(genreCount.keySet());

            genres.sort();

            //need to check behavior when there is only one genre or none
            mix.Primary_Genre__c = genres[0];
            mix.Secondary_Genre__c = genres.size() > 1 ? genres[1] : null;
            

            mixesToUpdate.add(mix);
        }

        System.debug('mixesToUpdate: ' + mixesToUpdate);
    }
}