@isTest
public class ScheduledBatchCleanLogInterfaceTest {
    public static testMethod void testScheduledBatch(){
        
        insert new LogInterfaceExpurgo__c(Days__c = 60);
        // Schedule the test job
        String scheduleJob = '0 0 0 3 9 ? 2025';
        
        String jobId = System.schedule('testBasicScheduledApex',
                                       scheduleJob,
                                       new ScheduledBatchCleanLogInterface());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(scheduleJob, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2025-09-03 00:00:00',
                            String.valueOf(ct.NextFireTime));
    }
}