public with sharing class ParentAccountSaleFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		
		System.debug('***** ParentAccountSaleFormula' + externalDataMap);
		
		String parentCode = String.valueOf(externalDataMap.get('KUNNR'));
		String childCode = String.valueOf(externalDataMap.get('KUNN2'));
		String result = null;
		
		if (parentCode != childCode) {
			result = parentCode;
		}
		
		return result;
	}
}