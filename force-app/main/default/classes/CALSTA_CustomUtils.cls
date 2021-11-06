/**
*--------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      07-OCT-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/

public  class CALSTA_CustomUtils {
    
    public static Map<String,String> requestRTAcronymsMap;

    public static Map<String,String> queueListMap;
    
    public static Map<String,String> queueIdsMap;
    
    public static Map<String,String> queueNamesMap;
    
    public static Map<String,String> emailTemplateIdsMap;   
    public static OrgWideEmailAddress owa;
    static{
        owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        addKeyValuePairs();
     }
     
    /**
    * To Add all the key and  Value into keyValuePairs Map
    * 
    */
    private static void addKeyValuePairs(){
      requestRTAcronymsMap = new Map<String,String>();
      queueListMap = new Map<String,String>();
      queueIdsMap = new Map<String,String>();
      queueNamesMap = new Map<String,String>();
      emailTemplateIdsMap = new Map<String,String>();
      
		for(CALSTA_Case_Record_Types_With_Acronyms__mdt requestRecordType:[Select Id,Key__c, Value__c from CALSTA_Case_Record_Types_With_Acronyms__mdt]){
			requestRTAcronymsMap.put(requestRecordType.Key__c,requestRecordType.Value__c);
		}

		for(CALSTA_Queue_List__mdt queue:[Select Id,Key__c, Value__c from CALSTA_Queue_List__mdt]){
			queueListMap.put(queue.Key__c,queue.Value__c);
		}
        
        List<Group> calstaGroups = [Select Id, Name From Group Where Type='Queue'];
        for(Group calstaGroup:calstaGroups){
            queueIdsMap.put(calstaGroup.Name,calstaGroup.Id);
        }
        
        List<Group> calstaGrps = [Select Id, Name From Group Where Type='Queue'];
        for(Group calstaGroup:calstaGrps){
            queueNamesMap.put(calstaGroup.Id,calstaGroup.Name);
        }
        
        List<EmailTemplate> emailTemplates = [SELECT Id,name,DeveloperName FROM EmailTemplate where Folder.DeveloperName='CalSTA_Email_Templates'];
        for(EmailTemplate emailTemplate:emailTemplates){
            emailTemplateIdsMap.put(emailTemplate.DeveloperName,emailTemplate.Id);
        }
        
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Getting Queue Members
	 * ________________________________________________________________
	 * 	 
	 *  @param    queueName           String
	 *  @return   List<GroupMember> 
     * _______________________________________________________________________________
	 */     
    public static List<GroupMember> getGroupMembers(String queueName) {
        List<GroupMember> groupMembers = new  List<GroupMember>();
        Set<Id> userIds = new Set<Id>();
        Group gp = [SELECT Id,Type,(SELECT Id,UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = :queueName];
        
        for (GroupMember gm : gp.GroupMembers) {
            String  userOrGroupId= gm.UserOrGroupId;
            if(userOrGroupId.startsWith('005')){
               userIds.add(gm.UserOrGroupId);
			}
		}
         Map<ID, User> userMap = new Map<ID, User>([Select id from User where id in:userIds and IsActive=true]);
         for (GroupMember gm : gp.GroupMembers) {
               User usr = userMap.get(gm.userOrGroupId);
                if(usr != null){
                    groupMembers.add(gm);
                }	
			}  
        return groupMembers;
    }    
    
     /**
     * ________________________________________________________________
     * 
	 *  Sending email to single user
	 * ________________________________________________________________
	 * 	 
	 *  @param    templateId           String
	 *  @param    userId               String
	 *  @param    recordId             String
     * _______________________________________________________________________________
	 */    
    public static void sendEmail(String templateId,String userId, String recordId){		       
        if(templateId != null && userId != null && recordId != null ){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, userId, recordId);
            String  subject = email.getSubject();
            String body = email.gethtmlBody();
            email.setTargetObjectId(userId);
            email.setSubject(subject);            
            email.sethtmlBody(body);
            email.saveAsActivity = false;   
            if(owa != null){
            	email.setOrgWideEmailAddressId(owa.id); 
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
   		 }
    }    
   
     /**
     * ________________________________________________________________
     * 
	 *  Sending emails to Queue Members
	 * ________________________________________________________________
	 * 	 
	 *  @param    templateId           String
	 *  @param    queueName            String
	 *  @param    recordId             String
     * _______________________________________________________________________________
	 */ 
    public static  void sendEmailToQueue(String templateId,String queueName,String recordId ){       
         if(templateId != null && queueName != null && recordId != null ){           
             List<GroupMember> groupMembers= getGroupMembers(queueName);
             List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
             for(GroupMember groupMem:groupMembers){
                   Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, groupMem.UserOrGroupId, recordId);
                   String  subject = email.getSubject();
                   String body = email.gethtmlBody();
                   email.setTargetObjectId(groupMem.UserOrGroupId);
                   email.setSubject(subject);
                   email.sethtmlBody(body);
                   email.saveAsActivity = false;  
                   if(owa != null){
                     email.setOrgWideEmailAddressId(owa.id); 
                   }
                   singleEmailMessagesList.add(email);
              }
            Messaging.sendEmail(singleEmailMessagesList);               
         }
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Creating event for single user
	 * ________________________________________________________________
	 * 	 
	 *  @param    userId               String
	 *  @param    subjectInfo          String
	 *  @param    trackingNumber       String
     * _______________________________________________________________________________
	 */ 
    public static void createEventforUser(String userId,String subjectInfo, String trackingNumber){        
        if(subjectInfo != null && userId != null && trackingNumber != null ){
            Event evet= new Event
                (
                    Ownerid = userId,
                    Subject = subjectInfo+' '+trackingNumber,
                    StartDateTime = Datetime.now() ,
                    EndDateTime = Datetime.now().AddDays(3)
                );
            if(evet != null){
                insert evet;
            }
        }
    }   
    
     /**
     * ________________________________________________________________
     * 
	 *  Creating events for Queue Members
	 * ________________________________________________________________
	 * 	 
	 *  @param    queueName            String
	 *  @param    subjectInfo          String
	 *  @param    trackingNumber       String
     * _______________________________________________________________________________
	 */ 
    public static  void createEventforQueueMembers(String queueName, String subjectInfo, String trackingNumber){       
        if(queueName != null && subjectInfo != null && trackingNumber != null ){  
            List<Event> eventlist = new List<Event>();
            List<GroupMember>  groupMembers = getGroupMembers(queueName);
            for (GroupMember gm : groupMembers) {
                createEventforUser(gm.UserOrGroupId,subjectInfo,trackingNumber);               
            }
        }
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Getting Department Name
	 * ________________________________________________________________
	 * 	 
	 *  @param     recordId            Id
	 *  @return    String       
     * _______________________________________________________________________________
	 */ 
    public static String getDepartmentName(Id recordId){
        String deptName = null;    
        if(recordId != null){
            deptName = [SELECT Id,Name FROM account where Id =: recordId].Name;            
        }
        return deptName;
    }
    
     /**
     * ________________________________________________________________
     * 
	 *  Getting Department Queue Name
	 * ________________________________________________________________
	 * 	 
	 *  @param     accountId            Id
	 *  @return    String       
     * _______________________________________________________________________________
	 */ 
    public static String getDepartmentQueueName(Id accountId){ 
        String queueName = null;
        if(accountId != null){
            List<Account> depatments = [Select Id,name from Account where Id =:accountId ];
            Map<Id,String> departmentNames = new Map<Id,String>();				
            for(Account department:depatments){
                departmentNames.put(department.Id,department.name);
            }	         
            String departName = departmentNames.get(accountId);
             queueName = queueListMap.get(departName);
        }        
        return queueName;
    }

    /**
    * ________________________________________________________________
    * 
    *  Getting Queue User Ids
    * ________________________________________________________________
    * 	 
    *  @param     accountId            Id
    *  @return    String       
    * _______________________________________________________________________________
    */ 
   public static List<Id> getActiveUserIdsFromQueueName(String queueName){ 

    Set<Id> userIds = new Set<Id>();
    List<Id> ActiveUserIds = new List<Id>();
    Group gp = [SELECT Id,Type,(SELECT Id,UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = :queueName];
    for (GroupMember gm : gp.GroupMembers) {
        String  userOrGroupId= gm.UserOrGroupId;
        if(userOrGroupId.startsWith('005')){
            userIds.add(gm.UserOrGroupId);
        }
    }
    for (User usr : [Select id from User where id in:userIds and IsActive=true]) {
        ActiveUserIds.add(usr.Id);
    }
    return ActiveUserIds;
   }
}