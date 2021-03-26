@isTest
private class ZTCSVIterator
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	CSVIterator iterator = new CSVIterator('fileDatafile', 'Data');
    	
    	iterator.iterator();
    	iterator.hasNext();
    	iterator.next();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(iterator != null);
    }
}