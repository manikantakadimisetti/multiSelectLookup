@isTest(seeAllData=true)
private class CALSTA_IM_GOAR_Email_Notification_Test {
    static testMethod void testEmailNotification() 
    {        
        Account acc = [Select Id,Name from Account where name='Board of Pilot Commissioners'];
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        
        Case cs = new Case ();
        cs.Subject = 'Testing schedule';
        cs.Tracking_Number__c ='Test12345';
        cs.Status = 'Draft';
        cs.RecordTypeId = RecordTypeIdCase;
        cs.AccountId = acc.Id;
        cs.Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1);
        cs.Constituent_Address__c = 'Bangalore';
        cs.Action_requested__c = 'Approval';
        cs.Date_of_IM__c = date.today();           
        insert cs;
        
        Test.startTest();   
        
        CALSTA_IM_GOAR_Email_Notification obj = new CALSTA_IM_GOAR_Email_Notification();
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}