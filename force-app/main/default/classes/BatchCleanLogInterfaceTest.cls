@isTest
public class BatchCleanLogInterfaceTest {
	 public static testMethod void testBatch() {
     	LogInterface__c batchTest = new LogInterface__c();
       // batchTest.CreatedDate = System.today();
        //batchTest.Name = 'Teste Batch';
        //batchTest.CurrencyIsoCode = 'USD';  
        
        insert batchTest;
         
        Database.executeBatch(new BatchCleanLogInterface(0));   
     }
}