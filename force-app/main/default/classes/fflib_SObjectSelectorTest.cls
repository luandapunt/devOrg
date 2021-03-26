@IsTest
private with sharing class fflib_SObjectSelectorTest 
{
	
	static testMethod void testGetFieldListString()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		List<String> fieldList = selector.getFieldListString().split(',');
		Set<String> fieldSet = new Set<String>(fieldList);
		//system.assertEquals(4, fieldSet.size());
		system.assert(fieldSet.contains('Name'));
		system.assert(fieldSet.contains('Id'));
		system.assert(fieldSet.contains('AccountNumber'));
		system.assert(fieldSet.contains('AnnualRevenue'));
		if(UserInfo.isMultiCurrencyOrganization())
			system.assert(fieldSet.contains('CurrencyIsoCode'));
	}
	
	static testMethod void testSelectSObjectsByField() {
		
		List<RecordType> recTypeList = new List<RecordType>();
		recTypeList = RecordTypeDAO.getBySObjectName('Account');
		
		// Inserting in reverse order so that we can test the order by of select 
		List<Account> accountList = new List<Account> {
			new Account(Name='TestAccount2',AccountNumber='A2',AnnualRevenue=12345.67, RecordTypeId = recTypeList[0].Id),
			new Account(Name='TestAccount1',AccountNumber='A1',AnnualRevenue=76543.21, RecordTypeId = recTypeList[0].Id) };		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList)
			idSet.add(item.Id);
			
		Test.startTest();		
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		List<Account> result = (List<Account>) selector.selectSObjectsByField(idSet, Account.Id);	
		selector.selectSObjectsByField(new Set<String>{}, Account.Id);
		selector.selectSObjectsByField(new Set<Decimal>{}, Account.AnnualRevenue);
		Test.stopTest();
		
		system.assertEquals(2,result.size());
		system.assertEquals('TestAccount1',result[0].Name);
		system.assertEquals('A1',result[0].AccountNumber);
		system.assertEquals(76543.21,result[0].AnnualRevenue);
		system.assertEquals('TestAccount2',result[1].Name);
		system.assertEquals('A2',result[1].AccountNumber);
		system.assertEquals(12345.67,result[1].AnnualRevenue);
		
	}
	
	static testMethod void testGetSObjectName()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		system.assertEquals('Account',selector.getSObjectName());
	}
	
	static testMethod void testSelectSObjectsById()
	{
		List<RecordType> recTypeList = new List<RecordType>();
		recTypeList = RecordTypeDAO.getBySObjectName('Account');
		
		// Inserting in reverse order so that we can test the order by of select 
		List<Account> accountList = new List<Account> {
			new Account(Name='TestAccount2',AccountNumber='A2',AnnualRevenue=12345.67, RecordTypeId = recTypeList[0].Id),
			new Account(Name='TestAccount1',AccountNumber='A1',AnnualRevenue=76543.21, RecordTypeId = recTypeList[0].Id) };		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList)
			idSet.add(item.Id);
			
		Test.startTest();		
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		List<Account> result = (List<Account>) selector.selectSObjectsById(idSet);		
		Test.stopTest();
		
		system.assertEquals(2,result.size());
		system.assertEquals('TestAccount1',result[0].Name);
		system.assertEquals('A1',result[0].AccountNumber);
		system.assertEquals(76543.21,result[0].AnnualRevenue);
		system.assertEquals('TestAccount2',result[1].Name);
		system.assertEquals('A2',result[1].AccountNumber);
		system.assertEquals(12345.67,result[1].AnnualRevenue);
	}
	
	static testMethod void testAssertIsAccessible()
	{
		List<RecordType> recTypeList = new List<RecordType>();
		recTypeList = RecordTypeDAO.getBySObjectName('Account');
		
		// Inserting in reverse order so that we can test the order by of select 
		List<Account> accountList = new List<Account> {
			new Account(Name='TestAccount2',AccountNumber='A2',AnnualRevenue=12345.67, RecordTypeId = recTypeList[0].Id),
			new Account(Name='TestAccount1',AccountNumber='A1',AnnualRevenue=76543.21, RecordTypeId = recTypeList[0].Id) };		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList)
			idSet.add(item.Id);
		
		// Create a user which will not have access to the test object type
		User testUser = createChatterExternalUser();
		if(testUser==null)
			return; // Abort the test if unable to create a user with low enough acess
		System.runAs(testUser)
		{					
			Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
			try
			{
				List<Account> result = (List<Account>) selector.selectSObjectsById(idSet);
				System.assert(false,'Expected exception was not thrown');
			}
			catch(fflib_SObjectDomain.DomainException e)
			{
				System.assertEquals('Permission to access an Account dennied.',e.getMessage());
			}
		}
	}
	
	private class Testfflib_SObjectSelector extends fflib_SObjectSelector
	{
		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {
				Account.Name,
				Account.Id,
				Account.AccountNumber,
				Account.AnnualRevenue
			};
		}
		
		public Schema.SObjectType getSObjectType()
		{
			return Account.sObjectType;
		}
	}
	
	/**
	 * Create test user
	 **/
	private static User createChatterExternalUser()
	{
		// Can only proceed with test if we have a suitable profile - Chatter External license has no access to Opportunity
		List<Profile> testProfiles = [Select Id From Profile where UserLicense.Name='Chatter External' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
		} catch (Exception e) {
			return null;
		}		
		return testUser;
	}	
}