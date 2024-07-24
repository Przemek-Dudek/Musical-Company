public with sharing class MixController
{
    private class mixWrapper
    {
        Id mixId;
        String mixName;
        Id contactId;
        List<Song__c> selectedSongs;

        public mixWrapper(Id mixId, String mixName, Id contactId, List<Song__c> selectedSongs) {
            this.mixId = mixId;
            this.mixName = mixName;
            this.contactId = contactId;
            this.selectedSongs = selectedSongs;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getMix(String mixId)
    {
        Mix__c selectedMix = [SELECT Id, Name, Customer__c FROM Mix__c WHERE Id = :mixId];

        mixWrapper wrapper = new mixWrapper(selectedMix.Id, selectedMix.Name, selectedMix.Customer__c, new List<Song__c>());

        List<Track__c> mixTracks = [SELECT Song__c FROM Track__c WHERE Mix__c = :mixId];

        Set<Id> selectedSongIds = new Set<Id>();
        for (Track__c track : mixTracks)
        {
            selectedSongIds.add(track.Song__c);
        }

        wrapper.selectedSongs = [SELECT Id, Name, Artist__c, Genre__c, Length__c FROM Song__c WHERE Id IN :selectedSongIds];

        String mixJson = JSON.serialize(wrapper);

        return mixJson;
    }

    @AuraEnabled(cacheable=false)
    public static void handleMixUpsert(String mixJson)
    {
        mixWrapper mix = (mixWrapper)JSON.deserialize(mixJson, mixWrapper.class);
        
        if (mix.mixId == null)
        {
            createNewMix(mix);
        }
        else
        {
            updateExistingMix(mix);
        }
    }

    private static void createNewMix(mixWrapper mix)
    {
        Mix__c newMix = new Mix__c(Name = mix.mixName, Customer__c = mix.contactId);
        insert newMix;

        List<Track__c> newTracks = new List<Track__c>();

        for (Song__c song : mix.selectedSongs)
        {
            newTracks.add(new Track__c(Mix__c = newMix.Id, Song__c = song.Id));
        }

        insert newTracks;
    }

    private static void updateExistingMix(mixWrapper mix)
    {
        Mix__c existingMix = [SELECT Id FROM Mix__c WHERE Id = :mix.mixId];

        existingMix.Name = mix.mixName;
        existingMix.Customer__c = mix.contactId;

        update existingMix;

        List<Track__c> existingTracks = [SELECT Id FROM Track__c WHERE Mix__c = :mix.mixId];

        if(existingTracks.size() > mix.selectedSongs.size())
        {
            List<Track__c> tracksToDelete = new List<Track__c>();

            for (Integer i = 0; i < existingTracks.size(); i++)
            {
                if (i < mix.selectedSongs.size())
                {
                    existingTracks[i].Song__c = mix.selectedSongs[i].Id;
                }
                else
                {
                    tracksToDelete.add(existingTracks[i]);
                    existingTracks.remove(i);
                }
            }

            delete tracksToDelete;
            update existingTracks;
        }
        else if(existingTracks.size() < mix.selectedSongs.size())
        {
            for (Integer i = 0; i < mix.selectedSongs.size(); i++)
            {
                if (i < existingTracks.size())
                {
                    existingTracks[i].Song__c = mix.selectedSongs[i].Id;
                }
                else
                {
                    existingTracks.add(new Track__c(Mix__c = mix.mixId, Song__c = mix.selectedSongs[i].Id));
                }
            }

            upsert existingTracks;
        }
        else
        {
            for (Integer i = 0; i < mix.selectedSongs.size(); i++)
            {
                existingTracks[i].Song__c = mix.selectedSongs[i].Id;
            }

            update existingTracks;
        }
    }
}