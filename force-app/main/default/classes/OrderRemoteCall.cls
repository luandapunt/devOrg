public without sharing class OrderRemoteCall 
    extends RestBaseServiceAbstraction
    implements integ_IRemoteCall{

    public String invoiceNumber {get;set;}
    public String customerCode {get;set;}
    public String orderNumber {get;set;}

    public OrderRemoteCall(String invoiceNumber, String customerCode, String orderNumber, Boolean bol) {
    }    

    public OrderRemoteCall(String invoiceNumber, String customerCode, String orderNumber) {
        super();
        this.invoiceNumber = invoiceNumber;
        this.customerCode = customerCode;
        this.orderNumber = orderNumber;
    }

    public String getBodyContent() {
        
        String bodyContent = null;
        
        if (this.orderNumber != null) {
            OrderRequestByOrderNumberJSON orderNumberRequest = new OrderRequestByOrderNumberJSON();
            orderNumberRequest.PEDIDO = this.orderNumber;
            SapRequestJSON sapReq = new SapRequestJSON(orderNumberRequest);
            bodyContent = JSON.serialize(sapReq);

        } else if ((this.orderNumber == null) && (this.customerCode != null) && (this.invoiceNumber == null)) {
            OrderRequestByCustomerLast30DaysJSON orderNumberRequest = new OrderRequestByCustomerLast30DaysJSON(this.customerCode);
            SapRequestJSON sapReq = new SapRequestJSON(orderNumberRequest);
            bodyContent = JSON.serialize(sapReq);
        } else {
            bodyContent = OrderRequestJSONCreater.execute(invoiceNumber, customerCode); 
        }

        return bodyContent;

    }

    public Object execute() {
        return parseAndExecuteResponse(this.callService('POST'));
    }
    
    private List<Invoice__c> parseAndExecuteResponse(String response) {
        system.debug('entrou 1');
        //response = response.substring(1, response.length());
        response = response.substring(1, response.length() - 1);
                
        String jsonStr = response.unescapeEcmaScript()
                            .unescapeEcmaScript();

        //ASHIROTA 20171611: ajuste de homolog
        jsonStr = jsonStr.substring(13, jsonStr.length()-1);
        
        Object obj = JSON.deserializeUntyped(jsonStr);
        
        system.debug('entrou 2');
        Map<String, Object> mp = (Map<String, Object>)obj;
        System.debug('***' + mp.get('invoiceData'));
   
        if(mp.get('invoiceData') == null || mp.get('orderData') == null || mp.get('shippingData') == null) {
            return null;
        }
        
        system.debug('entrou 3');
        List<IntegrationMap__c> integrationList = IntegrationMapDAO.getAll();
        Map<String, IntegrationMap__c> integMap = new Map<String, IntegrationMap__c>();
        system.debug('entrou 4');
        for(IntegrationMap__c aux : integrationList) {
            integMap.put(aux.SObjectApiNameTxt__c, aux);
        }
        
        integ_JSONTransformer jsonTransformer = new integ_JSONTransformer();
        system.debug('entrou 5');
        //add order and order item flow
        new integ_CustomOperationOrder().execute(jsonTransformer.convertToSObjectList(integMap.get('Order__c'), JSON.serialize(mp.get('orderData'))));
        new integ_CustomOperationOrderItem().execute(jsonTransformer.convertToSObjectList(integMap.get('OrderItem__c'), JSON.serialize(mp.get('orderData'))));
 system.debug('entrou 6');
        //add remittance and remittance item flow
        new integ_CustomOperationShipping().execute(jsonTransformer.convertToSObjectList(integMap.get('Remittance__c'), JSON.serialize(mp.get('shippingData'))));
        new integ_CustomOperationShippingItem().execute(jsonTransformer.convertToSObjectList(integMap.get('RemittanceItem__c'), JSON.serialize(mp.get('shippingData'))));
        system.debug('entrou 7');
        //add invoice and invoice item flow
        integ_CustomOperationInvoice invoiceOp = new integ_CustomOperationInvoice();
        List<Invoice__c> invoiceList = ((List<Invoice__c>)invoiceOp.execute(jsonTransformer.convertToSObjectList(integMap.get('Invoice__c'), JSON.serialize(mp.get('invoiceData')))));
        new integ_CustomOperationInvoiceItem().execute(jsonTransformer.convertToSObjectList(integMap.get('InvoiceItem__c'), JSON.serialize(mp.get('invoiceData'))));
system.debug('entrou 8');

        return invoiceList;

    }
    
    
}