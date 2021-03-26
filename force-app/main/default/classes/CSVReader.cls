/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 *
 * @author  Marty Y. Chang
 * @version beta
 */
public class CSVReader {
    /**
     * Returns a List containing Lists of Strings that represents
     * the values contained in an IETF RFC 4180-compliant CSV file.
     *
     * Each element in the outer list represents a row in the CSV file.
     * Each element in the inner list is the value in the field specified
     * by the row-column combination.
     *
     * @param  file the CSV file to read
     * @return      the List<List<String>> containing values read from the
     *              CSV file
     */
    public static List<List<String>> readIETFRFC4180CSVFile(Blob file) {
        String fileString = file.toString();
        
        if (!fileString.endsWith(Parser.CRLF)) {
          fileString = fileString + Parser.CRLF;
        }
        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();
        
        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
          System.debug(fileString);
          
            csvValue = readIETFRFC4180CSVValue(fileString);
            
            rowValues.add(csvValue.value);
            
            if (csvValue.delimiter == Parser.CRLF) {
              fileValues.add(rowValues);
              
              System.debug(rowValues);
              
              if (fileValues.size() > 0) {
                System.assertEquals(fileValues.get(0).size(),
                      rowValues.size());
              }
              
              rowValues = new List<String>();
            }
            
            if (csvValue.biteSize() == fileString.length()) {
              eod = true;
            }
            else {
              fileString = fileString.substring(csvValue.biteSize());
            }
        }
        
        return fileValues;
    }
    
    /**
     * Returns the first String value read from a String representation of
     * data contained in an IETF RFC 4180-compliant CSV file.
     *
     * The data is assumed to be terminated with a CRLF.
     *
     * @param  data the textual CSV data in one long string
     * @return      the first CSV value read from <code>data</code>.
     *              null is returned if no value is discerned.
     */
    public static CSVValue readIETFRFC4180CSVValue(String data) {
        System.assert(data.endsWith(Parser.CRLF));
        
        CSVValue csvValue = new CSVValue();
        
        if (data.startsWith(Parser.DQUOTE)) {
          csvValue.enclosed = true;
          
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE
                            
            Boolean closerFound = false;
            
            while (!closerFound) {
                dquoteIndex = data.indexOf(Parser.DQUOTE, searchIndex);
                
                dquotesIndex = data.indexOf(Parser.DQUOTEDQUOTE,
                        searchIndex);
                
                System.assert(dquoteIndex != -1);
                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex
                            + Parser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }
            
            csvValue.value = data.substring(
                    Parser.DQUOTE.length(), dquoteIndex)
                            .replaceAll(Parser.DQUOTEDQUOTE, Parser.DQUOTE);
            
            Integer commaIndex = data.indexOf(Parser.COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(Parser.CRLF, dquoteIndex);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.delimiter = Parser.CRLF;
            }
        }
        else {
          csvValue.enclosed = false;
          
            Integer commaIndex = data.indexOf(Parser.COMMA);
            Integer crlfIndex = data.indexOf(Parser.CRLF);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = Parser.CRLF;
            }
        }
        
        System.debug('Returning: ' + csvValue);
        
        return csvValue;
    }
    
    /**
     * CSVValue is a class structure containing information about a CSV
     * value that was read from a CSV file, including such information as
     * whether the value was encapsulated in double-quotes.
     */
    private class CSVValue {
        /**
         * The field value that was read from the CSV file.
         */
        public String value;
        
        /**
         * Whether the value was surrounded by double-quotes.
         */
        public Boolean enclosed;
        
        /**
         * The comma or CRLF delimiter that identified the end of the CSV value.
         */
        public String delimiter;
        
        /**
         * Default constructor, setting all members to null.
         */
        public CSVValue() {
            this(null, null, null);
        }
        
        /**
         * Constructor.
         *
         * @param value     the field value
         * @param enclosed  whether the value was surrounded by double-quotes
         * @param delimiter the delimiter that identified the end
         *                  of the CSV value
         */
        public CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }
        
        /**
         * Returns the number of characters to remove from the data
         * String which produced the CSVValue in order to reach the next
         * value in the data String.
         */
        public Integer biteSize() {
          Integer biteSize = value
                 .replaceAll(Parser.DQUOTE, Parser.DQUOTEDQUOTE).length()
                         + delimiter.length();
          
          if (enclosed) {
            biteSize += Parser.DQUOTE.length() * 2;
          }
          
          System.debug('biteSize: ' + biteSize);
          
          return biteSize;
        }
        
        /**
         * Returns whether a CSVValue has the same <code>value</code> and
         * <code>enclosed</code> as another CSVValue.
         */
        public Boolean equals(CSVValue compCSVValue) {
            return this.value.equals(compCSVValue.value)
                    && this.enclosed == compCSVValue.enclosed
                            && this.delimiter == compCSVValue.delimiter;
        }
        
        /**
         * Asserts that two <code>CSVValue</code> instances have the same
         * <code>value</code> and <code>enclosed</code>.
         */
        public void assertEquals(CSVValue compCSVValue) {
            System.assertEquals(value, compCSVValue.value);
            System.assertEquals(enclosed, compCSVValue.enclosed);
            System.assertEquals(delimiter, compCSVValue.delimiter);
        }
    }
    
    /**
     * Test some use cases for reading IETF RFC 4180-compliant CSV values.
     */
    public static testMethod void readIETFRFC4180CSVValueTest() {
        String data = null;  // Placeholder for data to use in testing.
        
        System.debug(data = Parser.CRLF);
        new CSVValue('', false, Parser.CRLF)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = '""' + Parser.CRLF);
        new CSVValue('', true, Parser.CRLF)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"",asdf' + Parser.CRLF);
        new CSVValue('', true, Parser.COMMA)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = ',asdf' + Parser.CRLF);
        new CSVValue('', false, Parser.COMMA)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"' + Parser.CRLF + '",blah' + Parser.CRLF);
        new CSVValue(Parser.CRLF, true, Parser.COMMA)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"""marty""","""chang"""' + Parser.CRLF);
        new CSVValue('"marty"', true, Parser.COMMA)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"com""pli""cate' + Parser.CRLF + 'd"'
                + Parser.CRLF);
        new CSVValue('com"pli"cate' + Parser.CRLF + 'd', true, Parser.CRLF)
                .assertEquals(readIETFRFC4180CSVValue(data));
        
        System.debug(data = 'asdf' + Parser.CRLF);
        new CSVValue('asdf', false, Parser.CRLF)
                .assertEquals(readIETFRFC4180CSVValue(data));
    }
    
    /**
     * Tests one case of parsing a CSV file that contains the following data:
     *
     * abc,"def","g""h""i"
     * "j
     * kl","m
     * n""o""",
     */
    public static testMethod void readIETFRFC4180CSVFile() {
      String data = 'abc,"def","g""h""i"' + Parser.CRLF + '"j' + Parser.CRLF
             + 'kl","m' + Parser.CRLF + 'n""o""",';
      
      List<List<String>> fileValues =
             readIETFRFC4180CSVFile(Blob.valueOf(data));
    }
}