public with sharing class RMTRemittanceSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Remittance__c.Id,
			Remittance__c.OrderLkp__c,
			Remittance__c.StatusFml__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Remittance__c.sObjectType;
	}
	
	public List<Remittance__c> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0}, OrderLkp__r.CaseLkp__c, OrderLkp__r.CaseLkp__r.Status, OrderLkp__r.CaseLkp__r.RecordType.DeveloperName ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet',
            new List<String>{
                getFieldListString(),
                getSObjectName()                     
            }
        );  

        return (List<Remittance__c>)Database.query(query);       
    }
}