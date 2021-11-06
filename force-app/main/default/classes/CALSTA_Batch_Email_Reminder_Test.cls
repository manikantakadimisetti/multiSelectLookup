@isTest
public class CALSTA_Batch_Email_Reminder_Test {
   
    @testSetup
    static void calledGroupAndGroupMembers(){
    	
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        //creating user
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User user1=new User(firstname = 'ABC',lastName = 'XYZ',email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1',Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',ProfileId = pf.Id);
        insert user1;
        
        //creating group
    	Group testGroup = new Group();
        testGroup.Name = 'abctest';
        testGroup.Type='Queue';
        testGroup.DeveloperName = 'ABCD';
        insert testGroup; 
        //Creating Group Members
        GroupMember grpMem = new GroupMember();
        grpMem.UserOrGroupId =user1.id;
        grpMem.GroupId = testGroup.id;
        insert grpMem;
        
        
}
    
    static testmethod void emailReminderCalledFunction1(){
       
        Account acc=new Account();
        acc.Name='Department of Transportation';
        insert acc;
              
        ID getRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Governor’s Office Action Request (GOAR)').getRecordTypeId();
        
       
        //fetching group details
        Group gp=[SELECT Id,Name FROM Group where group.name=:'abctest'];
      	system.debug(gp.name);
        //creating case record
        Case obj=new Case();
        obj.AccountId=acc.id;
        obj.Subject='Test2';
        obj.Action_requested__c='Approval';
        obj.Approve_Status__c='Draft';
        obj.RecordTypeId=getRecordTypeId;
        obj.Date_of_IM__c=date.today();
        obj.Reviewer__c=gp.name;
        insert obj;
       
       
        CALSTA_Batch_Email_Notification_Reminder executeJob=new CALSTA_Batch_Email_Notification_Reminder();
        test.startTest();
        Database.executeBatch(executeJob);
        test.stopTest();
        
        
        }
    static testmethod void emailReminderCalledFunction2(){
       Account acc=new Account();
        acc.Name='Department of Transportation';
        insert acc;
        
        ID getRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Governor’s Office Action Request (GOAR)').getRecordTypeId();
         
        //Fetching user details
       user u1=[select id,name from user where user.name=:'ABC XYZ'];
       //creating case record
        Case obj=new Case();
        obj.AccountId=acc.id;
        obj.Subject='Test2';
        obj.Action_requested__c='Approval';
        obj.Approve_Status__c='Draft';
        obj.RecordTypeId=getRecordTypeId;
        obj.Date_of_IM__c=date.today();
      	obj.Reviewer__c=u1.name;
        insert obj;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(obj.id);
        
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(u1.Id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the case
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
		        
        System.assertEquals('Pending', result.getInstanceStatus());
        
        CALSTA_Batch_Email_Notification_Reminder executeJob=new CALSTA_Batch_Email_Notification_Reminder();
        test.startTest();
        Database.executeBatch(executeJob);
        test.stopTest();
        
        }
    

}