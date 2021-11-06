/**
* This Class is used to display the Approval Process List and Approval Button Actions for both GOAR and IM's
*-------------------------------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      07-OCT-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/
public without sharing class  CalSTA_RequestApprovalProcessController {
    /* public Case currentRequest;
public CalSTA_RequestApprovalProcessController(ApexPages.StandardController controller) {
currentRequest = (Case)controller.getRecord();  
}
public void approvalProcessValidation() 
{
try {
String profileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].Name;
Case request = [SELECT Id,RecordType.Name,status,Type,Revision_of_Previous_version__c FROM Case WHERE Id = :currentRequest.Id];
if(request.Status == 'Pending at Agency'){
if(request.Type == null ){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '"Action Requested" field requied to submit for the approval.'));
}else{
List<ProcessInstance> pi = [select Id,TargetObjectId,status from ProcessInstance where TargetObjectId =: request.Id ORDER BY CreatedDate desc limit 1];
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setComments('Submitting request for review.');
req.setObjectId(request.id);
Approval.ProcessResult processResults = null;
processResults = Approval.process(req, true);
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, system.label.Successfully_submitted_for_Approval));
}
}
}catch(DmlException de){
Integer numErrors = de.getNumDml();
Set<Id> ids = new Set<Id>();
for(Integer i=0;i<numErrors;i++) {
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, de.getDmlMessage(i)));
}
}catch (Exception e) {            
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
}
} */
    
    /**
* ________________________________________________________________
* 
*  This method is used for getting approval process data 
* ________________________________________________________________
* 	 
*  @param    recId              Id
*  @return   WrapperClass  	 
*__________________________________________________________________
*/
    @AuraEnabled  
    public static ApprovalHistoryWrapper getApprovalData(Id recId){      
        Id recordId = recId;  
        //Mk added Date_Received__c field in soql using send for revision
        Case ApprovalStatus = [SELECT Id,Approve_Status__c,Confidential__c,Reviewed_Comment_History__c,RecordTypeId,addReviewers__c,Date_Received__c FROM Case WHERE Id =: recId limit 1];
        
        String  actionStatusVal = ApprovalStatus.Approve_Status__c;     
        String approvalHistorySubmittedByUser='';
        List<ApprovalHistory> approvals = new List<ApprovalHistory>();
        MAP<ID,ApprovalHistory> approvalsMap = new MAP<ID, ApprovalHistory>();       
        ApprovalHistoryWrapper approvalResultForObject = new ApprovalHistoryWrapper(); 
        //Mk
        List<ProcessInstance> ProceessInsta = [SELECT Id, (SELECT Id,Actor.Name FROM StepsAndWorkitems where Actor.Name=:System.Label.Approver_Queue_Two ) FROM ProcessInstance where TargetObjectId =: recId];
        String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(ApprovalStatus.RecordTypeId).getname();
        //Mk adding case record into wrapper class using send for revison
        approvalResultForObject.caseData = ApprovalStatus;
        approvalResultForObject.profileData = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        approvalResultForObject.RecordTypeId = ApprovalStatus.RecordTypeId;
        if(recordTypeName == 'Issue Memorandum (IM-PAL/IT)'){
            approvalResultForObject.isIMPAL = true; 
        }
        
        if(ApprovalStatus.Confidential__c){
            Map<String, Object> ReviewComments = new Map<String, Object>();
            if(ApprovalStatus.Reviewed_Comment_History__c != Null){
                ReviewComments = (Map<String, Object>) Json.deserializeUntyped(ApprovalStatus.Reviewed_Comment_History__c);
            }
            for(ProcessInstance processInstance: getProcessHistory(recordId).values()){                   
                List<User> approvalHistorySubmittedById = [SELECT Name,Id FROM User WHERE Id =: processInstance.SubmittedById];
                approvalHistorySubmittedByUser = approvalHistorySubmittedById[0].Name;
                
                String stepStatus = null;
                String assignedByName = null;
                String actorName = null;   
                String originalactorName = null; 
                Boolean AllowStep=true;
                
                if(ApprovalStatus.Approve_Status__c == 'Approved'){
                    for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems) { 
                        if(sWI.ProcessNode.Name == 'Reviewer Action1' && sWI.StepStatus == 'Approved'){
                            approvals.add(new ApprovalHistory(sWI.CreatedDate, sWI.OriginalActor.Name, sWI.StepStatus,'', sWI.comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,sWI.Actor.Name,sWI.TargetObjectId)); 
                            approvalsMap.put(sWI.id , new ApprovalHistory(sWI.CreatedDate, sWI.OriginalActor.Name, sWI.StepStatus,'', sWI.Comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,sWI.Actor.Name,sWI.TargetObjectId));
                        } 
                    }
                }
                for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems) {  
                    stepStatus = sWI.StepStatus;
                    
                    assignedByName= '';
                    actorName = '';    
                    originalactorName = ''; 
                    if(sWI.ProcessNode.Name == 'Reviewer Action'){
                        if(AllowStep){
                            if(sWI.StepStatus == 'Pending'){
                                actorName = sWI.OriginalActor.Name; 
                                originalactorName = sWI.OriginalActor.Name;
                                stepStatus = 'Pending';
                            }
                            else if(sWI.StepStatus == 'Approved'){ 
                                assignedByName = sWI.Actor.Name; 
                                originalactorName = sWI.OriginalActor.Name;
                                actorName = sWI.OriginalActor.Name; 
                                if(ApprovalStatus.Approve_Status__c!='Approved' ){
                                    stepStatus = 'Added Reviewers';
                                }
                            }    
                            approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                            AllowStep= false;
                        }
                    }else{
                        if(sWI.StepStatus == 'Started'){
                            assignedByName = sWI.Actor.Name;    
                            approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, 'Submitted',actorName, sWI.comments,'Approval Request Submitted',sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                        }
                        /*else if(sWI.StepStatus == 'Approved'){
                            assignedByName = sWI.Actor.Name; 
                            actorName = sWI.OriginalActor.Name; 
                            approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                            }*/
                        else if(sWI.StepStatus != 'Approved'){
                            actorName = sWI.OriginalActor.Name; 
                            if(ReviewComments.ContainsKey(sWI.OriginalActorId)){
                                List<String> data = String.valueOf(ReviewComments.get(sWI.OriginalActorId)).split('===>');
                                //sWI.OriginalActorId).split('===>')[0]
                                // ReviewComments.get(sWI.OriginalActorId).split('===>')[1]
                               // DateTime dts = date.valueOf(data[0]).format('yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
                                
                                approvals.add(new ApprovalHistory((datetime.valueOf(data[0])), originalactorName, 'Reviewed',actorName, data[1],sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                                
                            }else{
                                if(stepStatus == 'NoResponse'){
                                    stepStatus='No Response';
                                }
                                //sWI.OriginalActor.Name=='Review-Confidential Request' && 
                                if(string.valueOf(sWI.OriginalActorId).startsWith('00G')){
                                    originalactorName = sWI.OriginalActor.Name;
                                }
                                approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                                
                            }
                        }
                        //originalactorName = sWI.OriginalActor.Name; 
                        /* }else{
                            approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                            }*/
                    }                
                    
                    //Action Taken By - assignedBy  - assignedByName
                    //Assigned To  - actualApprovar  - actorName
                    //Queue - assignedTo  - originalactorName
                    
                    
                    approvalsMap.put(sWI.id , new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.Comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId));
                }                   
            }  
            
        }else{
            for(ProcessInstance processInstance: getProcessHistory(recordId).values()){                   
                List<User> approvalHistorySubmittedById = [SELECT Name,Id FROM User WHERE Id =: processInstance.SubmittedById];
                approvalHistorySubmittedByUser = approvalHistorySubmittedById[0].Name;
                
                Map<Id, String> reassignCommentsMap = new Map<Id, String>(); 
                List<CalSTA_Reassign_Comments__c> reassignComments = [SELECT Id, Name, ProcessStepId__c, TargetObjectId__c,Comments__c FROM CalSTA_Reassign_Comments__c where TargetObjectId__c =:recordId];
                for(CalSTA_Reassign_Comments__c Comments : reassignComments){
                    reassignCommentsMap.put(Comments.ProcessStepId__c, Comments.Comments__c);               
                }
                
                String comments = null;
                String stepStatus = null;
                String assignedByName = null;
                String actorName = null;   
                String originalactorName = null;  
                for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems) {  
                    if( sWI.comments == null){
                        comments = reassignCommentsMap.get(sWI.Id);
                    }else{
                        comments = sWI.comments;
                    }				
                    
                    
                    if(sWI.ProcessNode.Name == 'Reviewer Action' && sWI.StepStatus == 'Rejected'){
                        stepStatus = 'Revision';
                    }else if(sWI.ProcessNode.Name == 'Approver Action' && sWI.StepStatus == 'Rejected'){
                        stepStatus = 'Re-evaluation';
                    }else if(sWI.ProcessNode.Name == 'Reviewer Action' && sWI.StepStatus == 'Approved'){
                        stepStatus = 'Reviewed';
                    }else{
                        stepStatus = sWI.StepStatus;
                    }
                    
                    if(sWI.StepStatus == 'Started'){
                        originalactorName ='';
                    }else{
                        originalactorName = sWI.OriginalActor.Name;
                    }
                    
                    if(sWI.StepStatus == 'Started' || stepStatus == 'Reviewed' || sWI.StepStatus == 'Approved'){
                        actorName = '';
                        assignedByName = sWI.Actor.Name;
                        if(ProceessInsta[0].StepsAndWorkitems.size()!=0 && sWI.StepStatus == 'Approved' && sWI.ProcessNode.Name == 'Approver Action'){
                            originalactorName =ProceessInsta[0].StepsAndWorkitems[0].Actor.Name; 
                                //'Secretary Approver Queue';
                        }
                    }
                    else if(sWI.StepStatus == 'Reassigned'){
                        assignedByName = sWI.CreatedBy.Name;    
                        actorName = sWI.Actor.Name;
                    }else if(stepStatus == 'Revision' || stepStatus == 'Re-evaluation'){
                        assignedByName = sWI.Actor.Name;                     
                        actorName = '';
                    }else{                           
                        assignedByName = ''; 
                        actorName = sWI.Actor.Name;
                        if(sWI.ProcessNode.Name == 'Approver Action'){
                        originalactorName = sWI.Actor.Name;
                        }
                    }
                    
                    if(sWI.StepStatus == 'Started'){
                        approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, 'Submitted',actorName, comments,'Approval Request Submitted',sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                    }else{
                        approvals.add(new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                    } 
                    
                    approvalsMap.put(sWI.id , new ApprovalHistory(sWI.CreatedDate, originalactorName, stepStatus,actorName, sWI.Comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId));
                }                   
            }  
            
        }   
        
        approvalResultForObject.approvals = approvals;
        approvalResultForObject.approvalsMap = approvalsMap;
        approvalResultForObject.recordId = recordId; 
        approvalResultForObject.actionStatus = actionStatusVal;
        approvalResultForObject.isConfidential = ApprovalStatus.Confidential__c;
        approvalResultForObject.approvalHistorySubmittedUser = approvalHistorySubmittedByUser;
        return approvalResultForObject;         
    }  
    
    /**
* ________________________________________________________________
* 
*  This method is used for getting approval data using SOQL query
* ________________________________________________________________
* 	 
*  @param    objectId              Id
*  @return   Map<Id,ProcessInstance>  	 
*__________________________________________________________________
*/
    @AuraEnabled   
    public static Map<Id,ProcessInstance> getProcessHistory(Id objectId){  
        return new Map<Id,ProcessInstance>([SELECT Id,Status,SubmittedById, (SELECT Id, ProcessNodeId, StepStatus, Comments, TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name, OriginalActor.Name ,CreatedBy.Name, ProcessNode.Name FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC ) 
                                            FROM ProcessInstance where TargetObjectId =: objectId order by CreatedDate DESC]);  
    }  
    
    /** _________________________________________________________
* 
*   This class is used for declaring variables 
*   _________________________________________________________     
*/
    public class ApprovalHistory{ 
        @AuraEnabled  
        public DateTime createdDate {get;set;} 
        
        @AuraEnabled  
        public string assignedTo {get;set;}
        
        @AuraEnabled  
        public string steps {get;set;}  
        
        @AuraEnabled  
        public string actualApprovar {get;set;} 
        
        @AuraEnabled  
        public string comments {get;set;} 
        
        @AuraEnabled  
        public string processNode {get;set;} 
        
        @AuraEnabled  
        public string OriginalActorId {get;set;} 
        
        @AuraEnabled  
        public string ActualActorId {get;set;} 
        
        @AuraEnabled  
        public string InstanceStepId {get;set;}
        
        @AuraEnabled  
        public string assignedBy {get;set;}
        
        @AuraEnabled  
        public string TargetobjId {get;set;}       
        
        /** _________________________________________________________
* 
*   This contructor is used for stroring values
* _________________________________________________________     
*/
        public ApprovalHistory(DateTime crDate, string name, string stp, string actor, string commnets, string processName, string OriginalId, string ActorId, string stepid,string assignedByName,string TargetId) {  
            createdDate = crDate;  
            assignedTo = name;  
            steps = stp;  
            actualApprovar = actor; 
            comments = commnets;
            processNode = processName;
            OriginalActorId = OriginalId;
            ActualActorId = ActorId;
            InstanceStepId = stepid;
            assignedBy = assignedByName;
            TargetobjId = TargetId;
        }  
    }  
    
    /** _________________________________________________________
* 
*   This class is used for declaring  variables
* _________________________________________________________     
*/
    public class ApprovalHistoryWrapper{     
        @AuraEnabled  
        public Id recordId {get;set;} 
        
        @AuraEnabled
        public String  actionStatus {get;set;} 
        
        @AuraEnabled
        public String  approvalHistorySubmittedUser {get;set;}
        
        @AuraEnabled  
        public List<ApprovalHistory> approvals {get;set;} 
        
        @AuraEnabled  
        public Map<ID,ApprovalHistory> approvalsMap {get;set;} 
        
        @AuraEnabled  
        public Id recordTypeId {get;set;} 
        
        @AuraEnabled  
        public boolean isIMPAL {get;set;} 
        
        @AuraEnabled  
        public boolean isConfidential {get;set;}
        
        //Mk-Send for revision  date recieved value
        @AuraEnabled
        public case caseData {get;set;}
        
        @AuraEnabled
        public string profileData {get;set;}
        
        
    }
    
    /**
* ________________________________________________________________________
* 
*  This method is called when user clicked on "submit for approval" button
* ________________________________________________________________________
* 	 
*  @param     recordId       String
*  @param     Comments  	  String  
*  @return    Boolean
*__________________________________________________________________________
*/
    @AuraEnabled
    public static Boolean submitforApproveProcess(string recordId, String Comments){       
        Boolean isActionRequestedEmpty = false;
        Case CaseDetails = [Select Id,Action_requested__c,RecordType.Name, AccountId,Confidential__c,ConfidentialSubmitter__c,RecordTypeId,CreatedById,Subject,Tracking_Number__c From Case Where Id=:recordId];
        String sendtoRequestorsubmitforApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Requestor_For_Submitted_for_Approval');
        String deptQueueName = CALSTA_CustomUtils.getDepartmentQueueName(CaseDetails.AccountId);
        String submitforApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Request_is_Submitted_for_Approval');
        //RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:CaseDetails.RecordTypeId];
        String queueName = CALSTA_CustomUtils.queueListMap.get(CaseDetails.RecordType.Name); 
            
        if(CaseDetails.Action_requested__c != null){            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments(Comments);        
            req.setObjectId(recordId); 		
            Approval.ProcessResult result = Approval.process(req);
            if(CaseDetails.Confidential__c){
                List <Group> grp = [select id,name from Group where DeveloperName ='Review_Confidential_Request' ];
                if(grp.size()>0){
                    caseShare cShare = new caseShare();
                    cShare.CaseId = recordId;
                    cShare.UserOrGroupId = grp[0].id;
                    cShare.RowCause = 'manual';
                    cShare.CaseAccessLevel = 'edit';
                    insert cShare;
                    
                }                
            	//Sending Email to Submitted CalSTA User who Submit this Request    
                CALSTA_CustomUtils.sendEmail(sendtoRequestorsubmitforApprovalTemplate, UserInfo.getUserId(),  CaseDetails.Id);
                queueName = 'Review-Confidential Request';  
            }
            
            system.debug('---'+queueName);    
            if(queueName!=null){
                // sending email to record type related reviewer queue 
                CALSTA_CustomUtils.sendEmailToQueue(submitforApprovalTemplate,queueName,recordId);
            }    
             //Viswanath - 30/8/2021 
            if(!CaseDetails.Confidential__c){
                // sending email to requestor send email to department Queue
                CALSTA_CustomUtils.sendEmailToQueue(sendtoRequestorsubmitforApprovalTemplate, deptQueueName,  CaseDetails.Id);
            }
            if(result.isSuccess() == true){
                updateReviewer(recordId);
            }
            isActionRequestedEmpty = true; 
        }                  
        return isActionRequestedEmpty;        
    }
    
    /**
* ____________________________________________________________________________________________________
* 
*  This method is called when user clicked on "Forward for Approval and CalSTA Final Approval" button
* _____________________________________________________________________________________________________
* 	 
*  @param     recordId       String
*  @param     Comments  	  String  
*  @param     stage  	      String  
*  @return    Boolean
* _______________________________________________________________________________________________________
*/
    @AuraEnabled
    public static Boolean ApproveProcess(string recordId, String Comments,String stage) {
        Boolean isActionRequestedEmpty = false;
        Case CaseDetails = [Select Id,Approvers__c,Action_requested__c,Confidential__c,addReviewers__c,ConfidentialSubmitter__c,CreatedById,Subject,RecordTypeId,Tracking_Number__c From Case Where Id=:recordId];
        if(CaseDetails.Action_requested__c != null){ 
            List<ProcessInstanceWorkitem> pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
            if(CaseDetails.Confidential__c && CaseDetails.addReviewers__c != Null){
                Group grp = [select id,name from Group where name ='Review-Confidential Request' ];
                pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId AND OriginalActorId =:grp.Id];
            }else{
                pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
            }
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(Comments);
            req.setAction('Approve');
            req.setWorkitemId(pItem[0].Id);
            Approval.ProcessResult result = Approval.process(req);
            String queueName = null;
            String StageLevel = stage;             
            if(StageLevel == 'reviewApproval'){
                String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseDetails.RecordTypeId).getname();                
                if(recordTypeName == 'Issue Memorandum (IM-PAL/IT)'){
                    queueName = System.Label.Approver_Queue_IMPAL; 
                }else{
                    queueName = System.Label.Approver_Queue_One;
                } 
                List<String> idList = new List<String>(); 
                String ApprovalQueueOneTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Request_Forward_for_Approval_by_Reviewer');
                if(queueName!=null){   
                    // sending email to  Approver Queue One or Approver Queue IMPAL
                    CALSTA_CustomUtils.sendEmailToQueue(ApprovalQueueOneTemplate,queueName,recordId);
                    /* creating events for  related Approver Queue One or Approver Queue IMPAL
						CALSTA_CustomUtils.createEventforQueueMembers(queueName,CaseDetails.Subject,CaseDetails.Tracking_Number__c);*/
                    if(result.isSuccess() == true){
                        updateReviewer(recordId);
                    } 
                }                                    
            }   
            if(StageLevel == 'finalApproval'){
                String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseDetails.RecordTypeId).getname();
                String finalApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');
                if(CaseDetails.Confidential__c){
                    CaseDetails.Approve_Status__c='Approved';
                    if(recordtypename.containsIgnoreCase('Issue Memorandum')){
                        CaseDetails.Status='Completed';
                    }
                    else if(recordtypename.containsIgnoreCase('GOAR')){
                        CaseDetails.Status='Approved By CalSTA; Pending At GO';
                    }
                }
                if(CaseDetails.Approvers__c != null){
                    CaseDetails.Approvers__c = CaseDetails.Approvers__c +','+userinfo.getUserId();                
                }
                else{
                    CaseDetails.Approvers__c = userinfo.getUserId(); 
                }
                update CaseDetails;
                //Viswanath - Added for When final Approval Done for Both 
                If(CaseDetails.Confidential__c){
                    queueName = 'Review-Confidential Request';
                	CALSTA_RequestTriggerHelper.sendEmailToAddedReviewersUsers(CaseDetails, finalApprovalTemplate);
                    
                    if(CaseDetails.ConfidentialSubmitter__c !=null){
                      /*  List<String> userIds = CaseDetails.ConfidentialSubmitter__c.split(',');
                           for(String submitteduserId : userIds){ 
                            CALSTA_CustomUtils.sendEmail(finalApprovalTemplate,submitteduserId,CaseDetails.Id);
                        } */
                       CALSTA_CustomUtils.sendEmail(finalApprovalTemplate,CaseDetails.ConfidentialSubmitter__c,CaseDetails.Id); 
                    }
                }
                if(queueName!=null){
                    // sending email to record type related Approver queue 
                    CALSTA_CustomUtils.sendEmailToQueue(finalApprovalTemplate,queueName,recordId);
                }
                
                if(recordtypename == 'Issue Memorandum (Audit)' || recordtypename == 'Issue Memorandum (General)'|| recordtypename == 'Issue Memorandum (Legislative Reports)'
                   || recordtypename == 'Issue Memorandum (NCB)' || recordtypename == 'Issue Memorandum (Others)'  || recordtypename == 'Issue Memorandum (IM-PAL/IT)' || recordtypename == 'Issue Memorandum (Rulemaking)'){
                       //1/9/2021 - Added Non Confidential Check 
                       if(!CaseDetails.Confidential__c){
                           if(CaseDetails.Approvers__c != null){
                               List<String> userIds = CaseDetails.Approvers__c.split(',');
                               for(String userId : userIds){       
                                   CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userId, CaseDetails.Id);
                               }
                           }
                       }                     
                   }else {
                       if(!CaseDetails.Confidential__c){
                           CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userinfo.getUserId(), recordId);
                       }
                   }
            } 
            isActionRequestedEmpty = true;
        }
        return isActionRequestedEmpty;       
    }    
    
    /**
* _______________________________________________________________________
* 
*  This method is called when user clicked on "Send for Revision" button
* ________________________________________________________________________
* 	 
*  @param     recordId       String
*  @param     Comments  	  String   	  
*  @return    Boolean
*__________________________________________________________________________
*/
    @AuraEnabled
    public static Boolean RejectProcess(string recordId, String Comments){        
        Boolean isRevisionDateEmpty = false;
        Case CaseDetails = [Select Id,Subject,Reviewer__c,Tracking_Number__c,AccountId,Date_Revision_Due_Back_From_Dept__c,CreatedById From Case Where Id=:recordId];
        // if(CaseDetails.Date_Revision_Due_Back_From_Dept__c != null){            
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(Comments);  
        req.setAction('Reject');    
        ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
        req.setWorkitemId(pItem.Id);
        Approval.ProcessResult result = Approval.process(req);            
        isRevisionDateEmpty = true;             
        //  }
         
        
            
        return isRevisionDateEmpty;
    }    
    
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
    @AuraEnabled
    public static void ReassignProcess(string reassignTo, string recordId,String comments){
        Case CaseDetails = [Select Id,forwadedReviewers__c,Date_Revision_Due_Back_From_Dept__c,CreatedById,Subject,Tracking_Number__c From Case Where Id=:recordId];        
        List<ProcessInstanceWorkItem> workItemList = [SELECT ProcessInstance.Status,
                                                      ProcessInstance.TargetObjectId,ProcessInstanceId,OriginalActorId,Id,ActorId
                                                      FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId];
        workItemList.get(0).ActorId  = reassignTo;   
        update workItemList;     
        
        if(comments!=null || comments!=''){
            List<ProcessInstance>  processInstanceList =[SELECT Id,(SELECT Id FROM StepsAndWorkitems order by CreatedDate DESC )  FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC];
            String lastProcessInstanceHistoryId = null;
            integer i=1;
            for(ProcessInstance processInstance: processInstanceList){                
                for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems){                 
                    if(i == 1){
                        lastProcessInstanceHistoryId = sWI.Id;
                    }
                    i++;
                } 
            }			
            
            if(CaseDetails.forwadedReviewers__c != null){
                CaseDetails.forwadedReviewers__c = CaseDetails.forwadedReviewers__c +','+reassignTo;                
            }
            else{
                CaseDetails.forwadedReviewers__c = reassignTo; 
            }
            update CaseDetails;            
            
            CalSTA_Reassign_Comments__c reassignCmts = new CalSTA_Reassign_Comments__c();
            reassignCmts.Comments__c = comments;
            reassignCmts.ProcessStepId__c = lastProcessInstanceHistoryId;
            reassignCmts.TargetObjectId__c = recordId;
            insert reassignCmts;  
            
        }      
        String reviewerReassignTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Request_is_Forward_for_Review');
        //Sending email to re-assigned user
        CALSTA_CustomUtils.sendEmail(reviewerReassignTemplate, reassignTo, recordId);
        /*Creating event to re-assigned user
CALSTA_CustomUtils.createEventforUser(reassignTo.id, CaseDetails.Subject, CaseDetails.Tracking_Number__c);*/
        updateReviewer(recordId);        
    }
    
    /**
* 
* 
*  This method is called when user clicked on "Add Reviewers" button
* ________________________________________________________________________
* 	 
*  @param     reassignTo     sObject
*  @param     recordId       String
*  @param     comments  	  String   
* __________________________________________________________________________
*/
    /*
    @AuraEnabled
    public static void AddReviewersProcess(sObject reassignTo, string recordId,String comments){
        Case CaseDetails = [Select Id,addReviewers__c,Date_Revision_Due_Back_From_Dept__c,CreatedById,Subject,Tracking_Number__c From Case Where Id=:recordId];        
        List<ProcessInstanceWorkItem> workItemList = [SELECT ProcessInstance.Status,
                                                      ProcessInstance.TargetObjectId,ProcessInstanceId,OriginalActorId,Id,ActorId
                                                      FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId];
        workItemList.get(0).ActorId  = reassignTo.id;   
        update workItemList;     
        caseShare cShare = new caseShare();
        cShare.CaseId = recordId;
        cShare.UserOrGroupId = reassignTo.id;
        cShare.RowCause = 'manual';
        cShare.CaseAccessLevel = 'edit';
        insert cShare;
        if(comments!=null || comments!=''){
            List<ProcessInstance>  processInstanceList =[SELECT Id,(SELECT Id FROM StepsAndWorkitems order by CreatedDate DESC )  FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC];
            String lastProcessInstanceHistoryId = null;
            integer i=1;
            for(ProcessInstance processInstance: processInstanceList){                
                for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems){                 
                    if(i == 1){
                        lastProcessInstanceHistoryId = sWI.Id;
                    }
                    i++;
                } 
            }			
            
            if(CaseDetails.addReviewers__c != null){
                CaseDetails.addReviewers__c = CaseDetails.addReviewers__c +','+reassignTo.id;                
            }
            else{
                CaseDetails.addReviewers__c = reassignTo.id; 
            }
            update CaseDetails;            
            
            CalSTA_Reassign_Comments__c reassignCmts = new CalSTA_Reassign_Comments__c();
            reassignCmts.Comments__c = comments;
            reassignCmts.ProcessStepId__c = lastProcessInstanceHistoryId;
            reassignCmts.TargetObjectId__c = recordId;
            insert reassignCmts;  
            
        }      
        String reviewerReassignTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Request_is_Forward_for_Review');
        //Sending email to re-assigned user
        CALSTA_CustomUtils.sendEmail(reviewerReassignTemplate, reassignTo.id, recordId);
        updateReviewer(recordId);        
    }
  */  
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
    @AuraEnabled
    public static void reEvaluateProcess(string recordId,String Comments){
        Case CaseDetails = [Select Id,RecordTypeId From Case Where Id=:recordId];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(Comments);  
        req.setAction('Reject');            
        ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
        req.setWorkitemId(pItem.Id);
        Approval.ProcessResult result = Approval.process(req);
        RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:CaseDetails.RecordTypeId];
        String queueName = CALSTA_CustomUtils.queueListMap.get(rtype.Name);         
        String reevaluateTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Request_is_sent_back_for_Re_evaluation_by_Approver');
        if(queueName!=null){
            // Sending mail to record type related queue
            CALSTA_CustomUtils.sendEmailToQueue(reevaluateTemplate,queueName,recordId);            
        }             
        updateReviewer(recordId);
    }
    
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
    @AuraEnabled
    public static void secretoryApprovalProcess(String recordId, String Comments){         
        
        Case cs = [Select Id,Approvers__c,Approve_Status__c,Subject,Tracking_Number__c from Case where  Id =: recordId];
        cs.Approve_Status__c = 'Secretory Approval';
        if(cs.Approvers__c != null){
            cs.Approvers__c = cs.Approvers__c +','+userinfo.getUserId();                
        }
        else{
            cs.Approvers__c = userinfo.getUserId(); 
        }
        update cs;  
        
        String grupId = CALSTA_CustomUtils.queueIdsMap.get(System.Label.Approver_Queue_Two);        
        try{
            List<ProcessInstanceWorkItem> processworkItemList = [SELECT ProcessInstance.Status,
                                                                 ProcessInstance.TargetObjectId,ProcessInstanceId,OriginalActorId,Id,ActorId
                                                                 FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId];
            processworkItemList.get(0).ActorId  = grupId;
            update processworkItemList;
            
            if(Comments!=null || Comments!=''){
                List<ProcessInstance>  processInstanceList =[SELECT Id,(SELECT Id FROM StepsAndWorkitems order by CreatedDate DESC )  FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC];
                String lastProcessInstanceHistoryId = null;
                integer i =1;
                for(ProcessInstance processInstance: processInstanceList){                     
                    for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems){                 
                        if(i == 1){
                            lastProcessInstanceHistoryId = sWI.Id;
                        }
                        i++;
                    }     
                }			
                CalSTA_Reassign_Comments__c reassignCmts = new CalSTA_Reassign_Comments__c();
                reassignCmts.Comments__c = Comments;
                reassignCmts.ProcessStepId__c = lastProcessInstanceHistoryId;
                reassignCmts.TargetObjectId__c = recordId;
                insert reassignCmts;                   
                
            }           
            String approverQueueTwo = System.Label.Approver_Queue_Two;          
            List<String> idList = new List<String>(); 
            String ApprovalQueueTwoTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_request_Send_for_Secretary_s_Approval');
            if(approverQueueTwo!=null){ 
                // Sending mail to approver Queue Two
                CALSTA_CustomUtils.sendEmailToQueue(ApprovalQueueTwoTemplate,approverQueueTwo,recordId);
                /* Creating events for approver Queue Two
CALSTA_CustomUtils.createEventforQueueMembers(approverQueueTwo,cs.Subject,cs.Tracking_Number__c);*/
            }
            updateReviewer(recordId);
        }
        catch(DmlException e) {
            
        } 
        
    }
    
    /**
* ________________________________________________________________
* 
*  This method is used for showing "Forward for Review Users"
* ________________________________________________________________
* 	 	 
*  @param     recId               String
*  @param     searchKeyWord       String
*  @param     ObjectName  	       String   
* __________________________________________________________________
*/ 
    @AuraEnabled
    public static  List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String recId) {          
        String queueName= null;   system.debug('searching from lookup' +searchKeyword + ObjectName +recId );
        Case caseStatus = [Select Id, Approve_Status__c From Case Where Id =:recId  ];
        queueName = System.Label.Reviewer_Queue;
        List <sObject> QueueMembersList = new List <sObject> ();
        List<String> idList = new List<String>();    
        if(queueName!=''){          
            List<GroupMember>  groupMembers = CALSTA_CustomUtils.getGroupMembers(queueName);
            for (GroupMember gm : groupMembers) {            
                idList.add(gm.userOrGroupId);            
            } 
            User[] usr = [SELECT Id,name,email FROM user WHERE id IN :idList AND Name like: searchKeyWord + '%' ];        
            for(User u : usr) { 
                QueueMembersList.add(u);
            }
        }
        return QueueMembersList; 
    }   
    
    /**
* ___________________________________________________________________________
* 
*  This method is used for showing custom approval buttons are visible or not
* ___________________________________________________________________________
* 	 	 
*  @param     recordId               String	 
*  @return    Boolean  	        
* _____________________________________________________________________________
*/
    @AuraEnabled
    Public Static ButtonsVisibilityWrapper buttonsDisplay(string recordId){         
        Boolean isVisibleButtons = false;        
        ButtonsVisibilityWrapper ButtonsVisibility = new ButtonsVisibilityWrapper();  
        ButtonsVisibility.VisibleButtonsNC=false;
        ButtonsVisibility.CReviewed=false;
        ButtonsVisibility.CAddReviewer=false;
        ButtonsVisibility.CFinalApprover=false;
        
        Case CaseRec = [SELECT Id,Confidential__c,Approve_Status__c,addReviewers__c,Reviewed_Comment_History__c, RecordTypeId FROM Case WHERE Id =: recordId ];            
        String logggedUserProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;
        ProcessInstanceWorkItem WorkItemNC = new ProcessInstanceWorkItem();
        List<ProcessInstanceWorkItem> workItemList = [SELECT ProcessInstance.TargetObjectId,ProcessInstanceId,OriginalActorId,Id,ActorId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId];
        if(CaseRec.Confidential__c){
            Map<String, Object> ReviewComments = new Map<String, Object>();
            if(CaseRec.Reviewed_Comment_History__c != Null){
                ReviewComments = (Map<String, Object>) Json.deserializeUntyped(CaseRec.Reviewed_Comment_History__c);
            }
            for(ProcessInstanceWorkItem PWI:workItemList){      
                if(string.valueOf(PWI.ActorId).startsWith('005') && string.valueOf(PWI.ActorId) == userinfo.getUserId()){
                    if(ReviewComments.ContainsKey(PWI.ActorId)){
                        ButtonsVisibility.CReviewed = false; 
                        ButtonsVisibility.VisibleButtonsNC = false; 
                    }else{
                        ButtonsVisibility.CReviewed = true; 
                        ButtonsVisibility.VisibleButtonsNC = true; 
                    }
                }else if(string.valueOf(PWI.ActorId).startsWith('00G')) { 
                    WorkItemNC= PWI;
                }
            }
        }else{
            WorkItemNC= workItemList.get(0);
        }
        if(logggedUserProfile != System.Label.System_Administrator ) {           
            if(string.valueOf(WorkItemNC.ActorId).startsWith('005')){                
                User currentUser = [Select Id, Name From User Where Id=:WorkItemNC.ActorId];
                if(currentUser.Id == userinfo.getUserId()){
                    ButtonsVisibility.VisibleButtonsNC = true;   
                }    
            }else if(string.valueOf(WorkItemNC.ActorId).startsWith('00G')) {              
                Map<Id, List<GroupMember>> accIdToAccCallMap = new Map<Id, List<GroupMember>>();
                Group g = [SELECT Id, Name,DeveloperName, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group where Id=:WorkItemNC.ActorId];
                for (GroupMember gm : g.groupMembers) {            
                    accIdToAccCallMap.put(gm.userOrGroupId, new List<groupMember> {gm});
                } 
                if(accIdToAccCallMap.containsKey(userinfo.getUserId())) {
                    ButtonsVisibility.VisibleButtonsNC = true; 
                    ButtonsVisibility.CAddReviewer=true;
                    ButtonsVisibility.CFinalApprover=true;
                }
            }
        }else {
            ButtonsVisibility.VisibleButtonsNC = true;              
            ButtonsVisibility.CReviewed = false; 
            ButtonsVisibility.CAddReviewer=true;
            ButtonsVisibility.CFinalApprover=true;           
        }
        
        if(CaseRec.addReviewers__c != Null){
            ButtonsVisibility.CAddReviewer=false;
        }
        if(CaseRec.Approve_Status__c == 'Not Started' ||CaseRec.Approve_Status__c == 'Approved'){           
            ButtonsVisibility.CReviewed = false; 
            ButtonsVisibility.CAddReviewer=false;
            ButtonsVisibility.CFinalApprover=false;    
        }
        return ButtonsVisibility;
    } 
    
    
    public class ButtonsVisibilityWrapper{     
        @AuraEnabled  
        public boolean VisibleButtonsNC {get;set;}     
        @AuraEnabled  
        public boolean CReviewed {get;set;}     
        @AuraEnabled  
        public boolean CAddReviewer {get;set;}     
        @AuraEnabled  
        public boolean CFinalApprover {get;set;} 
        
    }
    
    
    /**
* ________________________________________________________________________________
* 
*  This method is used for showing "submit for approval" button is visible or not
* ________________________________________________________________________________
* 	 	 
*  @param     recordId               String	 
*  @return    Boolean  	        
* __________________________________________________________________________________
*/
    @AuraEnabled
    Public Static Boolean submitforApprovalButtonDisplay(string recordId){         
        Boolean issubmitforApprovalButton = false;
        String logggedUserProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;
        //Mk Confidential user show submit for approval button.
        /*List<group> Grp = [select (select UserOrGroupId from GroupMembers where  UserOrGroupId =: userinfo.getUserId()) from group where developername='Confidential_Users'];
        if(Grp[0].GroupMembers.size()>0){
            return issubmitforApprovalButton = True;
        }*/
        
        if(logggedUserProfile != System.Label.System_Administrator ) { 
            Case CaseDetails = [Select Id,CreatedById,AccountId From Case Where Id=:recordId];             
            List<User> users = [select Id, Name, UserRole.Name  from User where Id =:userinfo.getUserId() ];
            Map<Id,String> userDepartmentNames = new Map<Id,String>();				
            for(User user:users){
                if(user.UserRole.Name == 'CalSTA'){
                    userDepartmentNames.put(user.Id,'California State Transportation Agency');
                }else{
                    userDepartmentNames.put(user.Id,user.UserRole.Name);
                }                 
            }	         
            String userDepartName = userDepartmentNames.get(userinfo.getUserId());
            String requestCreatedUserDepartName = userDepartmentNames.get(CaseDetails.CreatedById);
            List<Account> depatments = [Select Id,name from Account where Id =: CaseDetails.AccountId];
            Map<Id,String> departmentNames = new Map<Id,String>();				
            for(Account department:depatments){
                departmentNames.put(department.Id,department.name);
            }	         
            String departName = departmentNames.get(CaseDetails.AccountId);
            if((userDepartName == departName) || (requestCreatedUserDepartName == userDepartName)){
                issubmitforApprovalButton = true;
            }            
        }
        else{
            issubmitforApprovalButton = true;
        }
        return issubmitforApprovalButton;
    }
    
    /**
* ________________________________________________________________
* 
*  This method is used for updating reviewer field
* ________________________________________________________________
* 	 	 
*  @param     recordId        String	 	        
* __________________________________________________________________
*/
    @AuraEnabled
    Public Static void updateReviewer(string recId){
        List<ProcessInstance>  processInstanceList =[SELECT Id,(SELECT Id,Actor.Name,IsPending,CreatedDate FROM StepsAndWorkitems  order by IsPending DESC, CreatedDate DESC )  FROM ProcessInstance where TargetObjectId =:recId order by CreatedDate DESC];
        String reviewerName = null;             
        integer i =1;
        for(ProcessInstance processInstance: processInstanceList){ 
            for(ProcessInstanceHistory sWI:processInstance.StepsAndWorkitems){                 
                if(i == 1){
                    reviewerName = sWI.Actor.Name;
                }
                i++;
            }                                    
        }
        Case request = [Select Id,Reviewer__c From Case where Id=:recId];
        request.Reviewer__c = reviewerName;   
        update request; 
    }
    
    //Get Record Type ID
    @AuraEnabled           
    public static Id getCaseRecordTypeID() {
        Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (IM-PAL/IT)').getRecordTypeId();
        return CaseRTID;
    } 
    
    
    /**
* ________________________________________________________________
* 
*  This method is used for showing "Forward for Approval Users"
* ________________________________________________________________
* 	 	 
*  @param     recId               String
*  @param     searchKeyWord       String
*  @param     ObjectName  	       String   
* __________________________________________________________________
*/ 
    @AuraEnabled
    public static  List<sObject> fetchLookUpValuesforwardapproval(String searchKeyWord, String ObjectName, String recId) {          
        String queueName= null;   system.debug('searching from lookup' +searchKeyword + ObjectName +recId );
        String queueNameAq1= null;
        Case caseStatus = [Select Id, Approve_Status__c From Case Where Id =:recId  ];
        queueName = System.Label.Approver_Queue_IMPAL;
        queueNameAq1 = System.Label.Approver_Queue_One;
        List <sObject> QueueMembersList = new List <sObject> ();
        List<String> idList = new List<String>();    
        if(queueName!='' || queueNameAq1!=''){          
            List<GroupMember>  groupMembers = CALSTA_CustomUtils.getGroupMembers(queueName);
            List<GroupMember>  groupMembersAq1 = CALSTA_CustomUtils.getGroupMembers(queueNameAq1);
            groupMembers.addAll(groupMembersAq1);
            for (GroupMember gm : groupMembers) {            
                idList.add(gm.userOrGroupId);            
            } 
            
            User[] usr = [SELECT Id,name,email FROM user WHERE id IN :idList AND Name like: searchKeyWord + '%' ];        
            for(User u : usr) { 
                QueueMembersList.add(u);
            }
        }
        return QueueMembersList; 
    }    
    
    /**
_______________________________________________________________________
* 
*  This method is called when user clicked on "Forward for Approval" and "CalSTA Final Approval" button
* ________________________________________________________________________
* 	 
*  @param     reassignTo     sObject
*  @param     recordId       String
*  @param     comments  	 String  
*  @param     stage			 String
/////////// Changed for "Forward For Approval" CR for IM-PAL 
* __________________________________________________________________________
*/
    @AuraEnabled
    public static Boolean forwardApprovalProcess(string recordId, String comments,String stage, sObject reassignTo) {
        Boolean isActionRequestedEmpty = false;
        Case CaseDetails = [Select Id,Approvers__c,Action_requested__c, IM_PAL_IT_Undersecretary__c, CreatedById, Subject, RecordTypeId, Tracking_Number__c 
                            From Case Where Id=:recordId];
        
        IMPALIT__c checkDeputy = IMPALIT__c.getOrgDefaults();
        
        if(reassignTo.get('Id').tostring() != checkDeputy.DeputyId__c)
        {
            CaseDetails.IM_PAL_IT_Undersecretary__c = true;
        }
        else
            CaseDetails.IM_PAL_IT_Undersecretary__c = false;
        
        
        CaseDetails.IM_PAL_Approver__c = reassignTo.get('Id').tostring();
        
        update CaseDetails;
        
        if(CaseDetails.Action_requested__c != null){ 
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comments);
            req.setAction('Approve');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: recordId];
            req.setWorkitemId(pItem.Id);
            Approval.ProcessResult result = Approval.process(req);
            system.debug(' --- Comments --- ' + comments);
            String queueName = null;
            String StageLevel = stage;  
            List<GroupMember> gm=[SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =: reassignTo.Id AND Group.Type = 'Queue' and (Group.Name='Approver Queue-IM PAL' OR Group.Name='Review-IM PAL')];
            if(StageLevel == 'reviewApproval'){
                String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseDetails.RecordTypeId).getname();                
                if( recordTypeName == 'Issue Memorandum (IM-PAL/IT)' && gm.size()>0 && (reassignTo.get('Id') == checkDeputy.DeputyId__c) ){
                    queueName = System.Label.Approver_Queue_IMPAL; 
                }else{
                    queueName = System.Label.Approver_Queue_One;
                }                
                List<String> idList = new List<String>(); 
                String ApprovalQueueOneTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_For_Request_Forward_for_Approval_by_Reviewer');
                if(queueName!=null){   
                    // sending email to  Approver Queue One or Approver Queue IMPAL
                    CALSTA_CustomUtils.sendEmail(ApprovalQueueOneTemplate,reassignTo.id,recordId);
                    /* creating events for  related Approver Queue One or Approver Queue IMPAL
CALSTA_CustomUtils.createEventforQueueMembers(queueName,CaseDetails.Subject,CaseDetails.Tracking_Number__c);*/
                    if(result.isSuccess() == true){
                        updateReviewer(recordId);
                    } 
                }                                    
            }   
            if(StageLevel == 'finalApproval'){
                String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseDetails.RecordTypeId).getname();
                String finalApprovalTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Approver_Requestor_For_Request_is_Completed');
                
                if(CaseDetails.Approvers__c != null){
                    CaseDetails.Approvers__c = CaseDetails.Approvers__c +','+reassignTo.id;                
                }
                else{
                    CaseDetails.Approvers__c = reassignTo.id; 
                }
                update CaseDetails; 
                
                if(recordtypename == 'Issue Memorandum (Audit)' || recordtypename == 'Issue Memorandum (General)'|| recordtypename == 'Issue Memorandum (Legislative Reports)'
                   || recordtypename == 'Issue Memorandum (NCB)' || recordtypename == 'Issue Memorandum (Others)'  || recordtypename == 'Issue Memorandum (IM-PAL/IT)' || recordtypename == 'Issue Memorandum (Rulemaking)'){
                       if(CaseDetails.Approvers__c != null){
                           List<String> userIds = CaseDetails.Approvers__c.split(',');
                           for(String userId : userIds){       
                               CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userId, CaseDetails.Id);
                           }
                       }                     
                   }else{
                       CALSTA_CustomUtils.sendEmail(finalApprovalTemplate, userinfo.getUserId(), recordId);
                   }
            } 
            isActionRequestedEmpty = true;
        }
        return isActionRequestedEmpty;       
    }
    
    
    
    @AuraEnabled
    public static Map<Id,User> getReviewers() {
        return new Map<Id,User>([Select Id,Name  from User  where IsActive=true AND UserRole.Name='CalSTA' order by name]);
    }
    
    @AuraEnabled
    public static Boolean AddingReviewersToRequest(String comments,String caseId,List<String> reviewerIds) {
        
        Boolean AddedReviewers = false;
        try{
            Case CaseDetails = [Select Id,addReviewers__c From Case Where Id=:caseId];
            List <Group> grp = [select id,name from Group where name = 'Review-Confidential Request' ];
            reviewerIds.add(grp[0].id);
            List<User> userList = [select id,name from user where id=:reviewerIds];
             CaseDetails.Reviewer__c = grp[0].name;
            for(user use:userList){
                CaseDetails.Reviewer__c = CaseDetails.Reviewer__c + ';' + use.Name;
            }
            CaseDetails.addReviewers__c = String.join(reviewerIds, ',');
            update CaseDetails;
            
            List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem PWI:[SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: caseId]){
                for(String revId:reviewerIds){
                    Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
                    result.setComments(comments);
                    result.setAction('Approve');
                    result.setWorkitemId(PWI.Id);
                    result.setNextApproverIds(new List<Id>{revId});
                    approvalRequestList.add(result);
                }
            }
            Approval.process(approvalRequestList);
            AddedReviewers = true;
            List<caseShare> caseShareList = new List<caseShare>();
            for(String revId:reviewerIds){
                caseShare cShare = new caseShare();
                cShare.CaseId = caseId;
                cShare.UserOrGroupId = revId; 
                cShare.RowCause = 'manual';
                cShare.CaseAccessLevel = 'Edit';
                caseShareList.add(cShare);
            } 
            
            Database.insert(caseShareList,false);
            //Viswanath -- 02/08/2021 - Sending Mail to Added Reviewers
            List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
            for(string s:reviewerIds){
                if(!s.startsWith('005')) {
                    continue;
                }
                String reviewerReassignTemplate = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewer_For_Request_is_Forward_for_Review');
                //CALSTA_CustomUtils.sendEmail(reviewerReassignTemplate, s, caseId);
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(reviewerReassignTemplate, s, caseId);
                String subject = email.getSubject();
                String body = email.gethtmlBody();
                email.setSubject(subject);
                email.setTargetObjectId(s);
                email.sethtmlBody(body);
                email.saveAsActivity = false;    
                singleEmailMessagesList.add(email);
            }
            if(singleEmailMessagesList != null && singleEmailMessagesList.size()>0){
                Messaging.sendEmail(singleEmailMessagesList);  
            }
            // 30/07/2021 ---> Email for Reviewers 
        }catch(exception ex){
            system.debug('Exception Occured in Add Reviewers');   
        }
        return AddedReviewers;
    }
    
    
    @AuraEnabled
    public static Boolean reviewedProcess(string recordId, String Comments) {
        Boolean isActionRequestedEmpty = false;
        case cse = [select id,Reviewer__c,Confidential__c,Reviewed_Comment_History__c from case where id=:recordId];
        Map<Id,String> CommHist = new Map<Id,String>();    
        String Separator = '===>';
        if(cse.Reviewed_Comment_History__c!=null){
            Map<String, Object> existD = (Map<String, Object>) Json.deserializeUntyped(cse.Reviewed_Comment_History__c);
            existD.put(userInfo.getUserId(),String.valueOf(system.now())+Separator+Comments);
            cse.Reviewed_Comment_History__c = JSON.serialize(existD);
        }else{        
            CommHist.put(userInfo.getUserId(),String.valueOf(system.now())+Separator+Comments);
            cse.Reviewed_Comment_History__c = JSON.serialize(CommHist);
        }
        List<String> reviewerList = (cse.Reviewer__c).split(';');
        reviewerList.remove(reviewerList.indexOf(userInfo.getName()));
        cse.Reviewer__c = string.join(reviewerList,';');
        update cse;
        //Reviewed one after one
         List <Group> grp = [select id,name from Group where name = 'Review-Confidential Request' ];
        String reviewedTemplateforConfidentialQueue = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewed_Email_for_Confidential_Queue');
        CALSTA_CustomUtils.sendEmailToQueue(reviewedTemplateforConfidentialQueue,grp[0].name,recordId);
        
        
        //Reviewed All
     	List<String> reviewerList1 = (cse.Reviewer__c).split(';');
        String allReviewersDoneReviewedTemplateforConfidentialQueue = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reviewed_Email_for_Confidential_Queue_for_Once_All_Reviewers_Done');
        if(reviewerList1.size()==1){
            CALSTA_CustomUtils.sendEmailToQueue(allReviewersDoneReviewedTemplateforConfidentialQueue,grp[0].name,recordId);
		
        }
        isActionRequestedEmpty= true;
        
        return isActionRequestedEmpty;       
    }
    
        /**
* ________________________________________________________________
* 
*  This method is used for showing "Forward for Review Users"
* ________________________________________________________________
* 	 	 
*  @param     recId               String
*  @param     searchKeyWord       String
*  @param     ObjectName  	       String   
* __________________________________________________________________
*/ 
    @AuraEnabled
    public static  List<sObject> fetchLookUpValuesForwardforReview(String recId) {          
        String queueName= null;   
        Case caseStatus = [Select Id, Approve_Status__c From Case Where Id =:recId  ];
        queueName = System.Label.Reviewer_Queue;
        List <sObject> QueueMembersList = new List <sObject> ();
        List<String> idList = new List<String>();    
        if(queueName!=''){          
            List<GroupMember>  groupMembers = CALSTA_CustomUtils.getGroupMembers(queueName);
            for (GroupMember gm : groupMembers) {            
                idList.add(gm.userOrGroupId);            
            } 
            User[] usr = [SELECT Id,name,email FROM user WHERE id IN :idList];        
            for(User u : usr) { 
                QueueMembersList.add(u);
            }
        }
        return QueueMembersList; 
    }   

}