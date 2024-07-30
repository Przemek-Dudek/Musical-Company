public with sharing class MixBuilderController
{
    @AuraEnabled(cacheable=true)
    public static String getMix(String mixId)
    {
        Mix__c selectedMix = MixSelector.selectById(new Set<Id>{(Id)mixId})[0];

        Set<Id> selectedSongIds = Utils.getIdFieldValue(
            TrackSelector.selectByMixId(new Set<Id>{(Id)mixId}), Consts.FIELD_SONG);

        MixWrapper wrapper = new MixWrapper(
            selectedMix.Id, selectedMix.Name, selectedMix.Customer__c,
            SongSelector.selectById(selectedSongIds)
        );

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

    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByIds(List<Id> musicList)
    {
        return SongSelector.selectById(new Set<Id>(musicList));
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenres()
    {
        List<String> genres = new List<String>();
        List<Schema.PicklistEntry> picklistEntries = Song__c.Genre__c.getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            genres.add(entry.getLabel());
        }
        
        return genres;
    }

    @AuraEnabled(cacheable=true)
    public static List<Song__c> getSongsByGenre(String genre, Integer offset)
    {
        return SongSelector.selectByGenre(genre, offset);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getPages(String genre)
    {
        Integer numberOfRecords = (Integer)SongSelector.numberOfRecords(genre).get('n');
        return numberOfRecords/Consts.PAGINATION_BATCH_SIZE + 1;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getTrackOrder(String mixId)
    {
        List<Track__c> tracks = TrackSelector.selectByMixId(new Set<Id>{(Id)mixId});
        
        List<Map<String, Object>> songIds = new List<Map<String, Object>>();

        for (Track__c track : tracks)
        {
            Map<String, Object> songMap = new Map<String, Object>();
            songMap.put(Consts.FIELD_ID, track.Song__c);
            songMap.put(Consts.FIELD_INDEX, track.Index__c);
            songIds.add(songMap);
        }

        return songIds;
    }

    @AuraEnabled
    public static void sendEmailWithPdf(String contactId, String pdfBase64, String fileName)
    {
        List<Contact> contacts = ContactSelector.selectById(new Set<Id>{(Id)contactId});
        
        EmailManager.sendEmailWithPdf(contacts, pdfBase64, fileName);
    }
}