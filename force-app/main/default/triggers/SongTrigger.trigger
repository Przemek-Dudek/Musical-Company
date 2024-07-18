trigger SongTrigger on Song__c (after update, after delete)
{
    SongTriggerHandler handler = new SongTriggerHandler();
    handler.run();
}