public class AddSurveyResult {
    
    public CustomerSurvey__c surveyCustomer {get;set;}
    public CustomerSurvey__c refSurveyCustomer;
    public TradeMktSurvey__c survey;
    public List <SurveyResult__c> addResult {get;set;}    
    public List <SurveyResult__c> resultList {get;set;}
    public List <SurveyProduct__c> surveyProducts;
    public List <Product2> productNames;
    public Set <SurveyResult__c> resultSet {get;set;}
    public integer rowNumber;
    public string resultMsgStr;
    
    public AddSurveyResult(ApexPages.StandardController controller) {
        
        Map<String, Id> mapSurveyId = new Map<String, Id>();
        Map<String, Decimal> mapSurveyTotal = new Map<String, Decimal>();
        Map<String, String> mapSurveyRemark = new Map<String, String>();        
        
        refSurveyCustomer = (CustomerSurvey__c) controller.getRecord();
        this.surveyCustomer = [SELECT Id, /*AccountLkp__c, */TradeMktSurveyLkp__c, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.SellerLkp__r.UserLkp__c FROM CustomerSurvey__c WHERE Id =: refSurveyCustomer.Id];
               
        surveyProducts = [SELECT Id, ProductDescriptionFml__c, MaterialGroupFml__c, SubsystemFml__c, TradeMktSurveyLkp__c, MinPriceNmb__c, MaxPriceNmb__c 
                          FROM SurveyProduct__c 
                          WHERE TradeMktSurveyLkp__c =: surveyCustomer.TradeMktSurveyLkp__c                         
                         ];        
        
        resultList = [SELECT Id, ProductDescriptionTxt__c, BrandTxt__c, CustomerSurveyLkp__c, PriceNmb__c, RemarkTxt__c, ChannelTxt__c, AttachmentRequiredBln__c
                      FROM SurveyResult__c 
                      WHERE CustomerSurveyLkp__c =: surveyCustomer.id
                      ];                
        
        for(SurveyResult__c res : resultList){
            mapSurveyId.put(res.ProductDescriptionTxt__c + res.BrandTxt__c, res.Id);
            mapSurveyTotal.put(res.ProductDescriptionTxt__c + res.BrandTxt__c, res.PriceNmb__c);
            mapSurveyRemark.put(res.ProductDescriptionTxt__c + res.BrandTxt__c, res.RemarkTxt__c);			         
        }
        
        map<string,string> mapSubsystems = new map<string,string>();        
        
        Schema.DescribeFieldResult fieldResult = SurveyProduct__c.OtherSubsystemTxt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
        
        for(Schema.PicklistEntry subsystem: ple){
            mapSubsystems.put(subsystem.getValue(),subsystem.getLabel());
        }
        
        
        resultList = new List<SurveyResult__c>();   
        
        survey = [SELECT BrandsTxt__c, OtherBrandsTxt__c 
                  FROM TradeMktSurvey__c 
              	  WHERE Id =: surveyCustomer.TradeMktSurveyLkp__c                 
        		];
        
        list<String> availableBrands = new List<String>();
        List<String> otherBrands = new List<String>();
		
        if(survey.BrandsTxt__c != null){        
        	availableBrands = survey.BrandsTxt__c.split(';');                       
        }
		system.debug(availableBrands);
        
        if(survey.OtherBrandsTxt__c != null){
            otherBrands = survey.OtherBrandsTxt__c.split(';');            
            
            for(integer j=0; j < otherBrands.size(); j++){
                if(otherBrands[j] == '' || otherBrands[j] == null)
                    otherBrands.remove(j);
            }
			           
        }
        
        list<String> brands = new list<String>();        
                
        brands.addAll(availableBrands);
        
        brands.addAll(otherBrands);
                 
        brands.sort();
        
        if(surveyProducts.size()>0){
            for(SurveyProduct__c sP: surveyProducts){
                if(brands.size()>0){
                    for(string brnd: brands){                        
                        SurveyResult__c result = new SurveyResult__c();
                        if(mapSurveyId.containsKey(sP.ProductDescriptionFml__c + brnd)){
                            result.Id = mapSurveyId.get(sP.ProductDescriptionFml__c + brnd);
                            result.PriceNmb__c = mapSurveyTotal.get(sP.ProductDescriptionFml__c + brnd);
                            result.RemarkTxt__c = mapSurveyRemark.get(sP.ProductDescriptionFml__c + brnd);							                           
                        }
						result.SurveyProductLkp__r = sP;
						result.SurveyProductLkp__c = sP.Id;
                        if(result.PriceNmb__c > result.SurveyProductLkp__r.MaxPriceNmb__c || result.PriceNmb__c < result.SurveyProductLkp__r.MinPriceNmb__c ){
                        	result.AttachmentRequiredBln__c = TRUE;
                        } else {
                            result.AttachmentRequiredBln__c = FALSE;
                        }
                        result.CustomerSurveyLkp__c = surveyCustomer.Id;
                        result.MaterialGroupTxt__c = sP.MaterialGroupFml__c;
                        result.ProductDescriptionTxt__c = sP.ProductDescriptionFml__c;
                        result.SubsystemTxt__c = mapSubsystems.get(sP.SubsystemFml__c);
                        result.BrandTxt__c = brnd;
						result.OwnerId = surveyCustomer.AccountAreaSalesLkp__r.SellerLkp__r.UserLkp__c;                        
                        resultList.add(result);                     
                    }
                }
            }
        }
                
    }
/*
    public Attachment attachment{
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    public PageReference upload() {
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = refSurveyCustomer.Id; // the record the file is attached to
        attachment.IsPrivate = true;
        
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Ocorreu um erro durante o carregamento do arquivo.'));
            return null;
        } finally {
            attachment = new Attachment(); 
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'O arquivo foi carregado com sucesso!'));
        return null;
    }
*/        
    
    public void doSave() {                
        List<SurveyResult__c> listOutOfRange = new List<SurveyResult__c>();
        
        for(SurveyResult__c res: resultList){
            if(res.PriceNmb__c > res.SurveyProductLkp__r.MaxPriceNmb__c || res.PriceNmb__c < res.SurveyProductLkp__r.MinPriceNmb__c ){
                listOutOfRange.add(res);
                res.AttachmentRequiredBln__c = TRUE;
            } else {
                res.AttachmentRequiredBln__c = FALSE;
            }            
        }
        //List<ContentDocumentLink> listSurveyContLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: refSurveyCustomer.Id];
        //List<Attachment> listSurveyAtt = [SELECT Id FROM Attachment WHERE ParentId =: refSurveyCustomer.Id];
		//System.debug(listSurveyAtt);        
        
        try{                      
            //if(listSurveyAtt.isEmpty() && listSurveyContLink.isEmpty()){
            //    resultMsgStr = ' Para que os resultados da pesquisa sejam registrados, é necessário anexar ao menos uma foto.';
            //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,resultMsgStr));                
            //} else {
                
                upsert resultList;           
                
                if(listOutOfRange.size()>0){
                    resultMsgStr = ' Existem produtos com preço fora da faixa esperada. Por favor, revise o preço inserido ou inclua uma foto como anexo para comprovação.';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,resultMsgStr));                
                } else {            
                    resultMsgStr = ' Os resultados da pesquisa preenchidos foram registrados!';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,resultMsgStr));
                }
            //}
        }
        catch (Exception ex){
            ApexPages.addMessages(ex);            
        }
    }    
}