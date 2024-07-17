trigger TrackTrigger on Track__c (before insert, before update, after insert, after update, after delete, after undelete)
{
    TrackTriggerHandler handler = new TrackTriggerHandler();
    handler.run();
}