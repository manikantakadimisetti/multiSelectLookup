global class CALSTA_Batch_Email_Notification implements Database.Batchable<sObject> {
    //Started Batch Class, Getting Request records list when status is Pending at Department for Revision and Date revision due back from dept greater than today
    global Database.QueryLocator start(Database.BatchableContext bc) {
        list <case> caseDetails = [select  id, Approve_Status__c  from case where Approve_Status__c IN ('Reviewed','Secretory Approval','Pending') limit 1];
       system.debug('caseDetails ++ '+ caseDetails);
        return Database.getQueryLocator('SELECT Id,Status,SubmittedById, (SELECT Id, ProcessNodeId, StepStatus, Comments, TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name, OriginalActor.Name ,CreatedBy.Name, ProcessNode.Name FROM StepsAndWorkitems where IsPending=true order by IsPending DESC, CreatedDate DESC ) FROM ProcessInstance where TargetObjectId IN: caseDetails   order by CreatedDate DESC ');

    }
    // Executing batch class and calling sendEmailNotification method
    global void execute(Database.BatchableContext bc, List<ProcessInstance> requests){
        system.debug('requests ++ '+ requests);
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
     private static  void sendEmailNotification(List<ProcessInstance> requests){     
		String templateId = '';
		String queueName = '';
        list <id>  recordTypeNames = new list<id>();
         list<case> caserecords = new list<case>();
         for (ProcessInstance pro : requests){
             for(ProcessInstanceHistory sWI:pro.StepsAndWorkitems) {
             recordTypeNames.add(sWI.TargetObjectId);
         }
         }
        system.debug('recordTypeNames>> '+ recordTypeNames); 
         if(recordTypeNames != null)
         caserecords = [Select Id,RecordType.Name from Case where id in:recordTypeNames];
         system.debug('caserecords>> '+ caserecords); 
		List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
		for(case request:caserecords){
          queueName = CALSTA_CustomUtils.queueListMap.get(request.RecordType.Name);
		   templateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Date_revision_due_back_from_Dept');
			
         if(templateId != null && queueName != null){   
             system.debug('templateId>> '+ templateId);
             system.debug('queueName>> '+ queueName);
		     List<GroupMember> groupMembers= CALSTA_CustomUtils.getGroupMembers(queueName);
             system.debug('groupMembers>>'+groupMembers);
             OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
 
             for(GroupMember groupMem:groupMembers){
                   Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, groupMem.UserOrGroupId, request.Id);
                   String  subject = email.getSubject();
                   String body = email.gethtmlBody();
                 system.debug('groupMem.UserOrGroupId >>'+ groupMem.UserOrGroupId);
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