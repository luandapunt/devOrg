@isTest
private class ZTOrderRequestByCustomerLast30DaysJSON
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
		OrderRequestByCustomerLast30DaysJSON json = new OrderRequestByCustomerLast30DaysJSON('xpto');
		String test = json.PARID;
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(ctrl != null);
    }
}