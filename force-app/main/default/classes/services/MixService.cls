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

            if(genreCount == null)
            {
                mix.Primary_Genre__c = null;
                mix.Secondary_Genre__c = null;

                mixesToUpdate.add(mix);
                continue;
            }

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
            Id mixId = (Id)r.get(Consts.FIELD_MIX);

            String genre = (String)r.get(Consts.FIELD_GENRE);
            Integer count = (Integer)r.get(Consts.AGGREGATE_COUNT);

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
        
        Set<Id> fullMixIds = new Set<Id>();
        for (AggregateResult r : queryRes)
        {
            fullMixIds.add((Id)r.get(Consts.FIELD_MIX));
        }

        return fullMixIds;
    }

    public static void createNewMix(MixWrapper mix)
    {
        Savepoint sp = Database.setSavepoint();
    
        try
        {
            Mix__c newMix = new Mix__c(Name = mix.mixName, Customer__c = mix.contactId);
            insert newMix;

            TrackService.createTracks(newMix.Id, mix.selectedSongs);
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            throw e;
        }
    }

    public static void updateMixData(MixWrapper mix)
    {
        Mix__c existingMix = MixSelector.selectById(new Set<Id>{mix.mixId})[0];
    
        if (existingMix.Name == mix.mixName && existingMix.Customer__c == mix.contactId)
        {
            return;
        }
    
        existingMix.Name = mix.mixName;
        existingMix.Customer__c = mix.contactId;
    
        update existingMix;
    }
    
    public static void updateExistingMix(MixWrapper mix)
    {
        Savepoint sp = Database.setSavepoint();
    
        try
        {
            updateMixData(mix);
    
            List<Track__c> existingTracks = TrackSelector.selectByMixId(new Set<Id>{mix.mixId});
            Set<Id> selectedSongIds = Utils.getIdFieldValue(mix.selectedSongs, Consts.FIELD_ID);
    
            for (Integer i = 0; i < existingTracks.size();)
            {
                Track__c track = existingTracks[i];
    
                if (selectedSongIds.contains(track.Song__c))
                {
                    existingTracks.remove(i);
                    selectedSongIds.remove(track.Song__c);
                }
                else
                {
                    i++;
                }
            }

            List<Track__c> tracksToDelete = new List<Track__c>();
    
            Integer delta = selectedSongIds.size() - existingTracks.size();
            if (delta > 0)
            {
                for (; delta > 0; delta--)
                {
                    existingTracks.add(new Track__c(Mix__c = mix.mixId));
                }
            }
            else if (delta < 0)
            {
                for (; delta < 0; delta++)
                {
                    tracksToDelete.add(existingTracks[0]);
                    existingTracks.remove(0);
                }
            }
    
            List<Id> songIds = new List<Id>(selectedSongIds);
            for (Track__c track : existingTracks)
            {
                track.Song__c = songIds.remove(0);
            }
    
            delete tracksToDelete;
            upsert existingTracks;
    
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            throw e;
        }
    }
}