@isTest
private class ZTCSECaseDOM
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	Case test1 = CSECaseDOM.getSampleObject();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}