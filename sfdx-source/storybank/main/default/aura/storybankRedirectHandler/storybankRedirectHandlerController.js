({
	doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
    },
    onPageReferenceChanged: function(cmp, event, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        cmp.set("v.recordId", recordId);
        $A.get('e.force:refreshView').fire();
    }
})