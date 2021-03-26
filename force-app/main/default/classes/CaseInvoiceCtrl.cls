public without sharing class CaseInvoiceCtrl {
	
	private ApexPages.StandardController controller;
	
	private static final String className = 'CaseInvoiceCtrl';
	
    public String invoiceNumber {get;set;}
    public List<CaseInvoiceItemsDAO> listCaseInvoiceDAO {get;set;}
    public List<CaseInvoice__c> listCaseInvoice;
    private String caseNumber {get;set;}
    private List<CaseInvoice__c> toBeDeleted {get;set;}
    
    private String record {get;set;}
    
    public Boolean showOrder {get;set;}
    public Boolean showQuota {get;set;}
    public Boolean showDaysToExtend {get;set;}
    public Boolean showCredit {get;set;}
    
    private List<Invoice__c> listInvoiceSAP;
    private String clientCode = '';
    private String accountId;
    
    public CaseInvoiceCtrl(ApexPages.StandardController controller) {
    	this.controller = controller;
       	
    	listCaseInvoiceDAO = new List<CaseInvoiceItemsDAO>();
    	
    	toBeDeleted = new List<CaseInvoice__c>();
    
    	if(Apexpages.currentPage().getParameters().get('retURL') == null) {
    		//exibir
    		String auxId = Apexpages.currentPage().getParameters().get('id');
    		System.debug(auxId);
    		CaseInvoice__c auxCaseInvoice = [Select CaseMdt__c from CaseInvoice__c where Id = :auxId];
    		loadCaseInvoices(auxCaseInvoice.CaseMdt__c);
    		caseNumber = auxCaseInvoice.CaseMdt__c;
    		
    	} else if(Apexpages.currentPage().getParameters().get('retURL') != null && Apexpages.currentPage().getParameters().get('id') != null) {
    		//edit
    		loadCaseInvoices(Apexpages.currentPage().getParameters().get('retURL').replace('/',''));
    		caseNumber = Apexpages.currentPage().getParameters().get('retURL').replace('/','');
    		//caseNumber 
    		caseNumber = caseNumber.split('\\?')[0];
    		//System.debug(caseNumber);
    	} else {
    		loadCaseInvoices(Apexpages.currentPage().getParameters().get('retURL').replace('/',''));
    		caseNumber = Apexpages.currentPage().getParameters().get('retURL').replace('/','');
    		caseNumber = caseNumber.split('\\?')[0];
    		//System.debug(caseNumber);
    	}
    	
    	Case caso = [Select RecordType.Name, Account.CodeCustomerTxt__c, AccountId from Case where Id = :caseNumber];
    	
    	clientCode = caso.Account.CodeCustomerTxt__c;
    	record = caso.RecordType.Name;
    	accountId = caso.AccountId;
    	
    	if(record.equals('Caminhão retido')) {
    		showOrder = true;
    		showQuota = false;
    		showDaysToExtend = false;
    		showCredit = false;
    	} else if(record.equals('Dúvidas tributárias')) {
    		showOrder = true;
    		showQuota = false;
    		showDaysToExtend = false;
    		showCredit = false;
    	} else if(record.equals('Solicitação de boleto')) {
    		showOrder = true;
    		showQuota = false;
    		showDaysToExtend = false;
    		showCredit = false;
    	} else if(record.equals('Prorrogação por fluxo de caixa')) {
    		showOrder = false;
    		showQuota = true;
    		showDaysToExtend = true;
    		showCredit = false;
    	} else if(record.equals('Abatimento de crédito')) {
    		showOrder = false;
    		showQuota = true;
    		showDaysToExtend = false;
    		showCredit = true;
    	} else if(record.equals('Negociação de débito')) {
    		showOrder = true;
    		showQuota = true;
    		showDaysToExtend = false;
    		showCredit = false;
    	} 
    }
    
    public PageReference doSave() {
    	listCaseInvoice = new List<CaseInvoice__c>();
    	//ULLog.methodInfo(className, 'doSave');
    	if(listCaseInvoiceDAO != null && listCaseInvoiceDAO.size() > 0) {
    		for(CaseInvoiceItemsDAO auxDao : listCaseInvoiceDAO) {
    			if(auxDao.id.equals('')) {
    				    				
    				listCaseInvoice.add(buildCaseInvoice(auxDao, true));
    				
    			} else {
    				    			
    				listCaseInvoice.add(buildCaseInvoice(auxDao, false));
    				
    			}
    		}
    		    		
    		upsert listCaseInvoice;
    	}
    	
    	if(toBeDeleted != null && !toBeDeleted.isEmpty()) {
    			delete toBeDeleted;
    	}
    	
    	PageReference page = new PageReference('/' + caseNumber); 
        page.setRedirect(true); 
        return page;
    }
    
    public PageReference doCancel() {
    	
    	PageReference page = new PageReference('/' + caseNumber); 
        page.setRedirect(true); 
        return page;
    }
    
    public PageReference insertInvoice() {
    	Invoice__c auxInvoice = findInvoice();
    	
    	if(auxInvoice != null) {
    		System.debug('******* Invoice: ' + auxInvoice);
    		    		System.debug('******* InvoiceOrder: ' + auxInvoice.RemittanceLkp__r.OrderLkp__r.Name);
    		Boolean found = false;
    		
    		for(CaseInvoiceItemsDAO aux : listCaseInvoiceDAO) {
    			if(auxInvoice.Name.equals(aux.invoiceNumber)) {
    				found = true;
    				break;
    			}
    		}
    		
    		if(!found) {
    			CaseInvoiceItemsDAO item;
    		
    			if(auxInvoice.RemittanceLkp__r.OrderLkp__r.Name != null) {
    				item = new CaseInvoiceItemsDAO(auxInvoice.Name, auxInvoice.Id, auxInvoice.RemittanceLkp__r.OrderLkp__r.Name, auxInvoice.OrderLkp__c, caseNumber);
    			} else {
    				item = new CaseInvoiceItemsDAO(auxInvoice.Name, auxInvoice.Id, caseNumber);
    			}
    		
    			listCaseInvoiceDAO.add(item);
    			
    		} else {
    			System.debug('Nota já inserida');
    			ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Nota já inserida.');
    			ApexPages.addMessage(errMsg);
    		}
    		    		
    	} else {
    		ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Nota não cadastrada');
			ApexPages.addMessage(errMsg);
    	}
    	
    	invoiceNumber = '';
    	
    	return null;
    }
    
    public PageReference removeInvoice() {
    	
    	List<CaseInvoiceItemsDAO> listAux = new List<CaseInvoiceItemsDAO>();
    	for(CaseInvoiceItemsDAO auxDao : listCaseInvoiceDAO) {
    		if(!auxDao.selected) {
    			listAux.add(auxDao);
    		} else {
    			if(!auxDao.Id.equals('')) {
    				CaseInvoice__c aux = new CaseInvoice__c();
    				aux.Id = auxDao.Id;
    				toBeDeleted.add(aux);
    			}
    		}
    	}
    	
    	listCaseInvoiceDAO = listAux;
    	
    	return null;
    }
    
    public PageReference loadCaseInvoices(String caso) {
    	
    	CSECaseInvoiceSelector caseInvoiceSelector = new CSECaseInvoiceSelector();
    	listCaseInvoice = new List<CaseInvoice__c>();
    	listCaseInvoice = caseInvoiceSelector.selectByCase(caso);
    		
    	listCaseInvoiceDAO = new List<CaseInvoiceItemsDAO>();	
    		
    	if(listCaseInvoice != null && !listCaseInvoice.isEmpty()) {	
    		for(CaseInvoice__c cseInv : listCaseInvoice) {
    			CaseInvoiceItemsDAO aux = new CaseInvoiceItemsDAO(cseInv.Id, cseInv.InvoiceLkp__r.Name, cseInv.InvoiceLkp__c, cseInv.OrderLkp__r.Name, cseInv.OrderLkp__c, cseInv.QuotaNmb__c, cseInv.ExtendDaysNmb__c, cseInv.CreditNmb__c, cseInv.CaseMdt__c);
    			listCaseInvoiceDAO.add(aux);
    		}	
    	}
    		
    	return null;
    } 
    
    private Invoice__c findInvoice() {
    	CSEInvoiceSelector invoiceSelector = new CSEInvoiceSelector();
    	List<Invoice__c> listInvoice = new List<Invoice__c>();
    	listInvoice = invoiceSelector.selectByNumberAndCustomer(invoiceNumber, accountId);
    	
    	/*if(listInvoice != null && !listInvoice.isEmpty()) {
    		return listInvoice[0];
    	}else*/ if(checkInvoiceOnSAP(invoiceNumber)) {
    		return listInvoiceSAP[0];
    	} 
    	else {
    		System.debug('Nota não cadastrada');
    		    		    		
    		return null;
    	}
    }
    
    private CaseInvoice__c buildCaseInvoice(CaseInvoiceItemsDAO auxDao, Boolean create) {
    	CaseInvoice__c aux = new CaseInvoice__c();
    	    	    	
    	if(record.equals('Caminhão retido')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			if(!auxDao.orderLkp.equals('')) {
    				aux.OrderLkp__c = auxDao.orderLkp;	
    			}
    			
    		} else {
    			aux.Id = auxDao.id;
    		}
    	} else if(record.equals('Dúvidas tributárias')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			if(!auxDao.orderLkp.equals('')) {
    				aux.OrderLkp__c = auxDao.orderLkp;	
    			}
    		} else {
    			aux.Id = auxDao.id;
    		}
    	} else if(record.equals('Solicitação de boleto')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			if(!auxDao.orderLkp.equals('')) {
    				aux.OrderLkp__c = auxDao.orderLkp;	
    			}
    		} else {
    			aux.Id = auxDao.id;
    		}
    	} else if(record.equals('Prorrogação por fluxo de caixa')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			aux.QuotaNmb__c = auxDao.quota;
    			aux.ExtendDaysNmb__c = auxDao.daysToExtend;
    		} else {
    			aux.Id = auxDao.id;
    			aux.QuotaNmb__c = auxDao.quota;
    			aux.ExtendDaysNmb__c = auxDao.daysToExtend;
    		}
    	} else if(record.equals('Abatimento de crédito')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			aux.QuotaNmb__c = auxDao.quota;
    			aux.CreditNmb__c = auxDao.credit;
    		} else {
    			aux.Id = auxDao.id;
    			aux.QuotaNmb__c = auxDao.quota;
    			aux.CreditNmb__c = auxDao.credit;
    		}
    	} else if(record.equals('Negociação de débito')) {
    		if(create) {
    			aux.InvoiceLkp__c = auxDao.invoiceLpk;
    			aux.CaseMdt__c = auxDao.caseId;
    			aux.QuotaNmb__c = auxDao.quota;
    		} else {
    			aux.Id = auxDao.id;
    			aux.QuotaNmb__c = auxDao.quota;
    		}
    	} 
    	
    	return aux;
    }
    
    private Boolean checkInvoiceOnSAP(String invoiceNumber) {
    	listInvoiceSAP = OrderService.getInvoiceList(invoiceNumber, clientCode);
    	if(listInvoiceSAP != null && !listInvoiceSAP.isEmpty()) {
    		return true;
    	} else {
    		return false;
    	}
    }
}