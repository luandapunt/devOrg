public with sharing class integ_FieldCastDecimal implements integ_IFieldCast {
    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 
			return Double.valueOf(fieldValue);
	}
}