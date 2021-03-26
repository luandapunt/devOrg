@isTest
private class ZTCSEEmailMessageDOM
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	EmailMessage test1 = CSEEmailMessageDOM.getSampleObject();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}