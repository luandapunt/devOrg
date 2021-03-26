public with sharing class ItensCasoBO {
	
    public String CaseId {get; set;}
    public String Tipo {get; set;}
    public String Registro {get; set;}
    
    public String Comments {get; set;}
    public String QualityProblem {get; set;}
    
    private static final String REG_REPOSICAO = 'Reposição';
    private static final String REG_DEVOLUCAO = 'Devolução';
    private static final String REG_SUBSTITUICAO = 'Substituição';
    private static final String REG_PRODUTOTROCADO = 'Produto trocado';
    private static final String REG_RECLAMACAO = 'Reclamação';
    
    private static final String TIPO_ITEM = 'Item';
    private static final String TIPO_VOLUME = 'Volume';
    
    private static final String FAILURE_FALTANTE = 'Produto faltante';
    private static final String FAILURE_EXTRAVIO = 'Extravio de volume';
    private static final String FAILURE_NEGOCIACAO = 'Negociação comercial';
    
    public ItensCasoBO(String CaseId) {
    	this.CaseId = CaseId;
    	loadTipoRegistro(CaseId);
    }
    
    private void loadTipoRegistro(String caseId) {
    	CSECaseSelector caseSelector = new CSECaseSelector();
    	
    	Set<Id> caseIdSet = new Set<Id>();
    	caseIdSet.add(caseId);
    	List<Case> caseList = caseSelector.selectById(caseIdSet);
    	
    	if(caseList != null && !caseList.isEmpty()) {
    		Tipo = caseList[0].Type;
    		Registro = loadRegistro(caseList[0]);
    	} else {
    		Tipo = '';
    		Registro = '';
    	}
    }
    
    private String loadRegistro(Case caseObj) {
    	
    	CSERecordTypeSelector recordTypeSelector = new CSERecordTypeSelector();
    	
    	Set<Id> recordTypeIdSet = new Set<Id>();
		recordTypeIdSet.add(caseObj.RecordTypeId);
		List<RecordType> recordTypeList = recordTypeSelector.selectById(recordTypeIdSet);
		
		if(recordTypeList != null && !recordTypeList.isEmpty()) {
			return recordTypeList[0].Name;
		} else {
			return '';
		}
		
    }

    public Boolean isReclamacao() {
    	return Registro == REG_RECLAMACAO;
    }

	public Boolean isSubstituicao() {
		return Registro == REG_SUBSTITUICAO;
	}

    public Boolean canEditProduct() {
    	return Registro == REG_RECLAMACAO;
    }
    
    public Boolean getShowProdutoTrocado() {
    	return Registro == REG_PRODUTOTROCADO;
    }
    
    public Boolean getShowComments() {
    	return (registro == REG_SUBSTITUICAO) || (registro == REG_RECLAMACAO);
    }
    
    public Boolean getShowQualityProblem() {
    	return false;//registro == REG_SUBSTITUICAO;
    }
    
    public List<SelectOption> getFailureOptions() {
    	return getFailureOptions(Tipo, Registro);
    }
    
    private List<SelectOption> getFailureOptions(String tipo, String registro) {
    	List<SelectOption> options = new List<SelectOption>();
    	if (registro == REG_DEVOLUCAO) {
				options.add(new SelectOption(FAILURE_FALTANTE, FAILURE_FALTANTE));
				options.add(new SelectOption(FAILURE_NEGOCIACAO, FAILURE_NEGOCIACAO));
				options.add(new SelectOption(FAILURE_EXTRAVIO, FAILURE_EXTRAVIO));
    	} else if(registro == REG_REPOSICAO) {
			if(tipo == TIPO_ITEM) {
				options.add(new SelectOption(FAILURE_FALTANTE, FAILURE_FALTANTE));
				options.add(new SelectOption(FAILURE_NEGOCIACAO, FAILURE_NEGOCIACAO));
			} else if(tipo == TIPO_VOLUME) {
				options.add(new SelectOption(FAILURE_EXTRAVIO, FAILURE_EXTRAVIO));
				options.add(new SelectOption(FAILURE_NEGOCIACAO, FAILURE_NEGOCIACAO));
			} else {
				options = getAllFailureOptions();
			}
		} else if(registro == REG_SUBSTITUICAO) {
			options = getAllFailureOptions();
		}
		return options;
    }
    
    private List<SelectOption> getAllFailureOptions() {
    	List<SelectOption> options = new List<SelectOption>();
    	Schema.DescribeFieldResult fieldResult = CaseItem__c.FailureTypeTxt__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	
    	for(Schema.PicklistEntry f: ple) {
    		options.add(new SelectOption(f.getLabel(), f.getValue()));
    	}
    	return options;
    }
    
    public List<CaseItemVO> loadCaseItemVO(Id caseId) {
    	
		System.debug(LoggingLevel.FINEST, '*** loadCaseItemVO ' + Registro);
    	
    	CSECaseSelector caseSelector = new CSECaseSelector();
    	CSEInvoiceItemSelector invoiceItemSelector = new CSEInvoiceItemSelector();
    	CSECaseItemSelector caseItemSelector = new CSECaseItemSelector();
    	
    	List<CaseItemVO> itemVoList = new List<CaseItemVO>();
    	
    	Set<Id> caseIdSet = new Set<Id>();
    	caseIdSet.add(caseId);
    	List<Case> caseList = caseSelector.selectById(caseIdSet);
    	
    	if (Registro == REG_RECLAMACAO) {

    		List<CaseItem__c> caseItemList = new List<CaseItem__c>();
    		caseItemList = caseItemSelector.selectByCaseId(caseId);
    		
    		if (!caseItemList.isEmpty()) {

	    		CaseItemVO vo = new CaseItemVO();
	    		vo.Checked = true;
	    		vo.CaseItem = caseItemList[0];
	    		itemVoList.add(vo);
    			
    		} else {

	    		CaseItemVO vo = new CaseItemVO();
	    		vo.Checked = true;
	    		vo.CaseItem = new CaseItem__c(CaseMdt__c = caseId);
	    		itemVoList.add(vo);
	    		
    		}
    		
    	} else if(caseList != null && !caseList.isEmpty()) {

    		Id invoiceId = caseList[0].InvoiceLkp__c;
    		List<InvoiceItem__c> invoiceList = invoiceItemSelector.selectByInvoiceId(invoiceId);
    		List<CaseItem__c> caseItemList =  caseItemSelector.selectByCaseId(caseId);
    		    		   		    		
    		itemVoList = convertCaseItemToVO(invoiceList, caseItemList);
    	} 
    	
    	return itemVoList;
    }
    
    private List<CaseItemVO> convertCaseItemToVO(List<InvoiceItem__c> invoiceList, List<CaseItem__c> caseItemList) {
    	List<CaseItemVO> items = new List<CaseItemVO>();
    	CaseItem__c caseItem;
    	CaseItemVO vo;
    	
    	if(invoiceList != null && caseItemList != null) {
    		for(InvoiceItem__c invoice: invoiceList) {
    			
    			Id productId = invoice.ProductLkp__r.Id;
    			
    			vo = new CaseItemVO();
    			//vo.ProductId = invoice.ProductLkp__r.Id;
    			//vo.ProductName = invoice.ProductLkp__r.Name;
    			//vo.Denomination = invoice.DenominationTxt__c;
    			vo.MaxQuantity = (Integer)invoice.QuantityNmb__c;
    			vo.Id = invoice.Id;
    			
    			caseItem = findCaseItemByProduct(productId, caseItemList);
    			
    			if(caseItem != null) {
    				vo.Checked = true;
    				//vo.Quantity = (Integer)caseItem.QuantityNmb__c;
    				vo.FailureType = caseItem.FailureTypeTxt__c;
    				vo.Comments = caseItem.CommentsTxt__c;    				
    				/*if(getShowComments() == true && Comments == '') {
    					Comments = vo.Comments;
    				}*/
    				vo.QualityProblem = caseItem.QualityProblemTxt__c;
    				/*if(getShowQualityProblem() == true && QualityProblem == '') {
    					QualityProblem = vo.QualityProblem;
    				}*/
    				vo.CaseItem = caseItem;
    			} else {
    				
    				vo.CaseItem = new CaseItem__c(CaseMdt__c = caseId, ProductLkp__c = productId);
    				vo.Checked = false;
    				
    			}
    			items.add(vo);
    		}
    	}
    	
    	return items;
    }
    
    private CaseItem__c findCaseItemByProduct(Id productId, List<CaseItem__c> caseItemList) {
    	CaseItem__c found = null;
    	
    	for(CaseItem__c item: caseItemList) {
    		if(item.ProductLkp__c == productId) {
    			found = item;
    			break;
    		}
    	}
    	
    	return found;
    }
}