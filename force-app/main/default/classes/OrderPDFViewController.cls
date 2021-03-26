public with sharing class OrderPDFViewController {
    public Order__c orderHeader {get;set;}
    public List<OrderItem__c> orderItemList {get;set;}
    public string totalValue {get;set;}
    public string orderNum {get;set;}
    
    public String getDynamicFormatString()
    {
        Decimal value = 1000.10;
        String formattedValue = value.format();
        String thousandSep = formattedValue.substring(1,2);
        String decimalSep = formattedValue.substring(5,6);
        System.debug('{0,number,#'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'##0'+decimalSep+'00}');
        return '{0,number,#'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'##0'+decimalSep+'00}';
    }
    
    public OrderPDFViewController (ApexPages.StandardController stdController){        
        
        Order__c orderHeader = new Order__c();
        orderHeader = (Order__c) stdController.getRecord();
        
        orderHeader = 	[	SELECT	Id, name, OrderNumberTxt__c, AccountLkp__c, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c, AccountReceiverLkp__c, OrderTypeTxt__c,
                         			PaymentTermLkp__c, CustomIDTxt__c, TotalLiquidPriceNmb__c, IPITotalValueNmb__c, TotalSTValueNmb__c, TotalPriceNmb__c, NetWeightKgNmb__c, QuotationBln__c, 
                         			PriceExpirationFml__c, CreatedDate
            				FROM	Order__c
                         	WHERE	Id =: orderHeader.Id
        				];
        
        orderNum = orderHeader.CustomIDTxt__c;
        
        totalValue = string.valueof(orderHeader.TotalPriceNmb__c).replace(',','*').replace('.',',').replace('*','.');
        
        orderItemList = [	SELECT Id, Name, ProductLkp__r.Name, ProductLkp__r.ProductCodeTxt__c, OrderQuantityNmb__c, LiquidNmb__c, ItemTotalFml__c, UnitPriceNmb__c, UnitPriceIPINmb__c, 
                         	IPIValueFml__c, IPIPercentFml__c, FinalPriceFml__c, STValueFml__c, ValueST__c, ValueIPI__c, ValueICMS__c, ValueROBNoIPIFml__c, ValueROBFml__c, ValueROLFml__c,
                         	UnitValueROLFml__c, UnitValueROBFml__c
                          	FROM OrderItem__c
                            WHERE OrderMdt__c =: orderHeader.Id 
                         	//AND UnitPriceNmb__c != null
                        ];                
    }    
}