/* 
 * This trigger is used to handle all the events on Case Object
 *--------------------------------------------------------------------------------------
 * Version#     Date                           Author                    Description
 *--------------------------------------------------------------------------------------
 *    1.0      04-Sep-2019                   GTP Dev Team               Initial Version
 *--------------------------------------------------------------------------------------
 */
Trigger CALSTA_RequestTrigger on Case(after insert,after update,after delete,before insert, before update,before delete) 
{
    CALSTAConfiguration__c  calstaConfiguration= CALSTAConfiguration__c.getOrgDefaults();
	if(calstaConfiguration.Is_Active_Case_Trigger__c){	
		CALSTA_RequestTriggerHelper.RequestTriggerExecute(trigger.New,trigger.Newmap,trigger.Old,trigger.Oldmap,trigger.isAfter,trigger.isBefore,trigger.isInsert,trigger.isUpdate,trigger.isDelete);
	}
}