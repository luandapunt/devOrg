public class SAPInteg {
    public static HttpResponse GetLog(String guid){
        Date docDate = Date.newInstance(2017, 10, 20);
        JSONGenerator gen = JSON.createGenerator(true);   
        
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'GUID', guid);
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/GetLog/Homologation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        req = setHeader(req);    
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
    public static HttpResponse quotationChange(String orderId, String[] oItemIds, Boolean isDelete){
        Order__c o = [SELECT Id, CustomIdTxt__c, ErrorMessageTxt__c FROM Order__c WHERE Id =: orderId];
        List<OrderItem__c> oItemList = [SELECT Id, 
                                        OrderQuantityNmb__c, 
                                        ItemNumberTxt__c,
                                        Remittance1DateDte__c,
                                        ProductLkp__r.ProductCodeTxt__c 
                                        FROM OrderItem__c WHERE Id IN :oItemIds];
        
        JSONGenerator gen = JSON.createGenerator(true);   
        
        gen.writeStartObject();
        
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        SAPIntegUtils.writeStringField(gen, 'SALESDOCUMENT', o.CustomIdTxt__c.leftPad(10,'0'));
        
        
        
        gen.writeFieldName('QUOTATION_HEADER_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'UPDATEFLAG', 'U');
        gen.writeEndObject();
        
        
        gen.writeFieldName('QUOTATION_ITEM_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : oItemList){
            gen.writeStartObject();
            if(!isDelete) SAPIntegUtils.writeStringField(gen, 'MATERIAL', oItem.ProductLkp__r.ProductCodeTxt__c.leftPad(18, '0'));
            if(!isDelete) SAPIntegUtils.writeStringField(gen, 'TARGET_QTY', String.valueOf(oItem.OrderQuantityNmb__c));
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
            gen.writeEndObject();
        }
        
        
        gen.writeEndArray();
        gen.writeEndObject();
        
        if(!isDelete){
            gen.writeFieldName('QUOTATION_ITEM_INX');
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'MATERIAL', 'X');
            SAPIntegUtils.writeStringField(gen, 'TARGET_QTY', 'X');
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', 'X');
            gen.writeEndObject();
        }
        else{
            gen.writeFieldName('QUOTATION_ITEM_INX');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            for(OrderItem__c oItem : oItemList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'UPDATEFLAG', 'D');
                SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
            
        }
        
        if(!isDelete){
            gen.writeFieldName('SCHEDULE_LINES');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            
            for(OrderItem__c oItem : oItemList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'REQ_DATE', oItem.Remittance1DateDte__c != null ? formatDate(oItem.Remittance1DateDte__c) : formatDate(System.today()));
                SAPIntegUtils.writeStringField(gen, 'REQ_QTY', String.valueOf(oItem.OrderQuantityNmb__c));
                SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
                gen.writeEndObject();
            }
            
            gen.writeEndArray();
            gen.writeEndObject();
            
            gen.writeFieldName('SCHEDULE_LINESX');
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'REQ_DATE', 'X');
            SAPIntegUtils.writeStringField(gen, 'REQ_QTY', 'X');
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', 'X');
            gen.writeEndObject();
        }
        
        gen.writeFieldName('RETURN');
        gen.writeStartObject();
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'QuotationChange'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/QuotationChange/Homologation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
    public static HttpResponse quotationChangePricing(Id orderId, List<Id> oItemIds){
        Order__c o = [SELECT Id, CustomIdTxt__c, ErrorMessageTxt__c, PaymentTermLkp__r.CustomizedIdTxt__c FROM Order__c WHERE Id =: orderId];
        List<OrderItem__c> oItemList = [SELECT Id, 
                                        OrderQuantityNmb__c, 
                                        ItemNumberTxt__c,
                                        Remittance1DateDte__c,
                                        ProductLkp__r.ProductCodeTxt__c 
                                        FROM OrderItem__c WHERE Id IN :oItemIds];
        
        JSONGenerator gen = JSON.createGenerator(true);   
        
        gen.writeStartObject();
        
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        SAPIntegUtils.writeStringField(gen, 'SALESDOCUMENT', o.CustomIdTxt__c.leftPad(10,'0'));
        
        gen.writeFieldName('QUOTATION_HEADER_IN');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', o.PaymentTermLkp__r.CustomizedIdTxt__c);
        gen.writeEndObject();
        
        gen.writeFieldName('QUOTATION_HEADER_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'UPDATEFLAG', 'U');
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', 'X');
        gen.writeEndObject();
        
        
        gen.writeFieldName('QUOTATION_ITEM_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : oItemList){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('QUOTATION_ITEM_INX');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : oItemList){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
            SAPIntegUtils.writeStringField(gen, 'UPDATEFLAG', 'U');
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('LOGIC_SWITCH');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PRICING', 'C');
        SAPIntegUtils.writeStringField(gen, 'COND_HANDL', 'X');
        gen.writeEndObject();
        
        gen.writeFieldName('RETURN');
        gen.writeStartObject();
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'QuotationChange'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/QuotationChange/Homologation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
    public static HttpResponse createQuotation(Id orderId){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        Order__c o = [SELECT OrderTypeTxt__c,
                      OrderTypeLkp__c,
                      OrderTypeLkp__r.QuoteOrderTypeCodeTxt__c,
                      OrderTypeLkp__r.SalesOrderTypeCodeTxt__c,
                      PaymentTermTxt__c,
                      PaymentTermLkp__c,
                      PaymentTermLkp__r.CustomizedIdTxt__c,
                      RemittanceDesiredDateDte__c,
                      OrderDateDte__c,
                      OrderNumberTxt__c,
                      AccountLkp__r.CodeCustomerTxt__c,
                      AccountReceiverLkp__c,
                      AccountReceiverLkp__r.CodeCustomerTxt__c,
                      AccountAreaSalesLkp__c, 
                      AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c,
                      AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c,
                      AccountAreaSalesLkp__r.CodeActivitySectorTxt__c,
                      SellerLkp__r.SellerNumberNmb__c,
                      CommercialRemarkTxt__c,
                      RepresentativeRemarkTxt__c,
                      InvoiceHeaderTxt__c,
                      OrderReasonTxt__c,
                      ErrorMessageTxt__c,
                      ClientTransportBln__c,
                      CarrierLkp__r.CodeCarrierTxt__c,
                      CarrierTxt__c
                      FROM Order__c WHERE Id =: orderId];
        
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        
        gen.writeFieldName('QUOTATION_HEADER_IN');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'DOC_TYPE', o.OrderTypeLkp__c != null ? 
                                       (o.OrderTypeLkp__r.QuoteOrderTypeCodeTxt__c != null ?
                                        o.OrderTypeLkp__r.QuoteOrderTypeCodeTxt__c : 
                                        o.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c) :
                                       o.OrderTypeTxt__c 
                                      );
        SAPIntegUtils.writeStringField(gen, 'SALES_ORG', o.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c);
        SAPIntegUtils.writeStringField(gen, 'DISTR_CHAN', o.AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c);
        SAPIntegUtils.writeStringField(gen, 'DIVISION', o.AccountAreaSalesLkp__r.CodeActivitySectorTxt__c);
        //SAPIntegUtils.writeStringField(gen, 'PURCH_NO_S', 'X');
        if(o.OrderNumberTxt__c != null)
        	SAPIntegUtils.writeStringField(gen, 'PURCH_NO_C', o.OrderNumberTxt__c);
        if(o.RemittanceDesiredDateDte__c != null)
            SAPIntegUtils.writeStringField(gen, 'REQ_DATE_H', formatDate(o.RemittanceDesiredDateDte__c));
        
        SAPIntegUtils.writeStringField(gen, 'PURCH_DATE', o.OrderDateDte__c != null ? formatDate(o.OrderDateDte__c) : formatDate(System.today()));        
        if(o.PaymentTermLkp__c != null) SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', o.PaymentTermLkp__r.CustomizedIdTxt__c);
        if(o.OrderReasonTxt__c != null) SAPIntegUtils.writeStringField(gen, 'ORD_REASON', o.OrderReasonTxt__c);
        gen.writeEndObject();
        
        gen.writeFieldName('QUOTATION_HEADER_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'DOC_TYPE', 'X');
        SAPIntegUtils.writeStringField(gen, 'SALES_ORG', 'X');
        SAPIntegUtils.writeStringField(gen, 'DISTR_CHAN', 'X');
        SAPIntegUtils.writeStringField(gen, 'DIVISION', 'X');
        //SAPIntegUtils.writeStringField(gen, 'PURCH_NO_S', 'X');
        SAPIntegUtils.writeStringField(gen, 'PURCH_NO_C', 'X');
        SAPIntegUtils.writeStringField(gen, 'REQ_DATE_H', 'X');
        SAPIntegUtils.writeStringField(gen, 'PURCH_DATE', 'X');
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', 'X');
        SAPIntegUtils.writeStringField(gen, 'ORD_REASON', 'X');
        gen.writeEndObject();
        
        
        gen.writeFieldName('QUOTATION_PARTNERS');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'AG');
        SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.AccountLkp__r.CodeCustomerTxt__c.leftPad(10, '0'));
        gen.writeEndObject();
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'WE');
        SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.AccountReceiverLkp__c != null ? o.AccountReceiverLkp__r.CodeCustomerTxt__c.leftPad(10, '0') : o.AccountLkp__r.CodeCustomerTxt__c.leftPad(10, '0'));
        gen.writeEndObject();
        if(o.SellerLkp__r.SellerNumberNmb__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'VE');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.SellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));
            gen.writeEndObject();
        }
        if(o.CarrierLkp__r.CodeCarrierTxt__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'RD');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.CarrierLkp__r.CodeCarrierTxt__c.leftPad(10, '0'));
            gen.writeEndObject();
        }
        if(o.ClientTransportBln__c){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'SP');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', '0000480000');
            gen.writeEndObject();            
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('QUOTATION_TEXT');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        if(o.InvoiceHeaderTxt__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9000');
            SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
            SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', o.InvoiceHeaderTxt__c);
            gen.writeEndObject();
        }
        if(o.CommercialRemarkTxt__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9001');
            SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
            SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', o.CommercialRemarkTxt__c);
            gen.writeEndObject();
        }
        if(o.RepresentativeRemarkTxt__c != null || o.CarrierTxt__c != null){
            String auxStr = (o.RepresentativeRemarkTxt__c != NULL ? o.RepresentativeRemarkTxt__c : '')+'\n'+
                       (o.CarrierTxt__c != NULL ? o.CarrierTxt__c : '');
            
            List<String> lineList = auxStr.split('\n');
            
            for(String line : lineList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9002');
                SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
                SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', line);
                gen.writeEndObject();                
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();

        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'Quotation'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/Quotation/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    } 
    
    public static  HttpResponse getDetails(String orderId, String[] conditionList, String oItemId){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        OrderItem__c oItem = oItemId != null ? [SELECT ID, ItemNumberTxt__c FROM OrderItem__c WHERE Id =: oItemId] : null;
        Order__c o = [SELECT Id, CustomIDTxt__c, ErrorMessageTxt__c FROM Order__c WHERE Id =: orderId];
        
        gen.writeStartObject();
        //SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        if(oItem != null){
            gen.writeFieldName('I_POSNR_TAB');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            gen.writeString(oItem.ItemNumberTxt__c);
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        gen.writeFieldName('I_BAPI_VIEW');
        gen.writeStartObject();
        //SAPIntegUtils.writeStringField(gen, 'HEADER', 'X');
        SAPIntegUtils.writeStringField(gen, 'ITEM', 'X');
        if(conditionList != null){
            SAPIntegUtils.writeStringField(gen, 'SDCOND', 'X');
            SAPIntegUtils.writeStringField(gen, 'SDCOND_ADD', 'X');
        }
        gen.writeEndObject();
        
        gen.writeFieldName('SALES_DOCUMENTS');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'VBELN', o.CustomIDTxt__c.leftPad(10,'0'));
        gen.writeEndObject();
        gen.writeEndObject();
        
        if(conditionList != null){
            gen.writeFieldName('GET_CONDITIONS');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            for(String condition : conditionList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'COND_TYPE', condition);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'OrderGetDetail'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/OrderGetDetail/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    /*
    public static  HttpResponse getDetailsList(String orderId, String[] conditionList, String[] oItemIds){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        List<OrderItem__c> oItems = oItemIds != null ? [SELECT ID, ItemNumberTxt__c FROM OrderItem__c WHERE Id IN  :oItemIds] : null;
        Order__c o = [SELECT Id, CustomIDTxt__c, ErrorMessageTxt__c FROM Order__c WHERE Id =: orderId];
        
        gen.writeStartObject();
        //SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        if(oItems != null){
            gen.writeFieldName('I_POSNR_TAB');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            for(OrderItem__c oItem : oItems){
                gen.writeString(oItem.ItemNumberTxt__c);
            }
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        gen.writeFieldName('I_BAPI_VIEW');
        gen.writeStartObject();
        //SAPIntegUtils.writeStringField(gen, 'HEADER', 'X');
        SAPIntegUtils.writeStringField(gen, 'ITEM', 'X');
        if(conditionList != null){
            SAPIntegUtils.writeStringField(gen, 'SDCOND', 'X');
            SAPIntegUtils.writeStringField(gen, 'SDCOND_ADD', 'X');
        }
        gen.writeEndObject();
        
        gen.writeFieldName('SALES_DOCUMENTS');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'VBELN', o.CustomIDTxt__c.leftPad(10,'0'));
        gen.writeEndObject();
        gen.writeEndObject();
        
        if(conditionList != null){
            gen.writeFieldName('GET_CONDITIONS');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            for(String condition : conditionList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'COND_TYPE', condition);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
        }
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        
        String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/OrderGetDetail/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }    
    */
    public static HttpResponse convertQuote(String orderId, String[] conditionList){
        Order__c o = [SELECT Id, 
                      OrderTypeLkp__c,
                      OrderTypeLkp__r.SalesOrderTypeCodeTxt__c,
                      PaymentTermLkp__c,
                      PaymentTermLkp__r.CustomizedIdTxt__c,
                      OrderNumberTxt__c,
                      AccountLkp__r.CodeCustomerTxt__c,
                      AccountReceiverLkp__c,
                      AccountReceiverLkp__r.CodeCustomerTxt__c,
                      AccountAreaSalesLkp__c, 
                      AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c,
                      AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c,
                      AccountAreaSalesLkp__r.CodeActivitySectorTxt__c,
                      SellerLkp__r.SellerNumberNmb__c,
                      CustomIdTxt__c,
                      CreatedDate,
                      CommercialRemarkTxt__c,
                      RepresentativeRemarkTxt__c,
                      InvoiceHeaderTxt__c,
                      OrderReasonTxt__c,
                      ErrorMessageTxt__c,
                      ClientTransportBln__c,
                      CarrierLkp__r.CodeCarrierTxt__c,
                      CarrierTxt__c,
                      (SELECT Id,
                       OrderQuantityNmb__c,
                       ItemNumberTxt__c,
                       ZPVC__c,
                       ZPRO__c,
                       ZCOT__c,
                       XXES__c,
                       YRXI__c,
                       YRVO__c,
                       YRME__C,
                       YRSO__c,
                       ZPXI__c,
                       ZPVO__c,
                       ZPME__c,
                       ZPSO__c,
                       ZVJ1__c,
                       ProductLkp__r.ProductCodeTxt__c,
                       Remittance1DateDte__c,
                       RemittanceGroupTxt__c,
                       PaymentConditionTxt__c
                       FROM Itens_da_Ordem__r
                      WHERE ItemNumberTxt__c != null)
                      FROM Order__c 
                      WHERE Id =: orderId];
        
        JSONGenerator gen = JSON.createGenerator(true);   
        
        gen.writeStartObject();
        //SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        gen.writeFieldName('ORDER_HEADER_IN');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'DOC_TYPE', o.OrderTypeLkp__c != null ? o.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c : '');
        SAPIntegUtils.writeStringField(gen, 'SALES_ORG', o.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c);
        SAPIntegUtils.writeStringField(gen, 'DISTR_CHAN', o.AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c);
        SAPIntegUtils.writeStringField(gen, 'DIVISION', o.AccountAreaSalesLkp__r.CodeActivitySectorTxt__c);
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', o.PaymentTermLkp__c != null ? o.PaymentTermLkp__r.CustomizedIdTxt__c : '');
        SAPIntegUtils.writeStringField(gen, 'REF_DOC', o.CustomIdTxt__c.leftPad(10,'0'));
        SAPIntegUtils.writeStringField(gen, 'REFDOC_CAT', 'B');
        SAPIntegUtils.writeStringField(gen, 'PURCH_NO_C', o.OrderNumberTxt__c!= null ? o.OrderNumberTxt__c : '');
        SAPIntegUtils.writeStringField(gen, 'PRSDT', formatDate(Date.valueof(o.CreatedDate)));
        SAPIntegUtils.writeStringField(gen, 'PURCH_DATE', formatDate(System.today()));
        if(o.OrderReasonTxt__c != null) SAPIntegUtils.writeStringField(gen, 'ORD_REASON', o.OrderReasonTxt__c);
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_HEADER_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'DOC_TYPE', 'X');
        SAPIntegUtils.writeStringField(gen, 'SALES_ORG', 'X');
        SAPIntegUtils.writeStringField(gen, 'DISTR_CHAN', 'X');
        SAPIntegUtils.writeStringField(gen, 'DIVISION', 'X');
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', 'X');
        SAPIntegUtils.writeStringField(gen, 'REF_DOC', 'X');
        SAPIntegUtils.writeStringField(gen, 'REFDOC_CAT', 'X');
        SAPIntegUtils.writeStringField(gen, 'PURCH_NO_C', 'X');
        SAPIntegUtils.writeStringField(gen, 'PRSDT', 'X');
        SAPIntegUtils.writeStringField(gen, 'PURCH_DATE', 'X');
        SAPIntegUtils.writeStringField(gen, 'ORD_REASON', 'X');
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_ITEMS_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'MATERIAL', 'X');
        SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', 'X');
        SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', 'X');
        SAPIntegUtils.writeStringField(gen, 'TARGET_QTY', 'X');
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_ITEMS_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : o.Itens_da_Ordem__r){
            if(oItem.ItemNumberTxt__c != null){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'MATERIAL', oItem.ProductLkp__r.ProductCodeTxt__c.leftPad(18, '0'));
                SAPIntegUtils.writeStringField(gen, 'TARGET_QTY', String.valueOf(oItem.OrderQuantityNmb__c));
                SAPIntegUtils.writeStringField(gen, 'DLV_GROUP', String.valueOf(oItem.RemittanceGroupTxt__c));
                SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
                SAPIntegUtils.writeStringField(gen, 'PMNTTRMS', oItem.PaymentConditionTxt__c != null ? oItem.PaymentConditionTxt__c : o.PaymentTermLkp__c != null ? o.PaymentTermLkp__r.CustomizedIdTxt__c : '');
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_PARTNERS');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'AG');
        SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.AccountLkp__r.CodeCustomerTxt__c.leftPad(10, '0'));
        gen.writeEndObject();
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'WE');
        SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.AccountReceiverLkp__c != null ? o.AccountReceiverLkp__r.CodeCustomerTxt__c.leftPad(10, '0') : o.AccountLkp__r.CodeCustomerTxt__c.leftPad(10, '0'));
        gen.writeEndObject();
        if(o.SellerLkp__r.SellerNumberNmb__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'VE');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.SellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));
            gen.writeEndObject();
        }
        if(o.CarrierLkp__r.CodeCarrierTxt__c != null){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'RD');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', o.CarrierLkp__r.CodeCarrierTxt__c.leftPad(10, '0'));
            gen.writeEndObject();
        }
        if(o.ClientTransportBln__c){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'PARTN_ROLE', 'SP');
            SAPIntegUtils.writeStringField(gen, 'PARTN_NUMB', '0000480000');
            gen.writeEndObject();            
        }
        gen.writeEndArray();
        gen.writeEndObject();
        /*
        gen.writeFieldName('ORDER_CONDITIONS_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', 'X');
        SAPIntegUtils.writeStringField(gen, 'COND_TYPE', 'X');
        SAPIntegUtils.writeStringField(gen, 'COND_VALUE', 'X');
        gen.writeEndObject();
        */
        /*
        gen.writeFieldName('ORDER_CONDITIONS_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : o.Itens_da_Ordem__r){
            for(String conditionName : conditionList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
                SAPIntegUtils.writeStringField(gen, 'COND_TYPE', conditionName);
                SAPIntegUtils.writeStringField(gen, 'COND_VALUE', oItem.get(conditionName+'__c') != null ? String.valueOf(oItem.get(conditionName+'__c')) : '0');
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        */
        gen.writeFieldName('T_XYPRICE');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oItem : o.Itens_da_Ordem__r){
            for(String conditionName : conditionList){
                Decimal conditionValue = (Decimal) (oItem.get(conditionName+'__c') != null ? oItem.get(conditionName+'__c') : 0);
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'POSNR', oItem.ItemNumberTxt__c);
                SAPIntegUtils.writeStringField(gen, 'KSCHL', conditionName);
                //if(conditionName != 'XXES'){
                    SAPIntegUtils.writeStringField(gen, 'KBETR', String.valueOf(-1 * conditionValue * 10));
                //}
                //else{
                //    SAPIntegUtils.writeStringField(gen, 'KWERT', String.valueOf(-1 * conditionValue));             
                //}
                
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_SCHEDULES_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        
        for(OrderItem__c oItem : o.Itens_da_Ordem__r){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'REQ_DATE', oItem.Remittance1DateDte__c != null ? formatDate(oItem.Remittance1DateDte__c) : formatDate(System.today()));
            SAPIntegUtils.writeStringField(gen, 'REQ_QTY', String.valueOf(oItem.OrderQuantityNmb__c));
            SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', oItem.ItemNumberTxt__c);
            gen.writeEndObject();
        }
        
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('ORDER_SCHEDULES_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'REQ_DATE', 'X');
        SAPIntegUtils.writeStringField(gen, 'REQ_QTY', 'X');
        SAPIntegUtils.writeStringField(gen, 'ITM_NUMBER', 'X');
        gen.writeEndObject();

        if(o.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c != 'ZNOV'){
            gen.writeFieldName('ORDER_TEXT');
            gen.writeStartObject();
            gen.writeFieldName('item');
            gen.writeStartArray();
            if(o.InvoiceHeaderTxt__c != null){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9000');
                SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
                SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', o.InvoiceHeaderTxt__c);
                gen.writeEndObject();
            }
            if(o.CommercialRemarkTxt__c != null){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9001');
                SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
                SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', o.CommercialRemarkTxt__c);
                gen.writeEndObject();
            }
            if(o.RepresentativeRemarkTxt__c != null || o.CarrierTxt__c != null){
                String auxStr = (o.RepresentativeRemarkTxt__c != NULL ? o.RepresentativeRemarkTxt__c : '')+'\n'+
                    (o.CarrierTxt__c != NULL ? o.CarrierTxt__c : '');
                
                List<String> lineList = auxStr.split('\n');
                
                for(String line : lineList){
                    gen.writeStartObject();
                    SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '9002');
                    SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
                    SAPIntegUtils.writeStringField(gen, 'TEXT_LINE', line);
                    gen.writeEndObject();                
                }
            }
            gen.writeEndArray();
            gen.writeEndObject();            
        }
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'Order'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/Order/Homologation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);    
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    /*
    public static HttpResponse getBottleneck(String[] oItemIds){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        List<OrderItem__c> oItems = oItemIds != null ? [SELECT ID, ItemNumberTxt__c, DistributionCenterTxt__c, ProductCode__c FROM OrderItem__c WHERE Id IN: oItemIds] : null;
        
        gen.writeStartObject();
        
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        
        gen.writeFieldName('T_ZPH_FCUR_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(OrderItem__c oitem : oItems){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'WERKS', oItem.DistributionCenterTxt__c);
            SAPIntegUtils.writeStringField(gen, 'MATNR', oItem.ProductCode__c.leftPad(18, '0'));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('T_ZPH_FCUR_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'MATNR', 'X');
        SAPIntegUtils.writeStringField(gen, 'WERKS', 'X');
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        
        String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/ZPH_FCUR/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    */
    public static HttpResponse getBottleNeck(String werks, String matnr){
        JSONGenerator gen = JSON.createGenerator(true);   
                
        gen.writeStartObject();
        
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        
        gen.writeFieldName('T_ZPH_FCUR_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'WERKS', werks);
        SAPIntegUtils.writeStringField(gen, 'MATNR', matnr.leftPad(18, '0'));
        gen.writeEndObject();
        
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeFieldName('T_ZPH_FCUR_INX');
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'MATNR', 'X');
        SAPIntegUtils.writeStringField(gen, 'WERKS', 'X');
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'ZPH_FCUR'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/ZPH_FCUR/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
    public static HttpResponse getLastPrice(String[] oItemIds){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        List<OrderItem__c> oItems =  [SELECT ID, 
                                      OrderMdt__r.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c,
                                      OrderMdt__r.AccountLkp__r.CodeCustomerTxt__c,
                                      OrderMdt__r.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c,
                                      ProductCode__c 
                                      FROM OrderItem__c WHERE Id IN: oItemIds];
        OrderItem__c oitem = oItems[0];
        gen.writeStartObject();
                
        gen.writeFieldName('I_S666');     
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'VKORG', oItem.OrderMdt__r.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c);
        SAPIntegUtils.writeStringField(gen, 'KUNNR', oItem.OrderMdt__r.AccountLkp__r.CodeCustomerTxt__c.leftPad(10, '0'));
        SAPIntegUtils.writeStringField(gen, 'AUART', oItem.OrderMdt__r.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c);
        SAPIntegUtils.writeStringField(gen, 'MATNR', oItem.ProductCode__c.leftPad(18, '0'));
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'S666'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/S666/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
    
    public static HttpResponse getConditionNames(String[] conditionNumberList){
        system.debug(conditionNumberList);
        JSONGenerator gen = JSON.createGenerator(true);   
        
        gen.writeStartObject();
        
        gen.writeFieldName('T_KNUMH');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(String conditionNumber : conditionNumberList){
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'KNUMH', conditionNumber);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'KONH'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/KONH/Homologation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        system.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);    
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }

    public static HttpResponse getQuotas(String[] salesmenCodeList, String[] dateList){
        System.debug(salesmenCodeList);
        System.debug(dateList);
        
        JSONGenerator gen = JSON.createGenerator(true);   
           
        gen.writeStartObject();
        gen.writeFieldName('T_ZPH_PREM_IN');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(String salesmanCode: salesmenCodeList){
            for(String quotaDate: dateList){
                gen.writeStartObject();
                SAPIntegUtils.writeStringField(gen, 'SPMON', quotaDate);
                SAPIntegUtils.writeStringField(gen, 'PERNR', salesmanCode);
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'ZPH_PREM'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/ZPH_PREM/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        return res;
    }
    
    public static HttpResponse createAccount(Id accountId){
        JSONGenerator gen = JSON.createGenerator(true);   
        Account acc = [SELECT Id, 
                       MarketedMaterialsTxt__c, CNPJTxt__c, RG_StateInscriptionTxt__c, IndustryTxt__c, NielsenZoneTxt__c, 
                       BillingStateCode, OperationModeTxt__c,BillingCity, BillingPostalCode, BillingCountryCode, Name, BillingStreet,
                       BillingDistrict__c, BillingNumber__c, ChannelLkp__c, ChannelLkp__r.Name,
                       LeadSalesOrganizationTxt__c, LeadDistributionChannelTxt__c, LeadActivitySectorTxt__c,
                       LeadSellerLkp__c, LeadSellerLkp__r.SellerNumberNmb__c,
                       ShortNameTxt__c, Phone, EmailTxt__c, XMLEmailTxt__c, SuframaCodeTxt__c, ShipmentConditionTxt__c, 
                       ChannelPVCTxt__c
                       FROM Account WHERE Id = :accountId];
        try{
            gen.writeStartObject();
            SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
            gen.writeFieldName('I_EI_MAIN');
            gen.writeStartObject();
                gen.writeFieldName('CUSTOMERS');
                gen.writeStartObject();
                    gen.writeFieldName('item');
					gen.writeStartObject();
                        gen.writeFieldName('HEADER');
                        gen.writeStartObject();
                            SAPIntegUtils.writeStringField(gen, 'OBJECT_TASK', 'I');
                        gen.writeEndObject();
            
                        gen.writeFieldName('CENTRAL_DATA');
                        gen.writeStartObject();
                            gen.writeFieldName('CENTRAL');
                            gen.writeStartObject();
                                gen.writeFieldName('DATA');
                                gen.writeStartObject();
                                    SAPIntegUtils.writeStringField(gen, 'KTOKD', 'EMOR');
                                    SAPIntegUtils.writeStringField(gen, 'KUKLA', acc.MarketedMaterialsTxt__c);
                                    //SAPIntegUtils.writeStringField(gen, 'KUKLA', acc.MarketedMaterialsTxt__c);
                                    SAPIntegUtils.writeStringField(gen, 'CFOPC', '00'); //FIXO
                                    SAPIntegUtils.writeStringField(gen, 'STCD1', SAPIntegUtils.removeAllButNumbers(acc.CNPJTxt__c));
                                    //SAPIntegUtils.writeStringField(gen, 'STCD1', acc.CNPJTxt__c); //REMOVER PONTUAÇÃO
                                    SAPIntegUtils.writeStringField(gen, 'STCD3', SAPIntegUtils.removeAllButNumbers(acc.RG_StateInscriptionTxt__c));
                                    //SAPIntegUtils.writeStringField(gen, 'STCD3', acc.RG_StateInscriptionTxt__c);
                                    SAPIntegUtils.writeStringField(gen, 'BRSCH', acc.IndustryTxt__c);
                                    //SAPIntegUtils.writeStringField(gen, 'BRSCH', acc.IndustryTxt__c);
                                    SAPIntegUtils.writeStringField(gen, 'NIELS', acc.NielsenZoneTxt__c);
                                    //SAPIntegUtils.writeStringField(gen, 'NIELS', acc.NielsenZoneTxt__c);
                                    SAPIntegUtils.writeStringField(gen, 'COUNC', acc.BillingStateCode);
                                    //SAPIntegUtils.writeStringField(gen, 'COUNC', acc.BillingState);
                                    SAPIntegUtils.writeStringField(gen, 'CITYC', acc.BillingStateCode);
                                    //SAPIntegUtils.writeStringField(gen, 'CITYC', acc.BillingState);
                                    SAPIntegUtils.writeStringField(gen, 'BRAN1', acc.OperationModeTxt__c);
                                    //SAPIntegUtils.writeStringField(gen, 'BRAN1', acc.OperationModeTxt__c);
                                gen.writeEndObject();
                                gen.writeFieldName('DATAX');
                                gen.writeStartObject();
                                    SAPIntegUtils.writeStringField(gen, 'KTOKD', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'KUKLA', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'CFOPC', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'STCD1', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'STCD3', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'BRSCH', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'NIELS', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'COUNC', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'CITYC', 'X');
                                    SAPIntegUtils.writeStringField(gen, 'BRAN1', 'X');
                                gen.writeEndObject();
                            gen.writeEndObject();
                            gen.writeFieldName('ADDRESS');
                            gen.writeStartObject();
                                SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                gen.writeFieldName('POSTAL');
                                gen.writeStartObject();
                                    gen.writeFieldName('DATA');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'CITY', StringUtils.removeDiacritics(acc.BillingCity));
                                        SAPIntegUtils.writeStringField(gen, 'POSTL_COD1', acc.BillingPostalCode); //Deve vir com pontuação
                                        SAPIntegUtils.writeStringField(gen, 'COUNTRY', acc.BillingCountryCode);
                                        SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT'); //FIXO
                                        SAPIntegUtils.writeStringField(gen, 'REGION', acc.BillingStateCode);
                                        SAPIntegUtils.writeStringField(gen, 'NAME', acc.Name); //TAMANHO MAXIMO: 40 Caracteres
                                        SAPIntegUtils.writeStringField(gen, 'DISTRICT', acc.BillingDistrict__c);
                                        SAPIntegUtils.writeStringField(gen, 'STREET', acc.BillingStreet);
                                        SAPIntegUtils.writeStringField(gen, 'HOUSE_NO', acc.BillingNumber__c);
                                        SAPIntegUtils.writeStringField(gen, 'SORT1', acc.ShortNameTxt__c); //TAMANHO MAXIMO: 20 Caracteres
                                    gen.writeEndObject();
                                    gen.writeFieldName('DATAX');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'CITY', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'POSTL_COD1', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'COUNTRY', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
                                        SAPIntegUtils.writeStringField(gen, 'REGION', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'NAME', 'X');
                                        //SAPIntegUtils.writeStringField(gen, 'DISTRICT', );
                                        SAPIntegUtils.writeStringField(gen, 'STREET', 'X');
                                        //en.writeStringField('HOUSE_NO', );
                                        SAPIntegUtils.writeStringField(gen, 'SORT1', 'X');
                                    gen.writeEndObject();
                                gen.writeEndObject();
                                gen.writeFieldName('COMMUNICATION');
                                gen.writeStartObject();
                                    gen.writeFieldName('PHONE');
                                    gen.writeStartObject();
                                        gen.writeFieldName('PHONE');
                                        gen.writeStartObject();
                                            gen.writeFieldName('item');
                                            gen.writeStartObject();
                                                gen.writeFieldName('CONTACT');
                                                gen.writeStartObject();
                                                    gen.writeFieldName('DATA');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'TELEPHONE', SAPIntegUtils.removeAllButNumbers(acc.Phone));
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATAX');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'TELEPHONE', 'X');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                            gen.writeEndObject();
                                        gen.writeEndObject();
                                    gen.writeEndObject();
                                    gen.writeFieldName('SMTP');
                                    gen.writeStartObject();
                                        gen.writeFieldName('SMTP');
                                        gen.writeStartObject();
                                            gen.writeFieldName('item');
                                            gen.writeStartObject();
                                                gen.writeFieldName('CONTACT');
                                                gen.writeStartObject();
                                                    gen.writeFieldName('DATA');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'E_MAIL', acc.EmailTxt__c);
                                                        //SAPIntegUtils.writeStringField(gen, 'E_MAIL', acc.EmailTxt__c);
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATAX');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'E_MAIL', 'X');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                            gen.writeEndObject();
                                        gen.writeEndObject();
                                    gen.writeEndObject();
                                gen.writeEndObject(); //END 'COMMUNICATION'
                                gen.writeFieldName('CONTACT');
                                gen.writeStartObject();
                                    gen.writeFieldName('CONTACTS');
                                    gen.writeStartObject();
                                        gen.writeFieldName('item');
                                        gen.writeStartObject();
                                            SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                            gen.writeFieldName('ADDRESS_TYPE_3');	
                                            gen.writeStartObject();
                                                SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                gen.writeFieldName('POSTAL');
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'FISTNAME', 'NFe'); //FIXO
                                                    SAPIntegUtils.writeStringField(gen, 'LASTNAME', 'NFe'); //FIXO
                                                gen.writeEndObject();
                                                gen.writeFieldName('COMMUNICATION');
                                                gen.writeStartObject();
                                                    gen.writeFieldName('SMTP');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                        SAPIntegUtils.writeStringField(gen, 'E_MAIL', acc.XMLEmailTxt__c);
                                                        //SAPIntegUtils.writeStringField(gen, 'E_MAIL', acc.XMLEmailTxt__c);
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                            gen.writeEndObject();
                                        gen.writeEndObject();
                                    gen.writeEndObject();
                                gen.writeEndObject(); //END 'CONTACT'
                            gen.writeEndObject(); //END 'ADDRESS'
                            if (acc.SuframaCodeTxt__c != null){
                                gen.writeFieldName('TEXT');
                                gen.writeStartObject();
                                    gen.writeFieldName('TEXTS');
                                    gen.writeStartObject();
                                        gen.writeFieldName('item');
                                        gen.writeStartObject();
                                            SAPIntegUtils.writeStringField(gen, 'TASK', 'M');
                                            gen.writeFieldName('DATA_KEY');
                                            gen.writeStartObject();
                                                SAPIntegUtils.writeStringField(gen, 'TEXT_ID', '0012'); //FIXO
                                                SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT'); //FIXO
                                            gen.writeEndObject();
                                            gen.writeFieldName('DATA');
                                            gen.writeStartObject();
                                                gen.writeFieldName('item');
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TDLINE', acc.SuframaCodeTxt__c);
                                                    //SAPIntegUtils.writeStringField(gen, 'TDLINE', acc.SuframaCodeTxt__c);
                                                gen.writeEndObject();
                                            gen.writeEndObject();
                                        gen.writeEndObject();
                                    gen.writeEndObject();
                                gen.writeEndObject(); //END 'TEXT'                            
                            }
                        gen.writeEndObject(); //END 'CENTRAL_DATA' 
                        gen.writeFieldName('SALES_DATA');
                        gen.writeStartObject();
                            gen.writeFieldName('SALES');
                            gen.writeStartObject();
                                gen.writeFieldName('item');
                                gen.writeStartObject();
                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                    gen.writeFieldName('DATA_KEY');
                                    gen.writeStartObject();
                                        //SAPIntegUtils.writeStringField(gen, 'VKORG', 'AM01');
                                        SAPIntegUtils.writeStringField(gen, 'VKORG', acc.LeadSalesOrganizationTxt__c);
                                        //SAPIntegUtils.writeStringField(gen, 'VTWEG', 'RV');
                                        SAPIntegUtils.writeStringField(gen, 'VTWEG', acc.LeadDistributionChannelTxt__c);
                                        //SAPIntegUtils.writeStringField(gen, 'SPART', 'PR');
                                        SAPIntegUtils.writeStringField(gen, 'SPART', acc.LeadActivitySectorTxt__c);
                                    gen.writeEndObject();
                                    gen.writeFieldName('DATA');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'VERSG', '1'); //FIXO
                                        
                                        if(acc.LeadSalesOrganizationTxt__c == '0099')
                                            SAPIntegUtils.writeStringField(gen, 'KALKS', '5');
                                        else
                                            SAPIntegUtils.writeStringField(gen, 'KALKS', '1');
                                        SAPIntegUtils.writeStringField(gen, 'VSBED', acc.ShipmentConditionTxt__c);      						
                                        //SAPIntegUtils.writeStringField(gen, 'VKBUR', '0050'); //SERÁ BUSCADO PELO SAP       						
                                        //SAPIntegUtils.writeStringField(gen, 'VKGRP', '001'); //SERÁ BUSCADO PELO SAP        						
                                        SAPIntegUtils.writeStringField(gen, 'KTGRD', '01'); //SERÁ BUSCADO PELO SAP        						
                                        SAPIntegUtils.writeStringField(gen, 'WAERS', 'BRL'); //FIXO        						
                                        SAPIntegUtils.writeStringField(gen, 'KKBER', 'BRAS'); //FIXO        						
                                        SAPIntegUtils.writeStringField(gen, 'ALAND', 'BR'); //FIXO        						
                                        SAPIntegUtils.writeStringField(gen, 'TAXYP', 'IBRX'); //FIXO        						
                                        SAPIntegUtils.writeStringField(gen, 'TAXKD', '1'); //SERA BUSCADO PELO SAP       						
                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'VE'); //FIXO - VE = VENDEDOR      
                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', acc.LeadSellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));			
                                        //SAPIntegUtils.writeStringField(gen, 'ZZDECISOR', ''); //NÃO MAPEADO NO SF        						
                                        //SAPIntegUtils.writeStringField(gen, 'ZZMARIZ', ''); //NÃO MAPEADO NO SF        						
                                        
                                        if(acc.LeadSalesOrganizationTxt__c == '0099')
                                            SAPIntegUtils.writeStringField(gen, 'VWERK', 'BR30');    
                                        else
                                            SAPIntegUtils.writeStringField(gen, 'VWERK', '');        						
                                        
                                        SAPIntegUtils.writeStringField(gen, 'LPRIO', '02'); //FIXO        
                                        SAPIntegUtils.writeStringField(gen, 'INCO1', 'CIF'); //FIXO        						
                                        SAPIntegUtils.writeStringField(gen, 'INCO2', 'Até o destino'); //FIXO    
                                             						
                                        if(acc.LeadSalesOrganizationTxt__c == '0099'){
                                            SAPIntegUtils.writeStringField(gen, 'KABSS', '0001');
                                            SAPIntegUtils.writeStringField(gen, 'KZTLF', '');
                                            SAPIntegUtils.writeStringField(gen, 'BZIRK', 'BR0007');
                                            SAPIntegUtils.writeStringField(gen, 'ANTLF', '9');
                                            SAPIntegUtils.writeStringField(gen, 'UNTTO', '10.0');
                                            SAPIntegUtils.writeStringField(gen, 'BZIRK', '10.0');                                            
                                        }else{
                                         	SAPIntegUtils.writeStringField(gen, 'KABSS', '0003');
                                            SAPIntegUtils.writeStringField(gen, 'KZTLF', 'C');
                                        }
            						gen.writeEndObject();
                                    gen.writeFieldName('DATAX');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'VERSG', 'X'); 
                                        SAPIntegUtils.writeStringField(gen, 'KALS', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'VSBED', 'X');        						
                                        //SAPIntegUtils.writeStringField(gen, 'VKBUR', 'X');        						
                                        //SAPIntegUtils.writeStringField(gen, 'VKGRP', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'KTGRD', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'WAERS', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'KKBER', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'ALAND', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'TATYP', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'TAXKD', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', 'X');        						
                                        //SAPIntegUtils.writeStringField(gen, 'ZZDECISOR', 'X');        						
                                        //SAPIntegUtils.writeStringField(gen, 'ZZMARIZ', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'VWERK', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'LPRIO', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'INCO1', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'INCO2', 'X');        						
                                        SAPIntegUtils.writeStringField(gen, 'KABSS', 'X');   
           								SAPIntegUtils.writeStringField(gen, 'KZTLF', 'X'); 
            							if(acc.LeadSalesOrganizationTxt__c == '0099'){
                                            SAPIntegUtils.writeStringField(gen, 'BZIRK', 'X');
                                            SAPIntegUtils.writeStringField(gen, 'ANTLF', 'X');
                                            SAPIntegUtils.writeStringField(gen, 'UNTTO', 'X');
                                            SAPIntegUtils.writeStringField(gen, 'BZIRK', 'X');                                             
                                        }
            							//SAPIntegUtils.writeStringField(gen, 'ZZCANPVC', 'X');        						
                                    gen.writeEndObject();
                                    gen.writeFieldName('FUNCTIONS');
                                    gen.writeStartObject();
                                        gen.writeFieldName('FUNCTIONS');
                                        gen.writeStartObject();
                                            gen.writeFieldName('item');
                                            gen.writeStartArray();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'WE');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'RG');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'RE');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'AG');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'VE');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATA');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', acc.LeadSellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));
                                                        //SAPIntegUtils.writeStringField(gen, 'PARTNER', '0000009880');
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATAX');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', 'X');
                                                    gen.writeEndObject();
                                                gen.writeEndObject();
                                            gen.writeEndArray(); //END 'item' ARRAY
                                        gen.writeEndObject(); //END 'FUNCTIONS'
                                    gen.writeEndObject(); //END 'FUNCTIONS'
                                gen.writeEndObject();
                            gen.writeEndObject();
                        gen.writeEndObject(); //END 'SALES_DATA'
                        gen.writeFieldName('COMPANY_DATA');
                        gen.writeStartObject();
                            gen.writeFieldName('COMPANY');
                            gen.writeStartObject();
                                gen.writeFieldName('item');
                                gen.writeStartObject();
                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                    gen.writeFieldName('DATA_KEY');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'BUKRS', '2190'); //FIXO
                                    gen.writeEndObject();
                                    gen.writeFieldName('DATA');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'AKONT', '0111510001'); //FIXO
                                        SAPIntegUtils.writeStringField(gen, 'ZUAWA', '009'); //FIXO
                                        SAPIntegUtils.writeStringField(gen, 'FDGRV', 'CLIE NAL'); //FIXO
                                        SAPIntegUtils.writeStringField(gen, 'VZSKZ', '01'); //FIXO
                                        SAPIntegUtils.writeStringField(gen, 'XZVER', 'X'); //FIXO
                                        
                                        if(/*KTOKD == 'PGFT'*/false)
                                            SAPIntegUtils.writeStringField(gen, 'ZWELS', 'A');
                                        else
                                            SAPIntegUtils.writeStringField(gen, 'ZWELS', 'D');
                    
                                    gen.writeEndObject();
                                    gen.writeFieldName('DATAX');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'AKONT', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'ZUAWA', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'FDGRV', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'VZSKZ', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'XZVER', 'X');
                                        SAPIntegUtils.writeStringField(gen, 'ZWELS', 'X');        
                                    gen.writeEndObject();
                                gen.writeEndObject();        					        					
                            gen.writeEndObject();
                        gen.writeEndObject(); //END 'COMPANY_DATA'    
                    gen.writeEndObject();
                gen.writeEndObject();
            gen.writeEndObject();
            gen.writeFieldName('I_Z_FIELDS');
            	gen.writeStartObject();
            		gen.writeFieldName('item');
            		gen.writeStartObject();
            				gen.writeFieldName('KNVV');	
            				gen.writeStartObject();
            					gen.writeFieldName('item');
            					gen.writeStartObject();
                                	gen.writeFieldName('DATA_KEY');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'VKORG', acc.LeadSalesOrganizationTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'VTWEG', acc.LeadDistributionChannelTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'SPART', acc.LeadActivitySectorTxt__c);
                                    gen.writeEndObject();
                                    gen.writeFieldName('DATA');
                                    gen.writeStartObject();
                                        SAPIntegUtils.writeStringField(gen, 'ZZCANPVC', acc.ChannelLkp__r.Name);
                                    gen.writeEndObject();
            						gen.writeFieldName('DATAX');
            						gen.writeStartObject();
            							SAPIntegUtils.writeStringField(gen, 'ZZCANPVC', 'X');
            						gen.writeEndObject();
            					gen.writeEndObject();//END item
            				gen.writeEndObject();//END KNVV
            		gen.writeEndObject();//END item
            	gen.writeEndObject();//END I_Z_FIELDS            
            gen.writeEndObject(); //END JSON     
        }
        catch(Exception e){
            System.debug(e);
            HttpResponse errorResponse = new HttpResponse();
            errorResponse.setStatus(e.getMessage());
            errorResponse.setStatusCode(501);
        }
        
        String jsonStr = gen.getAsString();
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'Customer'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/Customer/Homologation';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug(jsonStr);
        
        String auxReqBody = req.getBody();
        System.debug('###request: ' + auxReqBody.replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //HTTPResponse res = new HttpResponse();
        
        System.debug(res.getBody());
        
        return res; 
    }
    
	public static HttpResponse createPartner(Id accountId){
        JSONGenerator gen = JSON.createGenerator(true);   
        Account acc = [SELECT Id, 
                       Parent.MarketedMaterialsTxt__c, Parent.CNPJTxt__c, Parent.RG_StateInscriptionTxt__c, Parent.IndustryTxt__c, Parent.NielsenZoneTxt__c, 
                       Parent.BillingStateCode, Parent.OperationModeTxt__c, Parent.BillingCountryCode, Parent.Name, 
                       Parent.ChannelLkp__c, Parent.ChannelLkp__r.Name,
                       Parent.LeadSalesOrganizationTxt__c, Parent.LeadDistributionChannelTxt__c, Parent.LeadActivitySectorTxt__c,
                       Parent.LeadSellerLkp__c, Parent.LeadSellerLkp__r.SellerNumberNmb__c,
                       Parent.ShortNameTxt__c, Parent.EmailTxt__c, Parent.XMLEmailTxt__c, Parent.SuframaCodeTxt__c, Parent.ShipmentConditionTxt__c, 
                       Parent.ChannelPVCTxt__c, 
                       PartnerTypeTxt__c, BillingCity, BillingPostalCode, BillingDistrict__c, BillingCountry, BillingCountryCode,
                       BillingNumber__c, BillingStreet, Phone,
                       AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.SellerLkp__r.SellerNumberNmb__c, AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c,
                       AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c, AccountAreaSalesLkp__r.CodeActivitySectorTxt__c
                       FROM Account WHERE Id = :accountId];
        
        gen.writeStartObject();
        SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
        gen.writeFieldName('I_EI_MAIN');
        gen.writeStartObject();
        	gen.writeFieldName('CUSTOMERS');
        	gen.writeStartObject();
        		gen.writeFieldName('item');
        		gen.writeStartObject();
        			gen.writeFieldName('HEADER');
        			gen.writeStartObject();
        				SAPIntegUtils.writeStringField(gen, 'OBJECT_TASK', 'I');
        			gen.writeEndObject();
        
        			gen.writeFieldName('CENTRAL_DATA');
        			gen.writeStartObject();
						gen.writeFieldName('CENTRAL');
        				gen.writeStartObject();
        					gen.writeFieldName('DATA');
        					gen.writeStartObject();
        						SAPIntegUtils.writeStringField(gen, 'KTOKD', acc.PartnerTypeTxt__c);
        						SAPIntegUtils.writeStringField(gen, 'CFOPC', '00'); //FIXO
        						SAPIntegUtils.writeStringField(gen, 'STCD1', SAPIntegUtils.removeAllButNumbers(acc.Parent.CNPJTxt__c));
        						SAPIntegUtils.writeStringField(gen, 'STCD3', SAPIntegUtils.removeAllButNumbers(acc.Parent.RG_StateInscriptionTxt__c));
        						SAPIntegUtils.writeStringField(gen, 'BRSCH', acc.Parent.IndustryTxt__c);
        						SAPIntegUtils.writeStringField(gen, 'COUNC', acc.Parent.BillingStateCode);
        						SAPIntegUtils.writeStringField(gen, 'CITYC', acc.Parent.BillingStateCode);
        						SAPIntegUtils.writeStringField(gen, 'BRAN1', acc.Parent.OperationModeTxt__c);
        					gen.writeEndObject();
        					gen.writeFieldName('DATAX');
        					gen.writeStartObject();
        						SAPIntegUtils.writeStringField(gen, 'KTOKD', 'X');
        						SAPIntegUtils.writeStringField(gen, 'STCD1', 'X');
        						SAPIntegUtils.writeStringField(gen, 'STCD3', 'X');
    							SAPIntegUtils.writeStringField(gen, 'CFOPC', 'X');
        						SAPIntegUtils.writeStringField(gen, 'BRSCH', 'X');
                                SAPIntegUtils.writeStringField(gen, 'COUNC', 'X');
                                SAPIntegUtils.writeStringField(gen, 'CITYC', 'X');
                                SAPIntegUtils.writeStringField(gen, 'BRAN1', 'X');
        					gen.writeEndObject();
        				gen.writeEndObject();
        				gen.writeFieldName('ADDRESS');
        				gen.writeStartObject();
        					SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
        					gen.writeFieldName('POSTAL');
        					gen.writeStartObject();
        						gen.writeFieldName('DATA');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'CITY', StringUtils.removeDiacritics(acc.BillingCity));
        							SAPIntegUtils.writeStringField(gen, 'POSTL_COD1', acc.BillingPostalCode); //Deve vir com pontuação
        							SAPIntegUtils.writeStringField(gen, 'COUNTRY', acc.Parent.BillingCountryCode);
        							SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT'); //FIXO
        							SAPIntegUtils.writeStringField(gen, 'REGION', acc.Parent.BillingStateCode);
        							SAPIntegUtils.writeStringField(gen, 'NAME', acc.Parent.Name); //TAMANHO MAXIMO: 40 Caracteres
        							SAPIntegUtils.writeStringField(gen, 'DISTRICT', acc.BillingDistrict__c);
        							SAPIntegUtils.writeStringField(gen, 'STREET', acc.BillingStreet);
        							SAPIntegUtils.writeStringField(gen, 'HOUSE_NO', acc.BillingNumber__c);
        							SAPIntegUtils.writeStringField(gen, 'SORT1', acc.Parent.ShortNameTxt__c); //TAMANHO MAXIMO: 20 Caracteres
        						gen.writeEndObject();
        						gen.writeFieldName('DATAX');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'CITY', 'X');
        							SAPIntegUtils.writeStringField(gen, 'POSTL_COD1', 'X');
        							SAPIntegUtils.writeStringField(gen, 'COUNTRY', 'X');
        							SAPIntegUtils.writeStringField(gen, 'LANGU', 'PT');
        							SAPIntegUtils.writeStringField(gen, 'REGION', 'X');
        							SAPIntegUtils.writeStringField(gen, 'NAME', 'X');
        							SAPIntegUtils.writeStringField(gen, 'DISTRICT', 'X');
        							SAPIntegUtils.writeStringField(gen, 'STREET', 'X');
        							SAPIntegUtils.writeStringField(gen, 'HOUSE_NO', 'X');
        							SAPIntegUtils.writeStringField(gen, 'SORT1', 'X');
        						gen.writeEndObject();
        					gen.writeEndObject();
        					gen.writeFieldName('COMMUNICATION');
        					gen.writeStartObject();
        						gen.writeFieldName('PHONE');
        						gen.writeStartObject();
        							gen.writeFieldName('PHONE');
        							gen.writeStartObject();
        								gen.writeFieldName('item');
        								gen.writeStartObject();
        									gen.writeFieldName('CONTACT');
        									gen.writeStartObject();
        										gen.writeFieldName('DATA');
        										gen.writeStartObject();
        											SAPIntegUtils.writeStringField(gen, 'TELEPHONE', SAPIntegUtils.removeAllButNumbers(acc.Phone));
        										gen.writeEndObject();
                								gen.writeFieldName('DATAX');
        										gen.writeStartObject();
        											SAPIntegUtils.writeStringField(gen, 'TELEPHONE', 'X');
        										gen.writeEndObject();
        									gen.writeEndObject();
        								gen.writeEndObject();
        							gen.writeEndObject();
        						gen.writeEndObject();
        					gen.writeEndObject(); //END 'COMMUNICATION'
        				gen.writeEndObject(); //END 'ADDRESS'
    					gen.writeFieldName('TAX_IND');
    					gen.writeStartObject();
    						gen.writeFieldName('TAX_IND');
    						gen.writeStartObject();
    							gen.writeFieldName('item');
    							gen.writeStartObject();	
    								SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
    								gen.writeFieldName('DATA_KEY');
    								gen.writeStartObject();
    									SAPIntegUtils.writeStringField(gen, 'ALAND', 'BR');
    									SAPIntegUtils.writeStringField(gen, 'TATYP', 'IBRX');
    								gen.writeEndObject();
    								gen.writeFieldName('DATA');
    								gen.writeStartObject();
    									SAPIntegUtils.writeStringField(gen, 'TAXKD', '1');
    								gen.writeEndObject();
    								gen.writeFieldName('DATAX');
    								gen.writeStartObject();
    									SAPIntegUtils.writeStringField(gen, 'TAXKD', 'X');
    								gen.writeEndObject();
    							gen.writeEndObject();
    						gen.writeEndObject();
    					gen.writeEndObject();
        			gen.writeEndObject(); //END 'CENTRAL_DATA' 
        			gen.writeFieldName('SALES_DATA');
        			gen.writeStartObject();
        				gen.writeFieldName('SALES');
        				gen.writeStartObject();
        					gen.writeFieldName('item');
        					gen.writeStartObject();
        						SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
        						gen.writeFieldName('DATA_KEY');
        						gen.writeStartObject();
        
                                    if(acc.AccountAreaSalesLkp__r == null){
                                        SAPIntegUtils.writeStringField(gen, 'VKORG', acc.Parent.LeadSalesOrganizationTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'VTWEG', acc.Parent.LeadDistributionChannelTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'SPART', acc.Parent.LeadActivitySectorTxt__c);                                        
                                    }
                                    else{
                                        SAPIntegUtils.writeStringField(gen, 'VKORG', acc.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'VTWEG', acc.AccountAreaSalesLkp__r.CodeDistribubutionChannelTxt__c);
                                        SAPIntegUtils.writeStringField(gen, 'SPART', acc.AccountAreaSalesLkp__r.CodeActivitySectorTxt__c);  
                                    }
        			
        						gen.writeEndObject();
        						gen.writeFieldName('DATA');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'VERSG', '1'); //FIXO
        							
        							if(acc.Parent.LeadSalesOrganizationTxt__c == '0099')
        								SAPIntegUtils.writeStringField(gen, 'KALKS', '5');
                                    else
                                        SAPIntegUtils.writeStringField(gen, 'KALKS', '1');
        							SAPIntegUtils.writeStringField(gen, 'VSBED', acc.Parent.ShipmentConditionTxt__c);      						
        							//SAPIntegUtils.writeStringField(gen, 'VKBUR', '0050'); //SERÁ BUSCADO PELO SAP       						
        							//SAPIntegUtils.writeStringField(gen, 'VKGRP', '001'); //SERÁ BUSCADO PELO SAP        						
        							SAPIntegUtils.writeStringField(gen, 'KTGRD', '01'); //SERÁ BUSCADO PELO SAP        						     						
        							SAPIntegUtils.writeStringField(gen, 'KKBER', 'BRAS'); //FIXO        	
    								SAPIntegUtils.writeStringField(gen, 'LPRIO', '02'); //FIXO    
                       				if(acc.Parent.LeadSalesOrganizationTxt__c == '0099')
        								SAPIntegUtils.writeStringField(gen, 'KABSS', '0001');    
        							else
        								SAPIntegUtils.writeStringField(gen, 'KABSS', '0003');     							    						
        							SAPIntegUtils.writeStringField(gen, 'INCO1', 'CIF'); //FIXO        						
        							SAPIntegUtils.writeStringField(gen, 'INCO2', 'Até o destino'); //FIXO 
                                    SAPIntegUtils.writeStringField(gen, 'WAERS', 'BRL'); //FIXO  
        							SAPIntegUtils.writeStringField(gen, 'KONDA', 'VG'); //FIXO POR ENQUANTO, ATÉ DAVI ALINHAR COM GIBA
        						gen.writeEndObject(); 
         						gen.writeFieldName('DATAX');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'KALKS', 'X'); 
        							SAPIntegUtils.writeStringField(gen, 'VSBED', 'X');     
         							SAPIntegUtils.writeStringField(gen, 'VKBUR', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'KTGRD', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'KKBER', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'LPRIO', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'KABSS', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'INCO1', 'X');      						
        							SAPIntegUtils.writeStringField(gen, 'INCO2', 'X'); 
                                    SAPIntegUtils.writeStringField(gen, 'WAERS', 'X'); 	
        							SAPIntegUtils.writeStringField(gen, 'KONDA', 'X'); 
        						gen.writeEndObject();
        						gen.writeFieldName('FUNCTIONS');
        						gen.writeStartObject();
                                    gen.writeFieldName('FUNCTIONS');
                                    gen.writeStartObject();
        								gen.writeFieldName('item');
        								gen.writeStartArray();
                                            gen.writeStartObject();
                                                SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                gen.writeFieldName('DATA_KEY');
                                                gen.writeStartObject();
    												if(acc.PartnerTypeTxt__c == 'REOR')
                                                    	SAPIntegUtils.writeStringField(gen, 'PARVW', 'WE');
   													else if(acc.PartnerTypeTxt__c == 'PGFT')
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'RG');
                                                    SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                gen.writeEndObject();
        									gen.writeEndObject();
                                            gen.writeStartObject();
                                                SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                gen.writeFieldName('DATA_KEY');
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'PARVW', 'VE');
                                                    SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                gen.writeEndObject();
                                                gen.writeFieldName('DATA');
                                                gen.writeStartObject();
                                                    if(acc.AccountAreaSalesLkp__r == null){
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', acc.Parent.LeadSellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));                                      
                                                    }
                                                    else{
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', acc.AccountAreaSalesLkp__r.SellerLkp__r.SellerNumberNmb__c.leftPad(10, '0'));
                                                    }
                                                gen.writeEndObject();
                                                gen.writeFieldName('DATAX');
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'PARTNER', 'X');
                                                gen.writeEndObject();
                                            gen.writeEndObject();
        								gen.writeEndArray(); //END 'item' ARRAY
                                    gen.writeEndObject(); //END 'FUNCTIONS'
        						gen.writeEndObject(); //END 'FUNCTIONS'
        					gen.writeEndObject();
        				gen.writeEndObject();
        			gen.writeEndObject(); //END 'SALES_DATA'
        			gen.writeFieldName('COMPANY_DATA');
        			gen.writeStartObject();
        				gen.writeFieldName('COMPANY');
        				gen.writeStartObject();
        					gen.writeFieldName('item');
        					gen.writeStartObject();
                				SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
        						gen.writeFieldName('DATA_KEY');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'BUKRS', '2190'); //FIXO
        						gen.writeEndObject();
        						gen.writeFieldName('DATA');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'AKONT', '0111510001'); //FIXO
        							SAPIntegUtils.writeStringField(gen, 'ZUAWA', '009'); //FIXO
        							SAPIntegUtils.writeStringField(gen, 'FDGRV', 'CLIE NAL'); //FIXO
        							SAPIntegUtils.writeStringField(gen, 'VZSKZ', '01'); //FIXO
        							SAPIntegUtils.writeStringField(gen, 'XZVER', 'X'); //FIXO
        							
        							if(acc.PartnerTypeTxt__c == 'PGFT')
                                    	SAPIntegUtils.writeStringField(gen, 'ZWELS', 'A');
        							else
                                        SAPIntegUtils.writeStringField(gen, 'ZWELS', 'D');
       			
        						gen.writeEndObject();
          						gen.writeFieldName('DATAX');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'AKONT', 'X');
        							SAPIntegUtils.writeStringField(gen, 'ZUAWA', 'X');
        							SAPIntegUtils.writeStringField(gen, 'FDGRV', 'X');
        							SAPIntegUtils.writeStringField(gen, 'VZSKZ', 'X');
        							SAPIntegUtils.writeStringField(gen, 'XZVER', 'X');
        							SAPIntegUtils.writeStringField(gen, 'ZWELS', 'X');        
        						gen.writeEndObject();
        					gen.writeEndObject();        					        					
        				gen.writeEndObject();
        			gen.writeEndObject(); //END 'COMPANY_DATA'        			
        		gen.writeEndObject();
        	gen.writeEndObject();
        gen.writeEndObject();
        
        
        String jsonStr = gen.getAsString();
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'Customer'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/Customer/Homologation';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug(jsonStr);
        
        String auxReqBody = req.getBody();
        System.debug('###request: ' + auxReqBody.replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //HTTPResponse res = new HttpResponse();
        
        System.debug(res.getBody());
        
        return res; 
    }    
    
    public static HttpResponse associatePartner(Id accountId, Id partnerId){
        JSONGenerator gen = JSON.createGenerator(true);   
        
        Account acc = [SELECT Id, Name, CodeCustomerTxt__c FROM Account WHERE Id = :accountId];
        Account accPartner = [SELECT Id, Name, CodeCustomerTxt__c FROM Account WHERE Id = :partnerId];
        
        gen.writeStartObject();
        	SAPIntegUtils.writeStringField(gen, 'TUN_ONLINE', 'X');
            gen.writeFieldName('I_EI_MAIN');
            gen.writeStartObject();
        		gen.writeFieldName('CUSTOMERS');
        		gen.writeStartObject();
        			gen.writeFieldName('item');
        			gen.writeStartObject();
        				gen.writeFieldName('HEADER');
        				gen.writeStartObject();
        					gen.writeFieldName('OBJECT_INSTANCE');
        					gen.writeStartObject();
        						System.debug('CÓDIGO SAP DO PAI: '+acc.CodeCustomerTxt__c);
        						SAPIntegUtils.writeStringField(gen, 'KUNNR', acc.CodeCustomerTxt__c.leftPad(10, '0'));
        					gen.writeEndObject();
                            SAPIntegUtils.writeStringField(gen, 'OBJECT_TASK', 'U');
        				gen.writeEndObject();//END - HEADER
        				gen.writeFieldName('SALES_DATA');
        				gen.writeStartObject();
        					gen.writeFieldName('SALES');
        					gen.writeStartObject();
        						gen.writeFieldName('item');
        						gen.writeStartObject();
        							SAPIntegUtils.writeStringField(gen, 'TASK', 'U');
        							gen.writeFieldName('DATA_KEY');
        							gen.writeStartObject();
        								SAPIntegUtils.writeStringField(gen, 'VKORG', 'AM01');
        								SAPIntegUtils.writeStringField(gen, 'VTWEG', 'RV');
        								SAPIntegUtils.writeStringField(gen, 'SPART', 'PR');
        							gen.writeEndObject();
        							gen.writeFieldName('FUNCTIONS');
        							gen.writeStartObject();
        								gen.writeFieldName('FUNCTIONS');
        								gen.writeStartObject();
                                            gen.writeFieldName('item');
                                            gen.writeStartArray();
                                                gen.writeStartObject();
                                                    SAPIntegUtils.writeStringField(gen, 'TASK', 'I');
                                                    gen.writeFieldName('DATA_KEY');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARVW', 'WE');
                                                        SAPIntegUtils.writeStringField(gen, 'PARZA', '006');
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATA');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', accPartner.CodeCustomerTxt__c.leftPad(10, '0'));
                                                    gen.writeEndObject();
                                                    gen.writeFieldName('DATAX');
                                                    gen.writeStartObject();
                                                        SAPIntegUtils.writeStringField(gen, 'PARTNER', 'X');
                                                    gen.writeEndObject(); 
                                                gen.writeEndObject();
                                            gen.writeEndArray();        									
        								gen.writeEndObject(); //FUNCTIONS
        							gen.writeEndObject(); //FUNCTIONS
        						gen.writeEndObject();
        					gen.writeEndObject();
        				gen.writeEndObject(); //END - SALES_DATA
        			gen.writeEndObject();
        		gen.writeEndObject();
        	gen.writeEndObject();
        gen.writeEndObject();
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'Customer'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/Customer/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        return res;         
    }
    
    public static HttpResponse getReceivables(String[] accountCodeList){      
        JSONGenerator gen = JSON.createGenerator(true);   
           
        gen.writeStartObject();
        gen.writeFieldName('I_KUNNR_TAB');
        gen.writeStartObject();
        gen.writeFieldName('item');
        gen.writeStartArray();
        for(String accountCode: accountCodeList){
            if (accountCode != null){
            	gen.writeString(accountCode);    
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
        
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'ZPH_BSID'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/ZPH_BSID/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        return res;        
    }
    
    public static HttpResponse getCreditLimit(List<Id> accountIdList){
        List<Account> accountList = [SELECT Id, Name, CodeCustomerTxt__c FROM Account WHERE Id IN :accountIdList]; 
        JSONGenerator gen = JSON.createGenerator(true);  
        
        gen.writeStartObject();
        	gen.writeFieldName('T_ZPH_CRED_IN');
        	gen.writeStartObject();
        		gen.writeFieldName('item');
        		gen.writeStartArray();
        			for (Account acc: accountList){
                        gen.writeStartObject();
                            SAPIntegUtils.writeStringField(gen, 'KUNNR', acc.CodeCustomerTxt__c.leftPad(10, '0'));
                        	SAPIntegUtils.writeStringField(gen, 'KKBER', 'BRAS');
                        gen.writeEndObject();                        
                    }
        		gen.writeEndArray();
        	gen.writeEndObject();
        gen.writeEndObject();
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
     
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'ZPH_CRED'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/ZPH_CRED/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
       
        //System.debug(res.getBody());
        System.debug('###response: ' + res.getBody().replaceAll('(\\s+)', ''));
        
        return res;                
    }
    
    public static HttpResponse getNCDiscount(List<AccountAreaSales__c> areaSalesList, Date startDate, Date endDate){        
        //List<AccountAreaSales__c> areaSalesList = [SELECT Id, Name, SAPCodeFml__c FROM AccountAreaSales__c WHERE Id IN :areaSalesIdList];
        
        JSONGenerator gen = JSON.createGenerator(true);  
        
        gen.writeStartObject();
        	gen.writeStringField('TUN_ONLINE', 'X');
        	gen.writeFieldName('I_AUGDT_RANGE');
        	gen.writeStartObject();
        		gen.writeStringField('SIGN', 'I');
        		gen.writeStringField('OPTION', 'BT');
        		gen.writeStringField('LOW', formatDate(startDate));
        		gen.writeStringField('HIGH', formatDate(endDate));    		
        	gen.writeEndObject();
        	gen.writeFieldName('I_KUNNR_TAB');
        	gen.writeStartObject();
        		gen.writeFieldName('item');
        		gen.writeStartArray();
                    for(AccountAreaSales__c av : areaSalesList){
                        gen.writeString(av.SAPCodeFml__c.leftPad(10,'0'));
                    }
        		gen.writeEndArray();
        	gen.writeEndObject();
        	gen.writeFieldName('I_BUKRS_TAB');
        	gen.writeStartObject();
        		gen.writeFieldName('item');
        		gen.writeStartArray();
        			gen.writeString('2190');
        		gen.writeEndArray();
        	gen.writeEndObject();
        gen.writeEndObject();
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
     
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'NcCompensated'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/NcCompensated/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
       
        System.debug(res.getBody());
        
        return res;          
    }
    
    public static HttpResponse createCreditNote(Id creditNoteId){
        CreditNote__c creditNote = [SELECT Id, Name, AccountLkp__r.MainSalesAreaLkp__r.SalesOfficeTxt__c,
                                    TypeTxt__c, CampaignLkp__r.Name, Value__c, AccountLkp__r.MainSalesAreaLkp__r.SAPCodeFml__c,
                                    CampaignLkp__r.StartDate__c, CampaignLkp__r.EndDate__c, Date__c, InstallmentNumberNmb__c
                                    FROM CreditNote__c WHERE Id = :creditNoteId];
        
        JSONGenerator gen = JSON.createGenerator(true);  
        gen.writeStartObject();
        	gen.writeFieldName('I_REQUEST');
        	gen.writeStartObject();
        		SAPIntegUtils.writeStringField(gen, 'SF_CODNC', creditNote.Id);
                SAPIntegUtils.writeStringField(gen, 'SF_NUMNC', creditNote.Name);
                SAPIntegUtils.writeStringField(gen, 'VKBUR', creditNote.AccountLkp__r.MainSalesAreaLkp__r.SalesOfficeTxt__c);
                SAPIntegUtils.writeStringField(gen, 'TPCCD', creditNote.TypeTxt__c);
                SAPIntegUtils.writeStringField(gen, 'CMPDS', creditNote.CampaignLkp__r.Name);
                SAPIntegUtils.writeStringField(gen, 'TOTVL', String.valueOf(creditNote.Value__c));
                SAPIntegUtils.writeStringField(gen, 'KUNNR', creditNote.AccountLkp__r.MainSalesAreaLkp__r.SAPCodeFml__c.leftPad(10,'0'));
                SAPIntegUtils.writeStringField(gen, 'INIDT', formatDate(creditNote.CampaignLkp__r.StartDate__c));
                SAPIntegUtils.writeStringField(gen, 'FIMDT', formatDate(creditNote.CampaignLkp__r.EndDate__c));
                SAPIntegUtils.writeStringField(gen, 'PAGDT', formatDate(creditNote.Date__c));
                SAPIntegUtils.writeStringField(gen, 'PARCN', String.valueOf(creditNote.InstallmentNumberNmb__c.intValue()).leftPad(4, '0'));
        		/*
        		gen.writeStringField('SF_CODNC', creditNote.Id);
        		gen.writeStringField('SF_NUMNC', creditNote.Name);
        		gen.writeStringField('VKBUR', creditNote.AccountLkp__r.MainSalesAreaLkp__r.SalesOfficeTxt__c);
        		gen.writeStringField('TPCCD', creditNote.TypeTxt__c);
        		gen.writeStringField('CMPDS', creditNote.CampaignLkp__r.Name);
        		gen.writeStringField('TOTVL', String.valueOf(creditNote.Value__c));
        		gen.writeStringField('KUNNR', creditNote.AccountLkp__r.MainSalesAreaLkp__r.SAPCodeFml__c.leftPad(10,'0'));
        		gen.writeStringField('INIDT', formatDate(creditNote.CampaignLkp__r.StartDate__c));
        		gen.writeStringField('FIMDT', formatDate(creditNote.CampaignLkp__r.EndDate__c));
        		gen.writeStringField('PAGDT', formatDate(creditNote.Date__c));
				gen.writeStringField('PARCN', String.valueOf(creditNote.InstallmentNumberNmb__c.intValue()).leftPad(4, '0'));  */      
        	gen.writeEndObject();
        	gen.writeStringField('TUN_ONLINE', 'X');
        gen.writeEndObject();
        
        
        // Get the JSON string
        String jsonStr = gen.getAsString();
     
        String endpoint = ApexRedirectMap__c.getInstance('EndpointPrefix').UrlSufix__c+'CreateNc'+ApexRedirectMap__c.getInstance('EndpointSuffix').UrlSufix__c;
        //String endpoint = 'http://179.125.173.106:50000/RESTAdapter/SFDC/CreateNc/Homologation';
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(jsonStr); 
        
        System.debug('###request: ' + req.getBody().replaceAll('(\\s+)', ''));
        
        req = setHeader(req);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
       	//HTTPResponse res = new HttpResponse();
        
        System.debug(res.getBody());
        
        return res;                       
    }
    
    private static HttpRequest setHeader(HttpRequest req){
        //String username = 'USER_SFDC_HOMOLOG';
        //String password = 'homolog_2016*';
        String username = ApexRedirectMap__c.getInstance('WebServiceUser').UrlSufix__c;
        String password = ApexRedirectMap__c.getInstance('WebServicePassword').UrlSufix__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');     
        
        return req; 
    }
    
    private static String formatDate(Date d){
        if(d != null){
            return d.year() + '-' + d.month() + '-' + d.day();
        }
        else{
            return null;
        }
    }
}