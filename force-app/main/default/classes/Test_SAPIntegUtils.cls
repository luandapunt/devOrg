@isTest
private class Test_SAPIntegUtils {
    @isTest static void testRemoveAllButNumbers(){
        String fullString = '(11) 9999-9999';
        String justNumbersString = SAPIntegUtils.removeAllButNumbers(fullString);
        System.assertEquals('1199999999', justNumbersString);
        fullString = '55.927.649/0001-44';
        justNumbersString = SAPIntegUtils.removeAllButNumbers(fullString);
        System.assertEquals('55927649000144', justNumbersString);
        fullString = '797.453.163.943';
        justNumbersString = SAPIntegUtils.removeAllButNumbers(fullString);
        System.assertEquals('797453163943', justNumbersString);
    }
    
    @isTest static void testGetType(){
        Boolean boolValue = true;
        String strType = SAPIntegUtils.getType(boolValue);
        System.assertEquals('Boolean', strType);
        String strValue = 'Hello World';
        strType = SAPIntegUtils.getType(strValue);
        System.assertEquals('String', strType);		
        Account accValue = new Account();
        strType = SAPIntegUtils.getType(accValue);
        System.assertEquals('Account', strType);
        Account nullValue;
        strType = SAPIntegUtils.getType(nullValue);
        System.assertEquals('', strType);
		Blob blobValue = Blob.valueof(strValue);
        strType = SAPIntegUtils.getType(blobValue);
        System.assertEquals('Blob', strType);        
        Date dateValue = Date.newInstance(1960, 2, 17);
        strType = SAPIntegUtils.getType(dateValue);
        System.assertEquals('Date', strType);
        Datetime dateTimeValue = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        strType = SAPIntegUtils.getType(dateTimeValue);
        System.assertEquals('Datetime', strType);
        Time timeValue = Time.newInstance(18, 30, 2, 20);
        strType = SAPIntegUtils.getType(timeValue);
        System.assertEquals('Time', strType);
        Integer intValue = 100;
        strType = SAPIntegUtils.getType(intValue);
        System.assertEquals('Integer', strType);
       	Long longValue = 2147483648L;
        strType = SAPIntegUtils.getType(longValue);
        System.assertEquals('Long', strType);
        Decimal decimalValue = 20.10;
        strType = SAPIntegUtils.getType(decimalValue);
        System.assertEquals('Decimal', strType);      
        Map<String, String> mapValue = new Map<String, String>();
        strType = SAPIntegUtils.getType(mapValue);
        System.assertEquals('Object', strType);   
        /*if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets*/
    }   

    @isTest static void testWriteStringField(){
        JSONGenerator gen = JSON.createGenerator(true);   
        String strField = 'Value1';
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'FIELD1', strField);
        gen.writeEndObject();
        
        JSONGenerator genExpected = JSON.createGenerator(true);
        genExpected.writeStartObject();
        genExpected.writeStringField('FIELD1', strField);
        genExpected.writeEndObject();
            
        System.assertEquals(genExpected.getAsString(),  gen.getAsString());
        
        JSONGenerator gen2 = JSON.createGenerator(true);   
        String strFieldNull;
        gen2.writeStartObject();
        SAPIntegUtils.writeStringField(gen2, 'FIELD1', strFieldNull);
        gen2.writeEndObject();
        
        JSONGenerator genExpected2 = JSON.createGenerator(true);
        genExpected2.writeStartObject();
        genExpected2.writeStringField('FIELD1', '');
        genExpected2.writeEndObject();
            
        System.assertEquals(genExpected2.getAsString(),  gen2.getAsString());
    }
}