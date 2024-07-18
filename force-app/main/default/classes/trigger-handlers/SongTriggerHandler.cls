public with sharing class SongTriggerHandler extends TriggerHandlerBase
{
    protected override void onAfterUpdate()
    {
        handleGenreChange((Map<Id, Song__c>)Trigger.oldMap, (Map<Id, Song__c>)Trigger.newMap);
    }

    private void handleGenreChange(Map<Id, Song__c> oldMap, Map<Id, Song__c> newMap)
    {
        Set<Id> trackAffectedIds = new Set<Id>();

        for (Song__c newSong : newMap.values())
        {
            Song__c oldSong = oldMap.get(newSong.Id);

            if (newSong.Genre__c != oldSong.Genre__c)
            {
                trackAffectedIds.add(newSong.Id);
            }
        }

        if (trackAffectedIds.isEmpty())
        {
            return;
        }

        MixService.updateMixFields(TrackService.getMixIdsFromTracks(trackAffectedIds));
    }
}