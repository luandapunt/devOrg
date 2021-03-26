public class OrderRequestJSON {
    //public String invoiceNumber {get;set;}
    //public String customerCode {get;set;}
    //public String orderNumber {get;set;}
    
    public String NFENUM {get;set;}
    public String PARID {get;set;}
    
    public OrderRequestJSON(String invoiceNumber, String customerCode) {
    	NFENUM = invoiceNumber;
    	PARID = customerCode;
    }
}