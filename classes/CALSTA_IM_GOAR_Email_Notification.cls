/**
*--------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      07-OCT-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/
global class CALSTA_IM_GOAR_Email_Notification implements Database.Batchable<sObject> {
    //Started Batch Class, Getting Request records list when status is Pending at Department for Revision and Date revision due back from dept greater than today
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id,RecordType.Name from Case where Status = \'Pending at Department for Revision\' and Date_Revision_Due_Back_From_Dept__c != null and Date_Revision_Due_Back_From_Dept__c < TODAY');
    }
    // Executing batch class and calling sendEmailNotification method
    global void execute(Database.BatchableContext bc, List<Case> requests){
        sendEmailNotification(requests);
	}    
    
    global void finish(Database.BatchableContext bc){
       
    }   
    /**
     *  Sending Email Notification to  record type related Queue (When Date revision due back from dept greater than today)
     * _______________________________________________________________
     * 	 
	 *  @param     requests    List<Case>        
     * _________________________________________________________________
     * 
     */
     private static  void sendEmailNotification(List<Case> requests){     
		String templateId = '';
		String queueName = '';
		List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
		for(Case request:requests){
           queueName = CALSTA_CustomUtils.queueListMap.get(request.RecordType.Name);
		   templateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Date_revision_due_back_from_Dept');
			
         if(templateId != null && queueName != null){     
		     List<GroupMember> groupMembers= CALSTA_CustomUtils.getGroupMembers(queueName);
             OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
 
             for(GroupMember groupMem:groupMembers){
                   Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, groupMem.UserOrGroupId, request.Id);
                   String  subject = email.getSubject();
                   String body = email.gethtmlBody();
                   email.setTargetObjectId(groupMem.UserOrGroupId);
                   email.setSubject(subject);
                   email.sethtmlBody(body);
                  if(owa != null){
                     email.setOrgWideEmailAddressId(owa.id); 
                  }
                   email.saveAsActivity = false;    
                   singleEmailMessagesList.add(email);
              }
                        
         }
      }
         if(singleEmailMessagesList != null && singleEmailMessagesList.size()>0){
          Messaging.sendEmail(singleEmailMessagesList);  
         }    
     }
}