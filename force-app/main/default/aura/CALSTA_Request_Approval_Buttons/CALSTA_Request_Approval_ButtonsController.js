({    
    /**
     * ________________________________________________________________________
     * 
	 *  This method is called when user clicked on "submit for approval" button
	 * ________________________________________________________________________
	 * 	 
	 *  @param     recordId       String
  	 *  @param     Comments  	  String    
     *__________________________________________________________________________
	*/
    submitforApprovalsubmitModel : function(component, event, helper) {        
        var recordId = component.get("v.recordId");             
        var submitforapprovecomments = component.find("submitforapprovecomments").get("v.value");       
        if(submitforapprovecomments == undefined || submitforapprovecomments == '' || submitforapprovecomments == null )
        {         
            component.find('submitforapprovecomments').showHelpMessageIfInvalid();
        }
        else
        {       
            let isSubmitButton = event.getSource();
            isSubmitButton.set("v.disabled",true);
            var approveAction1 = component.get("c.submitforApproveProcess");
            approveAction1.setParams({
                recordId : recordId,
                Comments : submitforapprovecomments
            });            
            approveAction1.setCallback(this, function(response){  
                 var state = response.getState();
                if(state === 'SUCCESS')
                {       
                    var returnValue = response.getReturnValue();                   
                    if(returnValue == true)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request has been Submitted for Approval",
                            "type" : "success"         
                        });
                        toastEvent.fire();                       
                        component.set("v.SubmitforApprovalModal", false); 
                    }
                    else if(returnValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "These required field(s) must be completed : Action Requested",
                            "type" : "error"         
                        });
                        toastEvent.fire();
                        component.set("v.SubmitforApprovalModal", false);
                    }      
                    var a = component.get('c.getApprovalStatus');
                    $A.enqueueAction(a);                    
                    var event = component.getEvent("refreshChildComponent");                   
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }               
                else if(state ==='ERROR')
                {                     
                    isSubmitButton.set("v.disabled",false);
                    component.set("v.SubmitforApprovalModal", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been Submitted for Approval",
                        "type" : "error"         
                    });
                    toastEvent.fire();                   
                }
            });
            $A.enqueueAction(approveAction1); 
        }       
    },
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Submit for Approval" Model
     * ________________________________________________________________________
	 */
    submitforApprovalcloseModel: function(component, event, helper) {     
        component.set("v.SubmitforApprovalModal", false);
    }, 
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Submit for Approval" Model
     * ________________________________________________________________________
	 */
    submitforApprovalopenModel : function(component, event, helper) { 
         // alert("ok");
        var btnLabel = event.getSource().get("v.label");
        component.set("v.ApprovalLabelName",btnLabel);        
        component.set("v.SubmitforApprovalModal", true);        
    },     
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "CalSTA Final Approval" Model
     * ________________________________________________________________________
	 */
    showFinalApproveModal : function(component, event, helper){        
        component.set("v.isFinalApprovalModalOpen", true); 
        var btnLabel = event.getSource().get("v.label");        
        component.set("v.ApprovalLabelName",btnLabel); 
    },
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Forward for Approval" Model
     * ________________________________________________________________________
	 */
    handleApproveModal: function(component, event, helper) {  
        component.set("v.isApprovalModalOpen", true);
        var btnLabel = event.getSource().get("v.label");
        component.set("v.ApprovalLabelName",btnLabel); 
    },  
     /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "CalSTA Final Approval" Model
     * ________________________________________________________________________
	 */
    ApprovalcloseModel: function(component, event, helper) {     
        component.set("v.isApprovalModalOpen", false);
    }, 
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "CalSTA Final Approval" Model
     * ________________________________________________________________________
	 */
    finalApprovalcloseModel: function(component, event, helper) {     
        component.set("v.isFinalApprovalModalOpen", false);
    }, 
    /**
     * ____________________________________________________________________
     * 
	 *  This method is called when user clicked on "Forward for Approval
	 * ____________________________________________________________________
	 * 	 
	 *  @param     recordId       String
  	 *  @param     Comments  	  String  
  	 *  @param     stage  	      String    
     * _____________________________________________________________________
	 */
    ApprovalsubmitDetails: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var approveComments = component.find("approvecomments").get("v.value");
        if(approveComments == undefined || approveComments == null || approveComments == '')
        {         
            component.find('approvecomments').showHelpMessageIfInvalid();
        }
        else
        {            
            let isApprovalSubmitButton = event.getSource();
            isApprovalSubmitButton.set("v.disabled",true);           
            var stageLevel ='reviewApproval';           
            var approveAction = component.get("c.ApproveProcess");
            approveAction.setParams({
                recordId : recordId,
                Comments : approveComments,
                stage : stageLevel
            });
            approveAction.setCallback(this, function(response){
                var state = response.getState();               
                if(state === 'SUCCESS')
                {                  
                     var returnValue = response.getReturnValue();
                    if(returnValue == true)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request sent for approval.",
                            "type" : "success"         
                        });
                        toastEvent.fire();                   
                        component.set("v.isApprovalModalOpen", false);                        
                        var a = component.get('c.getApprovalStatus');
                        $A.enqueueAction(a);                    
                        var event = component.getEvent("refreshChildComponent");                       
                        event.fire();
                        $A.get('e.force:refreshView').fire();
                    }else if(returnValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "These required field(s) must be completed : Action Requested",
                            "type" : "error"         
                        });
                        toastEvent.fire();
                        component.set("v.isApprovalModalOpen", false);     
                    }
                }
                else
                {
                    isApprovalSubmitButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been sent for approval",
                        "type" : "error"         
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(approveAction); 
        }        
    }, 
	/**
     * ____________________________________________________________________________________________________
     * 
	 *  This method is called when user clicked on CalSTA Final Approval" button
	 * _____________________________________________________________________________________________________
	 * 	 
	 *  @param     recordId       String
  	 *  @param     Comments  	  String  
  	 *  @param     stage  	      String  
     * _______________________________________________________________________________________________________
	 */    
    finalApprovalsubmitDetails: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var approveComments = component.find("finalapprovecomments").get("v.value");       
        if(approveComments == undefined || approveComments == null || approveComments == '')
        {         
            component.find('finalapprovecomments').showHelpMessageIfInvalid();
        }
        else
        {            
            let isApprovalSubmitButton = event.getSource();
            isApprovalSubmitButton.set("v.disabled",true);          
            var stageLevel ='finalApproval';            
            var approveAction = component.get("c.ApproveProcess");
            approveAction.setParams({
                recordId : recordId,
                Comments : approveComments,
                stage : stageLevel
            });
            approveAction.setCallback(this, function(response){
                var state = response.getState();               
                if(state === 'SUCCESS')
                {                  
                    var returnValue = response.getReturnValue();
                    if(returnValue == true)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request has been approved.",
                            "type" : "success"         
                        });
                        toastEvent.fire();                   
                        component.set("v.isFinalApprovalModalOpen", false);                        
                        var a = component.get('c.getApprovalStatus');
                        $A.enqueueAction(a);                    
                        var event = component.getEvent("refreshChildComponent");                       
                        event.fire();
                        $A.get('e.force:refreshView').fire();
                    }else if(returnValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "These required field(s) must be completed : Action Requested",
                            "type" : "error"         
                        });
                        toastEvent.fire();
                        component.set("v.isFinalApprovalModalOpen", false);     
                    }
                }
                else
                {
                    isApprovalSubmitButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been  Approved",
                        "type" : "error"         
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(approveAction); 
        }        
    },  
     /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Send for Revision" Model
     * ________________________________________________________________________
	 */
    RejectcloseModel: function(component, event, helper) {     
        component.set("v.isRejectModalOpen", false);
    },  
    /**
    * _______________________________________________________________________
    * 
    *  This method is called when user clicked on "Send for Revision" button
    * ________________________________________________________________________
    * 	 
    *  @param     recordId       String
    *  @param     Comments  	  String  
    *__________________________________________________________________________
    */
    RejectsubmitDetails: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");        
        var rejectComments = component.find("rejectComments").get("v.value"); 
        var dateRevisionReq = component.find("dateRevisionReq").get("v.value");
        //Mk send for revision
        var caseDateRecieved = component.get("v.caseData");
        var profileData = component.get("v.profileData");
   		console.log("Date recieved "+caseDateRecieved.Date_Received__c +"Revision date"+dateRevisionReq);
        var currentDate = new Date().toJSON().slice(0,10);
        console.log("Date code"+currentDate);
        if( profileData=='Department User' || dateRevisionReq == '' || dateRevisionReq == null || dateRevisionReq == undefined || dateRevisionReq <= caseDateRecieved.Date_Received__c || dateRevisionReq <= currentDate){
           var errorMsg;
            var toastEvent = $A.get("e.force:showToast");
            if(profileData=='Department User'){
                errorMsg = "Department Requestor can't enter Date revision due back from dept";            
            }
            else if(dateRevisionReq <= caseDateRecieved.Date_Received__c || dateRevisionReq <= currentDate){
               errorMsg = "Enter "+'"Date Revision Due Back From Dept" greater than today';
            }else{
              errorMsg = "Enter "+'"Date Revision Due Back From Dept"';
            }
             toastEvent.setParams({
                "title": "Error!",            
                "message": errorMsg,                
                "type" : "error",
                mode: 'dismissible',
                duration:'5000'
            });
            toastEvent.fire();
        } else if(rejectComments == undefined || rejectComments == null || rejectComments == ''){
            component.find('rejectComments').showHelpMessageIfInvalid();
        }
            else
            {
                console.log(component.find("editForm").submit());
                component.find("editForm").submit();
                let isRejectButton = event.getSource();
                isRejectButton.set("v.disabled",true);
                var rejectAction = component.get("c.RejectProcess");
                rejectAction.setParams({
                    recordId : recordId,
                    Comments : rejectComments
                    
                });
            rejectAction.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){  
                    var responeValue = response.getReturnValue();                   
                    if(responeValue == true){                          
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request sent for revision",
                            "type" : "success"         
                        });
                        toastEvent.fire();
                        component.set("v.isRejectModalOpen", false);                       
                    }
                    else if(responeValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Go Back to Details tab and enter "+'"Date Revision due back from Dept"',
                            "type" : "error", 
                           
                            
                        });
                        toastEvent.fire();
                        component.set("v.isRejectModalOpen", true);
                    }
                    var callMethod = component.get('c.getApprovalStatus');
                    $A.enqueueAction(callMethod);                    
                    var event = component.getEvent("refreshChildComponent");                    
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    isRejectButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been sent for revision",
                        "type" : "error"         
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(rejectAction); 
        }
    }, 
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Send for Revision" Model
     * ________________________________________________________________________
	 */
    RejectApproveModal: function(component, event, helper) {
        var btnLabel = event.getSource().get("v.label");
        component.set("v.ApprovalLabelName",btnLabel); 
        component.set("v.isRejectModalOpen", true);
    },  
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Forward for Review" Model
     * ________________________________________________________________________
	 */
    RejectcloseModel: function(component, event, helper) {     
        component.set("v.isRejectModalOpen", false);
    },      
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Forward for Review" Model
     * ________________________________________________________________________
	 */
    reassignopenModel: function(component, event, helper) {
       /* var btnLabel = event.getSource().get("v.label");
        component.set("v.ApprovalLabelName",btnLabel); 
        component.set("v.isreassigningModalOpen", true);
        component.set("v.selectedRecord"," ");*/
        var modalOpen = component.get("v.isreassigningModalOpen");
        
            
        if(modalOpen){
            component.set("v.isreassigningModalOpen", false);
            
        }else{            
        var action = component.get("c.getReviewers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
 				var revs = response.getReturnValue();
                component.set("v.ReviewersMap", revs);
                var items = [];
                for (var key in revs){
                    var item = {"label": revs[key].Name,"value": revs[key].Id};
                    items.push(item);
                }
               /* for (var i = 0; i < revs.length ; i++) {
                    var item = {"label": revs[i].Name,"value": revs[i].Id};
                    items.push(item);
                }*/
                component.set("v.ReviewersList", items);
            }
            else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
        
            component.set("v.isreassigningModalOpen", true);
        }
        

    },    
     /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Forward for Review" Model
     * ________________________________________________________________________
	 */
    reassigncloseModel: function(component, event, helper) { 
        component.set("v.isreassigningModalOpen", false);
        //27/8/2021 
        
        /*
        var modalOpen = component.get("v.isreassigningModalOpen");
        
        if(modalOpen){
            component.set("v.isreassigningModalOpen", false);
            
        }else{
            console.log("Testing");
        var action = component.get("c.fetchLookUpValuesForwardforReview");
            action.setParams({            
            'recId' : component.get('v.recordId')            
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
 				var revs = response.getReturnValue();
                component.set("v.ReviewersMap", revs);
                var items = [];
                for (var key in revs){
                    var item = {"label": revs[key].Name,"value": revs[key].Id};
                    items.push(item);
                }
                component.set("v.ForwardForReviewersList", items);
            }
            else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
        
            component.set("v.isAddingReviwersModalOpen", true);
        } */
        //End 27/8/2021
    }, 
    /**
     * _______________________________________________________________________
     * 
	 *  This method is called when user clicked on "Forward for Review" button
	 * ________________________________________________________________________
	 * 	 
	 *  @param     reassignTo     sObject
	 *  @param     recordId       String
  	 *  @param     comments  	  String   
     * __________________________________________________________________________
	 */
        Reassign: function(component, event, helper) {
        var approveUser = component.get("v.selectedRecord");
         var reassignComments = component.find("forwardReviewComments").get("v.value");        
        if(reassignComments == undefined || reassignComments == null || reassignComments == ''){
            component.find('forwardReviewComments').showHelpMessageIfInvalid();          
        }
        else{          
            let isReassignButton = event.getSource();
            isReassignButton.set("v.disabled",true);
            const action = component.get('c.ReassignProcess');
            action.setParams({
                comments : reassignComments,
                reassignTo : component.get("v.SelectedReviewer"),
                recordId : component.get("v.recordId")               
            });            
            action.setCallback(this, function(actionResult) {            
                const state = actionResult.getState();
                if(state === 'SUCCESS') 
                {                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Request has been Reassigned",
                        "type" : "success"         
                    });
                    toastEvent.fire();                    
                    component.set("v.isreassigningModalOpen", false);
                    var a = component.get('c.getApprovalStatus');
                    $A.enqueueAction(a);                    
                    var event = component.getEvent("refreshChildComponent");                    
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === 'ERROR') {
                    isReassignButton.set("v.disabled",false);   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Choose User",
                        "type" : "error"         
                    });
                    toastEvent.fire(); 
                    
                }      
				
            });
            $A.enqueueAction(action);
        }        
    }, 
    
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to get the "Reassign Users"
     * ________________________________________________________________________
	 */
    addReviewer: function(component, event, helper) {
        var approveUser = component.get("v.selectedRecord");
         var reassignComments = component.find("forwardReviewComments").get("v.value");        
        if(reassignComments == undefined || reassignComments == null || reassignComments == ''){
            component.find('forwardReviewComments').showHelpMessageIfInvalid();          
        }
        else{          
            let isReassignButton = event.getSource();
            isReassignButton.set("v.disabled",true);
            const action = component.get('c.AddReviewersProcess');
            action.setParams({
                comments : reassignComments,
                reassignTo : component.get("v.selectedRecord"),
                recordId : component.get("v.recordId")               
            });            
            action.setCallback(this, function(actionResult) {            
                const state = actionResult.getState();
                if(state === 'SUCCESS') 
                {                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Request has been Add Review",
                        "type" : "success"         
                    });
                    toastEvent.fire();                    
                    component.set("v.isAddingReviwersModalOpen", false);
                    var a = component.get('c.getApprovalStatus');
                    $A.enqueueAction(a);                    
                    var event = component.getEvent("refreshChildComponent");                    
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === 'ERROR') {
                    isReassignButton.set("v.disabled",false);   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Choose User",
                        "type" : "error"         
                    });
                    toastEvent.fire(); 
                    
                }      
				
            });
            $A.enqueueAction(action);
        }        
    },
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to get the "addReviewer Users"
     * ________________________________________________________________________
	 */

    ReassignhandleComponentEvent : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
    },   
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Re-Evaluate" Model
     * ________________________________________________________________________
	 */
    reevaluatedopenModel: function(component, event, helper) {
        component.set("v.isreEvaluatedModalOpen", true);
    },    
     /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Re-Evaluate" Model
     * ________________________________________________________________________
	 */
    reevaluatecloseModel: function(component, event, helper) { 
        component.set("v.isreEvaluatedModalOpen", false);
    },    
    /**
     * ________________________________________________________________
     * 
	 *  This method is called when user clicked on "Re-Evalute" button
	 * ________________________________________________________________
	 * 	 	 
	 *  @param     recordId       String
  	 *  @param     Comments  	  String   
     *__________________________________________________________________
	 */
    Reevaluated: function(component, event, helper) {
        var approveUser = component.get("v.selectedRecord");        
        var reassignComments = component.find("reevaluatecomments").get("v.value");
                
        if(reassignComments == undefined || reassignComments == 'null' || reassignComments == ''){
            component.find('reevaluatecomments').showHelpMessageIfInvalid();          
        }
        else{ 
            let isReevaluatedButton = event.getSource();
            isReevaluatedButton.set("v.disabled",true);
            
            const action = component.get('c.reEvaluateProcess');
            action.setParams({
                Comments : reassignComments,               
                recordId : component.get("v.recordId"),                
            });            
            action.setCallback(this, function(actionResult) {            
                const state = actionResult.getState();                
                if(state === 'SUCCESS') 
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Request sent for re-evaluation",
                        "type" : "success"         
                    });
                    toastEvent.fire();                    
                    component.set("v.isreEvaluatedModalOpen", false);
                    var a = component.get('c.getApprovalStatus');
                    $A.enqueueAction(a);                    
                    var event = component.getEvent("refreshChildComponent");                    
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === 'ERROR') {  
                    isReevaluatedButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been sent for re-evaluation",
                        "type" : "error"         
                    });
                    toastEvent.fire();  
                }                      
            });
            $A.enqueueAction(action);
        }        
    },
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to open the "Send for Secretary Approval" Model
     * ________________________________________________________________________
	 */
    secretoryApproveopenModel: function(component, event, helper) {     
        component.set("v.issecretaryApprovalModalOpen", true);
    },  
    /**
     * _______________________________________________________________________
     * 
	 *  This method is used to close the "Send for Secretary Approval" Model
     * ________________________________________________________________________
	 */
    SecretoryApprovalcloseModel: function(component, event, helper) {     
        component.set("v.issecretaryApprovalModalOpen", false);
    },  
     /**
     * _______________________________________________________________________
     * 
	 *  This method is called when user clicked on "Send for Secretary" button
	 * _______________________________________________________________________
	 * 	 	 
	 *  @param     recordId       String
  	 *  @param     Comments  	  String   
     * ________________________________________________________________________
	 */
    SecretoryApprovalsubmitDetails: function(component, event, helper) {              
        var approvalComments = component.find("secratoryapprovecomments").get("v.value");   
        if(approvalComments == undefined || approvalComments == '' || approvalComments == null )
        {         
            component.find('secratoryapprovecomments').showHelpMessageIfInvalid();          
        }else{
            let isSecretaryButton = event.getSource();
            isSecretaryButton.set("v.disabled",true);
            
            var action = component.get('c.secretoryApprovalProcess'); 
            action.setParams({               
                recordId : component.get("v.recordId"),
                Comments : approvalComments
            });            
            action.setCallback(this, function(actionResult) {            
                const state = actionResult.getState();               
                if(state === 'SUCCESS') 
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Request has been sent to Secretary's Approval",
                        "type" : "success"         
                    });
                    toastEvent.fire();                    
                    component.set("v.issecretaryApprovalModalOpen", false);
                    var a = component.get('c.getApprovalStatus');
                    $A.enqueueAction(a);        
                    var event = component.getEvent("refreshChildComponent");                    
                    event.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === 'ERROR') {
                    isSecretaryButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been sent to Secretary's Approval",
                        "type" : "error"         
                    });
                    toastEvent.fire();  
                }                      
            });
            $A.enqueueAction(action);        
        }           
    },    
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user clicked on "refresh icon" in the Tracking History Tab
     * __________________________________________________________________________________
	 */
    refreshParentCmp : function(component, event, helper)
    {
        var a = component.get('c.getApprovalStatus');
        $A.enqueueAction(a);        
        var event = component.getEvent("refreshChildComponent");        
        event.fire();        
    },       
     /**
     * _______________________________________________________________________
     * 
	 *  This method is called when user clicked on "Tracking History" Tab
     * ________________________________________________________________________
	 */
    getApprovalStatus : function(component, event, helper){        
        var action = component.get('c.getApprovalData');
        var recId = component.get('v.recordId');        
        action.setParams({
            recId : recId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();           
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var statusval  = result.actionStatus;
                
                helper.aprovalButtons(component);       
                helper.submitforAprovalButtonVisible(component);
                //Mk send for revision
                component.set('v.caseData',result.caseData);
                component.set('v.profileData',result.profileData);
                component.set('v.isImpalItRt', result.isIMPAL);   
                if(result.isConfidential){
					component.set('v.isConfidential',true);
                    console.log('===statusval-Confidential=='+statusval);
                    if(statusval ==='Not Started'){ 
                        component.set('v.isDraftStatus',true)
                    }else{
                        component.set('v.isDraftStatus',false);
                    }
                }
                 else {
                if(statusval === 'Draft')  
                {
                    component.set('v.isfinalApprovalStatus',false);
                    component.set('v.isReviewStatus',true);
                    component.set('v.isDraftStatus',false);
                }
                else if(statusval === 'Reviewed')  
                {
                    component.set('v.isSecretoryApprovalStatus',true);
                    component.set('v.isfinalApprovalStatus',true);
                    component.set('v.isReviewStatus',false);
                    component.set('v.isDraftStatus',false);
                }
                else if(statusval === 'Approved')  
                {
                    component.set('v.isfinalApprovalStatus',false);
                    component.set('v.isReviewStatus',false);
                    component.set('v.isDraftStatus',false);
                 }
                else if(statusval === 'Secretory Approval')
                {
                    component.set('v.isSecretoryApprovalStatus',false);
                    component.set('v.isfinalApprovalStatus',true);
                    component.set('v.isReviewStatus',false);
                    component.set('v.isDraftStatus',false);
                }
                 else if(statusval === 'Rejected')  
                 {
                     component.set('v.isfinalApprovalStatus',false);
                     component.set('v.isReviewStatus',false);
                     component.set('v.isDraftStatus',false);                  
                 }
                 else if(statusval ==='Not Started')
                 {
                     component.set('v.isDraftStatus',true);
                     component.set('v.isfinalApprovalStatus',false);
                     component.set('v.isReviewStatus',false);
                 }  
                }
                $A.get('e.force:refreshView').fire();
                
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Unknown error, please check with System Admin.",
                    "type" : "error"         
                }); 
            }            
        });
        $A.enqueueAction(action);
        
    
    },
    
      /**
     * _______________________________________________________________________
     * 
	 *  This method is called when user clicked on "Forward for Approve" button
	 * ________________________________________________________________________
	 * 	 
	 *  @param     reassignTo     sObject
	 *  @param     recordId       String
  	 *  @param     comments  	  String   
     * __________________________________________________________________________
	 */
    
    forwardapprovalReassign: function(component, event, helper) {
        var recordId = component.get("v.recordId");
		var approveUser = component.get("v.selectedRecord");
        var approveComments = component.find("Forwardapprovalcomments").get("v.value");       
        if(approveComments == undefined || approveComments == null || approveComments == '')
        {         
            component.find('Forwardapprovalcomments').showHelpMessageIfInvalid();
        }
        else
        {            
            let isApprovalSubmitButton = event.getSource();
            isApprovalSubmitButton.set("v.disabled",true);           
            var stageLevel ='reviewApproval';           
            var approveAction = component.get("c.forwardApprovalProcess");
            approveAction.setParams({
                recordId : recordId,
				reassignTo : component.get("v.selectedRecord"),
                stage : stageLevel,
                comments : approveComments
            });
            approveAction.setCallback(this, function(response){
                var state = response.getState();               
                if(state === 'SUCCESS')
                {                  
                     var returnValue = response.getReturnValue();
                    if(returnValue == true)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request sent for approval.",
                            "type" : "success"         
                        });
                        toastEvent.fire();                   
                        component.set("v.isApprovalModalOpen", false);                        
                        var a = component.get('c.getApprovalStatus');
                        $A.enqueueAction(a);                    
                        var event = component.getEvent("refreshChildComponent");                       
                        event.fire();
                        $A.get('e.force:refreshView').fire();
                    }else if(returnValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "These required field(s) must be completed : Action Requested",
                            "type" : "error"         
                        });
                        toastEvent.fire();
                        component.set("v.isApprovalModalOpen", false);     
                    }
                }
                else
                {
                    isApprovalSubmitButton.set("v.disabled",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Request has not been sent for approval",
                        "type" : "error"         
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(approveAction); 
        }        
    },
    
    
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user clicked on "Add Reviewers" button
     * __________________________________________________________________________________
	 */
    AddReviewerModal : function(component, event, helper)
    {
        var modalOpen = component.get("v.isAddingReviwersModalOpen");
        
            
        if(modalOpen){
            component.set("v.isAddingReviwersModalOpen", false);
            
        }else{            
        var action = component.get("c.getReviewers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
 				var revs = response.getReturnValue();
                component.set("v.ReviewersMap", revs);
                var items = [];
                for (var key in revs){
                    var item = {"label": revs[key].Name,"value": revs[key].Id};
                    items.push(item);
                }
               /* for (var i = 0; i < revs.length ; i++) {
                    var item = {"label": revs[i].Name,"value": revs[i].Id};
                    items.push(item);
                }*/
                component.set("v.ReviewersList", items);
            }
            else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
        
            component.set("v.isAddingReviwersModalOpen", true);
        }
        
    },       
    
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user clicked on "Reviewed" button
     * __________________________________________________________________________________
	 */
    reviewingModal : function(component, event, helper)
    {
   
        var modalOpen = component.get("v.isReviewingModalOpen");
        if(modalOpen){
            component.set("v.isReviewingModalOpen", false);
            
        }else{
            component.set("v.isReviewingModalOpen", true);
            
        }
    },  
    
     /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user clicked on "Reviewer Submit" button - VS
     * __________________________________________________________________________________
	 */
    ReviewingOnly : function(component, event, helper)
    {    
        console.log('==ReviewingOnly==');
        var recordId = component.get("v.recordId");             
        var submitforapprovecomments = component.find("reviewingcomments").get("v.value");       
        if(submitforapprovecomments == undefined || submitforapprovecomments == '' || submitforapprovecomments == null )
        {         
            component.find('reviewingcomments').showHelpMessageIfInvalid();
        }
        else
        {   
        	var action = component.get("c.reviewedProcess");
            action.setParams({
                recordId : recordId,
                Comments : submitforapprovecomments
            });
            action.setCallback(this, function(response){
                var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                //VS
                    if(returnValue == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Request Reviewd Successfully",
                            "type" : "success"         
                        });
                        toastEvent.fire();
                        component.set("v.isReviewingModalOpen",false);
                        var a = component.get('c.getApprovalStatus');
                        $A.enqueueAction(a);                    
                        var event = component.getEvent("refreshChildComponent");                       
                        event.fire();
                        $A.get('e.force:refreshView').fire();
                    }else if(returnValue == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error!",
                            "type" : "error"         
                        });
                        toastEvent.fire();
                        component.set("v.isReviewingModalOpen",false);
                    }
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when userselecting the reviewer
     * __________________________________________________________________________________
	 */
    onSelectReviewer : function(component, event, helper){
   		var revs =  component.get("v.ReviewersMap");
        var selectedId = event.getParam("value");
        var temp =  component.get("v.SelectedReviewers");
        var test=component.find("v.isReviewersAdded");
        component.set("v.SelectedReviewer", selectedId);
        var Notexist = true;
        for(var item of temp){
            if(item.name == selectedId){
                Notexist = false;
                break;
            }
        
        }
        if(Notexist){
            temp.push({
                type: 'icon',
                label: revs[selectedId].Name,
                name: selectedId,
                iconName: 'standard:user',
                alternativeText: 'User',
            });
            component.set("v.SelectedReviewers", temp);
            
        }
        
    },     
    
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user removes selected Reviewers
     * __________________________________________________________________________________
	 */
    RemoveSelected : function(component, event, helper){
        var removeId = event.getParam("item").name;
        console.log(removeId + ' pill was removed!');
        var items = component.get('v.SelectedReviewers');
        var item = event.getParam("index");
        component.set("v.addReviewerComboVal","");
        items.splice(item, 1);
        component.set('v.SelectedReviewers', items);
        
    },     
    /**
     * __________________________________________________________________________________
     * 
	 *  This method is called when user removes selected Reviewers
     * __________________________________________________________________________________
	 */
    AddingReviewers : function(component, event, helper){
       
        var items = component.get('v.SelectedReviewers');
        var recId = component.get("v.recordId");
        var approveComments = component.find("AddingReviewercomments").get("v.value"); 
        
        if(approveComments == undefined || approveComments == null || approveComments == "" || items == null || items =="" || items == undefined)
        { 
            component.find('ComboboxReviewers').showHelpMessageIfInvalid(); 
            component.find('AddingReviewercomments').showHelpMessageIfInvalid();
         }
        else
        {            
            var reqIds = [];
            for(var item of items){   
                console.log('=item.name='+item.name);
                reqIds.push(item.name);
            }
            var action = component.get("c.AddingReviewersToRequest");
            action.setParams({
               /* caseId : recId,
                reviewerIds : reqIds,
                comments : approveComments */
                comments : approveComments,
                caseId : recId,
                reviewerIds : reqIds
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("AddingReviewersToRequest: " + response.getReturnValue());
                    var processCompleted = response.getReturnValue();
                    if(processCompleted){
                        component.set("v.isAddingReviwersModalOpen", false);
                    }
                    //VS
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Successfully Added Reviewers",
                            "type" : "success"         
                        });
                        toastEvent.fire();           
                    var a = component.get('c.getApprovalStatus');
                        $A.enqueueAction(a);                    
                        var event = component.getEvent("refreshChildComponent");                       
                        event.fire();
                        $A.get('e.force:refreshView').fire();
                }
                else if (state === "ERROR") {
                    
                }
            });
            $A.enqueueAction(action);
        }
        
    },     
	     
})