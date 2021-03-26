@isTest
private class ZTOrderRequestByOrderNumberJSON
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
		OrderRequestByOrderNumberJSON json = new OrderRequestByOrderNumberJSON();
		String test = json.PEDIDO;
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(ctrl != null);
    }
}