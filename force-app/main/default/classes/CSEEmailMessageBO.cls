public without sharing class CSEEmailMessageBO {
    public void setStatus(List<EmailMessage> records) {
	    CSECaseSelector caseSelector = new CSECaseSelector();
		system.debug('entrou set status email message: '+ records);
	    Map<String, Id> recordMap = new Map<String, Id>();
    	List<RecordType> recordType = [SELECT Id, Name FROM RecordType  where SobjectType = 'Case'];
    	for(RecordType rec : recordType) {
    		recordMap.put(rec.Name, rec.Id);
    	}
    	for(EmailMessage emessage : records) {

    		Set<Id> caseIdSet = new Set<Id>();
    		caseIdSet.add(emessage.ParentId);
    		List<Case> caso = caseSelector.selectById(caseIdSet);
            system.debug('achou caso: '+caso);
			
			if (!emessage.Status.equals('3')){	
								
	    		if(caso[0].RecordTypeId == recordMap.get('Reposição') && caso[0].Status.equals('Aguardando retorno transportadora')){
	    			
	    			caso[0].Status = 'Em análise';
	    			 
	    		}
	    		if(caso[0].RecordTypeId == recordMap.get('Reposição') && caso[0].Status.equals('Aguardando nota fiscal de devolução')){
	    			
	    			caso[0].Status = 'Em análise';
	    			 
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Consulta de pedido') && caso[0].Status == 'Aguardando parecer do setor'){
	    			
	    			caso[0].Status = 'Parecer retornado pelo setor';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Prorrogação') && caso[0].Status == 'QM em andamento'){
	    			
	    			caso[0].Status = 'Aguardando encerramento';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Sinistro') && caso[0].Status == 'Aguardando retorno transportes'){
	    			
	    			caso[0].Status = 'Em análise';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Devolução') && caso[0].DeliveryTxt__c == 'Pós'&& caso[0].Status == 'Aguardando retorno vendedor'){
	    			
	    			caso[0].Status = 'Em análise';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Devolução') && caso[0].DeliveryTxt__c == 'Pós'&& caso[0].Status == 'Aguardando nota fiscal de devolução'){
	    			
	    			caso[0].Status = 'Em análise';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Produto trocado') && caso[0].Status == 'Aguardando retorno transportadora'){
	    			
	    			caso[0].Status = 'Em análise';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Indicação de vendedor') && caso[0].Status == 'Aguardando retorno vendedor'){
	    			
	    			caso[0].Status = 'Em análise 1';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Substituição') && caso[0].Status == 'Aguardando retorno transportadora'){
	    			
	    			caso[0].Status = 'Em análise';
	    			
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Cancelamento de pedido') && caso[0].Status == 'Aguardando parecer do setor'){
	    			
	    			caso[0].Status = 'Parecer retornado pelo setor';
	
	    		}
	    		else if(caso[0].RecordTypeId == recordMap.get('Refaturamento') && caso[0].Status == 'Aguardando parecer do setor'){
	    			
	    			caso[0].Status = 'Aguardando nota fiscal de devolução';
	
	    		}
			}
			
			//if(caso[0].Status.equals('Cancelado') || caso[0].Status.equals('Encerrado')) {
			//	caso[0].ByPassBln__c = true;
			//}
		system.debug('update caso email message: '+caso[0]);
    	update caso[0];
    	}
    }
}