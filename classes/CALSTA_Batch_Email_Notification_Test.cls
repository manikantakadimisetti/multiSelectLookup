@isTest(seeAllData=true)

public class CALSTA_Batch_Email_Notification_Test {
 
    static testMethod void emailNotification(){
        Account acc=new Account();
        acc.Name='California Highway Patrol';
        insert acc;
        ID getRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Governor’s Office Action Request (GOAR)-Legislative Reports').getRecordTypeId();
        Case obj=new Case();
        obj.AccountId=acc.id;
        obj.Subject='Test1';
        obj.Action_requested__c='Approval';
        obj.Approve_Status__c='Draft';
        obj.RecordTypeId=getRecordTypeId;
        obj.Date_of_IM__c=date.today();
        
        insert obj;
      
        CALSTA_Batch_Email_Notification executeJob=new CALSTA_Batch_Email_Notification();
        test.startTest();
        Database.executeBatch(executeJob);
    }

}