public with sharing class CSEOrderSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Order__c.Id,
			Order__c.Name,
			Order__c.AccountLkp__c,
			Order__c.SellerLkp__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Order__c.sObjectType;
	}
	
	public List<Order__c> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0}, AccountLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<Order__c>)Database.query(query);       
    }
    
    public List<Order__c> selectByNumber(String orderNumber) {

        String query = String.format(
            ' SELECT {0}, AccountLkp__r.Name, CaseLkp__r.CaseNumber, SellerLkp__r.SellerEmailTxt__c, SellerLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE Name = :orderNumber' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  

        return (List<Order__c>)Database.query(query);       
    }
}