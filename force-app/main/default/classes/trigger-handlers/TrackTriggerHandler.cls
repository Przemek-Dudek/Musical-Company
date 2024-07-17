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
        handleMixUpdates(null, (Map<Id, Track__c>)Trigger.newMap);
    }

    protected override void onAfterUpdate()
    {
        handleMixUpdates((Map<Id, Track__c>)Trigger.oldMap, (Map<Id, Track__c>)Trigger.newMap);
    }

    protected override void onAfterDelete()
    {
        
    }

    protected override void onAfterUnDelete()
    {
        checkIfMaxTrackAmountPerMixWasHit();
        handleMixUpdates(null, (Map<Id, Track__c>)Trigger.newMap);
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
            if (oldMap == null)
            {
                updatedMixIds.add(newTrack.Mix__c);
                continue;
            }

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

        System.debug('updatedMixIds: ' + updatedMixIds);

        MixService.updateMixFields(updatedMixIds);
    }
}