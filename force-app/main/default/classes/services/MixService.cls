public with sharing class MixService
{
    public static void updateMixFields(Set<Id> mixIds)
    {
        Map<Id, Map<String, Integer>> mixGenreCount = MixSelector.getMixGenreCount(mixIds);

        List<Mix__c> mixesToUpdate = new List<Mix__c>();

        for (Id mixId : mixIds)
        {
            Mix__c mix = new Mix__c(Id = mixId);

            
            Map<String, Integer> genreCount = mixGenreCount.get(mixId);

            List<String> genres = new List<String>();
            genres.addAll(genreCount.keySet());

            genres.sort();

            mix.Primary_Genre__c = genres[0];
            mix.Secondary_Genre__c = genres.size() > 1 ? genres[1] : null;
            

            mixesToUpdate.add(mix);
        }

        update mixesToUpdate;
    }
}