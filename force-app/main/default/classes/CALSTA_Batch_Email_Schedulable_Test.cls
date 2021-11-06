@isTest
public class CALSTA_Batch_Email_Schedulable_Test {
    static testmethod void emailSchedule(){
        CALSTA_Batch_Email_Schedulable email=new CALSTA_Batch_Email_Schedulable();
        string cron='0 0 9 * * ?';
        test.startTest();
        system.schedule('TestSchedule', cron, email);
        test.stopTest();
        
    }

}