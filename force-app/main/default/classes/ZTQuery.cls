@isTest
private class ZTQuery
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
	   	Account account1 = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account1;
    	
    	// Start Test
		System.Test.startTest();
		
		Schema.SObjectType accountType = Schema.getGlobalDescribe().get('Account');
		Query query1 = new Query(accountType);
		
    	Query.QueryCondition queryCondition = new Query.QueryCondition(Account.Name.getDescribe().getSObjectField(), Query.QueryConditionType.EQUALS, account1);
    	
    	
    	Query test01 = query1.find(new List<Query.QueryCondition>{queryCondition});
		Query test02 = query1.wherez();
    	Query test03 = query1.with(new List<String>{'Contacts'});
    	Query test04 = query1.limitTo(10);
    	Query test05 = query1.orderBy('Name');
    	Query test06 = query1.with('Contacts');
    	String test07 = query1.toSOQL();
    	List<String> test08 = query1.getFieldList();
    	
    	Query query2 = new Query(accountType);
		List<SObject> test09 = query2.all();
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(lstAccountAddress != null);
    }
}