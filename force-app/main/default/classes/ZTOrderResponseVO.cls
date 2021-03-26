@isTest
private class ZTOrderResponseVO
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
    	OrderResponseVO obj = new OrderResponseVO();
    	String test1 = obj.invoiceData;
    	String test2 = obj.orderData;
    	String test3 = obj.shippingData;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(obj != null);
    }
}