global class CALSTA_Batch_Email_Reminder_Schedulable implements Schedulable{
	global void execute(SchedulableContext ctx) {
      CALSTA_Batch_Email_Notification_Reminder emailNotification = new CALSTA_Batch_Email_Notification_Reminder(); 
	   Database.executeBatch(emailNotification, 50);
    }
    
}