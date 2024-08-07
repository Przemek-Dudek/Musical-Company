public with sharing class MixBuilderController
{
    private static void songLicenseException(List<Song__c> songs)
    {
        Set<Id> songIds = Utils.getIdFieldValue(songs, Consts.FIELD_ID);
        List<String> songNames = SongService.getUnavailableSongNames(SongSelector.selectById(songIds));

        throw new AuraHandledException('Insufficient song licenses: ' + String.join(songNames, ', '));
    }
    
    @AuraEnabled(cacheable=false)
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
    public static String handleMixUpsert(String mixJson)
    {
        MixWrapper mix = (MixWrapper)JSON.deserialize(mixJson, MixWrapper.class);

        Id mixId = mix.mixId;

        if (mix.mixId == null)
        {
            try
            {
                mixId = MixService.createNewMix(mix);
            } 
            catch (DmlException e)
            {
                for (Integer i = 0; i < e.getNumDml(); i++)
                {
                    if (e.getDmlMessage(i).contains('Track Count cannot exceed the number of Track Licenses'))
                    {
                        songLicenseException(mix.selectedSongs);
                        return null;
                    }
                }

                throw e;
            }
        }
        else
        {
            try
            {
                MixService.updateExistingMix(mix);
            }
            catch (DmlException e)
            {
                for (Integer i = 0; i < e.getNumDml(); i++)
                {
                    if (e.getDmlMessage(i).contains('Track Count cannot exceed the number of Track Licenses'))
                    {
                        songLicenseException(mix.selectedSongs);
                        return null;
                    }
                }

                throw e;
            }
        }

        return mixId;
    }

    @AuraEnabled(cacheable=false)
    public static void handleVinylProduce(String mixJson)
    {
        MixWrapper mix = (MixWrapper)JSON.deserialize(mixJson, MixWrapper.class);

        Id mixId = mix.mixId;

        Map<Id, Integer> songIds = new Map<Id, Integer>();
        for (MixWrapper.SongIndex song : mix.songIndexes)
        {
            songIds.put(song.songId, (Integer)song.songIndex);
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
        
        for (Schema.PicklistEntry entry : picklistEntries)
        {
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

        if (Math.mod(numberOfRecords, Consts.PAGINATION_BATCH_SIZE) == 0 && numberOfRecords > 0)
        {
            return numberOfRecords/Consts.PAGINATION_BATCH_SIZE;
        }

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