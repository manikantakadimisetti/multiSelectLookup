@isTest(seeAllData=true)
private class CalSTA_Pdf_Generation_Controller_Test {       
   
    static testmethod void validatePdfGenerationProcess(){        
        
        Account acc = [Select Id,Name from Account where name='Board of Pilot Commissioners'];      
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        
        Case cs = new Case ();
        cs.Subject = 'Testing Pdf Generation';
        cs.Tracking_Number__c ='Test12345';
        cs.Status = 'Draft';
        cs.RecordTypeId = RecordTypeIdCase;
        cs.AccountId = acc.Id;
        cs.Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1);
        cs.Constituent_Address__c = 'Bangalore';
        cs.Action_requested__c = 'Approval';
        cs.Date_of_IM__c = date.today();
        insert cs;                    
        
        String submitforApprovalComments = 'Submit for approval';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User usr = new User(Alias = uid, Email= uid + '@myorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/New_York', UserName= uid + '@myorg1.com');  
        insert usr;
        
        
        CalSTA_RequestApprovalProcessController.submitforApproveProcess(cs.Id, submitforApprovalComments);
        CalSTA_Pdf_Generation_Controller.getApprovalHistoryList(cs.Id);
        CalSTA_Pdf_Generation_Controller.departmentUser();     
        
        Id GoldenrodRecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Goldenrod').getRecordTypeId();
        
        Case cs1 = new Case ();
        cs1.Subject = 'Testing Goldenrod record';
        cs1.Tracking_Number__c ='Test12345';
        cs1.Status = 'Draft';
        cs1.RecordTypeId = GoldenrodRecordTypeIdCase;
        cs1.AccountId = acc.Id;
        cs1.Department_Sent_To__c = acc.Id;          
        cs1.Constituent_Address__c = 'Bangalore';
        cs1.Instructions_to_the_Department__c = 'Reply direct and furnish to CalSTA with copies';
        insert cs1;
        
        ApexPages.currentPage().getParameters().put('id',cs1.Id);        
        CalSTA_Pdf_Generation_Controller controller = new CalSTA_Pdf_Generation_Controller(); 
    }
    
   
}