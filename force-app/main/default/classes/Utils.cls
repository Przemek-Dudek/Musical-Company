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
}