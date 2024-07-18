public with sharing class TrackTriggerHandler extends TriggerHandlerBase
{
    protected override void onBeforeInsert()
    {
        checkIfMaxTrackAmountPerMixWasHit();
    }

    protected override void onBeforeUpdate()
    {
        checkIfMaxTrackAmountPerMixWasHit();
    }

    protected override void onAfterInsert()
    {
        handleMixUpdates((Map<Id, Track__c>)Trigger.newMap);

        handleTrackCount((Map<Id, Track__c>)Trigger.newMap);
    }

    protected override void onAfterUpdate()
    {
        handleMixUpdates((Map<Id, Track__c>)Trigger.oldMap, (Map<Id, Track__c>)Trigger.newMap);

        handleTrackCount((Map<Id, Track__c>)Trigger.oldMap, (Map<Id, Track__c>)Trigger.newMap);
    }

    protected override void onAfterDelete()
    {
        handleMixUpdates((Map<Id, Track__c>)Trigger.oldMap);

        handleTrackCount((Map<Id, Track__c>)Trigger.oldMap);
    }

    protected override void onAfterUnDelete()
    {
        checkIfMaxTrackAmountPerMixWasHit();

        handleMixUpdates((Map<Id, Track__c>)Trigger.newMap);

        handleTrackCount((Map<Id, Track__c>)Trigger.newMap);
    }

    private void checkIfMaxTrackAmountPerMixWasHit()
    {
        TrackService.processAddedTracks((List<Track__c>)Trigger.new);
    }

    private void handleMixUpdates(Map<Id, Track__c> oldMap, Map<Id, Track__c> newMap)
    {
        Set<Id> updatedMixIds = new Set<Id>();
        
        for (Track__c newTrack : newMap.values())
        {
            Track__c oldTrack = oldMap.get(newTrack.Id);

            if (newTrack.Mix__c != oldTrack.Mix__c)
            {
                if (newTrack.Mix__c != null)
                {
                    updatedMixIds.add(newTrack.Mix__c);
                }

                if (oldTrack.Mix__c != null)
                {
                    updatedMixIds.add(oldTrack.Mix__c);
                }
            }

            if (newTrack.Song__c != oldTrack.Song__c)
            {
                if (newTrack.Mix__c != null)
                {
                    updatedMixIds.add(newTrack.Mix__c);
                }
            }
        }

        MixService.updateMixFields(updatedMixIds);
    }

    private void handleMixUpdates(Map<Id, Track__c> trackMap)
    {
        Set<Id> mixIds = new Set<Id>();

        for (Track__c track : trackMap.values())
        {
            mixIds.add(track.Mix__c);
        }

        MixService.updateMixFields(mixIds);
    }

    private void handleTrackCount(Map<Id, Track__c> trackMap)
    {
        Set<Id> songIds = new Set<Id>();

        for (Track__c track : trackMap.values())
        {
            if (track.Song__c != null)
            {
                songIds.add(track.Song__c);
            }
        }

        SongService.updateSongFields(songIds);
    }

    private void handleTrackCount(Map<Id, Track__c> oldMap, Map<Id, Track__c> newMap)
    {
        Set<Id> songIds = new Set<Id>();

        for (Track__c newTrack : newMap.values())
        {
            Track__c oldTrack = oldMap.get(newTrack.Id);

            if (newTrack.Song__c != oldTrack.Song__c)
            {
                if (newTrack.Song__c != null)
                {
                    songIds.add(newTrack.Song__c);
                }

                if (oldTrack.Song__c != null)
                {
                    songIds.add(oldTrack.Song__c);
                }
            }
        }

        SongService.updateSongFields(songIds);
    }
}