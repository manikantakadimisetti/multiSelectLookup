@isTest(seealldata=true)
private class CalSTA_RequestApprovalProcessTest {
    
    static testmethod void releaseA(){
        Account acc3 = new account(name='Board of Pilot Commissioners');
        insert acc3;
        Id RecordTypeIdCase3 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (IM-PAL/IT)').getRecordTypeId();
        Case cs3 = new Case ();
        cs3.Confidential__c = true;
        cs3.Subject = 'Testing Record';
        cs3.Status = 'Draft';
        cs3.RecordTypeId = RecordTypeIdCase3;
        cs3.AccountId = acc3.Id;
        cs3.Constituent_Address__c = 'Bangalore';
        cs3.Action_requested__c = 'Approval';
        cs3.Date_of_IM__c = date.today();
        cs3.Reviewed_Comment_History__c = '{"005t0000005FLlSAAW":"2021-08-04 22:35:56===>Reviewed","005t0000005FLlTAAW":"2021-08-04 22:23:12===>Avital reviewed","005t0000005FLlRAAW":"2021-08-04 22:25:31===>check1"}';
        insert cs3;
        CalSTA_RequestApprovalProcessController.submitforApproveProcess(cs3.Id,'Comments');
        List<string> addReviewersList = new List<string> {userinfo.getUserId()};
            CalSTA_RequestApprovalProcessController.AddingReviewersToRequest('comments', cs3.Id,addReviewersList);
        CalSTA_RequestApprovalProcessController.reviewedProcess(cs3.Id, 'Comments');
        CalSTA_RequestApprovalProcessController.submitforApprovalButtonDisplay(cs3.Id);
        //CalSTA_RequestApprovalProcessController.ApproveProcess(cs3.Id,'Comments','finalApproval');
        CalSTA_RequestApprovalProcessController.getApprovalData(cs3.Id);
        CalSTA_RequestApprovalProcessController.buttonsDisplay(cs3.Id);
        CalSTA_RequestApprovalProcessController.fetchLookUpValues('test', 'user', cs3.Id);
        
        
    }
    static testMethod void validateApprovalProcess() {
        
        Account acc = new account(name='Board of Pilot Commissioners');
        insert acc;       
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (NCB)').getRecordTypeId();
        Case cs = new Case ();
        cs.Subject = 'Testing Record';
        cs.Status = 'Draft';
        cs.RecordTypeId = RecordTypeIdCase;
        cs.AccountId = acc.Id;
        cs.Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1);
        cs.Constituent_Address__c = 'Bangalore';
        cs.Action_requested__c = 'Approval';
        cs.Date_of_IM__c = date.today();
        insert cs;              

        Id RecordTypeIdCase2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Issue Memorandum (IM-PAL/IT)').getRecordTypeId();        
        Case cs2 = new Case ();
        cs2.Subject = 'Testing Record';
        cs2.Status = 'Draft';
        cs2.RecordTypeId = RecordTypeIdCase2;
        cs2.AccountId = acc.Id;
        cs2.Date_Revision_Due_Back_From_Dept__c = date.today().adddays(1);
        cs2.Constituent_Address__c = 'Bangalore';
        cs2.Action_requested__c = 'Approval';
        cs2.Date_of_IM__c = date.today();
        insert cs2;
        
        
        
        String submitforApprovalComments = 'Submit for approval';
        String forwardforApprovalComments = 'forwarded to next stage';
        String CalSTAfinalApprovalComments = 'finally approved';
        String rejectedComments = 'Send for Revision';
        String reassignComments = 'reassigned to some user';
        String reevaluateComments = 'reevaluated';
        String secretaryComments = 'send to Secretary Approval';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User usr = new User(Alias = uid, Email= uid + '@myorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');  
        insert usr;        
        
        IMPALIT__c settings = IMPALIT__c.getOrgDefaults();
        
        settings.DeputyId__c = UserInfo.getUserId();
        
        update settings;
        
        CalSTA_RequestApprovalProcessController.submitforApproveProcess(cs.Id, submitforApprovalComments);
        Test.startTest();
        System.runAs(usr){
        CalSTA_RequestApprovalProcessController.submitforApprovalButtonDisplay(cs.Id);
            CalSTA_RequestApprovalProcessController.buttonsDisplay(cs.Id);
        }
        
        CalSTA_RequestApprovalProcessController.ApproveProcess(cs.Id,forwardforApprovalComments,'reviewApproval');        
        CalSTA_RequestApprovalProcessController.ReassignProcess(usr, cs.Id, reassignComments);            
        rejectprocess(cs.Id,rejectedComments);
        secretoryApprovalProcess(cs.Id, secretaryComments);
        reEvaluateProcess(cs.Id,reevaluateComments);   
        CalSTA_RequestApprovalProcessController.getApprovalData(cs.Id);
        Test.stopTest();
       // CalSTA_RequestApprovalProcessController.fetchLookUpValues('test', 'user', cs.Id);
        //CalSTA_RequestApprovalProcessController.buttonsDisplay(cs.Id);
        

        //CalSTA_RequestApprovalProcessController.submitforApproveProcess(cs2.Id, submitforApprovalComments);
        //CalSTA_RequestApprovalProcessController.ApproveProcess(cs2.Id,forwardforApprovalComments,'reviewApproval');
        try{
        CalSTA_RequestApprovalProcessController.fetchLookUpValuesforwardapproval('test', 'user', cs2.Id);
        }
        catch(Exception ex)
        {
            
        }
        try{
        CalSTA_RequestApprovalProcessController.forwardApprovalProcess(cs2.Id,forwardforApprovalComments,'reviewApproval', usr);
        }
        catch(Exception ex)
        {
            
        }
    }
    static void rejectprocess(String recordId,String Comments){
        CalSTA_RequestApprovalProcessController.RejectProcess(recordId, Comments); 
    } 
    static void reEvaluateProcess(String recordId,String Comments){
        CalSTA_RequestApprovalProcessController.reEvaluateProcess(recordId, Comments);
    }
    static void secretoryApprovalProcess(String recordId,String Comments){
        CalSTA_RequestApprovalProcessController.secretoryApprovalProcess(recordId, Comments);        
    }
   
}