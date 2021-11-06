({
    /**
     * _____________________________________________________________________________________________________
     * 
	 *  This method is used for showing/hiding IM and GOAR record types "Print PDF" details to the users	 
     *______________________________________________________________________________________________________
	*/
	doInit: function(component) {       
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