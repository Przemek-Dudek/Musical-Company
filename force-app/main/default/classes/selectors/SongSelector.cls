public with sharing class SongSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>();
        
        fieldsList.add(Song__c.Id);
        fieldsList.add(Song__c.Name);
        fieldsList.add(Song__c.Genre__c);
        fieldsList.add(Song__c.Length__c);
        fieldsList.add(Song__c.Artist__c);

        return fieldsList;
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

    public static List<Song__c> selectByGenre(String genre, Integer offset)
    {
        SongSelector selector = new SongSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();

        if(genre != 'all')
        {
            queryFactory.setCondition('Genre__c = :genre');
        }
        queryFactory.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        queryFactory.setLimit(100);
        queryFactory.setOffset(offset*100);

        return (List<Song__c>) Database.query(queryFactory.toSOQL());
    }
}