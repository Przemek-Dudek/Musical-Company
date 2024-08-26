public with sharing class MixTriggerHandler extends TriggerHandlerBase
{
    protected override void onBeforeDelete()
    {
        deleteTracks((List<Mix__c>)Trigger.old);
    }

    private static void deleteTracks(List<Mix__c> mixes)
    {
        Set<Id> mixIds = Utils.getIdFieldValue(mixes, Consts.FIELD_ID);
        List<Track__c> tracks = TrackSelector.selectByMixId(mixIds);

        delete tracks;
    }
}