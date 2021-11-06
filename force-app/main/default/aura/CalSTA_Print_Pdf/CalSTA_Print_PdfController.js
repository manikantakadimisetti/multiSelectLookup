({
    /**
     * _________________________________________________________________________________________________________________________
     * 
	 *  This method is used for showing/hiding Constituent Concern and Goldenrod record types "Print PDF" details to the users	 
     *_________________________________________________________________________________________________________________________
	*/
    doInit : function(component, event, helper) {       
         var pdfAction = component.get("c.departmentUser");
         pdfAction.setCallback(this, function(response){  
            var state = response.getState();            
            if(state === 'SUCCESS')
            {       
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                     component.set('v.isShowPDF',true);
                }
            }
        });
        $A.enqueueAction(pdfAction); 
    }
})