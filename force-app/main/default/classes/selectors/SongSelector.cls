public with sharing class SongSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField>(Song__c.SObjectType.getDescribe().fields.getMap().values());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Song__c.SObjectType;
    }

    public static List<Song__c> selectById(Set<Id> ids)
    {
        SongSelector selector = new SongSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Song__c>) Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
    }
}