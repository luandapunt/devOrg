public with sharing class integ_CustomOperationSalesArea implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationSalesArea::execute() ' + recordList);
		List<AccountAreaSales__c> accAreaSaleList = new List<AccountAreaSales__c>();
		accAreaSaleList.addAll((List<AccountAreaSales__c>)recordList);
		upsert accAreaSaleList CustomIdTxt__c;
		return accAreaSaleList;
	}
	
}