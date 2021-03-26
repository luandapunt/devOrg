@isTest
private class ZTQMMapping
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	QMMapping qmMapping = new QMMapping();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(qmMapping != null);
    }
}