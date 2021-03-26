public with sharing class integ_CustomOperationAccount implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationAccount::execute() ' + recordList);
		List<Account> accountList = new List<Account>();
		accountList.addAll((List<Account>)recordList);
        
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        skipVal.Skip__c = true;

        update skipVal;
        
		upsert accountList CodeCustomerTxt__c;
        
        skipVal.Skip__c = false;
        update skipVal;
        
		return accountList;
	}
}