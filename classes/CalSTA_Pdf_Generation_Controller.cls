/**
*--------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      07-OCT-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/
public class CalSTA_Pdf_Generation_Controller {    
    public Case caseobj{get;set;} 
    public account department{get;set;}
    public String recordTypeName{get;set;} 
    public Map<String,boolean> instructionPickListValuesList {get;set;}
    public Boolean isInstructionValid{get;set;}
    public Boolean isSectionVisible{get;set;}   
    public String initialDuetoText{get;set;}
    public List<ApprovalHistoryWrapper> approvalHistoryWrapperList{get;set;}
    
    /** 
    * __________________________________________________________________________
    * 
    * This constructor is used to display data in Print PDF
    * __________________________________________________________________________
    */
    public CalSTA_Pdf_Generation_Controller(){              
        
        
        string recordId = ApexPages.currentPage().getParameters().get('id');       
            
            caseobj =[SELECT Id,RecordTypeId,Department_Sent_To__c,Account.Name,Date_Received_by_CalSTA__c,Issue_Memo_Type__c,Request_Due_Date__c  ,Related_to_Red_Flag_Issue__c,Transmitting_Mandated_Report__c ,Revision_of_Previous_version__c,Eventual_recipient_if_differ_than_above__c, Due_Date_to_Eventual_Recipient__c, Days_overdue_to_Eventual_Recipient__c, Date_Completed__c,Date_Due_to_CALSTA__c,Date_of_IM__c,Under_review_or_being_processed_by__c ,Date_Revision_Due_Back_From_Dept__c  ,Date_Received__c ,Subject , Tracking_Number__c, CreatedDate, Date_Due__c, Initially_Due_To__c,Days_Overdue__c, Number_of_Days_Overdue__c,Action_requested__c ,CreatedBy.Name, Status, GO_Tracking_Number__c, Date_Due_to_the_GO__c, Date_CalSTA_Received_from_GO__c, Constituent_Name__c, Constituent_Address__c, Constituent_Phone__c, Constituent_Email__c, Date_of_Correspondence__c, Date_of_Transmittal__c, Submitted_Duplicate_Correspondence__c, Instructions_to_the_Department__c FROM Case Where Id=: recordId];
            if(caseobj.Department_Sent_To__c !=null){
                department = [SELECT Id,Name FROM account where Id =: caseobj.Department_Sent_To__c];            
            }
            
            RecordType rtype = [SELECT Name, DeveloperName, Id FROM RecordType where id=:caseobj.RecordTypeId];
            recordTypeName = rtype.Name;
            isSectionVisible =true;
            if(recordTypeName == 'Constituent Concern'){
                isSectionVisible =false;
            }
            if(recordTypeName == 'Governor’s Office Action Request (GOAR)' || recordtypename == 'Governor’s Office Action Request (GOAR)-Scheduling' || recordtypename == 'Governor’s Office Action Request – Legal (GOAR)' ){           
                initialDuetoText = 'Governors Office';    
            }
        	
           /** 
             * _______________________________________________________
             * 
             * Getting Instruction to department picklist values 
             * ________________________________________________________
             */
            Map<String,boolean> pickListValuesList = new Map<String,boolean>();
            Schema.DescribeFieldResult fieldResult = Case.Instructions_to_the_Department__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                isInstructionValid = false;
                if(pickListVal.getLabel() == caseobj.Instructions_to_the_Department__c ){
                    isInstructionValid = true; 
                }                          
                pickListValuesList.put(pickListVal.getLabel(),isInstructionValid);
            }                      
            instructionPickListValuesList = pickListValuesList;    
            approvalHistoryWrapperList = getApprovalHistoryList(recordId);
    }
    
    /** 
    * __________________________________________________________________________
    * 
    * This method is used for checking if logged user is department user or not
    * __________________________________________________________________________
    */
	@AuraEnabled
    public static Boolean departmentUser(){
          Boolean isDepartmentUser=false;
         String departmentUserProfile = [select Name from profile where id =: userinfo.getProfileId()].Name;
        if(departmentUserProfile =='Department User'){
            isDepartmentUser=true;
        }
        return isDepartmentUser;
    }
    
    /** 
    * __________________________________________________________________________
    * 
    * This method is used for getting approval process data     
    * _________________________________________________________________________
    * 
    * @param       recId                             Id
    * @return      List<ApprovalHistoryWrapper>
    * __________________________________________________________________________
    */
    public static List<ApprovalHistoryWrapper> getApprovalHistoryList(Id recId){      
        Id recordId = recId;         
        List<ApprovalHistoryWrapper> approvalHistoryWrapperList = new List<ApprovalHistoryWrapper>();
        for(ProcessInstance processInstance: getProcessHistory(recordId).values()){                   
            Map<Id, String> reassignCommentsMap = new Map<Id, String>(); 
            List<CalSTA_Reassign_Comments__c> reassignComments = [SELECT Id, Name, ProcessStepId__c, TargetObjectId__c,Comments__c FROM CalSTA_Reassign_Comments__c where TargetObjectId__c =:recordId];
            for(CalSTA_Reassign_Comments__c Comments : reassignComments){
                reassignCommentsMap.put(Comments.ProcessStepId__c, Comments.Comments__c);               
            }
           	String comments = null;
            String stepStatus =null;
            String assignedByName = null;
            String actorName = null; 
            String originalactorName =null;
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
                }   
                
                if(sWI.StepStatus == 'Started'){
                    approvalHistoryWrapperList.add(new ApprovalHistoryWrapper(sWI.CreatedDate, originalactorName, 'Submitted',actorName, comments,'Approval Request Submitted',sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                }else{
                    approvalHistoryWrapperList.add(new ApprovalHistoryWrapper(sWI.CreatedDate, originalactorName, stepStatus,actorName, comments,sWI.ProcessNode.Name,sWI.OriginalActorId,sWI.ActorId,sWI.Id,assignedByName,sWI.TargetObjectId)); 
                } 
             }                   
        }      
             
        return approvalHistoryWrapperList;         
    }  
    
    /** 
    * __________________________________________________________________________
    * 
    * This method is used for getting approval data using SOQL query     
    * _________________________________________________________________________
    * 
    * @param       objectId                             Id
    * @return      Map<Id,ProcessInstance>
    * __________________________________________________________________________
    */
    public static Map<Id,ProcessInstance> getProcessHistory(Id objectId){  
        return new Map<Id,ProcessInstance>([SELECT Id,Status,SubmittedById, (SELECT Id, ProcessNodeId, StepStatus, Comments, TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name, OriginalActor.Name ,CreatedBy.Name, ProcessNode.Name FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC ) 
                                            FROM ProcessInstance where TargetObjectId =: objectId order by CreatedDate DESC]);  
    }  
    
     /** _____________________________________________
     * 
	 *	 This class is used for declaring variables 
	 *  _______________________________________________
     */    
    public class ApprovalHistoryWrapper{ 
        
	    public DateTime createdDate {get;set;}         
        
        public string assignedTo {get;set;}        
       
        public string steps {get;set;}         
          
        public string actualApprovar {get;set;}        
        
        public string comments {get;set;}         
        
        public string processNode {get;set;}         
         
        public string OriginalActorId {get;set;}         
      
        public string ActualActorId {get;set;}         
        
        public string InstanceStepId {get;set;}      
       
        public string assignedBy {get;set;}
       
        public string TargetobjId {get;set;}       
        
         /* _____________________________________________
         * 
         *	 This contructor  is used for assigning values to variables
         *  _______________________________________________
         */
        public ApprovalHistoryWrapper(DateTime crDate, string name, string stp, string actor, string commnets, string processName, string OriginalId, string ActorId, string stepid,string assignedByName,string TargetId) {  
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
    
}