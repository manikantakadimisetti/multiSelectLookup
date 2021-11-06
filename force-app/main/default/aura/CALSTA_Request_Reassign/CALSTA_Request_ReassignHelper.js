({
     /**
     * _____________________________________________________________
     * 
	 *  This method is used for getting  "Re-assigning" Users list 
	 * _____________________________________________________________
	 * 
	 * @param    searchKeyWord     string
	 * @param    recId             Id
     *______________________________________________________________
	 */
	searchHelper : function(component,event,getInputkeyWord) {
     var action = component.get("c.fetchLookUpValues");
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