public class StringUtils {
    
    static String diacritic 	= 'çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÜÃÕÑâêîôûÂÊÎÔÛ';
    static String nonDiacritic  = 'cCaeiouyAEIOUYaeiouAEIOUaonaeiouyAEIOUAONaeiouAEIOU';
    static Map<Integer, Integer> table;
    static {
        table = new Map<Integer, Integer>();
        
        for (Integer i = 0; i < diacritic.length(); i++) {
            table.put(diacritic.charAt(i), nonDiacritic.charAt(i));
        }
    }

    /**
    * Method responsible for removing diacritics.
    * @param a String
    * @return a integer list
    */
    public static String removeDiacritics (String s) {
        
        if (String.isBlank(s)) return s;
        
        List<Integer> chars = new List<Integer>();
        for (Integer i = 0; i < s.length(); i++) {
            Integer ch = s.charAt(i);
            
            Integer replacedChar = table.get(ch);
            
            if (replacedChar == null)
                replacedChar = ch;
      
            chars.add(replacedChar);    
        }
        return String.fromCharArray(chars);
    }
    
    /**
    * Method to truncate a string that matches with the length condition
    * @param a String and a Integer
    * @return truncated string
    */
    public static String truncate (String s, Integer position) {
         if (String.isBlank(s)) return s;
        String result = s.length() > position ? s.substring(0, position) : s;
        return result;
    }
    
    public static String toEmpty (String s) {
        if (String.isBlank(s)) return '';
        return s;
    }

    /*public static String normalizeRemoveSpecialChars(String str) {
        if (String.isBlank(str)) return str;
        
        return removeDiacritics(str).replaceAll('[^a-zA-Z0-9]', '').toUpperCase();
    } */   
    
    /**
    * Method to remove left padding zeros from a String
    * @param a String
    * @return string without left padding zeros
    */
    public static String removeLeftPadZeros(String str){
        return str.replaceFirst('^0+', '');
    }
}