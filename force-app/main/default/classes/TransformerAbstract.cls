/**
 * @author: Diéffrei T. de Quadros
 * @date: 01/03/2016
 * @description:
 */
public abstract with sharing class TransformerAbstract {
	
	public class TransformerAbstractException extends Exception {}
	
	public Map<String, integ_IFieldCast> fieldCastMap;
	
	public TransformerAbstract() {
			
			/*
				Map implementations of field transformers by type and responsability
			*/
			this.fieldCastMap = new Map<String, integ_IFieldCast> {
				integ_FieldTypes.STRINGZ => new integ_FieldCastString(),
				integ_FieldTypes.BOOLEANZ => new integ_FieldCastBoolean(),
				integ_FieldTypes.DECIMALZ => new integ_FieldCastDecimal(),
				integ_FieldTypes.INTEGERZ => new integ_FieldCastInteger(),
				integ_FieldTypes.LOOKUP => new integ_FieldCastLookup(),
				integ_FieldTypes.LOOKUP_FORMULA => new integ_FieldCastLookupFormula(),
				integ_FieldTypes.FORMULA => new integ_FieldCastFormula()
			};
			
	}
	
	/*
		Converts raw data data to List<SObject>
	*/
	public abstract List<SObject> convertToSObjectList(IntegrationMap__c integrationMap, String jsonData);
	
	/*
		Converts List<SObject> to raw data 
	*/
	public abstract String convertToRawData(List<SObject> sObjectRecordList);
	
	/*
		return cast implementation by field type (arugment key type)
	*/
	public integ_IFieldCast getFieldCastImpl(String keyType) {
		integ_IFieldCast fieldCastImpl = fieldCastMap.get(keyType);
		if (fieldCastImpl == null){
			throw new TransformerAbstractException('integ_IFieldCast implementation for [' + keyType + ']' + 'not found.');
		}
		return fieldCastImpl;
	}
	
}