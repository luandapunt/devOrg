public with sharing class CSECaseInvoiceSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			CaseInvoice__c.Id,
			CaseInvoice__c.CaseMdt__c,
			CaseInvoice__c.OrderLkp__c,
			CaseInvoice__c.CreditNmb__c,
			CaseInvoice__c.ExtendDaysNmb__c,
			CaseInvoice__c.QuotaNmb__c,
			CaseInvoice__c.InvoiceLkp__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return CaseInvoice__c.sObjectType;
	}
	
	public List<CaseInvoice__c> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0}, OrderLkp__r.Name, InvoiceLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<CaseInvoice__c>)Database.query(query);       
    }
    
    public List<CaseInvoice__c> selectByCase(String caso) {

        String query = String.format(
            ' SELECT {0}, OrderLkp__r.Name, InvoiceLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE CaseMdt__c = :caso' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<CaseInvoice__c>)Database.query(query);       
    }
}