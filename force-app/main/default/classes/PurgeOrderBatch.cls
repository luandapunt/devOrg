global class PurgeOrderBatch implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		List<Case> caseList = new List<Case>();
		Set<Id> orderIdSet = new Set<Id>();

		//selecting cases that are related to invoices or orders
		//or the order date was in the last 30 days
		caseList = [SELECT Id, OrderLkp__r.Id, InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id 
						FROM Case
							WHERE (OrderLkp__c != null OR InvoiceLkp__c != null)
							OR (OrderLkp__r.OrderDateDte__c = LAST_N_DAYS:30 OR InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.OrderDateDte__c = LAST_N_DAYS:30)
					];

		for (Case cse : caseList) {
			if (cse.OrderLkp__r != null) {	
				orderIdSet.add(cse.OrderLkp__r.Id);				
			} else if (cse.InvoiceLkp__r != null) {
				if (cse.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r != null) {					
					orderIdSet.add(cse.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id);
				}
			}
		}

		return Database.getQueryLocator([
											SELECT Id, CaseLkp__c, OrderDateDte__c,  (SELECT Id FROM Remessas__r), 
												(SELECT Id FROM Notas_fiscais__r)
												FROM Order__c
												WHERE Id NOT IN: orderIdSet
												AND CaseLkp__c = null
												AND OrderDateDte__c < LAST_N_DAYS:30
										]);

	}

   	global void execute(Database.BatchableContext BC, List<Order__c> orderList) {

		List<Order__c> orderToDelete = new List<Order__c>();
		List<Remittance__c> shippingToDelete = new List<Remittance__c>();
		List<Invoice__c> invoiceToDelete = new List<SObject>();
		
		for(Order__c ord : orderList){
			orderToDelete.add(ord);
			shippingToDelete.addAll(ord.Remessas__r);
			invoiceToDelete.addAll(ord.Notas_fiscais__r);
		}

		Database.delete(invoiceToDelete);
		Database.delete(shippingToDelete);
		Database.delete(orderToDelete);

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}