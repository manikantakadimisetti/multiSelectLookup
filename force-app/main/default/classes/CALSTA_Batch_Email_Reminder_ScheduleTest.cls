@isTest
public class CALSTA_Batch_Email_Reminder_ScheduleTest {
    static testMethod void emailReminder(){
        CALSTA_Batch_Email_Reminder_Schedulable emailScheduleReminder=new CALSTA_Batch_Email_Reminder_Schedulable();
        string cronJob='0 0 12 * * ?';
        Test.startTest();
        system.schedule('Test Schedule', cronJob, emailScheduleReminder);
        test.stopTest();
        
    }

}