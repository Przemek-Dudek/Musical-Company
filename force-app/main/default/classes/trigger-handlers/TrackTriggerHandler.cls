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
        
    }

    protected override void onAfterUpdate()
    {
        
    }

    protected override void onAfterDelete()
    {
        
    }

    protected override void onAfterUnDelete()
    {
        checkIfMaxTrackAmountPerMixWasHit();
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
        }

        MixService.updateMixFields(updatedMixIds);
    }
}