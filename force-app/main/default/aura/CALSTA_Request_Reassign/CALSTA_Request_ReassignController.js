({
   /**
     * ____________________________________________________________________
     * 
	 *  This method is used for getting "Re-assigning" Users list
     *__________________________________________________________________
	 */
   onfocus : function(component,event,helper){      
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');           
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    /**
     * ____________________________________________________________________
     * 
	 *  This method is used for showing "Re-assigning" Users list as Empty
     *_____________________________________________________________________
	 */
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
     /**
     * ____________________________________________________________________________________________
     * 
	 *  This method is used for showing "Re-assigning" Users list while key pressed in the input field
     *_____________________________________________________________________________________________
	 */
    keyPressController : function(component, event, helper) {
         var getInputkeyWord = component.get("v.SearchKeyWord");
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},    
    /**
     * _____________________________________________________________
     * 
	 *  This method is used for clearing "Re-assigning" Users list 
     *______________________________________________________________
	 */
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField");        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },   
     /**
     * _____________________________________________
     * 
	 *  This method is called when event fired 
     *______________________________________________
	 */
    handleComponentEvent : function(component, event, helper) {	 
        var selectedUsersFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedUsersFromEvent);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');  
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    },
})