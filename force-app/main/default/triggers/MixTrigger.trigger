trigger MixTrigger on Mix__c (before delete, after undelete)
{
    MixTriggerHandler handler = new MixTriggerHandler();
    handler.run();
}