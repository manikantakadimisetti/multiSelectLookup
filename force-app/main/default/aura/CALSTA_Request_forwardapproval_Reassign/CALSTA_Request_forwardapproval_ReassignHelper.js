({
    /**
     * _____________________________________________________________
     * 
	 *  This method is used for getting  "Forward for Approval" Users list 
	 * _____________________________________________________________
	 * 
	 * @param    searchKeyWord     string
	 * @param    recId             Id
     *______________________________________________________________
	 */
    
    
    searchHelperforapproval : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchLookUpValuesforwardapproval");
        action.setParams({
            'searchKeyWord': getInputkeyWord,            
            'recId' : component.get('v.recordId')            
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();              
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            } 
        });
        $A.enqueueAction(action);    
    },
})