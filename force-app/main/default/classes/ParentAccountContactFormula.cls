public with sharing class ParentAccountContactFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		
		System.debug('***** ParentAccountContactFormula' + externalDataMap);
		
		String parentCode = String.valueOf(externalDataMap.get('KUNNR'));
		String childCode = String.valueOf(externalDataMap.get('PARNR'));
		String result = null;
		
		if (parentCode != childCode) {
			result = parentCode;
		}
		
		return result;
	}
}