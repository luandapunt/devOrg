public with sharing class CSEAccountSelector extends fflib_SObjectSelector {
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.Name,
            Account.CodeCustomerTxt__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Account.sObjectType;
	}
	
	public List<Account> selectById(Set<Id> idSet) {
		
        String query = String.format(
            ' SELECT {0}, SellerLkp__r.SellerEmailTxt__c' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        
        System.debug(query);
        
        return (List<Account>)Database.query(query);       
    }
    
}