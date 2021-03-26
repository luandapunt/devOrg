public with sharing class CSEInvoiceItemSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		InvoiceItem__c.Id,
    		InvoiceItem__c.ProductLkp__c,
    		InvoiceItem__c.QuantityNmb__c,
    		InvoiceItem__c.DenominationTxt__c
    	};
    }
    
    public Schema.SObjectType getSObjectType() {
    	return InvoiceItem__c.sObjectType;
    }
    
    public List<InvoiceItem__c> selectById(Set<Id> idSet) {
    	String query = String.format(
    		' SELECT {0}' +
    		' FROM {1}' +
    		' WHERE Id IN :idSet' +
    		' ORDER BY {2}',
    		new List<String>{
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<InvoiceItem__c>)Database.query(query);
    }
    
    public List<InvoiceItem__c> selectByInvoiceId(Id invoiceId) {
    	String query = String.format(
    		' SELECT {0}, ProductLkp__r.Name, ProductLkp__r.Id' +
    		' FROM {1}' +
    		' WHERE InvoiceMdt__c = :invoiceId' +
    		' ORDER BY {2}',
    		new List<String>{
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<InvoiceItem__c>)Database.query(query);
    }
}