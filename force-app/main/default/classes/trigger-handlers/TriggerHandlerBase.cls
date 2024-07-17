public abstract class TriggerHandlerBase
{
    public void run()
    {
        if (Trigger.isBefore)
        {
            if (Trigger.isInsert)
            {
                onBeforeInsert();
            }
            else if (Trigger.isUpdate)
            {
                onBeforeUpdate();
            }
            else if (Trigger.isDelete)
            {
                onBeforeDelete();
            }
        }
        else if (Trigger.isAfter)
        {
            if (Trigger.isInsert)
            {
                onAfterInsert();
            }
            else if (Trigger.isUpdate)
            {
                onAfterUpdate();
            }
            else if (Trigger.isDelete)
            {
                onAfterDelete();
            }
            else if (Trigger.isUndelete)
            {
                onAfterUndelete();
            }
        }
    }

    protected virtual void onBeforeInsert() {}

    protected virtual void onBeforeUpdate() {}

    protected virtual void onAfterUpdate() {}

    protected virtual void onBeforeDelete() {}

    protected virtual void onAfterInsert() {}

    protected virtual void onAfterDelete() {}

    protected virtual void onAfterUndelete() {}
}