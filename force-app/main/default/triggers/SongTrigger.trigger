trigger SongTrigger on Song__c (before delete, after delete, after update, after undelete)
{
    SongTriggerHandler handler = new SongTriggerHandler();
    handler.run();
}