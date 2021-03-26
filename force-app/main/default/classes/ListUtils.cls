public with sharing class ListUtils {
    public static Boolean contains(List<Object> baseList, Object obj) {
    	for(Object aux : baseList) {
    		if(aux == obj) {
    			return true;
    		}
    	}
    	return false;
    }
}