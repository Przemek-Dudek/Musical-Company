public with sharing class MixService
{
    public static void updateMixFields(Set<Id> mixIds)
    {
        Map<Id, Map<Integer, List<String>>> mixGenreCount = getMixGenreCountMap(mixIds);

        List<Mix__c> mixesToUpdate = new List<Mix__c>();

        for (Id mixId : mixIds)
        {
            Mix__c mix = new Mix__c(Id = mixId);

            Map<Integer, List<String>> genreCount = mixGenreCount.get(mixId);
            List<String> topGenres = getTopGenres(genreCount);

            mix.Primary_Genre__c = null;
            mix.Secondary_Genre__c = null;

            if(topGenres.isEmpty())
            {
                mixesToUpdate.add(mix);
                continue;
            }

            mix.Primary_Genre__c = topGenres[0];

            if(topGenres.size() > 1)
            {
                mix.Secondary_Genre__c = topGenres[1];
            }

            mixesToUpdate.add(mix);
        }

        update mixesToUpdate;
    }

    private static List<String> getTopGenres(Map<Integer, List<String>> genreCount)
    {
        List<String> topGenres = new List<String>();
        if(genreCount == null)
        {
            return topGenres;
        }

        List<Integer> counts = new List<Integer>(genreCount.keySet());
        if(counts.isEmpty())
        {
            return topGenres;
        }

        counts.sort();

        if(counts.isEmpty())
        {
            return topGenres;
        }

        List<String> primaryGenres = genreCount.get(counts[counts.size() - 1]);

        if(primaryGenres != null)
        {
            primaryGenres.sort();
            topGenres.addAll(primaryGenres);
        }

        if(counts.size() > 1)
        {
            List<String> secondaryGenres = genreCount.get(counts[counts.size() - 2]);

            if(secondaryGenres != null)
            {
                secondaryGenres.sort();
                topGenres.addAll(secondaryGenres);
            }
        }
        
        return topGenres;
    }

    public static Map<Id, Map<Integer, List<String>>> getMixGenreCountMap(Set<Id> mixIds)
    {
        List<AggregateResult> queryRes = TrackSelector.getGenresByMixes(mixIds);

        Map<Id, Map<Integer, List<String>>> mixGenreCount = new Map<Id, Map<Integer, List<String>>>();

        for (AggregateResult r : queryRes)
        {
            Id mixId = (Id)r.get(Consts.FIELD_MIX);

            String genre = (String)r.get(Consts.FIELD_GENRE);
            Integer count = (Integer)r.get(Consts.AGGREGATE_COUNT);

            if (!mixGenreCount.containsKey(mixId))
            {
                mixGenreCount.put(mixId, new Map<Integer, List<String>>());
            }

            Map<Integer, List<String>> genreCount = mixGenreCount.get(mixId);

            if (!genreCount.containsKey(count))
            {
                genreCount.put(count, new List<String>());
            }

            genreCount.get(count).add(genre);
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

    public static Id createNewMix(MixWrapper mix)
    {
        Savepoint sp = Database.setSavepoint();
        
        Mix__c newMix;

        try
        {
            newMix = new Mix__c(Name = mix.mixName, Customer__c = mix.contactId);
            insert newMix;

            TrackService.createTracks(newMix.Id, mix.selectedSongs);
        }
        catch (DmlException e)
        {
            Database.rollback(sp);
            throw e;
        }

        return newMix.Id;
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