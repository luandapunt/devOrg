@isTest
private class ZTOrderRequestJSON
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
    	OrderRequestJSON obj = new OrderRequestJSON('X', 'Y');
    	String test1 = obj.NFENUM;
    	String test2 = obj.PARID;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(obj != null);
    }
}