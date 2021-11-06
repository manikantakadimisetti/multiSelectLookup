/**
* This Class is used to handle all emails sent based on status changes
*--------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      04-Sep-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/
public class CALSTA_RequestTriggerHelper{ 
    public static void RequestTriggerExecute(List<Case> triggerNew,Map<Id,Case> triggerNewMap,List<Case> triggerOld,Map<Id,Case> triggeroldMap,boolean isAfter,boolean isBefore,boolean isInsert,boolean isUpdate,boolean isDelete){
        if(isBefore && isInsert){
            updateDepartmentName(triggerNew);
            updateTrackingNumbers(triggerNew);
            statusChangedtoPendingatAgencyforCalSTADepartment(triggerNew,triggeroldMap);   
			//caseAssignToDepartmentIMC(triggerNew,triggeroldMap);
            updateReviewerField(triggerNew,triggeroldMap);
        }
        
        if(isBefore && isUpdate){       
            updateDepartmentName(triggerNew,triggeroldMap);
            //caseAssignToDepartmentIMC(triggerNew,triggeroldMap);
            statusChangedEmailTemplates(triggerNew,triggeroldMap);
            // caseAssignToGoarQueue(triggerNew,triggeroldMap);
            statusChangedtoPendingatAgencyforCalSTADepartment(triggerNew,triggeroldMap);
        }
        if(isAfter && (isInsert || isUpdate)){
             caseAssignToEmailNotification(triggerNew,triggeroldMap);
        } 
    }    
    
    
    /**
    * ________________________________________________________________
    * 
    *  To Update DepartmentName 
    * ________________________________________________________________
    * 	 
    *  @param    triggerNew    List<Case>
    *  @return   String  	 
    * __________________________________________________________________
    */
    private static void updateDepartmentName(List<Case> triggerNew){
        
        Map<Id,String> AccNameMap = new Map<Id,String>();
        for(Case cse:triggerNew){
            if(cse.AccountId != NUll) AccNameMap.put(cse.AccountId,'');
        }
        for(Account Acc:[Select  Id,Name from Account where Id IN:AccNameMap.keyset()]){
            AccNameMap.put(Acc.Id,Acc.Name);
        }
        for(Case cse:triggerNew){
            if(cse.AccountId != NUll) cse.DepartmentName__c = AccNameMap.get(cse.AccountId);
        }
    }
    
    /**
    * ________________________________________________________________
    * 
    *  To Update DepartmentName 
    * ________________________________________________________________
    * 	 
    *  @param    triggerNew    List<Case> , Map<Id,Case>
    *  @return   void  	 
    * __________________________________________________________________
    */
    private static void updateDepartmentName(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        List<Case> CaseList = new List<Case>();
        Map<Id,String> AccNameMap = new Map<Id,String>();
        for(Case cse:triggerNew){
            if(cse.AccountId != NUll && cse.AccountId != triggeroldMap.get(cse.Id).AccountId){
                CaseList.add(cse);
            } 
        }
        updateDepartmentName(CaseList);
    }
    
    /**
    * ________________________________________________________________
    * 
    *  To Generate CalSTA Tracking Number 
    * ________________________________________________________________
    * 	 
    *  @param    triggerNew    List<Case>
    *  @return   String  	 
    * __________________________________________________________________
    */
    private static void updateTrackingNumbers(List<Case> triggerNew){
        CALSTAConfiguration__c  calstaConfiguration= CALSTAConfiguration__c.getOrgDefaults();
        Integer currentTrackingNumberYear = Integer.valueOf(calstaConfiguration.Tracking_Number_Year__c);
        Integer lastTrackingNumber= Integer.valueOf(calstaConfiguration.Last_Tracking_Number__c);
        Map<ID,Schema.RecordTypeInfo> recordTypesMap = Case.sObjectType.getDescribe().getRecordTypeInfosById();      
        
        Map<String,String> requestRTAcronymsMap = CALSTA_CustomUtils.requestRTAcronymsMap;
        Integer currentYear =  System.today().Year();
        String trackingNumber = null;
        for(Case request:triggerNew){
            if(currentTrackingNumberYear <> currentYear){
                lastTrackingNumber = 1;
            }else{
                lastTrackingNumber++;
            }
            trackingNumber = String.valueOf(currentYear) +'-'+String.valueOf(lastTrackingNumber).leftPad(4, '0')+'-'+requestRTAcronymsMap.get(recordTypesMap.get(request.recordTypeID).getName());
            request.Tracking_Number__c = trackingNumber;
        }   
        calstaConfiguration.Tracking_Number_Year__c = String.valueOf(currentYear);
        calstaConfiguration.Last_Tracking_Number__c = String.valueOf(lastTrackingNumber);
        update calstaConfiguration;	
        
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  updating Case Owner as "CalSTA IMC" when GOAR Status is "Approved by CalSTA"
	 * ________________________________________________________________
	 * 	 
	 *  @param    triggerNew       List<Case>
	 *  @param    triggeroldMap    Map<Id,Case>  	  	 
     * _______________________________________________________________________________
	 */
   /* private static void caseAssignToGoarQueue(List<Case> triggerNew,Map<Id,Case> triggeroldMap){         
        String calstaGroupId = CALSTA_CustomUtils.queueIdsMap.get('CalSTA IMC');
        if(calstaGroupId != null){
            for(Case cs : triggerNew){
                String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getname();
                if(recordtypename == 'Governor’s Office Action Request (GOAR)' || recordtypename =='Governor’s Office Action Request (GOAR)-Scheduling' || recordtypename == 'Governor’s Office Action Request (GOAR)-Legal'){                       
                    if(cs.Status == 'Approved by CalSTA' && triggeroldMap.get(cs.ID).Status !='Approved by CalSTA'){
                        cs.ownerid = calstaGroupId;                               
                    }                                 
                }   
            }
        }
    }  */
    
    /**
    * ________________________________________________________________
    * 
    *  updating Case Owner as "Department IMC" when Goldenrod or Constituent Concern record types
    * ________________________________________________________________
    * 	 
    *  @param    triggerNew       List<Case>
    *  @param    triggeroldMap    Map<Id,Case>  	  	 
    * _______________________________________________________________________________
    */      
   /* private static void caseAssignToDepartmentIMC(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        Set<Id>  departmentSentToIds = new Set<Id>();
        for(Case cs : triggerNew){   
            if((cs.Department_Sent_To__c != null && triggeroldMap == null) || (cs.Department_Sent_To__c != null && triggeroldMap !=null && triggeroldMap.get(cs.ID).Department_Sent_To__c != cs.Department_Sent_To__c )){
                String recordTypdepartmentSentToIdseName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getname();
                      if(recordTypdepartmentSentToIdseName == 'Goldenrod' ||recordTypdepartmentSentToIdseName =='Constituent Concern' ){                           
                            departmentSentToIds.add(cs.Department_Sent_To__c);
                    }   
            }
        }	
        
        if(departmentSentToIds != null && departmentSentToIds.size() > 0){				
            List<Account> depatments = [Select Id,name from Account where Id in :departmentSentToIds];
            Map<Id,String> departmentNames = new Map<Id,String>();				
            for(Account department:depatments){
                departmentNames.put(department.Id,department.name);
            }				
            for(Case cs : triggerNew){
                String departName = departmentNames.get(cs.Department_Sent_To__c);
                String queueName = CALSTA_CustomUtils.queueListMap.get(departName);
                String queueId = CALSTA_CustomUtils.queueIdsMap.get(queueName);                                  	
                cs.ownerid = queueId; 
            }
        }
    } */
	
     /**
     * ________________________________________________________________
     * 
	 *  Sending emails to "Department IMC" when Goldenrod or Constituent Concern record types
	 * ________________________________________________________________
	 * 	 
	 *  @param    triggerNew       List<Case>
	 *  @param    triggeroldMap    Map<Id,Case>  	  	 
     * _______________________________________________________________________________
     */    
	 private static void caseAssignToEmailNotification(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        Set<Id>  departmentSentToIds = new Set<Id>();
        for(Case cs : triggerNew){   
            if((cs.Department_Sent_To__c != null && triggeroldMap == null) || (cs.Department_Sent_To__c != null && triggeroldMap !=null && triggeroldMap.get(cs.ID).Department_Sent_To__c != cs.Department_Sent_To__c )){
                String recordTypdepartmentSentToIdseName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getname();
                    if(recordTypdepartmentSentToIdseName == 'Goldenrod' ||recordTypdepartmentSentToIdseName =='Constituent Concern' ){                        
                        departmentSentToIds.add(cs.Department_Sent_To__c);
                    }
             }
        }	
        
        if(departmentSentToIds != null && departmentSentToIds.size() > 0){				
            List<Account> depatments = [Select Id,name from Account where Id in :departmentSentToIds];
            Map<Id,String> departmentNames = new Map<Id,String>();				
            for(Account department:depatments){
                departmentNames.put(department.Id,department.name);
            }				
            for(Case cs : triggerNew){
                String departName = departmentNames.get(cs.Department_Sent_To__c);
                String queueName = CALSTA_CustomUtils.queueListMap.get(departName);
                String queueId = CALSTA_CustomUtils.queueIdsMap.get(queueName);
                mailToDepartmentIMC(cs.Id,queueId);                   
            }
        }
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  when "Submitted to Go on" or "Received from Go on" status changed
	 * ________________________________________________________________
	 * 	 
	 *  @param    recordId       String
	 *  @param    queueId      	 String	 
     * _______________________________________________________________________________
	 */  
    private static void SubmittedandReceivedfromGOon(String recordId, String queueId)
    {
        String sendingtoTransmittalStatusTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_for_Transmittal_Document_Status_changed');
        String queueName = CALSTA_CustomUtils.queueNamesMap.get(queueId);        
        if(queueName != null){
            // Sending emails to queue members
            CALSTA_CustomUtils.sendEmailToQueue(sendingtoTransmittalStatusTemplate,queueName,recordId);           
        }
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  when status is changed to "Approved By CalSTA; Pending At GO" for GOAR record types
	 * ________________________________________________________________
	 * 	 
	 *  @param    recordId       String
	 *  @param    queueId      	 String	 
     * _______________________________________________________________________________
	 */ 
    private static void mailToCalstaIMC(String recordId, String queueId){          
        String sendingtoQueueTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_for_GOARs_changes_to_Approved_by_CalSTA');
        String queueName = CALSTA_CustomUtils.queueNamesMap.get(queueId);
        if(queueName!=null){    
            // Sending emails to queue members
            CALSTA_CustomUtils.sendEmailToQueue(sendingtoQueueTemplate,queueName,recordId);
        }  
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  when Department sent to field  value is Changed
	 *  and Sending emails to "Department IMC"
	 * ________________________________________________________________
	 * 	 
	 *  @param    recordId       String
	 *  @param    queueId      	 String	 
     * _______________________________________________________________________________
	 */     
    private static void mailToDepartmentIMC(String recordId, String queueId){
        String sendingtoDeptQueueTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_for_Constituent_Concern_Status_changed_to_Pending_at_Department');
        String queueName = CALSTA_CustomUtils.queueNamesMap.get(queueId);
        if(queueName!=null){    
            // Sending emails to queue members
            CALSTA_CustomUtils.sendEmailToQueue(sendingtoDeptQueueTemplate,queueName,recordId);
        }                
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Sending emails when status changed
	 * ________________________________________________________________
	 * 	 
	 *  @param    triggerNew       List<Case>
	 *  @param    triggeroldMap    Map<Id,Case>	 
     * _______________________________________________________________________________
	 */    
    private static void statusChangedEmailTemplates(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        for(Case cs : triggerNew){  
            String agencyUserProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;           
            if(agencyUserProfile == 'Agency User' ) {
                // Validation rule for agency user ("Agency user cannot change Status to completed manually if Action requested is Approval")
                if(cs.Approve_Status__c == 'Not Started' || cs.Approve_Status__c == 'Draft' || cs.Approve_Status__c == 'Reviewed' || cs.Approve_Status__c =='Secretory Approval'){
                    if(cs.Status == 'completed' && cs.Action_requested__c == 'Approval'){
                        cs.addError('Agency user cannot change Status to completed manually if Action requested is Approval.');
                    }
                }
            }         
            
            //  when status changed to Date Revision Due Back From Dept
            string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getname();
            if( (cs.Date_Revision_Due_Back_From_Dept__c != null && triggeroldMap.get(cs.ID).Date_Revision_Due_Back_From_Dept__c != cs.Date_Revision_Due_Back_From_Dept__c) && triggeroldMap.get(cs.ID).Date_Revision_Due_Back_From_Dept__c != null ){                              
                String requesterdateRevisionDueBackTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Date_revision_due_back_from_Dept_changed');
                 // Sending Email to Requestor
                CALSTA_CustomUtils.sendEmail(requesterdateRevisionDueBackTemplate,cs.CreatedById,cs.Id);
                /*Department IMC queue send email notification Mk*/
                    if(cs.AccountId != null && !cs.Confidential__c){
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                        System.debug('@@@	deptQueueName	@@@ 	'+deptQueueName);
                        CALSTA_CustomUtils.sendEmailToQueue(requesterdateRevisionDueBackTemplate, deptQueueName, cs.Id);
                    }
                /* Creating  Event for Requestor
                CALSTA_CustomUtils.createEventforUser(Userinfo.getUserId(), cs.Subject, cs.Tracking_Number__c);*/
            }
            
            //  when status changed to Pending at Department for Revision 
            if(cs.Status == 'Pending at Department for Revision' && triggeroldMap.get(cs.ID).Status != cs.Status){               
                String pendingatDeptTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Status_changed_to_Pending_at_Department_for_Revision');
                 String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
               
                // Sending Email to department queue members when status changed to "Pending at Department for Revision"
                if(cs.AccountId != null) {
                  if(deptQueueName != null){
                CALSTA_CustomUtils.sendEmailToQueue(pendingatDeptTemplate,deptQueueName,cs.Id);               
                /* Creating  Event for Requestor 
                CALSTA_CustomUtils.createEventforUser(Userinfo.getUserId(), cs.Subject, cs.Tracking_Number__c);*/
                
                    cs.Reviewer__c = deptQueueName;
                  }
               }  
            }                
            
             // when status changed to (Pending at GO) or (Pending at GO - Communications) for all IM's 
            if(recordtypename == 'Issue Memorandum (Audit)' || recordtypename == 'Issue Memorandum (General)'|| recordtypename == 'Issue Memorandum (Legislative Reports)'
               || recordtypename == 'Issue Memorandum (NCB)' || recordtypename == 'Issue Memorandum (Others)'  || recordtypename == 'Issue Memorandum (IM-PAL/IT)' || recordtypename == 'Issue Memorandum (Rulemaking)'){
                   String queueName = CALSTA_CustomUtils.queueListMap.get(recordtypename); //Realese A
                   
                   if(cs.Status == 'Pending at GO' && triggeroldMap.get(cs.ID).Status != cs.Status){
                       String pendingatGoandCommunicationsTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Status_changed_to_Pending_at_GO_Communications');
                       // Sending Email to Requestor
                       //1/9/2021 - Sending Emails to Confidential Submitted user 
                       if(cs.Confidential__c && cs.ConfidentialSubmitter__c != null){
                           CALSTA_CustomUtils.sendEmail(pendingatGoandCommunicationsTemplate,cs.ConfidentialSubmitter__c,cs.Id);
                       }else if(!cs.Confidential__c){
                           CALSTA_CustomUtils.sendEmail(pendingatGoandCommunicationsTemplate,cs.CreatedById,  cs.Id);
                       }
                   } 
                   //Realese A
                   if(cs.Status == 'Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){
                       String IMStausCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');

                       //    Map<Id,Set<String>> UsrEmailTemplate = Map<Id,Set<String>>();
					   // Sending email to Queue
                       if(queueName != null && !cs.Confidential__c){
                        //    for (Id usrid : CALSTA_CustomUtils.getActiveUserIdsFromQueueName(queueName)) {
                        //        if (UsrEmailTemplate.containsKey(usrid)) {
                        //             UsrEmailTemplate.get(usrid).add(IMStausCompletedTemplate);
                        //        } else {
                        //            // UsrEmailTemplate.put(usrid,new )
                        //        }
                        //    }
                           // Sending email to recordtype related queue
                           CALSTA_CustomUtils.sendEmailToQueue(IMStausCompletedTemplate, queueName, cs.Id);                    
                       }
                       //Sending Email to the Forward for Review Users when IM status as "Completed"
                       if(cs.forwadedReviewers__c != null){
                           List<String> userIds = cs.forwadedReviewers__c.split(',');
                           for(String userId : userIds){                             
                               CALSTA_CustomUtils.sendEmail(IMStausCompletedTemplate,userId,cs.Id);
                           }
                       }
                       String finalApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');
                       //Sending Email to the Approver Users when status as "Completed"                 
                       
                       if(!cs.Confidential__c && cs.Approvers__c != null){
                           List<String> userIds = cs.Approvers__c.split(',');
                           for(String userId : userIds){                                                            
                               CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userId, cs.Id);
                           }
                       }                    
                   }
                   //Realese A
               }            
            //Viswanath -->Added 'Governor’s Office Action Request (GOAR)-Legislative Reports' Record Type -30/7/2021
           // Sending emails while GOAR related status changed
            if(recordtypename == 'Governor’s Office Action Request (GOAR)' || recordtypename == 'Governor’s Office Action Request (GOAR)-Scheduling' || recordtypename == 'Governor’s Office Action Request (GOAR)-Legal' || recordtypename == 'Governor’s Office Action Request (GOAR)-Legislative Reports' ){           
                String calstaGroupId = CALSTA_CustomUtils.queueIdsMap.get('CalSTA IMC');  
                String GOARStatus = System.Label.Approved_By_CalSTA_Pending_At_GO;
                
                String queueName = CALSTA_CustomUtils.queueListMap.get(recordtypename);
                
                if(cs.Status == 'Pending at GO' && triggeroldMap.get(cs.ID).Status != cs.Status) {
                    String pendingStatusTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_for_Transmittal_Document_Status_changed');
                    //Viswanath - Sending mails to confidential queue and All Added Reviewers - 02/08/2021
                    if(cs.Confidential__c){
                    queueName = 'Review-Confidential Request';
                        if(cs.addReviewers__c!= null && cs.addReviewers__c!=''){
                            sendEmailToAddedReviewersUsers(cs,pendingStatusTemplate);
                        }
                        //1/9/2021 - Sending Emails to Confidental Submitted user when status changes to Pending at GO
                        if(cs.ConfidentialSubmitter__c !=null){
                          CALSTA_CustomUtils.sendEmail(pendingStatusTemplate,cs.ConfidentialSubmitter__c,cs.Id);  
                        }
                     }
                    if(queueName != null)
                    {
                        // Sending email to recordtype related queue
                        CALSTA_CustomUtils.sendEmailToQueue(pendingStatusTemplate, queueName, cs.Id);                    
                    }
                 /*Department IMC queue send email notification Mk*/
                 if(cs.AccountId != null && !cs.Confidential__c){
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                        CALSTA_CustomUtils.sendEmailToQueue(pendingStatusTemplate, deptQueueName, cs.Id);
                    }
                    
                }
                if(cs.Status == 'GO Approved; Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){
                    String goApprovedCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Status_changed_to_Returned_from_GO_Approved_Completed');
                    //1/9/2021 - Sending Emails Submitted Users for both Confidential and Non Confidential
                    if(cs.Confidential__c && cs.ConfidentialSubmitter__c != null){
                        CALSTA_CustomUtils.sendEmail(goApprovedCompletedTemplate,cs.ConfidentialSubmitter__c,cs.Id);
                    }else if(!cs.Confidential__c){
                        CALSTA_CustomUtils.sendEmail(goApprovedCompletedTemplate,cs.CreatedById,cs.Id);
                    }
                    /*Department IMC queue send email notification Mk*/
                    if(cs.AccountId != null && !cs.Confidential__c){
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                        System.debug('@@@	deptQueueName	@@@ 	'+deptQueueName);
                        CALSTA_CustomUtils.sendEmailToQueue(goApprovedCompletedTemplate, deptQueueName, cs.Id);
                    }
                   
                }
                if(cs.Status == 'GO Denied; Completed' && triggeroldMap.get(cs.ID).Status != cs.Status)
                {
                    String goDeniedCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Status_changed_to_Returned_from_GO_Denied_Completed');
                    // Sending email to requestor
                    //1/9/2021 - Sending Emails Submitted Users for both Confidential and Non Confidential
                    if(cs.Confidential__c && cs.ConfidentialSubmitter__c != null){
						CALSTA_CustomUtils.sendEmail(goDeniedCompletedTemplate,cs.ConfidentialSubmitter__c,cs.Id);
                    }else if(!cs.Confidential__c){
	                    CALSTA_CustomUtils.sendEmail(goDeniedCompletedTemplate,cs.CreatedById,cs.Id);
                    }
                    
                    /*Department IMC queue send email notification Mk*/
                    if(cs.AccountId != null && !cs.Confidential__c){
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                        System.debug('@@@	deptQueueName	@@@ 	'+deptQueueName);
                        CALSTA_CustomUtils.sendEmailToQueue(goDeniedCompletedTemplate, deptQueueName, cs.Id);
                    }
                   
                }
                if(cs.Status == GOARStatus && triggeroldMap.get(cs.ID).Status != cs.Status){
                    String goarApprovedbyCalSTATemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_Reviewer_For_status_of_GOARs_changes_to_Approved_by_CalSTA');
                    // Sending email to requestor
                    // 1/9/2021 - Added Non Confidential Check for Sending emails to Requestor
                   if(!cs.Confidential__c){
                        CALSTA_CustomUtils.sendEmail(goarApprovedbyCalSTATemplate,cs.CreatedById,cs.Id);
                    }
                    
                    if(!cs.Confidential__c && queueName !=null){
                        	CALSTA_CustomUtils.sendEmailToQueue(goarApprovedbyCalSTATemplate,queueName,cs.Id);
                    }
                    
                    //Viswanath - 02/08/2021
                    if(calstaGroupId != null && !cs.Confidential__c){
                        // calling mailToCalstaIMC method 
                        mailToCalstaIMC(cs.Id,calstaGroupId);
                    }
                    /*Department IMC queue send email notification Mk*/
                    if(cs.AccountId != null && !cs.Confidential__c){
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                        System.debug('@@@	deptQueueName	@@@ 	'+deptQueueName);
                        CALSTA_CustomUtils.sendEmailToQueue(goarApprovedbyCalSTATemplate, deptQueueName, cs.Id);
                    }
                     cs.Reviewer__c = 'CalSTA IMC';                   
                }
                if(cs.Status == 'Completed' && triggeroldMap.get(cs.ID).Status != cs.Status)
                {
                    String GOARStausCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');
                    // Sending email to Queue
                     if(queueName != null)
                    {
                        // Sending email to recordtype related queue
                        CALSTA_CustomUtils.sendEmailToQueue(GOARStausCompletedTemplate, queueName, cs.Id);                    
                    } 
                    //Sending Email to the Forward for Review Users when GOAR status as "Completed"                 
                    if(cs.forwadedReviewers__c != null){
                        List<String> userIds = cs.forwadedReviewers__c.split(',');
                        for(String userId : userIds){                             
                            CALSTA_CustomUtils.sendEmail(GOARStausCompletedTemplate,userId,cs.Id);
                        }
                    }
                    
                    String finalApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');
                    //Sending Email to the Approver Users when status as "Completed"                 
                    if(cs.Approvers__c != null){
                        List<String> userIds = cs.Approvers__c.split(',');
                        for(String userId : userIds){                                                            
                            CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userId, cs.Id);
                        }
                    }                    
                }
                if((cs.Submitted_to_the_GO_On__c != null && triggeroldMap.get(cs.ID).Submitted_to_the_GO_On__c != cs.Submitted_to_the_GO_On__c)  || (cs.Received_from_the_GO_on__c != null && triggeroldMap.get(cs.ID).Received_from_the_GO_on__c != cs.Received_from_the_GO_on__c)){
                    if(calstaGroupId != null){
                        // calling SubmittedandReceivedfromGOon method
                        SubmittedandReceivedfromGOon(cs.Id, calstaGroupId);
                    }
                }
            }  
            
            // while status changed to "Completed" for both GOAR and IM's
            if(recordtypename == 'Governor’s Office Action Request (GOAR)' || recordtypename == 'Governor’s Office Action Request (GOAR)-Scheduling' || recordtypename == 'Governor’s Office Action Request (GOAR)-Legal' ||
               recordtypename == 'Issue Memorandum (Audit)' || recordtypename == 'Issue Memorandum (General)'|| recordtypename == 'Issue Memorandum (Legislative Reports)'
               || recordtypename == 'Issue Memorandum (NCB)' || recordtypename == 'Issue Memorandum (Others)'  || recordtypename == 'Issue Memorandum (IM-PAL/IT)' || recordtypename == 'Issue Memorandum (Rulemaking)'){
                   if(cs.Status == 'Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){                       
                       String recordtypeApprovalCompleted = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requester_for_status_changed_to_Completed');
                       String recordtypeforInformationOnlyCompleted = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requester_for_status_changed_to_Completed2');
                     user u = [select profile.name from user WHERE Id =: cs.CreatedById];
                       
                       if(u.profile.name == 'Agency User'){
                           if(cs.Action_requested__c == 'Approval'){
                               // sending email to requestor when  action status is "Approval" 
                               if(!cs.Confidential__c){
                                   CALSTA_CustomUtils.sendEmail(recordtypeApprovalCompleted,cs.CreatedById,cs.Id); 
                               }
                           }
                           if (cs.Action_requested__c == 'For Information Only'){
                               // sending email to requestor when  action status is "For Information Only"
                               if(!cs.Confidential__c){
                                   CALSTA_CustomUtils.sendEmail(recordtypeforInformationOnlyCompleted,cs.CreatedById,cs.Id);
                               }
                           }
                       }
                       else
                       {           
                           String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                           
                           if(cs.AccountId != null) {
                               if (deptQueueName != null){
                                   if(cs.Action_requested__c == 'Approval'){
                                       // sending email to requestor when  action status is "Approval"     
                                       if(!cs.Confidential__c){                    
                                           CALSTA_CustomUtils.sendEmailToQueue(recordtypeApprovalCompleted,deptQueueName,cs.Id);
                                       }
                                   }
                                   if(cs.Action_requested__c == 'For Information Only'){
                                       // sending email to requestor when  action status is "For Information Only"
                                       if(!cs.Confidential__c){
                                           CALSTA_CustomUtils.sendEmailToQueue(recordtypeforInformationOnlyCompleted,deptQueueName,cs.Id);
                                       }
                                   }
                               }
                                 
                         }  
                           
                       }
                                              
                       cs.Reviewer__c = '';
                   }        
               }             
            
            String approvalQueueName = System.Label.Approver_Queue;
            if(cs.Status == 'GO Approved; CalSTA Action Pending' && triggeroldMap.get(cs.ID).Status != cs.Status){
                String goApprovedCalSTAPendingTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Status_changed_to_GO_Approved_CalSTA_Action_Pending');
                RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:cs.RecordTypeId];
                String queueName = CALSTA_CustomUtils.queueListMap.get(rtype.Name);
                if(cs.Confidential__c){
                    queueName = 'Review-Confidential Request';
                    if(cs.addReviewers__c!= null && cs.addReviewers__c!=''){
                            sendEmailToAddedReviewersUsers(cs,goApprovedCalSTAPendingTemplate);
                     }
                    //1/9/2021 - Sending Emails to Confidential Submitted user when status changes to GO Approved; CalSTA Action Pending
                    if(cs.ConfidentialSubmitter__c != null){
                        CALSTA_CustomUtils.sendEmail(goApprovedCalSTAPendingTemplate,cs.ConfidentialSubmitter__c,cs.Id);
                    }
                }
                CALSTA_CustomUtils.sendEmailToQueue(goApprovedCalSTAPendingTemplate, queueName, cs.Id);
                
                if(approvalQueueName != null && !cs.Confidential__c)
                {
                    // Sending email to approval queue when status changed to "GO Approved; CalSTA Action Pending" 
                    CALSTA_CustomUtils.sendEmailToQueue(goApprovedCalSTAPendingTemplate, approvalQueueName, cs.Id);
                }
                	/*Department IMC queue send email notification Mk*/
                if(cs.AccountId != null && !cs.Confidential__c){
                    String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
                    System.debug('@@@	deptQueueName	@@@ 	'+deptQueueName);
                    CALSTA_CustomUtils.sendEmailToQueue(goApprovedCalSTAPendingTemplate, deptQueueName, cs.Id);
                }
                
            }
            if(cs.Status == 'GO Denied; CalSTA Action Pending' && triggeroldMap.get(cs.ID).Status != cs.Status){
                String goDeniedCalSTAPendingTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Status_changed_to_GO_Denied_CalSTA_Action_Pending');
                RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:cs.RecordTypeId];
                String queueName = CALSTA_CustomUtils.queueListMap.get(rtype.Name);
                if(cs.Confidential__c){
                    queueName = 'Review-Confidential Request';
                    if(cs.addReviewers__c!= null && cs.addReviewers__c!=''){
                            sendEmailToAddedReviewersUsers(cs,goDeniedCalSTAPendingTemplate);
                     }
                }
                CALSTA_CustomUtils.sendEmailToQueue(goDeniedCalSTAPendingTemplate, queueName, cs.Id);
                if(approvalQueueName != null && !cs.Confidential__c)
                {
                    // Sending email to approval queue when status changed to "GO Denied; CalSTA Action Pending"
                    CALSTA_CustomUtils.sendEmailToQueue(goDeniedCalSTAPendingTemplate, approvalQueueName, cs.Id);
                }   
            }
            //Sending email to approval queue and reviewer queue when status change to "GO Approved; Completed" - Mk
            if(cs.Status == 'GO Approved; Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){
                String goApprovedCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Status_changed_to_GO_Approved_Completed');
                RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:cs.RecordTypeId];
                String queueName = CALSTA_CustomUtils.queueListMap.get(rtype.Name);
                if(cs.Confidential__c){
                    queueName = 'Review-Confidential Request';
                    if(cs.addReviewers__c!= null && cs.addReviewers__c!=''){
                            sendEmailToAddedReviewersUsers(cs,goApprovedCompletedTemplate);
                     }
                }
                CALSTA_CustomUtils.sendEmailToQueue(goApprovedCompletedTemplate, queueName, cs.Id); 
                if(approvalQueueName != null && !cs.Confidential__c)
                {
                    // Sending email to approval queue when status changed to "GO Approved; Completed"
                    CALSTA_CustomUtils.sendEmailToQueue(goApprovedCompletedTemplate, approvalQueueName, cs.Id);                    
                }   
            }
            //Sending email to approval queue and reviewer queue when status change to "GO Denied; Completed" -Mk
            if(cs.Status == 'GO Denied; Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){
                String goDeniedCalSTAPendingTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Status_changed_to_Go_Denied_Completed');
                RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:cs.RecordTypeId];
                String queueName = CALSTA_CustomUtils.queueListMap.get(rtype.Name);
                if(cs.Confidential__c){
                    queueName = 'Review-Confidential Request';
                    if(cs.addReviewers__c!= null && cs.addReviewers__c!=''){
                            sendEmailToAddedReviewersUsers(cs,goDeniedCalSTAPendingTemplate);
                     }
                }
                CALSTA_CustomUtils.sendEmailToQueue(goDeniedCalSTAPendingTemplate, queueName, cs.Id); 
                
                if(approvalQueueName != null && !cs.Confidential__c)
                {
                    // Sending email to approval queue when status changed to "GO Denied; Completed"
                    CALSTA_CustomUtils.sendEmailToQueue(goDeniedCalSTAPendingTemplate, approvalQueueName, cs.Id);
                }   
            }
           
            if(recordtypename == 'Goldenrod'){  
                String userProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;
                if(cs.Status == 'Pending at Agency' && triggeroldMap.get(cs.ID).Status != cs.Status){ 
                    if(userProfile == 'Department User'){
                        // Checking whether file is uploaded or not when status is "pending at agency" for Goldenrod (Department user)
                        List<ContentDocumentLink> files =  [SELECT ContentDocumentId,ShareType, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where Id=:cs.Id ) and LinkedEntity.Type='Case'];
                        if(files.size()>0){                        
                            Boolean isDepartmentUSer = false;
                            for(ContentDocumentLink file : files){        
                                List<ContentDocument> fileDescription = [SELECT Id, OwnerId, Title,CreatedById FROM ContentDocument where Id=: file.ContentDocumentId];
                                for(ContentDocument fileDesc : fileDescription){                                
                                    Profile p = [select Id, Name from Profile where Id in (select ProfileId from User where Id = :fileDesc.OwnerId)];
                                    if(p.Name == 'Department User'){
                                        isDepartmentUSer = true;
                                        String goldenrodStatusPendingatAgencyTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requester_for_Goldenrod_Status_Pending_at_Agency');
                                        // Sending email to requestor when status changed to "Pending at Agency"
                                        CALSTA_CustomUtils.sendEmail(goldenrodStatusPendingatAgencyTemplate,cs.CreatedById,  cs.Id);
                                    }                                
                                }                            
                            }
                            if(!isDepartmentUSer)
                            {
                                cs.addError('Please make sure to attach all the relevant files before changing the status.');
                            }
                        }
                        else
                        {
                            cs.addError('Please make sure to attach all the relevant files before changing the status');
                        }
                    }
                    else
                    {
                        String goldenrodStatusPendingatAgencyTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requester_for_Goldenrod_Status_Pending_at_Agency');
                        // Sending email to requestor when status changed to "Pending at Agency"
                        CALSTA_CustomUtils.sendEmail(goldenrodStatusPendingatAgencyTemplate,cs.CreatedById,  cs.Id);
                    }
                }
                if(cs.Status == 'Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){ 
                    if(userProfile == 'Agency User'){
                        // Checking whether file is uploaded or not when status is "Completed" for Goldenrod (Agency User)
                        List<ContentDocumentLink> files =  [SELECT ContentDocumentId,ShareType, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where Id=:cs.Id ) and LinkedEntity.Type='Case'];
                        if(files.size()>0){                        
                            Boolean isAgencyUSer = false;
                            for(ContentDocumentLink file : files){        
                                List<ContentDocument> fileDescription = [SELECT Id, OwnerId, Title,CreatedById FROM ContentDocument where Id=: file.ContentDocumentId];
                                for(ContentDocument fileDesc : fileDescription){                                
                                    Profile p = [select Id, Name from Profile where Id in (select ProfileId from User where Id = :fileDesc.OwnerId)];
                                    if(p.Name == 'Agency User'){
                                        isAgencyUSer = true;
                                        String goldenrodStatusCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Goldenrod');
                                         // Sending email to requestor when status changed to "Completed"
                                        CALSTA_CustomUtils.sendEmail(goldenrodStatusCompletedTemplate,cs.CreatedById,  cs.Id);    
                                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.Department_Sent_To__c);                                      
                                        String sendingtoUserTemplateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Goldenrod');
                                        if(cs.Department_Sent_To__c != null){
                                            if(deptQueueName != null)
                                            {
                                                // Sending email to department queue members when status changed to "Completed"
                                                CALSTA_CustomUtils.sendEmailToQueue(sendingtoUserTemplateId, deptQueueName, cs.Id);
                                            }
                                        }
                                    }                                
                                }                            
                            }
                            if(!isAgencyUSer)
                            {
                                cs.addError('Please make sure to attach all the relevant files before changing the status');
                            }
                        }
                        else
                        {
                            cs.addError('Please make sure to attach all the relevant files before changing the status');
                        }
                    }
                    else{
                        String goldenrodStatusCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Goldenrod');
                        // Sending email to requestor when status changed to "Completed"
                        CALSTA_CustomUtils.sendEmail(goldenrodStatusCompletedTemplate,cs.CreatedById,  cs.Id);                        
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.Department_Sent_To__c);                       
                        String sendingtoUserTemplateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Goldenrod');
                        if(cs.Department_Sent_To__c != null){
                            if(deptQueueName != null)
                            {
                                // Sending email to department queue members when status changed to "Completed"
                                CALSTA_CustomUtils.sendEmailToQueue(sendingtoUserTemplateId, deptQueueName, cs.Id);
                            }
                        }
                    }
                }
            }
 
            
            // Constituent Concern Related email templates - starts here
            if(recordtypename == 'Constituent Concern'){
                if(cs.Status == 'Completed' && triggeroldMap.get(cs.ID).Status != cs.Status){
                     String userProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;
                    if(userProfile == 'Department User'){
                        // Checking whether file is uploaded or not when status is "Completed" for Constituent Concern (Department User)
                        List<ContentDocumentLink> files =  [SELECT ContentDocumentId,ShareType, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where Id=:cs.Id ) and LinkedEntity.Type='Case'];
                        if(files.size()>0){                        
                            Boolean isDepartmentUSer = false;
                            for(ContentDocumentLink file : files){        
                                List<ContentDocument> fileDescription = [SELECT Id, OwnerId, Title,CreatedById FROM ContentDocument where Id=: file.ContentDocumentId];
                                for(ContentDocument fileDesc : fileDescription){                                
                                    Profile p = [select Id, Name from Profile where Id in (select ProfileId from User where Id = :fileDesc.OwnerId)];
                                    if(p.Name == 'Department User'){
                                        isDepartmentUSer = true;
                                        String ConstituentConcernStatusCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Constituent_Concern');
                                        // Sending email to requestor when status changed to "Completed" 
                                        CALSTA_CustomUtils.sendEmail(ConstituentConcernStatusCompletedTemplate, cs.CreatedById,  cs.Id);                                        
                                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.Department_Sent_To__c);                                       
                                        String sendingtoUserTemplateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Constituent_Concern');
                                        if(cs.Department_Sent_To__c != null){
                                            if(deptQueueName != null)
                                            {
                                                // Sending email to department queue members when status changed to "Completed"
                                                CALSTA_CustomUtils.sendEmailToQueue(sendingtoUserTemplateId, deptQueueName, cs.Id);
                                            }
                                        }
                                    }                                
                                }                            
                            }
                            if(!isDepartmentUSer)
                            {
                                cs.addError('Please make sure to attach all the relevant files before changing the status.');
                            }
                        }
                        else
                        {
                            cs.addError('Please make sure to attach all the relevant files before changing the status');
                        }
                    }                    
                    else
                    {
                        String ConstituentConcernStatusCompletedTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Constituent_Concern');
                        // Sending email to requestor when status changed to "Completed"
                        CALSTA_CustomUtils.sendEmail(ConstituentConcernStatusCompletedTemplate, cs.CreatedById,  cs.Id);                        
                        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.Department_Sent_To__c);
                       // String deptQueueName = CALSTA_CustomUtils.queueNamesMap.get(cs.OwnerId);                        
                        String sendingtoUserTemplateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Responder_requestor_Status_changed_to_completed_Constituent_Concern');
                        if(cs.Department_Sent_To__c != null){
                            if(deptQueueName != null)
                            {
                                 // Sending email to department queue members when status changed to "Completed"
                                CALSTA_CustomUtils.sendEmailToQueue(sendingtoUserTemplateId, deptQueueName, cs.Id);
                            }
                        }
                    }                    
                }                
            }
        }
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Changing status based on department sent to field
	 * ________________________________________________________________
	 * 	 
	 *  @param    triggerNew       List<Case>
	 *  @param    triggeroldMap    Map<Id,Case>	 
     * _______________________________________________________________________________
	 */    
    private static void statusChangedtoPendingatAgencyforCalSTADepartment(List<Case> triggerNew, Map<Id,Case> triggeroldMap){
        for(Case cs : triggerNew){           
            if((cs.Department_Sent_To__c != null && triggeroldMap == null) || (cs.Department_Sent_To__c != null && triggeroldMap !=null && triggeroldMap.get(cs.ID).Department_Sent_To__c != cs.Department_Sent_To__c )){
                String departmentsendtoName = CALSTA_CustomUtils.getDepartmentName(cs.Department_Sent_To__c);
                if(departmentsendtoName != null){
                    cs.Department_Sent_To_Name__c = departmentsendtoName;
                    if(departmentsendtoName == 'California State Transportation Agency' && cs.Status != 'completed'){
                        cs.Status = 'Pending at Agency';
                    }
                    else{
                        String userProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;                                   
                        if(userProfile == 'Department User' && cs.Status != 'completed'){
                            cs.Status = 'Pending at Agency';
                        }
                        else if((userProfile == 'Agency User' && cs.Status != 'completed') || (userProfile == 'System Administrator' && cs.Status != 'completed')){
                            cs.Status = 'Pending at Department';
                        }  
                    }
                }
            }
            
        }
    }    
 
	/**
     * ________________________________________________________________
     * 
	 *  Updating reviewer field
	 * ________________________________________________________________
	 * 	 
	 *  @param    triggerNew       List<Case>
	 *  @param    triggeroldMap    Map<Id,Case>	 
     * _______________________________________________________________________________
	 */    
    private static void updateReviewerField(List<Case> triggerNew,Map<Id,Case> triggeroldMap){
        for(Case cs : triggerNew){
           String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(cs.AccountId);
            if(deptQueueName != null){
                cs.Reviewer__c = deptQueueName;
            }
        }
    }
    //Viswanath - Sending Mails to Added Reviewers Method. - 01/08/2021
    public static void sendEmailToAddedReviewersUsers(Case cs,String EmailTemplate) {
        List<String> usersToSend = new List<String>();
        if(cs.addReviewers__c != null) {
            List<String> reviewers = cs.addReviewers__c.split(',');
            for(String reviewer : reviewers) {
                if(reviewer.startsWith('005')) {
                    usersToSend.add(reviewer);
                }
            }
        }
        // Sending email to requestor & reviewers
        //usersToSend.add(cs.CreatedById);
        for(String userId : usersToSend) {
            CALSTA_CustomUtils.sendEmail(EmailTemplate,userId,cs.Id);
        }
    }
}