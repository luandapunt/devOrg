public with sharing class CaseMotiveCtrl {
    
    public List<SelectOption> recordType {get;set;}
    public List<SelectOption> caseMotive {get;set;}
    public List<SelectOption> caseCategory {get;set;}
    public List<SelectOption> contact {get;set;}
    public List<SelectOption> nature {get;set;}
    
    public String selectedRecordType {get;set;}
    public String selectedCaseMotive {get;set;}
    public String selectedCategory {get;set;}
    public String selectedContact {get;set;}
    public String selectedNature {get;set;}
    
    public Boolean showHeader {get;set;}
    
    private CSECaseMotiveSelector caseMotiveSelector = new CSECaseMotiveSelector(); 
    private List<CaseMotive__c> listCaseMotiveObject = new List<CaseMotive__c>();
    
    private ApexPages.StandardController controller;
        
    private String accountId = '';    
    
    private ApexRedirectMap__c customConfig;
    
    private Map<String, Id> recordMap = new Map<String, Id>();
    // WA tela casao   
    public PageReference telaTipoRegistro(){
       // PageReference pgRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&nooverride=1');
        PageReference pgRef = new PageReference('/500/o');
        pgRef.setRedirect(true);
        return pgRef;
    }    
    public CaseMotiveCtrl(ApexPages.StandardController controller) {
    	this.controller = controller;
    	    	    	    	 	   	 	
    	initialize();
    	
    }
      
    
    private PageReference initialize() {
    	
    	//if(Apexpages.currentPage().getParameters().get('inConsole').equals('yes')) {
    	//	showHeader=false;
     	//}else {
    	//	showHeader=true;
    	//}
    	showHeader=false;
        //RSilva 13/11/2017 comentada verificação showheader e chapado valor como false para usar versão console; URL de redirecionamento não está enviando esse paramentro, isInConsole() e URLFOR()
    	contact = new List<SelectOption>();
    	nature = new List<SelectOption>();
    	caseCategory = new List<SelectOption>();
    	caseMotive = new List<SelectOption>();
    	recordType = new List<SelectOption>();
    	
    	Id userProfileId = UserInfo.getProfileId();
   		Profile profile = [Select Name from Profile where Id = :userProfileId];
    	//System.debug('aqui chega0');
    	listCaseMotiveObject = caseMotiveSelector.selectAll();
    	contact.add(new SelectOption('--Nenhum--','--Nenhum--'));
    	for(CaseMotive__c aux : listCaseMotiveObject) {
    		SelectOption sel = new SelectOption(aux.ContactTxt__c,aux.ContactTxt__c);
    		
    		if(!ListUtils.contains(contact, sel) && ListUtils.contains(parseProfiles(aux.Profile__c), profile.Name)) {
    			contact.add(sel);
    		}
    	}

      contact.sort();

    	//System.debug('aqui chega');
    	nature.add(new SelectOption('--Nenhum--','--Nenhum--'));
    	caseCategory.add(new SelectOption('--Nenhum--','--Nenhum--'));
    	caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
    	recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
    	
    	if(Apexpages.currentPage().getParameters().get('accountId') != null) {    	
    		accountId = Apexpages.currentPage().getParameters().get('accountId');
    	}   
    	
    	//System.debug('aqui chega2');
    	
    	return null;
    }  
      
    public PageReference setNatureList() {
    	nature = new List<SelectOption>();
   		
   		if(selectedContact.equals('--Nenhum--')) {
   			nature.add(new SelectOption('--Nenhum--','--Nenhum--'));
   			selectedNature = '--Nenhum--';
   			
   			caseMotive = new List<SelectOption>();
			caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedCaseMotive = '--Nenhum--';
			
			caseCategory = new List<SelectOption>();
			caseCategory.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedCategory = '--Nenhum--';
			
			recordType = new List<SelectOption>();
			recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedRecordType = '--Nenhum--';
   			return null;
   		}
   		
   		Id userProfileId = UserInfo.getProfileId();
   		Profile profile = [Select Name from Profile where Id = :userProfileId];
   		   		
   		caseMotive = new List<SelectOption>();
		caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedCaseMotive = '--Nenhum--';
		
		caseCategory = new List<SelectOption>();
		caseCategory.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedCategory = '--Nenhum--';
		
		recordType = new List<SelectOption>();
		recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedRecordType = '--Nenhum--';
   		
   		nature = new List<SelectOption>();
   		nature.add(new SelectOption('--Nenhum--','--Nenhum--'));
   		selectedNature = '--Nenhum--';
   		
   		for(CaseMotive__c aux : listCaseMotiveObject) {
   			SelectOption sel = new SelectOption(aux.NatureTxt__c,aux.NatureTxt__c);
   			
   			if(!ListUtils.contains(nature, sel) && aux.ContactTxt__c.equals(selectedContact) && ListUtils.contains(parseProfiles(aux.Profile__c), profile.Name)) {
   				nature.add(sel);
   			}
   		}

      nature.sort();
    	return null;
    }
    
    public PageReference setCategoryList() {
    	caseCategory = new List<SelectOption>();
   		
   		if(selectedNature.equals('--Nenhum--')) {
   			caseCategory.add(new SelectOption('--Nenhum--','--Nenhum--'));
   			selectedCategory = '--Nenhum--';
   			
   			caseMotive = new List<SelectOption>();
			caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedCaseMotive = '--Nenhum--';
			
			recordType = new List<SelectOption>();
			recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedRecordType = '--Nenhum--';
        caseCategory.sort();
   			return null;
   		}
   		
   		Id userProfileId = UserInfo.getProfileId();
   		Profile profile = [Select Name from Profile where Id = :userProfileId];
   		
   		caseMotive = new List<SelectOption>();
		caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedCaseMotive = '--Nenhum--';
		
		recordType = new List<SelectOption>();
		recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedRecordType = '--Nenhum--';
   		
   		caseCategory = new List<SelectOption>();
   		caseCategory.add(new SelectOption('--Nenhum--','--Nenhum--'));
   		selectedCategory = '--Nenhum--';
   		
   		for(CaseMotive__c aux : listCaseMotiveObject) {
   			SelectOption sel = new SelectOption(aux.Category__c,aux.Category__c);
   			
   			if(!ListUtils.contains(caseCategory, sel) && aux.NatureTxt__c.equals(selectedNature) && ListUtils.contains(parseProfiles(aux.Profile__c), profile.Name)) {
   				caseCategory.add(sel);
   			}
   		}
      caseCategory.sort();
    	return null;
    }  
    
    public PageReference setMotiveList() {
    	caseMotive = new List<SelectOption>();
   		
   		if(selectedCategory.equals('--Nenhum--')) {
   			caseMotive = new List<SelectOption>();
   			caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
   			selectedCaseMotive = '--Nenhum--';
   			
   			recordType = new List<SelectOption>();
			recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
			selectedRecordType = '--Nenhum--';
			
   			return null;
   		}
   		
   		Id userProfileId = UserInfo.getProfileId();
   		Profile profile = [Select Name from Profile where Id = :userProfileId];
   		
   		recordType = new List<SelectOption>();
		recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
		selectedRecordType = '--Nenhum--';
   		
   		caseMotive.add(new SelectOption('--Nenhum--','--Nenhum--'));
   		selectedCaseMotive = '--Nenhum--';
   		
   		for(CaseMotive__c aux : listCaseMotiveObject) {
   			SelectOption sel = new SelectOption(aux.Name,aux.Name);
   			
   			if(!ListUtils.contains(caseMotive, sel) && aux.Category__c.equals(selectedCategory) && ListUtils.contains(parseProfiles(aux.Profile__c), profile.Name)) {
   				caseMotive.add(sel);
   			}
   		}
      caseMotive.sort();
    	return null;
    }    
      
   	public PageReference setRecordTypeList() {
   		recordType = new List<SelectOption>();
   		
   		if(selectedCaseMotive.equals('--Nenhum--')) {
   			recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
   			return null;
   		}
   		
   		Id userProfileId = UserInfo.getProfileId();
   		Profile profile = [Select Name from Profile where Id = :userProfileId];
   		
   		recordType.add(new SelectOption('--Nenhum--','--Nenhum--'));
   		
   		for(CaseMotive__c aux : listCaseMotiveObject) {
   			if(aux.CaseTypeTxt__c != null) {
   				//System.debug('>>>>>>>>>>>>>' + aux.CaseTypeTxt__c);
   				SelectOption sel = new SelectOption(aux.CaseTypeTxt__c,aux.CaseTypeTxt__c);
   			
   				if(!ListUtils.contains(recordType, sel) && aux.Name.equals(selectedCaseMotive) && ListUtils.contains(parseProfiles(aux.Profile__c), profile.Name)) {
   					recordType.add(sel);
   				}
   			}
   		}
      recordType.sort();
   		return null; 
   	}  
   	
   	private List<String> parseProfiles(String profile) {
   		List<String> profiles = new List<String>();
   		
   		if(profile != null && !profile.equals('')) {
   			Integer i = 0;
   			for(i = 0; i < profile.split(';').size();i++) {
   				profiles.add(profile.split(';')[i]);
   			}
   		}
   		return profiles;
   	}
   	
   	public PageReference doNext() {
   		if(!selectedRecordType.equals('--Nenhum--') && !selectedCaseMotive.equals('--Nenhum--') && 
   		   !selectedRecordType.equals('') && !selectedCaseMotive.equals('') &&
   		   !selectedNature.equals('--Nenhum--') && !selectedNature.equals('') &&
   		   !selectedContact.equals('--Nenhum--') && !selectedContact.equals('') &&
   		   !selectedCategory.equals('--Nenhum--') && !selectedCategory.equals('')) {
   		   	
   			List<RecordType> recordType = [SELECT Id, Name FROM RecordType  where SobjectType = 'Case'];
    		for(RecordType rec : recordType) {
    			recordMap.put(rec.Name.toLowercase(), rec.Id);
    		}
   			//PageReference page = null;
            PageReference page = new PageReference('/500/e');     
   			customConfig = ApexRedirectMap__c.getValues('CreateCase'); 
   		   		
   			if(selectedRecordType.equals('Indicação de vendedor') || selectedRecordType.equals('Indicação BNDES') || selectedRecordType.equals('Informações gerais')
   			   || selectedRecordType.equals('Portal neogrid') || selectedRecordType.equals('Negociação de débito') || selectedRecordType.equals('Abatimento de crédito')
   			   || selectedRecordType.equals('Prorrogação por fluxo de caixa') || selectedRecordType.equals('Solicitação de boleto') || selectedRecordType.equals('Dúvidas tributárias')
   			   || selectedRecordType.equals('Caminhão retido') || selectedRecordType.equals('Dúvida técnica') || selectedRecordType.equals('Reclamação') || selectedRecordType.equals('Outros - financeiro')
   			   || selectedRecordType.equals('Reclamação contra o vendedor')) {
   				if(accountId.equals('')) {
   					page = new PageReference(customConfig.UrlSufix__c + '&RecordType=' + recordMap.get(selectedRecordType.toLowercase()) + (showHeader ? '&inConsole=no' : '&inConsole=yes') +
   					 '&' + ApexRedirectMap__c.getValues('ReasonCase').UrlSufix__c + '=' + selectedCaseMotive.replace(' ', '%20') + '&' + ApexRedirectMap__c.getValues('ContactCase').UrlSufix__c + '=' + selectedContact +
   					  '&' + ApexRedirectMap__c.getValues('NatureCase').UrlSufix__c + '=' + selectedNature + '&' + ApexRedirectMap__c.getValues('CategoryCase').UrlSufix__c + '=' + selectedCategory + '&ent=Case');
                  //  system.debug('entrou1');
   				}else {
                   
                //    page.getParameters().put('RecordType', recordMap.get(selectedRecordType.toLowercase()));
                //    page.getParameters().put('inConsole', !showHeader ? 'yes' : 'no');
                //    page.getParameters().put('def_account_id', accountId );
   					page = new PageReference(customConfig.UrlSufix__c + '&def_account_id=' + accountId + '&RecordType=' + recordMap.get(selectedRecordType.toLowercase()) + 
   					(showHeader ? '&inConsole=no' : '&inConsole=yes') + '&' + ApexRedirectMap__c.getValues('ReasonCase').UrlSufix__c + '=' + selectedCaseMotive.replace(' ', '%20') + '&' + ApexRedirectMap__c.getValues('ContactCase').UrlSufix__c + '=' + selectedContact +
   					  '&' + ApexRedirectMap__c.getValues('NatureCase').UrlSufix__c + '=' + selectedNature + '&' + ApexRedirectMap__c.getValues('CategoryCase').UrlSufix__c + '=' + selectedCategory + '&ent=Case'); 
   				//RSILVA comentado para testar getParameters.put, direciona para o tipo de registro certo, mas não preenche campos
                    system.debug('entrou2'+ recordMap.get(selectedRecordType.toLowercase()));
                }
   			}else {
   				if(accountId.equals('')) {
   					page = new PageReference('/apex/CaseCreateInvoiceAndOrder' + '?RecordType=' + recordMap.get(selectedRecordType.toLowercase())  + (showHeader ? '&inConsole=no' : '&inConsole=yes') +
   					 '&reason=' + selectedCaseMotive  + '&nature=' + selectedNature + '&contact=' + selectedContact + '&category=' + selectedCategory); 
   				system.debug('entrou3');
                }else {
   					page = new PageReference('/apex/CaseCreateInvoiceAndOrder' + '?def_account_id=' + accountId + '&RecordType=' + recordMap.get(selectedRecordType.toLowercase()) +
                                             (showHeader ? '&inConsole=no' : '&inConsole=yes') +'&reason=' + selectedCaseMotive + '&nature=' + selectedNature + '&contact=' + selectedContact + '&category=' + selectedCategory); 
   				system.debug('entrou4');
                }
   			}
   			page.setRedirect(true);	
               system.debug(page);
   			return page; 
               
   		} else {
   			ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Selecione uma opção válida.');
    		ApexPages.addMessage(errMsg);
    		return null;
   		}
   	}
   	
   	public PageReference doCancel() {
    	PageReference page;
    	customConfig = ApexRedirectMap__c.getValues('CaseList'); 
    	
    	if(accountId.equals('')) {
    		page = new PageReference('/' + customConfig.UrlSufix__c); 
        	page.setRedirect(true); 
    	}else {
    		page = new PageReference('/' + accountId); 
        	page.setRedirect(true);
    	}
      	
        return page;
    }
}