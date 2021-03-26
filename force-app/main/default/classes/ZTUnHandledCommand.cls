@isTest
private class ZTUnHandledCommand
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
    	UnHandledCommand un = new UnHandledCommand();
    	un.execute(null);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(un != null);
    }
}