global class CALSTA_Batch_Email_Schedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
      CALSTA_Batch_Email_Notification emailNotification = new CALSTA_Batch_Email_Notification(); 
	   Database.executeBatch(emailNotification);
    }
}