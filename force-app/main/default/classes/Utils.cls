public with sharing class Utils
{
    public static Set<Id> getIdFieldValue(List<SObject> records, String fieldName)
    {
        Set<Id> values = new Set<Id>();
        for (SObject record : records)
        {
            Id value = (Id)record.get(fieldName);
            if(value != null)
            {
                values.add(value);
            }
        }

        return values;
    }

    public static Map<Id, List<sObject>> getParentIdToChildrenMapping(List<sObject> childrenRecords, String fieldName) {
        Map<Id, List<sObject>> mappingResult = new Map<Id, List<sObject>>();
    
        for (sObject sObjectRecord : childrenRecords) {
            Id parentId = (Id)sObjectRecord.get(fieldName);
            if (parentId != null) {
                if (mappingResult.get(parentId) == null) {
                    mappingResult.put(parentId, new List<sObject>());
                }
    
                mappingResult.get(parentId).add(sObjectRecord);
            }
        }
    
        return mappingResult;
    }
}