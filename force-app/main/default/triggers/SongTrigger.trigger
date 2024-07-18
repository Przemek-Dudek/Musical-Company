trigger SongTrigger on Song__c (after update)
{
    SongTriggerHandler handler = new SongTriggerHandler();
    handler.run();
}