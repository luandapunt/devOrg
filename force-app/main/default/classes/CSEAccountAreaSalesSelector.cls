public with sharing class CSEAccountAreaSalesSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		AccountAreaSales__c.Id,
    		AccountAreaSales__c.FiscalClassificationTxt__c
    	};
    }
    
    public Schema.SObjectType getSObjectType() {
    	return AccountAreaSales__c.sObjectType;
    }
    
    public List<AccountAreaSales__c> selectById(Set<Id> idSet) {
    	String query = String.format(
    		' SELECT {0} ' +
    		' FROM {1}' +
    		' WHERE Id IN :idSet' +
    		' ORDER BY {2}',
    		new List<String> {
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<AccountAreaSales__c>)Database.query(query);
    }
    
    public List<AccountAreaSales__c> selectByAccountId(Set<Id> accountIdSet) {
    	String query = String.format(
    		' SELECT {0} ' +
    		' FROM {1} ' +
    		' WHERE AccountLkp__c IN :accountIdSet' +
    		' ORDER BY {2}',
    		new List<String> {
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<AccountAreaSales__c>)Database.query(query);
    }
}