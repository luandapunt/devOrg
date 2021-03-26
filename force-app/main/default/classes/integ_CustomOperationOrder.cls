public with sharing class integ_CustomOperationOrder implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
        
        System.debug(LoggingLevel.INFO, '*** integ_CustomOperationOrder::execute() ' + recordList);
		system.debug('ALOU CUSTOMOPERATIONORDER: ');
		List<Order__c> orderList = new List<Order__c>();
		orderList.addAll((List<Order__c>)recordList);
		
		Map<String, Order__c> orderMap = new Map<String, Order__c>();
		
		//unify list by inv
		for (Order__c ord : orderList) {
            system.debug('ordem atual: '+ord);
            system.debug('ordem caso atual: '+ord.CaseLkp__c);
			if (!orderMap.containsKey(ord.CustomIDTxt__c)) {
				orderMap.put(ord.CustomIDTxt__c, ord);
			}
		}
		
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        skipVal.Skip__c = true;
        update skipVal;
        
		orderList = orderMap.values(); 
		System.debug('*** orderList' + orderList);
		
        
        
		//System.debug('=======================External ID da ordem: ' + Order__c.CustomIDTxt__c);
		//
		Database.UpsertResult[] resultList = Database.upsert(orderList, Order__c.CustomIDTxt__c, true);
		
        skipVal.Skip__c = false;
        update skipVal;
        
		integer i = 0;
		for (Database.UpsertResult result : resultList) {
			if (!result.isSuccess()) {
        		System.debug(LoggingLevel.INFO, '*** DML ERROR : integ_CustomOperationOrder::execute() ' + orderList[i] +  result.getErrors());
        		
			}
			i++;
		}
		
		return orderList;
	}
}