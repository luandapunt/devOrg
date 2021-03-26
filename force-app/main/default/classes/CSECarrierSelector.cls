public with sharing class CSECarrierSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Carrier__c.Id,
			Carrier__c.Name,
			Carrier__c.EmailTxt__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Carrier__c.sObjectType;
	}
	
	public List<Carrier__c> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0} ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<Carrier__c>)Database.query(query);       
    }
    
}