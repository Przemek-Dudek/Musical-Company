public with sharing class MixController
{
    @AuraEnabled(cacheable=true)
    public static String getMix(String mixId)
    {
        Mix__c selectedMix = MixSelector.selectById(new Set<Id>{(Id)mixId})[0];

        Set<Id> selectedSongIds = TrackService.getSongIdsFromTracks(
            TrackSelector.selectByMixId(new Set<Id>{(Id)mixId}));

        MixWrapper wrapper = new MixWrapper(
            selectedMix.Id, selectedMix.Name, selectedMix.Customer__c,
            SongSelector.selectById(selectedSongIds));

        return JSON.serialize(wrapper);
    }

    @AuraEnabled(cacheable=false)
    public static void handleMixUpsert(String mixJson)
    {
        MixWrapper mix = (MixWrapper)JSON.deserialize(mixJson, MixWrapper.class);
        
        if (mix.mixId == null)
        {
            MixService.createNewMix(mix);
        }
        else
        {
            MixService.updateExistingMix(mix);
        }
    }

    @AuraEnabled(cacheable=false)
    public static void handleVinylProduce(String mixJson)
    {
        VinylWrapper vinyl = (VinylWrapper)JSON.deserialize(mixJson, VinylWrapper.class);

        Id mixId = vinyl.mixId;

        Map<Id, Integer> songIds = new Map<Id, Integer>();
        for (Track__c song : vinyl.selectedTracks)
        {
            songIds.put(song.Id, (Integer)song.Index__c);
        }

        List<Track__c> tracks = TrackSelector.selectByMixId(new Set<Id>{mixId});

        for (Track__c track : tracks)
        {
            track.Index__c = songIds.get(track.Song__c);
        }

        update tracks;
    }
}