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
}