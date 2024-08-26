//UNUSED, JUST AN EXAMPLE
public with sharing class MixSharing
{
    public static boolean shareRecord(Id recordId, Id userId)
    {
        Mix__Share share = new Mix__Share();

        share.ParentId = recordId;
        share.UserOrGroupId = userId;
        share.AccessLevel = Consts.EDIT_ACCESS_LEVEL;

        Database.SaveResult result = Database.insert(share, false);

        if (!result.isSuccess())
        {
            System.debug('Error: ' + result.getErrors());
            return false;
        }

        return true;
    }
}