public with sharing class UniqueIdConfigurator implements ICustomFieldConfigurator {
	
	public void configure(Schema.SObjectField customIdField, List<SObject> recordList, List<Schema.SObjectField> fieldList) {
		for (SObject record : recordList){
			record.put(customIdField, IdUtil.generateUUID());
		}
	}
    
}