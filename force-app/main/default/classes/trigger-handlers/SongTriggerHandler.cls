public with sharing class SongTriggerHandler extends TriggerHandlerBase
{
    private static Set<Id> mixesToUpdate = new Set<Id>();

    protected override void onAfterUpdate()
    {
        handleGenreChange((Map<Id, Song__c>)Trigger.oldMap, (Map<Id, Song__c>)Trigger.newMap);
    }

    protected override void onBeforeDelete()
    {
        addMixesToUpdate();
    }

    protected override void onAfterDelete()
    {
        updateMixes();
    }

    protected override void onAfterUndelete()
    {
        Set<Id> affectedMixes = getAffectedMixes((List<Song__c>)Trigger.new);

        MixService.updateMixFields(affectedMixes);
    }

    private void addMixesToUpdate()
    {
        mixesToUpdate.addAll(getAffectedMixes((List<Song__c>)Trigger.old));
    }

    private void updateMixes()
    {
        MixService.updateMixFields(mixesToUpdate);
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

    private static Set<Id> getAffectedMixes(List<Song__c> songs)
    {
        Set<Id> songIds = new Set<Id>();

        for (Song__c song : songs)
        {
            songIds.add(song.Id);
        }

        return TrackService.getMixIdsFromTracks(TrackService.getTrackIdsFromSongs(songIds));
    }
}