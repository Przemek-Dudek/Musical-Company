public with sharing class SongTriggerHandler extends TriggerHandlerBase
{
    protected override void onAfterUpdate()
    {
        handleGenreChange((Map<Id, Song__c>)Trigger.oldMap, (Map<Id, Song__c>)Trigger.newMap);
    }

    protected override void onBeforeDelete()
    {
        handleSongRemoval();
    }

    private void handleGenreChange(Map<Id, Song__c> oldMap, Map<Id, Song__c> newMap)
    {
        Set<Id> songsWithChangedGenreIds = new Set<Id>();

        for (Song__c newSong : newMap.values())
        {
            Song__c oldSong = oldMap.get(newSong.Id);

            if (newSong.Genre__c != oldSong.Genre__c)
            {
                songsWithChangedGenreIds.add(newSong.Id);
            }
        }

        if (songsWithChangedGenreIds.isEmpty())
        {
            return;
        }

        Set<Id> trackIds = TrackService.getTrackIdsFromSongs(songsWithChangedGenreIds);

        MixService.updateMixFields(TrackService.getMixIdsFromTracks(trackIds));
    }

    private void handleSongRemoval()
    {
        Set<Id> songIds = new Set<Id>();

        for (Song__c song : (List<Song__c>)Trigger.old)
        {
            songIds.add(song.Id);
        }

        SongService.clearRelatedTracks(songIds);
    }
}