public with sharing class CustomerRemoteCall extends RestBaseServiceAbstraction
    implements integ_IRemoteCall{

    public String customerCode {get;set;}
    public Date fromDate {get;set;}
    public Date toDate {get;set;}

    public CustomerRemoteCall(String customerCode, Date fromDate, Date toDate) {
        super(ApexRedirectMap__c.getValues('WebServiceCustomer').UrlSufix__c);
        this.customerCode = customerCode;
        this.fromDate = fromDate;
        this.toDate = toDate;
    }
        
    /* Converts a Date type variable into a YYYYMMDDHHMMSSmmm format string. */
	public static String dateToSapForm(Date inputDate) {

		String year = String.valueOf(inputDate.year());
		String month = String.valueOf(inputDate.month());
		String day = String.valueOf(inputDate.day());

		if(inputDate.day() < 10) { day = '0' + day; }
		if(inputDate.month() < 10) { month = '0' + month; }
		if(inputDate.year() < 10) { year = '000' + year; }
		else if(inputDate.year() < 100) { year = '00' + year; }
		else if(inputDate.year() < 1000) { year = '0' + year; }

		String outputDate = year + month + day;
 
		return outputDate;
	}


    public String getBodyContent() {
        CustomerSyncRequestJSON customerSyncRequest = 
            new CustomerSyncRequestJSON(this.customerCode, dateToSapForm(this.fromDate), dateToSapForm(this.toDate));
        SapRequestJSON sapReq = new SapRequestJSON(customerSyncRequest);
        return JSON.serialize(sapReq);
    }

    public Object execute() {
        return parseAndExecuteResponse(this.callService('POST'));
    }
    
    private List<Invoice__c> parseAndExecuteResponse(String response) {
        
        //response = response.substring(1, response.length());
        response = response.substring(1, response.length() - 1);
                
        String jsonStr = response.unescapeEcmaScript()
                            .unescapeEcmaScript();

        //system.debug('jsonStr: '+ jsonStr);
        //ASHIROTA 20171611: ajuste de homolog
        jsonStr = jsonStr.substring(13, jsonStr.length()-1);
        
        Object obj = JSON.deserializeUntyped(jsonStr);
        
        //system.debug('obj:' + obj);
        Map<String, Object> mp = (Map<String, Object>)obj;
        System.debug('***' + mp.get('invoiceData'));
   
        if(mp.get('invoiceData') == null || mp.get('orderData') == null || mp.get('shippingData') == null) {
            return null;
        }
        
        List<IntegrationMap__c> integrationList = IntegrationMapDAO.getAll();
        Map<String, IntegrationMap__c> integMap = new Map<String, IntegrationMap__c>();
        
        for(IntegrationMap__c aux : integrationList) {
            integMap.put(aux.SObjectApiNameTxt__c, aux);
        }
        
        integ_JSONTransformer jsonTransformer = new integ_JSONTransformer();
        new integ_CustomOperationOrder().execute(jsonTransformer.convertToSObjectList(integMap.get('Order__c'), JSON.serialize(mp.get('orderData'))));
        new integ_CustomOperationShipping().execute(jsonTransformer.convertToSObjectList(integMap.get('Remittance__c'), JSON.serialize(mp.get('shippingData'))));
        integ_CustomOperationInvoice invoiceOp = new integ_CustomOperationInvoice();
        List<Invoice__c> invoiceList = ((List<Invoice__c>)invoiceOp.execute(jsonTransformer.convertToSObjectList(integMap.get('Invoice__c'), JSON.serialize(mp.get('invoiceData')))));

        return invoiceList;

    }
    
    
}