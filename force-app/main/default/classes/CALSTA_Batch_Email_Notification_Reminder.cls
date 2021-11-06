//Reminder for reviewers & approvals 
global class CALSTA_Batch_Email_Notification_Reminder implements Database.Batchable<sObject> {
    
    //Started Batch Class, Getting Request records list when Approve_Status__c is Reviewed and Draft
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer count = 0;
        DateTime todayDate = DateTime.Now();
        Integer days= integer.valueOf(System.label.Due_Days_Count_for_Reminder_Email_Notifications);
        set<date> holidaySet = new set<date>();
        
        
         //* Take the No.of Days from label
         //* have for loop on that count and add the days to label value if there are saturdays and sundays
         //* then will get a final date including satuday and sunday
         //* then have query on holidays withing this date if there are any again add the days to it also add extra days if sat and sun comes in it
         //* take that final date and have it in the query
         
        integer counting = days;
        
        
        for(holiday dt:[select ActivityDate  from holiday]){
            holidaySet.add(dt.ActivityDate);
        }
        for(integer i=0;counting!=0;i++){
            if((todayDate-i).format('EEEE') == 'Sunday' || (todayDate-i).format('EEEE') == 'Saturday' || holidaySet.contains(date.today()-i)){  
                days++;
            }else{
                counting--;
            }
        }              

        dateTime dateTrigger = (DateTime.Now()-Integer.valueOf((days)));
        System.debug('dateTrigger	====>	'+dateTrigger);
        List<ProcessInstance> Check = [SELECT TargetObjectId FROM ProcessInstance where Status='pending' AND lastModifiedDate <=: dateTrigger];
        Set<id> CaseIds = new Set<id>();
        For(ProcessInstance PI:Check){
            CaseIds.add(PI.TargetObjectId);
        }
        return Database.getQueryLocator('select id,Confidential__c,Status, Approve_Status__c,forwadedReviewers__c,Approvers__c,Reviewer__c from case where Approve_Status__c IN (\'Reviewed\',\'Draft\',\'Secretory Approval\')'+'AND id IN :CaseIds' );
    }
    
    // Executing batch class and calling sendEmailNotification method
    global void execute(Database.BatchableContext bc, List<Case> requests){
        system.debug('requests ++ '+ requests);
        sendEmailNotification(requests);
    }    
    
    global void finish(Database.BatchableContext bc){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@Final');
    }   
    
    /**
*  Sending Email Notification to  record type related Queue 
* _______________________________________________________________
* 	 
*  @param     requests    List<Case>        
* _________________________________________________________________
* 
*/
    private static void sendEmailNotification(List<Case> requests){
        
        List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
        Map<String,List<String>> cseRevMap = new Map<String,List<String>>();
        List<String> templist = new List<String>();
        String templateId = CALSTA_CustomUtils.emailTemplateIdsMap.get('Reminder_Email_to_Reviewer_Queue');
        //OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        map<id,user> activeMap = new map<id,user> ([select id,IsActive  from user]);
        for(Case req:requests){
            if(req.Reviewer__c != NUll){
                if(req.Confidential__c){
                    List<String> reviewerList1 = (req.Reviewer__c).split(';');
                    for(string str:reviewerList1){
                        if(cseRevMap.containsKey(str)){
                            templist=cseRevMap.get(str);
                            templist.add(req.Id);
                            cseRevMap.put(str,templist);
                        }else{
                            cseRevMap.put(str,new List<String>{req.Id});
                        }
                    }
                }else{
                    if(cseRevMap.containsKey(req.Reviewer__c) && !req.Confidential__c){
                        templist=cseRevMap.get(req.Reviewer__c);
                        templist.add(req.Id);
                        cseRevMap.put(req.Reviewer__c,templist);
                    }else{
                        cseRevMap.put(req.Reviewer__c,new List<String>{req.Id});
                    }
                }
            }
        }
        system.debug('===='+cseRevMap);
        
        for(Group grp:[SELECT Id,Name,Type,(SELECT Id,UserOrGroupId FROM GroupMembers) FROM Group where Name IN:cseRevMap.keySet()]){
            for(String caseId:cseRevMap.get(grp.Name)){
                for(GroupMember groupMem:grp.GroupMembers){
                    if(cseRevMap.containsKey(groupMem.UserOrGroupId)){
                        templist=cseRevMap.get(groupMem.UserOrGroupId);
                        templist.add(caseId);
                        cseRevMap.put(groupMem.UserOrGroupId,templist);
                    }else{
                        cseRevMap.put(groupMem.UserOrGroupId,new List<String>{caseId});
                    }
                    /*System.debug(activeMap.get(groupMem.UserOrGroupId).isActive);
                    if(activeMap.get(groupMem.UserOrGroupId).isActive){
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, groupMem.UserOrGroupId,caseId);
                        //new Messaging.SingleEmailMessage();
                        //Messaging.renderStoredEmailTemplate(templateId, groupMem.UserOrGroupId,caseId);
                        String  subject = email.getSubject();
                        String body = email.gethtmlBody();
                        //
                        //email.setTemplateId(templateId);
                        //email.setWhatId(caseId);
                        //
                        email.setTargetObjectId(groupMem.UserOrGroupId);
                        email.setSubject(subject);
                        email.sethtmlBody(body);
                        if(owa != null){
                            email.setOrgWideEmailAddressId(owa.id); 
                        }
                        email.saveAsActivity = false;    
                        singleEmailMessagesList.add(email);
                    }*/
                }
            }
        }        
        
        for(User usr:[select Id,Name  from User where name IN:cseRevMap.keySet() AND isActive = true]){
            for(String caseId:cseRevMap.get(usr.Name)){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, usr.Id , caseId);
                String subject = email.getSubject();
                String body = email.gethtmlBody();
                //email.setTargetObjectId(usr.Id);
                email.setSubject(subject);
                email.sethtmlBody(body);
                email.setOrgWideEmailAddressId(System.label.CIMTS_Org_Wide_Email_Address_Id);
                /*
                if(owa != null){
                    email.setOrgWideEmailAddressId(System.label.CIMTS_Org_Wide_Email_Address_Id); 
                }*/
                email.saveAsActivity = false;    
                singleEmailMessagesList.add(email);       
            }
        }
        if(singleEmailMessagesList != null && singleEmailMessagesList.size()>0){
            Messaging.sendEmail(singleEmailMessagesList);  
        }    
    }
}