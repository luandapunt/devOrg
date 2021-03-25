({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteLine");
        action.setParams({
            quoteLineId : component.get("v.quoteLineId")
        });
        action.setCallback(this, function(response){
            component.set("v.quoteLine", response.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})