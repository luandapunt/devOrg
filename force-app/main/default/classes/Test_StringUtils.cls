@isTest
private class Test_StringUtils {
    @isTest static void testRemoveDiacritics(){
        String diacriticString = 'São Paulo SÃO PAULO Piauí PIAUÍ Valença VALENÇA Itajubá ITAJUBÁ Hórus HÓRUS';
        String nonDiacriticString = StringUtils.removeDiacritics(diacriticString);
        System.assertEquals('Sao Paulo SAO PAULO Piaui PIAUI Valenca VALENCA Itajuba ITAJUBA Horus HORUS', nonDiacriticString);
    }
    
    @isTest static void testTruncate(){
        String longString = 'Salesforce Test';
        String shortString = StringUtils.truncate(longString, 8);
        System.assertEquals('Salesfor', shortString);
        shortString = StringUtils.truncate(longString, 11);
        System.assertEquals('Salesforce ', shortString); 
        shortString = StringUtils.truncate(longString, 20);
        System.assertEquals('Salesforce Test', shortString); 
    }
    
    @isTest static void testToEmpty(){
        String nullString;
        String emptyString = StringUtils.toEmpty(nullString);
        System.assertEquals('', emptyString); 
        
        String notNullString = 'Apex Test';
        emptyString = StringUtils.toEmpty(notNullString);
        System.assertEquals('Apex Test', emptyString); 
    }
    
    @isTest static void testRemoveLeftPadZeros(){
        String paddedStr = '0000999999';
        String nonPaddedStr = StringUtils.removeLeftPadZeros(paddedStr);
        System.assertEquals('999999', nonPaddedStr);
        
        paddedStr = '0000999909';
        nonPaddedStr = StringUtils.removeLeftPadZeros(paddedStr);
        System.assertEquals('999909', nonPaddedStr);
        
        paddedStr = '999099';
        nonPaddedStr = StringUtils.removeLeftPadZeros(paddedStr);
        System.assertEquals('999099', nonPaddedStr);
    }
}