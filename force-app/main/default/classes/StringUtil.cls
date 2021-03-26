public with sharing class StringUtil {
 	
 	/*
 		Converts "1" to "00000001";
 	*/
 	public static String leftPadding(Integer length, String paddingChar, String value) {
		value = value.leftPad(length);
		value = value.replaceAll(' ', paddingChar);
		return value;
 	}
 	
 	public static String leftTrim(String source) {
 		
 		String lastChar = '';
 		Boolean copyAll = false;
 		String newString = '';
 		
 		Integer i = 0;
 		for(i = 0; i < source.length(); i++) {
 			String currentChar = source.substring(i, i+1);
 			System.debug('current ' +  currentChar);
 			if(lastChar.equals('0') && !currentChar.equals('0') && !copyAll) {
 				copyAll = true;					
 			}
 			if(copyAll) {
 				newString += currentChar;
 			}	
 		}
 		return newString;	
 	}
 	   
}