/**
*--------------------------------------------------------------------------------------
* Version#     Date                           Author                    Description
*--------------------------------------------------------------------------------------
*    1.0      07-OCT-2019                   GTP Dev Team               Initial Version
*--------------------------------------------------------------------------------------
*/
global class CALSTA_IM_GOAR_Email_Schedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
      CALSTA_IM_GOAR_Email_Notification emailNotification = new CALSTA_IM_GOAR_Email_Notification(); 
	   Database.executeBatch(emailNotification);
    }
}