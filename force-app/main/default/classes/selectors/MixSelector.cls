public with sharing class MixSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField>(Mix__c.SObjectType.getDescribe().fields.getMap().values());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Mix__c.SObjectType;
    }

    public static List<Mix__c> selectByMixId(Set<Id> mixIds)
    {
        MixSelector selector = new MixSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Mix__c>) Database.query(queryFactory.setCondition('Id IN :mixIds').toSOQL());
    }
}