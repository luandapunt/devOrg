public with sharing class ItensCasoController {
    
    public List<CaseItemVO> itemList {get; set;}
    public String CaseId {get; set;}
    public List<SelectOption> failureTypeList {get; set;}
    private ApexPages.StandardController controller;
    public ItensCasoBO itensCasoBO {get; set;}
    
    public Boolean ShowProdutoTrocado {get; set;}
    public Boolean ShowComments {get; set;}
    public Boolean ShowQualityProblem {get; set;}
    public Boolean canEditProduct {get;set;}
    public Boolean isReclamacao {get;set;}
    public Boolean isSubstituicao {get;set;}
    
    private String urlId {get;set;}
    private Case currentCase {get;set;}
    
    public ItensCasoController(ApexPages.StandardController controller) {
       this.controller = controller;
        getParams();
        initialize();
    }
    
    private void getParams() {
        currentCase = (Case)this.controller.getRecord();
        CaseId = currentCase.Id;
    }
    
    public void initialize() {      
        
        itensCasoBO = new itensCasoBO(CaseId);
        failureTypeList = itensCasoBO.getFailureOptions();
        ShowProdutoTrocado = itensCasoBO.getShowProdutoTrocado();
        ShowComments = itensCasoBO.getShowComments();
        ShowQualityProblem = itensCasoBO.getShowQualityProblem();
        canEditProduct = itensCasoBO.canEditProduct();
        isReclamacao = itensCasoBO.isReclamacao();
        isSubstituicao = itensCasoBO.isSubstituicao();
        itemList = itensCasoBO.loadCaseItemVO(CaseId);
    }

    public PageReference save() {
    	
        List<CaseItem__c> caseItemToUpsert = new List<CaseItem__c>();
        List<CaseItem__c> caseItemToDeleted = new List<CaseItem__c>();
        
        CaseItem__c caseItem;
        
        for(CaseItemVO item: itemList) {
            caseItem = updateCaseItem(item);
            if(item.Checked == true) {
            	caseItem.Id = null;
            	caseItemToUpsert.add(caseItem);
            } else {
                if(item.CaseItem.Id != null) {
                    /* Unchecked and existing CaseItem: Delete */
                    caseItemToDeleted.add(caseItem);
                }
            }
        }
        
		System.debug(LoggingLevel.FINEST, '*** save() caseItemToUpsert ' + caseItemToUpsert);
		System.debug(LoggingLevel.FINEST, '*** save() caseItemToDeleted ' + caseItemToDeleted);
        upsert caseItemToUpsert CustomIdTxt__c;
    	delete caseItemToDeleted;	
        
        refresh();
        
        // TODO redirect?
        //initialize();
        
        return doBack();
    }
    
    private CaseItem__c updateCaseItem (CaseItemVO itemVO) {
        Boolean isNew = false;
        CaseItem__c caseItem = itemVO.CaseItem;
        if(caseItem == null) {
            isNew = true;
            caseItem = new CaseItem__c();
        }
        
        //caseItem.QuantityNmb__c = itemVO.Quantity;
        caseItem.FailureTypeTxt__c = itemVO.FailureType;
        
        //todo refactor custom id to trigger's case
        caseItem.CustomIdTxt__c = CaseId + itemVO.CaseItem.ProductLkp__c;
        caseItem.QualityProblemTxt__c = itemVO.QualityProblem;
        caseItem.CommentsTxt__c = itemVO.Comments;

        if(isNew) { 
            caseItem.CaseMdt__c = CaseId;
            caseItem.ProductLkp__c = itemVO.CaseItem.ProductLkp__c;
        }
        
        return caseItem;
    }
    
    public void refresh() {
		System.debug(LoggingLevel.FINEST, '*** refresh()' + itemList);
    }
    
    public PageReference doBack() {
    	PageReference page;
        page = new PageReference('/' + CaseId); 
        page.setRedirect(true); 
        
 		return page;
    }
    
}