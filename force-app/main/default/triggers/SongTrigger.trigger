trigger SongTrigger on Song__c (before delete, after update)
{
    SongTriggerHandler handler = new SongTriggerHandler();
    handler.run();
}