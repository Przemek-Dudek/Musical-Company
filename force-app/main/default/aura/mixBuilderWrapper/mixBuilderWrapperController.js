({
    doInit: function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var contactId = helper.getRecordIdFromPageRef(pageRef);
        
        component.set("v.contactId", contactId);
    }
})
