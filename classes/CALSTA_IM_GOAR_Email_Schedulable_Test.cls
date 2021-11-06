@isTest
private class CALSTA_IM_GOAR_Email_Schedulable_Test {
    private static testMethod void testschedule() {
        
        //Test.StartTest();
        CALSTA_IM_GOAR_Email_Schedulable sh1 = new CALSTA_IM_GOAR_Email_Schedulable();
        
        String sch = '0 0 23 * * ?';
        system.schedule('Test GOAR Email Schedulable', sch, sh1);
        //Test.stopTest(); 
    }
}