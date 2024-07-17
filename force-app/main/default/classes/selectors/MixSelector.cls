public with sharing class MixSelector
{
    public static Set<Id> selectFullMixIds(Set<Id> mixIds)
    {
        //found no way to implement this in fflib
        List<AggregateResult> queryRes = [SELECT Mix__c FROM Track__c GROUP BY Mix__c HAVING COUNT(Id) > :Consts.MAX_TRACKS_PER_MIX AND Mix__c IN :mixIds];
        
        Set<Id> fullMixesIds = new Set<Id>();

        for (AggregateResult res : queryRes)
        {
            fullMixesIds.add((Id)res.get('Mix__c'));
        }

        return fullMixesIds;
    }
}