@isTest
private class ZTSoql
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	Soql soql = new Soql();
    	Soql test1 = soql.addLine('AND X = Y');
    	String test2 = soql.toString();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
		System.assert(test2 != null);
    }
}