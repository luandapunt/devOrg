@isTest
private class ZTCSEOrderDOM
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	Order__c test1 = CSEOrderDOM.getSampleObject();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}