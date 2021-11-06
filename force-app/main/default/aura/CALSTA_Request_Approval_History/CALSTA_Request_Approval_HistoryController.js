({      
    /**
     * ____________________________________________________________________
     * 
	 *  This method is used for getting "Tracking History" details
	 * _____________________________________________________________________
	 * 	 	 
	 *  @param     recordId       String
     *__________________________________________________________________
	 */
    doProcess : function(component, event, helper) {      
        var Id = component.get("v.recordId"); 
        var action = component.get('c.getApprovalData');
        action.setParams({
            recId : Id
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();           
            if(state === 'SUCCESS')
            {
                var result = response.getReturnValue();
                component.set("v.approvalHistoryList", result.approvals);                
                component.set('v.showapprovalHistorySubmittedBy',result.approvalHistorySubmittedUser);                
                component.set('v.approvalsHistoryMap',result.approvalsMap);                
            }
            else
            {
                var errors = action.getError();
                if (errors)
                {                    
                    if (errors[0] && errors[0].message) {                        
                        console.log(errors[0].message);                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },  
    /**
     * ________________________________________________
     * 
	 *  This method is used for showing spinner
     *_________________________________________________
	 */
    showSpinner: function(component, event, helper) {     
        component.set("v.isSpinnerLoading", true); 
    }, 
    /**
     * ________________________________________________
     * 
	 *  This method is used for hiding spinner
     *_________________________________________________
	 */
    hideSpinner : function(component,event,helper){       
        component.set("v.isSpinnerLoading", false);
    },
    /**
     * ______________________________________________________________________________
     * 
	 *  This method is used for showing Tracking details when click on step name
     *_______________________________________________________________________________
	 */
    popupModal : function(component,event,helper)
    {        
        component.set("v.ispopupModalOpen", true);        
        var InstanceStepId = event.getSource().get('v.name');
        var approvalcustomArray = [];
        var conts = component.get('v.approvalsHistoryMap');
        for(var key in conts){
            if(key == InstanceStepId)
            {
                approvalcustomArray.push({value:conts[key], key:key});
            }        
        }
    	component.set("v.approvalsMapList", approvalcustomArray);               
    },
    /**
     * ______________________________________________________________________________
     * 
	 *  This method is used to close the popup modal
     *_______________________________________________________________________________
	 */
    popupcloseModel : function(component,event,helper)
    {
       
         component.set("v.ispopupModalOpen", false);
    },
    /**
     * ______________________________________________________________________________
     * 
	 *  This method is used for refreshing the "Tracking History" details
     *_______________________________________________________________________________
	 */
    refreshChild : function(component,event,helper)
    {
        var message = event.getParam("message");   
        var a = component.get('c.doProcess');
        $A.enqueueAction(a);
    },
   
})