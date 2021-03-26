@isTest
private class ZTCSERecordTypeSelector
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account'});
    	
    	// Start Test
		System.Test.startTest();
		
		List<RecordType> test1 = new CSERecordTypeSelector().selectById(new Set<Id>{mapRecType.get('BusinessAccountSAC')});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}