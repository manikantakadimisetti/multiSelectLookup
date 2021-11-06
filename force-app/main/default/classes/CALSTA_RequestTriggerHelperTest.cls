@isTest(seeAllData=true)
private class CALSTA_RequestTriggerHelperTest {
    static testMethod void updateTrackingNumbers() {
        Account acc = [select id,Name from Account where name = 'Board of Pilot Commissioners'];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        
        Case cs = new Case(
            Status='Draft', 
            AccountId=acc.id,
            RecordTypeId = RecordTypeIdCase,
            Subject='Test IM NCB',
            Action_requested__c = 'For Information Only',
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),
            Date_of_IM__c = date.today());
        
        Test.startTest();        
        insert cs;  
        cs.Status ='Completed';
        update cs;
        Test.stopTest();
    }
    static testMethod void caseAssignToEmailNotification() {
        Account acc = [select id,Name from Account where name = 'Board of Pilot Commissioners'];
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Goldenrod').getRecordTypeId();
        Case css = new Case(
            Status='Draft', 
            AccountId=acc.id,
            Subject='Test Goldenrod', 
            Department_Sent_To__c = acc.id,
            Constituent_Address__c = 'Address',
            RecordTypeId = RecordTypeIdCase);
        insert css;
    }
    static testMethod void statusChangedEmailTemplates() {        
        
        Account acc = [select id,Name from Account where name = 'Board of Pilot Commissioners'];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        Case cs = new Case(
            AccountId=acc.id,
            RecordTypeId = RecordTypeIdCase,
            Subject='Test IM NCB',
            Date_of_IM__c = date.today(),
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),
            Approve_Status__c = 'Not Started',
            Status = 'Draft',
            Action_requested__c = 'Approval');
        insert cs;        
        
        cs.Date_Revision_Due_Back_From_Dept__c = date.today().adddays(2);
        cs.Status = 'Pending at Department for Revision';
        update cs; 
        cs.Status = 'Completed';
        update cs; 
        
    }
    static testMethod void statusChangedEmailTemplatesforGOARStatus(){
        Account acc = [select id,Name from Account where name = 'Board of Pilot Commissioners'];
        Id GOARRecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Governor’s Office Action Request (GOAR)').getRecordTypeId();
        Case cs1 = new Case(
            AccountId=acc.id,
            RecordTypeId = GOARRecordTypeIdCase,
            Subject='Test GOAR',
            Date_of_IM__c = date.today(),
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),            
            Status = 'Pending at Agency',
            Submitted_to_the_GO_On__c = date.today(),
            Action_requested__c = 'Approval');
        insert cs1;
        cs1.Status = 'Pending at GO';       
        update cs1;
        cs1.Status = 'GO Approved; Completed';
        update cs1;
        cs1.Status = 'GO Denied; Completed';
        update cs1;
        cs1.Status = 'GO Approved; CalSTA Action Pending';
        update cs1;
        cs1.Status = 'GO Denied; CalSTA Action Pending';
        update cs1;  
    }
    
    static testMethod void statusChangedEmailTemplatestoGOAR(){
        Account acc1 = [select id,Name from Account where Name = 'Department of Motor Vehicles'];
        Id GOARRecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Governor’s Office Action Request (GOAR)').getRecordTypeId();
        
        Case cs2 = new Case(
            AccountId=acc1.id,
            RecordTypeId = GOARRecordTypeIdCase,
            Subject='Test GOAR1',
            Date_of_IM__c = date.today(),
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),            
            Status = 'Pending at Agency',
            Submitted_to_the_GO_On__c = date.today(),
            Action_requested__c = 'Approval');
        insert cs2;
        cs2.Status = 'Approved By CalSTA; Pending At GO';
        cs2.Submitted_to_the_GO_On__c = System.Today()-1;
        update cs2;
    }
    static testMethod void statusChangedEmailTemplatestoIMs(){
        Account acc1 = [select id,Name from Account where Name = 'Department of Motor Vehicles'];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        
        Case cs2 = new Case(
            AccountId=acc1.id,
            RecordTypeId = RecordTypeIdCase,
            Subject='Test IM pending at Go',
            Date_of_IM__c = date.today(),
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),            
            Status = 'Pending at Agency',
            Submitted_to_the_GO_On__c = date.today(),
            Action_requested__c = 'Approval');
        insert cs2;
        cs2.Status = 'Pending at GO';        
        update cs2;
    }
    static testMethod void statusChangedtoPendingatAgencyforCalSTADepartment() {
        Account acc = [select id,Name from Account where name = 'California State Transportation Agency'];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Goldenrod').getRecordTypeId();
        Profile pf = [Select Id from Profile where Name = 'Department User'];
        Case cs = new Case(
            Status='Pending at Agency', 
            Department_Sent_To__c = acc.id,
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),
            Constituent_Address__c = 'Address',
            RecordTypeId = RecordTypeIdCase);
        insert cs;      
        cs.Department_Sent_To__c = acc.id;
        cs.Status = 'Pending at Agency';
        update cs;
        
        Profile pf1 = [Select Id from Profile where Name = 'Agency User'];
        Case cs1 = new Case(
            Status='Pending at Agency', 
            Department_Sent_To__c = acc.id,
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),
            Constituent_Address__c = 'Address',
            RecordTypeId = RecordTypeIdCase);
        insert cs1;        
        cs1.Status = 'Completed';
        pf1.Name = 'Agency User';
        update cs1;      
    }
    static testMethod void checkingCCStatusatCompleted(){
        Account acc = [select id,Name from Account where Name = 'Department of Motor Vehicles'];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Constituent Concern').getRecordTypeId();
        
        Profile pf1 = [Select Id from Profile where Name = 'Department User'];       
        
        Case cs1 = new Case(
            Status='Pending at Agency', 
            Department_Sent_To__c = acc.id,
            Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1),
            Constituent_Address__c = 'Address',
            RecordTypeId = RecordTypeIdCase);			      
        insert cs1;      
        
        cs1.Status = 'Completed';       
        pf1.Name = 'Department User';
        update cs1;
    }
    
    static testMethod void ccStatusCompletedFileAttachement()
    {
        UserRole r = [Select Id,Name,DeveloperName from UserRole where Name ='Department of Motor Vehicles'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Department User']; 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User usr = new User(Alias = uid, Email= uid + '@myorg2.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/New_York', UserName= uid + '@myorg2.com',UserRoleId = r.Id );  
        insert usr;   
        
        system.runAs(usr)
        {
            Account acc = [select id,Name from Account where Name = 'Department of Motor Vehicles'];
            Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Constituent Concern').getRecordTypeId();
            
            Profile pf1 = [Select Id from Profile where Name = 'Department User'];
            Case cs = new Case(
                Status='Pending at Agency', 
                Department_Sent_To__c = acc.id,                
                Constituent_Address__c = 'Address',
                RecordTypeId = RecordTypeIdCase);			      
            insert cs;  
            
            String yourFiles = 'Lets assume this is your binary string of the files';
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'ionicLogo.png'; 
            conVer.Title = 'Testing Files '; 
            conVer.VersionData = EncodingUtil.base64Decode(yourFiles); 
            insert conVer;            
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;            
            
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = cs.Id; 
            cDe.ShareType = 'I'; 
            cDe.Visibility = 'AllUsers';
            insert cDe;
            
            test.startTest();                                 
            pf1.Name = 'Department User';
            cs.Date_Completed__c = System.today();
            cs.Status = 'Completed';
            update cs;
            test.stopTest();
        }
    }
    
}