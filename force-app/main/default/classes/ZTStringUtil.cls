@isTest
private class ZTStringUtil
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	String test1 = StringUtil.leftPadding(8, '0', '1');
    	
    	String test2 = StringUtil.leftTrim('1000000010'); // always return ''.
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 == '00000001', 'test1='+test1);
		System.assert(test2 == '', 'test2='+test2);
    }
}