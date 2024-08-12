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
        fieldsList.add(Song__c.Track_Count__c);
        fieldsList.add(Song__c.Track_Licenses__c);
        fieldsList.add(Song__c.Is_Active__c);

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
        return (List<Song__c>) Database.query(queryFactory.setCondition('Id IN :ids')
            .addOrdering(Consts.FIELD_NAME, fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
    }

    public static List<Song__c> selectByGenre(String genre, Integer offset)
    {
        SongSelector selector = new SongSelector();

        fflib_QueryFactory queryFactory = selector.newQueryFactory();

        if(genre != Consts.GENRE_ALL)
        {
            queryFactory.setCondition('Genre__c = :genre');
        }
        queryFactory.addOrdering(Consts.FIELD_NAME, fflib_QueryFactory.SortOrder.ASCENDING);
        queryFactory.setLimit(Consts.PAGINATION_BATCH_SIZE);
        queryFactory.setOffset(offset*Consts.PAGINATION_BATCH_SIZE);

        return (List<Song__c>) Database.query(queryFactory.toSOQL());
    }

    public static AggregateResult numberOfRecords(String genre)
    {
        String query = 'SELECT COUNT(Id) n FROM Song__c';

        if (genre != Consts.GENRE_ALL)
        {
            query += ' WHERE Genre__c = :genre';
        }

        return Database.query(query);
    }
}