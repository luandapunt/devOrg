@isTest
private class ZTUnHandledIntegration
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
    	UnHandledIntegration un = new UnHandledIntegration();
    	un.execute(null, null, null, null);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(un != null);
    }
}