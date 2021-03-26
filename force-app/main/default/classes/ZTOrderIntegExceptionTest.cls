@isTest
private class ZTOrderIntegExceptionTest
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
		try {
			Integer value = 1 / 0;
		}
		catch (Exception ex) {
			new OrderIntegException(ex, 'Divion by zero');
		}
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(ctrl != null);
    }
}