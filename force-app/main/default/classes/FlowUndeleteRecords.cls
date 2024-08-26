public with sharing class FlowUndeleteRecords
{
    @InvocableMethod(label='Undelete Records' description='Undelete records from the Recycle Bin')
    public static void UndeleteRecords(List<Id> recordIds)
    {
        if(recordIds.isEmpty())
        {
            return;
        }

        Database.undelete(recordIds);
    }
}