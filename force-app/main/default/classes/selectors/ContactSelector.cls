public with sharing class ContactSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField>(Contact.SObjectType.getDescribe().fields.getMap().values());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Contact.SObjectType;
    }

    public static List<Contact> selectById(Set<Id> contactIds)
    {
        ContactSelector selector = new ContactSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();
        return (List<Contact>) Database.query(queryFactory.setCondition('Id IN :contactIds').toSOQL());
    }
}