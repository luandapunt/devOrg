@isTest
private class ZTOrderRequestJSONCreater
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
		String test01 = OrderRequestJSONCreater.execute('1', '2');
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(ctrl != null);
    }
}