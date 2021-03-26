public without sharing class CaseCreateInvoiceAndOrderCtrl {
    //block name depending on the record type
    public String finderBlockTitle {get;set;}
    
    //fields to insert the number to be searched
    public String invoiceNumber {get;set;}
    public String orderNumber {get;set;}
    
    //list to insert in the tables
    public List<Invoice__c> listInvoice {get;set;}
    public List<Order__c> listOrder {get;set;}
    
    //variables that determines which object must be shown
    public Boolean showInvoice {get;set;}
    public Boolean showOrder {get;set;}
    
    //objects selectors
    private CSEInvoiceSelector invoiceSelector;
    private CSEOrderSelector orderSelector;
    private CSECaseSelector caseSelector;
    
    //url parameter
    private String recordTypeId;
    private String recordTypeName;
    private String accountId = '';
    private String reason = '';
    private String contact = '';
    private String nature = '';
    private String caseCategory = '';
    
    //cases to complements the tables
    public String caseInvoice {get;set;}
    public String caseOrder {get;set;}
    
    //custom configurations manager
    private ApexRedirectMap__c customConfig;
    
    //control what to display if console
    public Boolean showHeader {get;set;}
    
    //emails to put to add to case
    private String sellerEmail = '';
    private String carrierEmail = '';
    
    //parameters for carrier and seller, if recordTypeName equals Devolucao
    private String carrierId = '';
    private String carrierName = '';
    private String sellerId = '';
    private String sellerName = '';
    private String coordinatorEmail = '';
    private String managerEmail = '';
    
    //parameter for extended page
    private ApexPages.StandardController controller;
    
    //code to find invoice in sap
    private String clientCode = '';
    
    public CaseCreateInvoiceAndOrderCtrl(ApexPages.StandardController controller) {
        
        this.controller = controller;
        
        //if(Apexpages.currentPage().getParameters().get('inConsole').equals('yes')) {
        //   showHeader=false;
        //}else {
        //   showHeader=true;
       //}
        ////RSilva 13/11/2017 comentada verificação showheader e chapado valor como false para usar versão console; URL de redirecionamento não está enviando esse paramentro, isInConsole() e URLFOR()
        showHeader=false;
        
        reason = Apexpages.currentPage().getParameters().get('reason');
        contact = Apexpages.currentPage().getParameters().get('contact');
        nature = Apexpages.currentPage().getParameters().get('nature');
        caseCategory = Apexpages.currentPage().getParameters().get('category');
        
        finderBlockTitle = '';
        
        invoiceSelector = new CSEInvoiceSelector();
        orderSelector = new CSEOrderSelector();
        caseSelector = new CSECaseSelector();
        
        listInvoice = new List<Invoice__c>();
        listOrder = new List<Order__c>();
        
        setLayout();
        
        invoiceNumber = '';
        orderNumber = '';
        
        caseInvoice = '';
        caseOrder = '';
        
                    
    }
    
    public PageReference findInvoice() {
        
        if(!invoiceNumber.equals('')) {

            listInvoice = invoiceSelector.selectByNumberAndCustomer(invoiceNumber, accountId);
            
            if(checkInvoiceOnSAP(invoiceNumber)) {
                
                System.debug('>>>>>>>>>>>>>invoice name: ' + listInvoice[0].Name);
                System.debug('>>>>>>>>>>>>>account ID: ' + accountId);
                
                listInvoice = invoiceSelector.selectByNumberAndCustomer(listInvoice[0].Name, accountId);
                
                System.debug('>>>>>>>>>>>>>>>>>retorno invoice list: ' + listInvoice);
                
                if(listInvoice == null || listInvoice.isEmpty()) {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Falha na busca, tente novamente.');
                    ApexPages.addMessage(errMsg);
                    return null;
                }
                
                List<Case> auxCaseList = caseSelector.selectByInvoice(listInvoice[0].Id);
                for(Case auxCase : auxCaseList) {
                    caseInvoice += auxCase.CaseNumber + '; ';
                }
                
                if(listInvoice[0].CarrierLkp__r.EmailTxt__c != null && !listInvoice[0].CarrierLkp__r.EmailTxt__c.equals('')) {
                    carrierEmail = listInvoice[0].CarrierLkp__r.EmailTxt__c;    
                }
                
                if(listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c != null && !listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c.equals('')) {
                    sellerEmail = listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c;
                } 
                
                if(listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c != null && !listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c.equals('')) {
                    coordinatorEmail = listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c;
                } 
                
                if(listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c != null && !listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c.equals('')) {
                    managerEmail = listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c;
                } 
                
                if(listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Name != null && !listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Name.equals('')) {
                    sellerId = listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Id;
                    sellerName = listInvoice[0].RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Name;
                }
                
                if(listInvoice[0].CarrierLkp__r.Name != null && !listInvoice[0].CarrierLkp__r.Name.equals('')) {
                    carrierId = listInvoice[0].CarrierLkp__r.Id;
                    carrierName = listInvoice[0].CarrierLkp__r.Name;
                }
            } else {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Nota fiscal não encontrada.');
                ApexPages.addMessage(errMsg);
            }

        } else {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Digite uma nota fiscal para ser pesquisada.');
            ApexPages.addMessage(errMsg);
        }
        
        return null;    
    }
    
    public PageReference findOrder() {

        if(!orderNumber.equals('')) {
            this.syncOnSapByOrderNumber(orderNumber);
            this.listOrder = orderSelector.selectByNumber(orderNumber);
            
            if(listOrder != null && !listOrder.isEmpty()) {
                List<Case> auxCaseList = caseSelector.selectByOrder(listOrder[0].Id);
                for(Case auxCase : auxCaseList) {
                    caseOrder += auxCase.CaseNumber + '; ';
                }
                
                List<Invoice__c> auxInvoice = invoiceSelector.selectByOrderId(listOrder[0].Id);
                
                if(auxInvoice != null && !auxInvoice.isEmpty() && auxInvoice[0].CarrierLkp__r.EmailTxt__c != null && !auxInvoice[0].CarrierLkp__r.EmailTxt__c.equals('')) {
                    carrierEmail= auxInvoice[0].CarrierLkp__r.EmailTxt__c;
                }
                
                if(listOrder[0].SellerLkp__r.SellerEmailTxt__c != null && !listOrder[0].SellerLkp__r.SellerEmailTxt__c.equals('')) {
                    sellerEmail= listOrder[0].SellerLkp__r.SellerEmailTxt__c;
                }
                
                if(auxInvoice != null && !auxInvoice.isEmpty() && auxInvoice[0].CarrierLkp__r.Name != null && !auxInvoice[0].CarrierLkp__r.Name.equals('')) {
                    carrierId = auxInvoice[0].CarrierLkp__c;
                    carrierName = auxInvoice[0].CarrierLkp__r.Name;
                }
                
                if(listOrder[0].SellerLkp__r.Name != null && !listOrder[0].SellerLkp__r.Name.equals('')) {
                    sellerId = listOrder[0].SellerLkp__c;
                    sellerName = listOrder[0].SellerLkp__r.Name;
                }
                
            }else {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Ordem não encontrada.');
                ApexPages.addMessage(errMsg);   
            }
        }else {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Digite uma ordem a ser pesquisada.');
            ApexPages.addMessage(errMsg);
        }
        
        return null;    
    }
    
    public PageReference doBack() {
        PageReference page;
        
        if(accountId.equals('')) {
            page = new PageReference('/apex/CaseMotive?inConsole=' + (showHeader ? 'no' : 'yes')); 
            page.setRedirect(true); 
        }else {
            page = new PageReference('/apex/CaseMotive?accountId=' + accountId + '&inConsole=' + (showHeader ? 'no' : 'yes')); 
            page.setRedirect(true);
        }
        
        return page;
    }
    
    public PageReference doNext() {

        PageReference page = null;
        
        if((listInvoice != null && !listInvoice.isEmpty()) || (listOrder != null && !listOrder.isEmpty())) { 
            
            customConfig = ApexRedirectMap__c.getValues('CreateCase'); 
                
            
                if(!listInvoice.isEmpty()) {
                    page = new PageReference(customConfig.UrlSufix__c + '&def_account_id=' + accountId + '&RecordType=' + recordTypeId + '&' + 
                    ApexRedirectMap__c.getValues('InvoiceName').UrlSufix__c + '=' + listInvoice[0].Name + '&' + ApexRedirectMap__c.getValues('InvoiceLkpCase').UrlSufix__c +
                     '=' + listInvoice[0].Id + (!sellerEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('SellerEmail').UrlSufix__c + '=' + sellerEmail : '') +
                      (!carrierEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierEmail').UrlSufix__c + '=' + carrierEmail : '') +
                     (recordTypeName.equals('Devolução') && !carrierId.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierNameCase').UrlSufix__c + '=' + carrierName + '&' + ApexRedirectMap__c.getValues('CarrierLkpCase').UrlSufix__c + '=' + carrierId : '') + 
                     (recordTypeName.equals('Devolução') && !sellerId.equals('') ? '&' + ApexRedirectMap__c.getValues('SellerNameCase').UrlSufix__c + '=' + sellerName + '&' + ApexRedirectMap__c.getValues('SellerLkpCase').UrlSufix__c + '=' + sellerId : '') + 
                     (recordTypeName.equals('Carta de correção') && !carrierId.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierNameCase').UrlSufix__c + '=' + carrierName + '&' + ApexRedirectMap__c.getValues('CarrierLkpCase').UrlSufix__c + '=' + carrierId : '') +
                     (coordinatorEmail != null && !coordinatorEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('CoordinatorEmailCase').UrlSufix__c +
                     '=' + coordinatorEmail : '') + (managerEmail != null && !managerEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('ManagerEmailCase').UrlSufix__c + '=' + managerEmail : '') +
                     '&' + ApexRedirectMap__c.getValues('ReasonCase').UrlSufix__c + '=' + reason.replace(' ', '%20') + '&' + ApexRedirectMap__c.getValues('ContactCase').UrlSufix__c +
                     '=' + contact + '&' + ApexRedirectMap__c.getValues('NatureCase').UrlSufix__c +
                     '=' + nature + '&' + ApexRedirectMap__c.getValues('CategoryCase').UrlSufix__c +
                     '=' + caseCategory + '&ent=Case'); 
                                                                  
                }else if(!listOrder.isEmpty()) {
                    page = new PageReference(customConfig.UrlSufix__c + '&def_account_id=' + accountId + '&RecordType=' + recordTypeId + '&' +
                    ApexRedirectMap__c.getValues('OrderName').UrlSufix__c + '=' + listOrder[0].Name + '&' + ApexRedirectMap__c.getValues('OrderLkpCase').UrlSufix__c +
                     '=' + listOrder[0].Id + (!sellerEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('SellerEmail').UrlSufix__c + '=' + sellerEmail : '') +
                      (!carrierEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierEmail').UrlSufix__c + '=' + carrierEmail : '') +
                     (recordTypeName.equals('Devolução') && !carrierId.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierNameCase').UrlSufix__c + '=' + carrierName + '&' + ApexRedirectMap__c.getValues('CarrierLkpCase').UrlSufix__c + '=' + carrierId : '') + 
                     (recordTypeName.equals('Devolução') && !sellerId.equals('') ? '&' + ApexRedirectMap__c.getValues('SellerNameCase').UrlSufix__c + '=' + sellerName + '&' + ApexRedirectMap__c.getValues('SellerLkpCase').UrlSufix__c + '=' + sellerId : '') + 
                     (recordTypeName.equals('Carta de correção') && !carrierId.equals('') ? '&' + ApexRedirectMap__c.getValues('CarrierNameCase').UrlSufix__c + '=' + carrierName + '&' + ApexRedirectMap__c.getValues('CarrierLkpCase').UrlSufix__c + '=' + carrierId : '') +
                     (coordinatorEmail != null && !coordinatorEmail.equals('') ? '&' + ApexRedirectMap__c.getValues('CoordinatorEmailCase').UrlSufix__c +
                     '=' + coordinatorEmail : '') + (managerEmail != null && !managerEmail.equals('') ? managerEmail + '&' + ApexRedirectMap__c.getValues('ManagerEmailCase').UrlSufix__c + '=' : '') +
                     '&' + ApexRedirectMap__c.getValues('ReasonCase').UrlSufix__c + '=' + reason.replace(' ', '%20') + '&' + ApexRedirectMap__c.getValues('ContactCase').UrlSufix__c +
                     '=' + contact + '&' + ApexRedirectMap__c.getValues('NatureCase').UrlSufix__c +
                     '=' + nature + '&' + ApexRedirectMap__c.getValues('CategoryCase').UrlSufix__c +
                     '=' + caseCategory + '&ent=Case');  
                }     
                
            
        
            page.setRedirect(true);
        }else {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'É necessário selecionar uma nota ou uma ordem para prosseguir.');
            ApexPages.addMessage(errMsg);
        }
        System.debug(page);
        return page;
    }
    
    private PageReference setLayout() {
        
        if(Apexpages.currentPage().getParameters().get('def_account_id') != null) {     
            accountId = Apexpages.currentPage().getParameters().get('def_account_id');
        } 
        
        system.debug(accountid);
        Account auxAcc = [Select CodeCustomerTxt__c from Account where Id = :accountId];
        clientCode = auxAcc.CodeCustomerTxt__c;
        
        recordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
        recordTypeName = [Select Name from RecordType where Id = :recordTypeId].Name;    
        
        if(recordTypeName.equals('Reposição')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Substituição')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Devolução')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Prorrogação')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Produto trocado')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Extravio de nota fiscal')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Sinistro')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Sustação')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Refaturamento')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Carta de correção')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }else if(recordTypeName.equals('Transtorno na entrega')) {
            
            finderBlockTitle = 'Localizar nota fiscal';
            showInvoice = true;
            showOrder = false;
            
        }/*else if(recordTypeName.equals('Página localizar Ordem')) {
            
            finderBlockTitle = 'Localizar ordem';
            showInvoice = false;
            showOrder = true;
            
        }*/else if(recordTypeName.equals('Consulta de pedido')) {
            
            finderBlockTitle = 'Localizar ordem';
            showInvoice = false;
            showOrder = true;
            
        }else if(recordTypeName.equals('Alteração de pedido')) {
            
            finderBlockTitle = 'Localizar ordem';
            showInvoice = false;
            showOrder = true;
            
        }else if(recordTypeName.equals('Cancelamento de pedido')) {
            
            finderBlockTitle = 'Localizar ordem';
            showInvoice = false;
            showOrder = true;
            
        }else if(recordTypeName.equals('Reclamação contra o vendedor')) {
            
            finderBlockTitle = 'Localizar ordem';
            showInvoice = false;
            showOrder = true;
            
        }   
        
        return null;
    }

    private Boolean syncOnSapByOrderNumber(String orderNumber){

        try {
 
            //load form sap
            OrderService.getInvoiceListByOrderNumber(orderNumber);

        } catch (Exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Ocorreu um erro ao integrar a nota fiscal.1' + ex.getMessage());
            ApexPages.addMessage(errMsg);
            return false;
        }

        return true;
    }    
    
    private Boolean checkInvoiceOnSAP(String invoiceNumber) {

        try {
            listInvoice = OrderService.getInvoiceList(invoiceNumber, clientCode);
        } catch(Exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Ocorreu um erro ao integrar a nota fiscal.2' + ex.getMessage());
            ApexPages.addMessage(errMsg);
        }

        if(listInvoice != null && !listInvoice.isEmpty()) {
            return true;
        } else {
            return false;
        }

    }

}