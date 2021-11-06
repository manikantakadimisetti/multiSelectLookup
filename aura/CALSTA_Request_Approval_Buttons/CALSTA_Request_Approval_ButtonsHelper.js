({
    /**
     * _____________________________________________________________________________________
     * 
	 *  This method is used for showing/hiding "Tracking History" buttons  to the users
	 * _____________________________________________________________________________________
	 * 	 	 
	 *  @param     recordId       String
     *______________________________________________________________________________________
	 */
	aprovalButtons: function(component, event, helper) {           
			let actionCustom = component.get('c.buttonsDisplay');
        	var recId = component.get('v.recordId');
            actionCustom.setParams({
                recordId : recId 
            });
			actionCustom.setCallback(this, function(response) {
				let state = response.getState();
				if (state === 'SUCCESS') {
                    var ButtonsWrapper = response.getReturnValue();     
                    console.log('=ButtonsWrapper=='+  JSON.stringify(ButtonsWrapper));
                    
					component.set('v.submittingbuttons', ButtonsWrapper.VisibleButtonsNC);
					component.set('v.showReviewed', ButtonsWrapper.CReviewed);
					component.set('v.showAddReviewers', ButtonsWrapper.CAddReviewer);
					component.set('v.showFinalApproval', ButtonsWrapper.CFinalApprover);
				}               
			});
			$A.enqueueAction(actionCustom);
	},
    /**
     * ________________________________________________________________________________
     * 
	 *  This method is used for showing/hiding "Submit for approval" button to the user
	 * ________________________________________________________________________________
	 * 	 	 
	 *  @param     recordId       String
     *_________________________________________________________________________________
	 */
    submitforAprovalButtonVisible: function(component, event, helper) {           
			let submiforApprovalAction = component.get('c.submitforApprovalButtonDisplay');
        	var recId = component.get('v.recordId');
            submiforApprovalAction.setParams({
                recordId : recId 
            });
			submiforApprovalAction.setCallback(this, function(response) {
				let state = response.getState();
				if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.isSubmitforApprovalbuttonVisible',result);                    
				}               
			});
			$A.enqueueAction(submiforApprovalAction);
	},

})