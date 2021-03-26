public without sharing class CSEOrderBO 
{
    public void setCarrierDescription(List<Order__c> records){
        for(Order__c o : records){
            if(o.CarrierName1Txt__c != NULL || o.CarrierName2Txt__c != NULL || o.CarrierStreetTxt__c != NULL || o.CarrierCityTxt__c != NULL ||
               o.CarrierStateTxt__c != NULL || o.CarrierPostalCodeTxt__c != NULL || o.CarrierCNPJCPFTxt__c != NULL || o.CarrierStateInscriptionTxt__c != NULL){
                   
                   String auxStr = 'Nome 1: '+(o.CarrierName1Txt__c != NULL ? o.CarrierName1Txt__c : '')+'\n'+
                       'Nome 2: '+(o.CarrierName2Txt__c != NULL ? o.CarrierName2Txt__c : '')+'\n'+
                       'Rua/Nº: '+(o.CarrierStreetTxt__c != NULL ? o.CarrierStreetTxt__c : '')+'\n'+
                       'Cidade: '+(o.CarrierCityTxt__c != NULL ? o.CarrierCityTxt__c : '')+'\n'+
                       'Estado: '+(o.CarrierStateTxt__c != NULL ? o.CarrierStateTxt__c : '')+'\n'+
                       'CEP: '+(o.CarrierPostalCodeTxt__c != NULL ? o.CarrierPostalCodeTxt__c : '')+'\n'+
                       'CPNJ: '+(o.CarrierCNPJCPFTxt__c != NULL ? o.CarrierCNPJCPFTxt__c : '')+'\n'+
                       'Inscrição Est.: '+(o.CarrierStateInscriptionTxt__c != NULL ? o.CarrierStateInscriptionTxt__c : '');
                   
                   o.CarrierTxt__c = auxStr;
               }
        }         
    }
    
    public void setPurchaseDateAccount(List<Order__c> records){
        Map<Id, Account> mapAccToUpdate = new Map<Id, Account>();
        for(Order__c o : records){
            if(!mapAccToUpdate.containsKey(o.AccountLkp__c))
                mapAccToUpdate.put(o.AccountLkp__c, new Account(Id = o.AccountLkp__c, LastOrderDateDte__c = o.OrderDateDte__c));
            else{
                Account acc = mapAccToUpdate.get(o.AccountLkp__c);
                if(o.OrderDateDte__c > acc.LastOrderDateDte__c){
                    mapAccToUpdate.put(o.AccountLkp__c, new Account(Id = o.AccountLkp__c, LastOrderDateDte__c = o.OrderDateDte__c));                    
                }
            }
        }
        update mapAccToUpdate.values();
    }
    
    public void validateOrderType(List<Order__c> records){
        List<OrderType__c> zcovTypes = [SELECT Id FROM OrderType__c WHERE CustomIdTxt__c = 'ZCOV'];
        OrderType__c zcov = zcovTypes.isEmpty() ? null : zcovTypes[0];
        List<Id> listAvIds = new List<Id>();
        List<Id> listOrderTypeIds = new List<Id>();
        List<String> listOrderTypeCodes = new List<String>();
        for(Order__c o : records){
            if(o.OrderTypeLkp__c == null && zcov != null)
                o.OrderTypeLkp__c =  zcov.Id;
            listAvIds.add(o.AccountAreaSalesLkp__c);
            listOrderTypeIds.add(o.OrderTypeLkp__c);
        }
        Map<Id, AccountAreaSales__c> mapAv = new Map<Id, AccountAreaSales__c>([
            SELECT Id, 
            ChannelLkp__c
            FROM AccountAreaSales__c 
            WHERE Id IN :listAvIds
        ]);
         
        
        List<BlockedItem__c> blockItems = [SELECT Id, ChannelPVCLkp__c, OrderTypeLkp__c FROM BlockedItem__c WHERE OrderTypeLkp__c IN :listOrderTypeIds AND ChannelPVCLkp__c != null AND RecordType.DeveloperName = 'OrderTypeBlockRT'];
        Set<String> blockedKeys = new Set<String>();
        for(BlockedItem__c block : blockItems){
            blockedKeys.add(String.valueOf(block.ChannelPVCLkp__c).substring(0,15) + String.valueOf(block.OrderTypeLkp__c).substring(0,15));
        }
        for(Order__c o : records){
            if(o.OrderTypeLkp__c != null && mapAv.containsKey(o.AccountAreaSalesLkp__c) && mapAv.get(o.AccountAreaSalesLkp__c).ChannelLkp__c != null){
                if(blockedKeys.contains(String.valueOf(mapAv.get(o.AccountAreaSalesLkp__c).ChannelLkp__c).substring(0,15) + String.ValueOf(o.OrderTypeLkp__c).substring(0,15))){
                    o.addError('Esse tipo de pedido está bloqueado para venda nesse canal');
                }
            }
        }
    }
    
    public void setPaymentTermAndOrderType(List<Order__c> records){
        Map<String, List<Order__C>> mapOrderTerms = new Map<String, List<Order__c>>();
        Map<String, List<Order__c>> mapOrderTypes = new Map<String, List<Order__c>>();
        for(Order__c o : records){
            if(o.PaymentTermTxt__c != null){
                if(mapOrderTerms.containsKey(o.PaymentTermTxt__c)){
                    mapOrderTerms.get(o.PaymentTermTxt__c).add(o);
                }
                else{
                    mapOrderTerms.put(o.PaymentTermTxt__c, new List<Order__c>{o});
                }
            }
            if(o.OrderTypePicklistTxt__c != null){
                if(mapOrderTypes.containsKey(o.OrderTypePicklistTxt__c)){
                    mapOrderTypes.get(o.OrderTypePicklistTxt__c).add(o);
                }
                else{
                    mapOrderTypes.put(o.OrderTypePicklistTxt__c, new List<Order__c>{o});
                }
            }
        }
        for(PaymentTerm__c term : [SELECT Id, CustomizedIdTxt__c FROM PaymentTerm__c WHERE CustomizedIdTxt__c IN :mapOrderTerms.keySet()]){
            for(Order__c o : mapOrderTerms.get(term.CustomizedIdTxt__c)){
                o.PaymentTermLkp__c = term.Id;
            }
        }
        for(OrderType__c orderType : [SELECT Id, CustomIdTxt__c FROM OrderType__c WHERE CustomIdTxt__c IN :mapOrderTypes.keySet()]){
            for(Order__c o : mapOrderTypes.get(orderType.CustomIdTxt__c)){
                o.OrderTypeLkp__c = orderType.Id; 
            }
        }      
    }
    
    public void setPrimaryOrders(List<Id> listPrimaryIds){
        List<Order__c> listOrders = [SELECT Id, OpportunityLkp__c, PrimaryBln__c FROM Order__c WHERE Id IN :listPrimaryIds];
        List<Order__c> ordersToUpdate = new List<Order__c>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<Id> listOppIds = new List<Id>();
        
        for(Order__c o : listOrders){
            listOppIds.add(o.OpportunityLkp__c);
            oppToUpdate.add(new Opportunity(Id = o.OpportunityLkp__c, OrderLkp__c = o.Id));
        }
        for(Order__c o : [SELECT Id FROM Order__c WHERE OpportunityLkp__c IN :listOppIds AND Id NOT IN :listPrimaryIds]){
            o.PrimaryBln__c = false;
            ordersToUpdate.add(o);
        }
        
        upsert oppToUpdate;
        upsert ordersToUpdate;
        
    }

    public void setOwner(List<Order__c> records){
        List<Id> listIds = new List<Id>();        
        
        for(Order__c o : records){
            if(o.SellerLkp__c != null){
                listIds.add(o.SellerLkp__c);
            }            
        }               
        
        Map<Id, Seller__c> mapSellers = new Map<Id, Seller__c>([SELECT Id, UserLkp__c, SellerNumberNmb__c, UserLkp__r.CPFTxt__c, CoordinatorLkp__c, ManagerLkp__c FROM Seller__c WHERE Id IN :ListIds]);
        for(Order__c o : records){
            if(o.SellerLkp__c != null){
                if(o.OwnerId != mapSellers.get(o.SellerLkp__c).UserLkp__c && mapSellers.get(o.SellerLkp__c).UserLkp__c != null){
                    o.OwnerId = mapSellers.get(o.SellerLkp__c).UserLkp__c;
                }
                if(mapSellers.get(o.SellerLkp__c).UserLkp__r.CPFTxt__c != null){
                    o.SellerCPFTxt__c = mapSellers.get(o.SellerLkp__c).UserLkp__r.CPFTxt__c;
                }
                if(mapSellers.get(o.SellerLkp__c).CoordinatorLkp__c != null){
                    o.CoordinatorLkp__c = mapSellers.get(o.SellerLkp__c).CoordinatorLkp__c;
                }
                if(mapSellers.get(o.SellerLkp__c).ManagerLkp__c != null){
                    o.ManagerLkp__c = mapSellers.get(o.SellerLkp__c).ManagerLkp__c;
                }
            }
        }
    }
    
    public void setSalesAreaOrAccount(List<Order__c> records){
        List<Id> listIds = new List<Id>();
        List<Id> listAccIds = new List<Id>();
        List<Id> listAvIds = new List<Id>();
        List<Id> listOppIds = new List<Id>();
        Map<Id, List<AccountAreaSales__c>> mapSalesAreaByAccount = new Map<Id, List<AccountAreaSales__c>>();
        for(Order__c o : records){
            if(o.AccountLkp__c == null || o.AccountAreaSalesLkp__c == null || o.SellerLkp__c == null){
            	listIds.add(o.Id);
                if(o.AccountLkp__c != null) listAccIds.add(o.AccountLkp__c);
                if(o.AccountAreaSalesLkp__c != null) listAvIds.add(o.AccountAreaSalesLkp__c);
                if(o.OpportunityLkp__c != null) listOppIds.add(o.OpportunityLkp__c);
            }
        }
        if(listIds.size() > 0){
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([
                SELECT Id, Opty_Sales_Area__c, AccountId FROM Opportunity
                WHERE Id IN :listOppIds
            ]);
            for(Opportunity opp : mapOpp.values()){
                listAvIds.add(opp.Opty_Sales_Area__c);
            }
            Map<Id, AccountAreaSales__c> mapAv = new Map<Id, AccountAreaSales__c>([
                SELECT Id, 
                AccountLkp__c, 
                CodeSalesOrganizationTxt__c, 
                SellerLkp__c, 
                SellerLkp__r.UserLkp__c 
                //OwnerId 
                FROM AccountAreaSales__c 
                WHERE AccountLkp__c IN :listAccIds 
                OR Id IN :listAvIds
            ]);
            for(AccountAreaSales__c av : mapAv.values()){
                List<AccountAreaSales__c> listAux = new List<AccountAreaSales__c>();
                if(mapSalesAreaByAccount.containsKey(av.AccountLkp__c)){
                    listAux = mapSalesAreaByAccount.get(av.AccountLkp__c);
                }
                listAux.add(av);
                mapSalesAreaByAccount.put(av.AccountLkp__c, listAux);
            }
            for(Order__c o : records){
                if(o.AccountLkp__c == null && o.AccountAreaSalesLkp__c == null){
                    if(o.OpportunityLkp__c != null){
                        o.AccountAreaSalesLkp__c = mapOpp.get(o.OpportunityLkp__c).Opty_Sales_Area__c;
                        o.AccountLkp__c = mapOpp.get(o.OpportunityLkp__c).AccountId;
                        o.SellerLkp__c =  mapAv.get(o.AccountAreaSalesLkp__c).SellerLkp__c;
                    }
                    else{
                    	//o.addError('A conta ou área de vendas devem estar selecionadas');
                    }
                }
                else if(o.AccountLkp__c == null){
                    o.AccountLkp__c = mapAv.get(o.AccountAreaSalesLkp__c).AccountLkp__c;
                    if(o.SellerLkp__c == null)
                    	o.SellerLkp__c =  mapAv.get(o.AccountAreaSalesLkp__c).SellerLkp__c;
                }
                else if(o.AccountAreaSalesLkp__c == null){
                    if(mapSalesAreaByAccount.containsKey(o.AccountLkp__c)){
                        List<AccountAreaSales__c> listAux = mapSalesAreaByAccount.get(o.AccountLkp__c);
                        if(listAux.size() == 1){
                            o.AccountAreaSalesLkp__c = listAux[0].Id;
                            if(o.SellerLkp__c == null)
                                o.SellerLkp__c = listAux[0].SellerLkp__c;
                        }
                        else{
                            if(o.SellerLkp__c != null){
                                for(AccountAreaSales__c av : listAux){
                                    if(av.SellerLkp__c == o.SellerLkp__c)
                                        o.AccountAreaSalesLkp__c = av.Id;
                                }
                                if(o.AccountAreaSalesLkp__c == null){
                                    o.addError('Não foi achada nenhuma área de vendas cadastrada para esse vendedor');
                                }
                            }
                            else{
                                o.addError('Selecione um vendedor para atribuir a Área de Vendas');
                            }
                        }
                    }
                    else{
                        o.addError('A conta selecionada não possui área de vendas cadastrada');
                    }
                }
                else if(o.SellerLkp__c == null){
                    o.SellerLkp__c =  mapAv.get(o.AccountAreaSalesLkp__c).SellerLkp__c;
                }
            }
        }
    }
    
    public void recalculatePrices(List<Order__c> records){
        if(records.size() == 1){
            OrderIntegrationUtils.recalculatePricesFuture(records[0].Id);
        }
    }
    
    /*public void updateOrderSAP(List<Order__c> records){
        if(records.size() == 1)
            OrderService.getInvoiceListByOrderNumberFuture(records[0].CustomIdTxt__c);
    }*/
    
    /*public void setAccountReceiver(List<Order__c> records){
        for(Order__c o : records){
            if(o.AccountLkp__c != null && o.AccountReceiverLkp__c == null)
                o.AccountReceiverLkp__c = o.AccountLkp__c;
        }
    }*/
    	/*
		Retrives all cases related to every order
	*/
	private Map<Id, Case> getCaseMap(List<Order__c> orderList) 
	{
	    CSECaseSelector caseSelector = new CSECaseSelector();

		Set<Id> caseIdSet = new Set<Id>();
		Map<Id, Case> caseMap = new Map<Id, Case>();
	
    	for(Order__c ordem : orderList) 
    	{
			caseIdSet.add(ordem.CaseLkp__c);
    	}

        if(!caseIdSet.isEmpty()){
            List<Case> caseList = caseSelector.selectById(caseIdSet);
            caseMap = new Map<Id, Case>(caseList);
        }
		return caseMap;
	}
	
	// Método que realiza o cancelamento do Caso se a Ordem fora cancelada
    public void setStatusCase(List<Order__c> records) 
    {
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap = getCaseMap(records);

		Set<Case> caseToUpdateSet = new Set<Case>();

    	for(Order__c ordem : records) 
    	{
    		Case currentCase = caseMap.get(ordem.CaseLkp__c);

    		if (ordem.OrderStatusTxt__c == 'Cancelada')
    		{
	    		if(!currentCase.Status.equals('Encerrado') && !currentCase.Status.equals('Cancelado'))
	    		{
	    			currentCase.Status = 'Cancelado';
	    			currentCase.ClouseReasonTxt__c = 'Ordem cancelada';
	    			caseToUpdateSet.add(currentCase);
	    		}
    		}
    	}

    	update new List<Case>(caseToUpdateSet);
    }

    public Map<String, Integer> getProdutosTrocados(List<Order__c> records, Map<Id, Case> caseMap, Map<String, Id> recordMap) 
    {
        Map<String, Integer> qmMap = new Map<String, Integer>();
        
        /* Validando parâmetros */
        if((records == null) || (caseMap == null) || (recordMap == null)) 
        { 
        	return qmMap; 
        }
        
		Set<Id> idSetCase = new Set<Id>();
		for(Order__c ordem : records) 
		{
			if(ordem.CaseLkp__c == null) { continue; }

			Case currentCase = caseMap.get(ordem.CaseLkp__c);
			
			if(currentCase == null) { continue; }
			
			if (currentCase.RecordTypeId == recordMap.get('Produto trocado') &&
			    currentCase.Type.equals('Quantidades diferentes')) 
			{
				idSetCase.add(ordem.CaseLkp__c);
			}
		}

		List<QM__c> qmList = QMDAO.getByCaseId(idSetCase);
		
		if (qmList == null) { return qmMap; }

		/* Levantando QMs distintas */
		for(QM__c qm : qmList) 
		{
			if(qmMap.get(qm.CaseLkp__c) == null) 
			{
				qmMap.put(qm.CaseLkp__c, 0);
			}
		}

		/* Contando numero de QMs por caso */
        for(QM__c qm : qmList) 
        {
        	qmMap.put(qm.CaseLkp__c, qmMap.get(qm.CaseLkp__c) + 1);
        }

        return qmMap;
    }

    public void setOrderInCase(List<Order__c> records) 
    {
    	Set<Case> caseToUpdateSet = new Set<Case>();
    	String profileName = getProfile();

    	// Validando perfil de usuário.
        if(profileName != 'Administrador do sistema' && profileName != 'Interface Salesforce') 
        {
            return;
        }

        // Criando mapa de cases.
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap = getCaseMap(records);

        if(!caseMap.isEmpty()){
            
        
            // Criando mapa de record types de case.
            Map<String, Id> recordMap = new Map<String, Id>();	    
            List<RecordType> recordType = [SELECT Id, Name FROM RecordType  where SobjectType = 'Case'];
            
            for(RecordType rec : recordType) 
            {
                recordMap.put(rec.Name, rec.Id);
            }
            
            // ???
            Map<String, Integer> qmMapProdutosTrocados = getProdutosTrocados(records, caseMap, recordMap);
            
            // Iterando sobre registros de ordens em buscas de atualizações.
            for(Order__c ordem : records) 
            {
                // Validando case.
                if(ordem.CaseLkp__c == null) { continue; }
                
                // Caso o case seja válido, recupera-se o mesmo do mapa de cases.
                Case currentCase = caseMap.get(ordem.CaseLkp__c);
                
                // Flag para indicar se o registro corrente deve ser atualizado.
                Boolean updateCase = false;
                
                if (currentCase.RecordTypeId == recordMap.get('Reposição'))
                {	    			
                    if(currentCase.Status.equals('Aberto') || 
                       currentCase.Status.equals('Em análise') ||
                       currentCase.Status.equals('Aguardando retorno transportadora') ||
                       currentCase.Status.equals('Aguardando nota fiscal de devolução'))
                    {
                        // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                        //currentCase.CreatedOrderTxt__c = ordem.Name;
                        currentCase.CreatedOrderTxt__c = ordem.CustomIDTxt__c;
                        
                        if (ordem.OrderTypeTxt__c == 'ZREP' ||
                            ordem.OrderTypeTxt__c == 'ZREI'||
                            ordem.OrderTypeTxt__c == 'ZRVO')
                        {		    		
                            currentCase.Status = 'Ordem de reposição criada';	
                        }		    				
                        else if ((ordem.OrderTypeTxt__c == 'ZOOP') ||
                                 (ordem.OrderTypeTxt__c == 'ZRES') ||
                                 (ordem.OrderTypeTxt__c == 'ZROS') ||
                                 (ordem.OrderTypeTxt__c == 'ZROB') ||
                                 (ordem.OrderTypeTxt__c == 'ZDIR') ||
                                 (ordem.OrderTypeTxt__c == 'ZDCS') ||
                                 (ordem.OrderTypeTxt__c == 'ZDCM') ||
                                 (ordem.OrderTypeTxt__c == 'ZDRF') ||
                                 (ordem.OrderTypeTxt__c == 'ZDRE') ||
                                 (ordem.OrderTypeTxt__c == 'ZDNP') ||
                                 (ordem.OrderTypeTxt__c == 'ZDNQ') ||
                                 (ordem.OrderTypeTxt__c == 'ZDEP') ||
                                 (ordem.OrderTypeTxt__c == 'ZDR0') ||
                                 (ordem.OrderTypeTxt__c == 'ZDUB') ||
                                 (ordem.OrderTypeTxt__c == 'ZDSO') ||
                                 (ordem.OrderTypeTxt__c == 'ZDMO') ||
                                 (ordem.OrderTypeTxt__c == 'ZDND') ||
                                 (ordem.OrderTypeTxt__c == 'ZDOI') ||
                                 (ordem.OrderTypeTxt__c == 'ZREB') ||
                                 (ordem.OrderTypeTxt__c == 'ZDES') ||
                                 (ordem.OrderTypeTxt__c == 'ZEOP') ||
                                 (ordem.OrderTypeTxt__c == 'ZD2S') ||
                                 (ordem.OrderTypeTxt__c == 'ZD2M') ||
                                 (ordem.OrderTypeTxt__c == 'ZD3F') ||
                                 (ordem.OrderTypeTxt__c == 'ZD3E') ||
                                 (ordem.OrderTypeTxt__c == 'ZDNR') ||
                                 (ordem.OrderTypeTxt__c == 'ZDNS') ||
                                 (ordem.OrderTypeTxt__c == 'ZRU2') ||
                                 (ordem.OrderTypeTxt__c == 'ZDU2') ||
                                 (ordem.OrderTypeTxt__c == 'ZDOP'))
                        {
                            currentCase.Status = 'Ordem de devolução simbólica criada';
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            if (ordem.OrderStatusTxt__c.equals('Processado completamente'))
                            {
                                currentCase.Status = 'Aguardando encerramento';		    					
                            }
                        }  
                        
                        updateCase = true;
                    } 
                    else if( !currentCase.Status.equals('Cancelado') &&
                            !currentCase.Status.equals('Encerrado') &&
                            ((ordem.OrderTypeTxt__c == 'ZOOP') ||
                             (ordem.OrderTypeTxt__c == 'ZRES') ||
                             (ordem.OrderTypeTxt__c == 'ZROS') ||
                             (ordem.OrderTypeTxt__c == 'ZROB') ||
                             (ordem.OrderTypeTxt__c == 'ZDIR') ||
                             (ordem.OrderTypeTxt__c == 'ZDCS') ||
                             (ordem.OrderTypeTxt__c == 'ZDCM') ||
                             (ordem.OrderTypeTxt__c == 'ZDRF') ||
                             (ordem.OrderTypeTxt__c == 'ZDRE') ||
                             (ordem.OrderTypeTxt__c == 'ZDNP') ||
                             (ordem.OrderTypeTxt__c == 'ZDNQ') ||
                             (ordem.OrderTypeTxt__c == 'ZDEP') ||
                             (ordem.OrderTypeTxt__c == 'ZDR0') ||
                             (ordem.OrderTypeTxt__c == 'ZDUB') ||
                             (ordem.OrderTypeTxt__c == 'ZDSO') ||
                             (ordem.OrderTypeTxt__c == 'ZDMO') ||
                             (ordem.OrderTypeTxt__c == 'ZDND') ||
                             (ordem.OrderTypeTxt__c == 'ZDOI') ||
                             (ordem.OrderTypeTxt__c == 'ZREB') ||
                             (ordem.OrderTypeTxt__c == 'ZDES') ||
                             (ordem.OrderTypeTxt__c == 'ZEOP') ||
                             (ordem.OrderTypeTxt__c == 'ZD2S') ||
                             (ordem.OrderTypeTxt__c == 'ZD2M') ||
                             (ordem.OrderTypeTxt__c == 'ZD3F') ||
                             (ordem.OrderTypeTxt__c == 'ZD3E') ||
                             (ordem.OrderTypeTxt__c == 'ZDNR') ||
                             (ordem.OrderTypeTxt__c == 'ZDNS') ||
                             (ordem.OrderTypeTxt__c == 'ZRU2') ||
                             (ordem.OrderTypeTxt__c == 'ZDU2') ||
                             (ordem.OrderTypeTxt__c == 'ZDOP')))
                    {
                        currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                        
                        if (ordem.OrderStatusTxt__c.equals('Processado completamente'))
                        {  
                            currentCase.Status = 'Aguardando encerramento';
                        }
                        
                        updateCase = true;
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Extravio de nota fiscal'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado') && !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                        //currentCase.CreatedOrderTxt__c = ordem.Name;
                        currentCase.CreatedOrderTxt__c = ordem.CustomIDTxt__c;
                        currentCase.Status = 'Ordem de venda criada';
                        
                        updateCase = true;
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Sinistro') && currentCase.SinisterTxt__c.equals('Total'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado') && !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                        //currentCase.CreatedOrderTxt__c = ordem.Name;
                        currentCase.CreatedOrderTxt__c = ordem.CustomIDTxt__c;		    			
                        currentCase.Status = 'Ordem de venda criada';
                        
                        updateCase = true;
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Reclamação'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado') && !currentCase.Status.equals('Aguardando encerramento'))
                    {	    			
                        currentCase.Status = 'Ordem de Indenização produto criada';
                        
                        updateCase = true;
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Devolução'))
                {
                    if(!currentCase.Status.equals('Cancelado') && 
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('QM em andamento') &&
                       !currentCase.Status.equals('Aguardando encerramento') &&
                       !currentCase.Status.equals('Ordem de devolução criada'))
                    {
                        // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                        //currentCase.CreatedOrderTxt__c = ordem.Name;
                        currentCase.CreatedOrderTxt__c = ordem.CustomIDTxt__c;
                        currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                        
                        if (!ordem.OrderStatusTxt__c.equals('Processado completamente'))
                        {
                            currentCase.Status = 'Ordem de devolução criada';
                        }
                        else if (ordem.OrderStatusTxt__c.equals('Processado completamente'))
                        {
                            currentCase.Status = 'Aguardando encerramento';
                        }
                        
                        updateCase = true;
                    }
                    else if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderStatusTxt__c.equals('Processado completamente'))
                        {		    					
                            currentCase.Status = 'Aguardando encerramento';		    					
                        }
                        
                        currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                        
                        updateCase = true;
                    }
                } 
                else if (currentCase.RecordTypeId == recordMap.get('Refaturamento'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if(ordem.OrderTypeTxt__c == 'ZROB'||
                           ordem.OrderTypeTxt__c == 'ZDIR'||
                           ordem.OrderTypeTxt__c == 'ZDCS'||
                           ordem.OrderTypeTxt__c == 'ZDCM'||
                           ordem.OrderTypeTxt__c == 'ZDRF'||
                           ordem.OrderTypeTxt__c == 'ZDRE'||
                           ordem.OrderTypeTxt__c == 'ZDNP'||
                           ordem.OrderTypeTxt__c == 'ZDNQ'||
                           ordem.OrderTypeTxt__c == 'ZDEP'||
                           ordem.OrderTypeTxt__c == 'ZDR0'||
                           ordem.OrderTypeTxt__c == 'ZDUB'||
                           ordem.OrderTypeTxt__c == 'ZDSO'||
                           ordem.OrderTypeTxt__c == 'ZDMO'||
                           ordem.OrderTypeTxt__c == 'ZDND'||
                           ordem.OrderTypeTxt__c == 'ZDOI'||
                           ordem.OrderTypeTxt__c == 'ZREB'||
                           ordem.OrderTypeTxt__c == 'ZDES'||
                           ordem.OrderTypeTxt__c == 'ZEOP'||
                           ordem.OrderTypeTxt__c == 'ZD2S'||
                           ordem.OrderTypeTxt__c == 'ZD2M'||
                           ordem.OrderTypeTxt__c == 'ZD3F'||
                           ordem.OrderTypeTxt__c == 'ZD3E'||
                           ordem.OrderTypeTxt__c == 'ZDNR'||
                           ordem.OrderTypeTxt__c == 'ZDNS'||
                           ordem.OrderTypeTxt__c == 'ZRU2'||
                           ordem.OrderTypeTxt__c == 'ZDU2'||
                           ordem.OrderTypeTxt__c == 'ZDOP'||
                           ordem.OrderTypeTxt__c == 'ZOOP' ||
                           (ordem.OrderTypeTxt__c == 'ZRES') ||
                           (ordem.OrderTypeTxt__c == 'ZROS') ||
                           (ordem.OrderTypeTxt__c == 'ZROB') ||
                           (ordem.OrderTypeTxt__c == 'ZDIR') ||
                           (ordem.OrderTypeTxt__c == 'ZDCS') ||
                           (ordem.OrderTypeTxt__c == 'ZDCM') ||
                           (ordem.OrderTypeTxt__c == 'ZDRF') ||
                           (ordem.OrderTypeTxt__c == 'ZDRE') ||
                           (ordem.OrderTypeTxt__c == 'ZDNP') ||
                           (ordem.OrderTypeTxt__c == 'ZDNQ') ||
                           (ordem.OrderTypeTxt__c == 'ZDEP') ||
                           (ordem.OrderTypeTxt__c == 'ZDR0') ||
                           (ordem.OrderTypeTxt__c == 'ZDUB') ||
                           (ordem.OrderTypeTxt__c == 'ZDSO') ||
                           (ordem.OrderTypeTxt__c == 'ZDMO') ||
                           (ordem.OrderTypeTxt__c == 'ZDND') ||
                           (ordem.OrderTypeTxt__c == 'ZDOI') ||
                           (ordem.OrderTypeTxt__c == 'ZREB') ||
                           (ordem.OrderTypeTxt__c == 'ZDES') ||
                           (ordem.OrderTypeTxt__c == 'ZEOP') ||
                           (ordem.OrderTypeTxt__c == 'ZD2S') ||
                           (ordem.OrderTypeTxt__c == 'ZD2M') ||
                           (ordem.OrderTypeTxt__c == 'ZD3F') ||
                           (ordem.OrderTypeTxt__c == 'ZD3E') ||
                           (ordem.OrderTypeTxt__c == 'ZDNR') ||
                           (ordem.OrderTypeTxt__c == 'ZDNS') ||
                           (ordem.OrderTypeTxt__c == 'ZRU2') ||
                           (ordem.OrderTypeTxt__c == 'ZDU2') ||
                           (ordem.OrderTypeTxt__c == 'ZDOP')) 
                        {
                            if (currentCase.DevolutionOrderTxt__c == null)
                            {
                                
                                // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                                //currentCase.DevolutionOrderTxt__c = ordem.Name;
                                currentCase.DevolutionOrderTxt__c = ordem.CustomIDTxt__c;
                            }
                            
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                        } 
                        else 
                        {
                            currentCase.SalesOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            if (currentCase.NewSalesOrder__c == null)
                            {
                                // RSILV 23/01/18 - Alterar de Númeração SF para SAP
                                //currentCase.NewSalesOrder__c = ordem.Name;
                                currentCase.NewSalesOrder__c = ordem.CustomIDTxt__c;
                            }
                        }	
                    }
                    
                    if(!currentCase.Status.equals('Cancelado') && 
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('Ordem de devolução simbólica criada') &&
                       !currentCase.Status.equals('QM em andamento') &&
                       !currentCase.Status.equals('Ordem de refaturamento criada') &&
                       !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZROB'||
                            ordem.OrderTypeTxt__c == 'ZDIR'||
                            ordem.OrderTypeTxt__c == 'ZDCS'||
                            ordem.OrderTypeTxt__c == 'ZDCM'||
                            ordem.OrderTypeTxt__c == 'ZDRF'||
                            ordem.OrderTypeTxt__c == 'ZDRE'||
                            ordem.OrderTypeTxt__c == 'ZDNP'||
                            ordem.OrderTypeTxt__c == 'ZDNQ'||
                            ordem.OrderTypeTxt__c == 'ZDEP'||
                            ordem.OrderTypeTxt__c == 'ZDR0'||
                            ordem.OrderTypeTxt__c == 'ZDUB'||
                            ordem.OrderTypeTxt__c == 'ZDSO'||
                            ordem.OrderTypeTxt__c == 'ZDMO'||
                            ordem.OrderTypeTxt__c == 'ZDND'||
                            ordem.OrderTypeTxt__c == 'ZDOI'||
                            ordem.OrderTypeTxt__c == 'ZREB'||
                            ordem.OrderTypeTxt__c == 'ZDES'||
                            ordem.OrderTypeTxt__c == 'ZEOP'||
                            ordem.OrderTypeTxt__c == 'ZD2S'||
                            ordem.OrderTypeTxt__c == 'ZD2M'||
                            ordem.OrderTypeTxt__c == 'ZD3F'||
                            ordem.OrderTypeTxt__c == 'ZD3E'||
                            ordem.OrderTypeTxt__c == 'ZDNR'||
                            ordem.OrderTypeTxt__c == 'ZDNS'||
                            ordem.OrderTypeTxt__c == 'ZRU2'||
                            ordem.OrderTypeTxt__c == 'ZDU2'||
                            ordem.OrderTypeTxt__c == 'ZDOP'||
                            ordem.OrderTypeTxt__c == 'ZOOP' ||
                            (ordem.OrderTypeTxt__c == 'ZRES') ||
                            (ordem.OrderTypeTxt__c == 'ZROS') ||
                            (ordem.OrderTypeTxt__c == 'ZROB') ||
                            (ordem.OrderTypeTxt__c == 'ZDIR') ||
                            (ordem.OrderTypeTxt__c == 'ZDCS') ||
                            (ordem.OrderTypeTxt__c == 'ZDCM') ||
                            (ordem.OrderTypeTxt__c == 'ZDRF') ||
                            (ordem.OrderTypeTxt__c == 'ZDRE') ||
                            (ordem.OrderTypeTxt__c == 'ZDNP') ||
                            (ordem.OrderTypeTxt__c == 'ZDNQ') ||
                            (ordem.OrderTypeTxt__c == 'ZDEP') ||
                            (ordem.OrderTypeTxt__c == 'ZDR0') ||
                            (ordem.OrderTypeTxt__c == 'ZDUB') ||
                            (ordem.OrderTypeTxt__c == 'ZDSO') ||
                            (ordem.OrderTypeTxt__c == 'ZDMO') ||
                            (ordem.OrderTypeTxt__c == 'ZDND') ||
                            (ordem.OrderTypeTxt__c == 'ZDOI') ||
                            (ordem.OrderTypeTxt__c == 'ZREB') ||
                            (ordem.OrderTypeTxt__c == 'ZDES') ||
                            (ordem.OrderTypeTxt__c == 'ZEOP') ||
                            (ordem.OrderTypeTxt__c == 'ZD2S') ||
                            (ordem.OrderTypeTxt__c == 'ZD2M') ||
                            (ordem.OrderTypeTxt__c == 'ZD3F') ||
                            (ordem.OrderTypeTxt__c == 'ZD3E') ||
                            (ordem.OrderTypeTxt__c == 'ZDNR') ||
                            (ordem.OrderTypeTxt__c == 'ZDNS') ||
                            (ordem.OrderTypeTxt__c == 'ZRU2') ||
                            (ordem.OrderTypeTxt__c == 'ZDU2') ||
                            (ordem.OrderTypeTxt__c == 'ZDOP'))
                        {
                            currentCase.Status = 'Ordem de devolução simbólica criada';
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    } 
                    else if(!currentCase.Status.equals('Cancelado') && 
                            !currentCase.Status.equals('Encerrado') &&
                            !currentCase.Status.equals('Ordem de refaturamento criada') &&
                            !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZROB'&&
                            ordem.OrderTypeTxt__c != 'ZDIR'&&
                            ordem.OrderTypeTxt__c != 'ZDCS'&&
                            ordem.OrderTypeTxt__c != 'ZDCM'&&
                            ordem.OrderTypeTxt__c != 'ZDRF'&&
                            ordem.OrderTypeTxt__c != 'ZDRE'&&
                            ordem.OrderTypeTxt__c != 'ZDNP'&&
                            ordem.OrderTypeTxt__c != 'ZDNQ'&&
                            ordem.OrderTypeTxt__c != 'ZDEP'&&
                            ordem.OrderTypeTxt__c != 'ZDR0'&&
                            ordem.OrderTypeTxt__c != 'ZDUB'&&
                            ordem.OrderTypeTxt__c != 'ZDSO'&&
                            ordem.OrderTypeTxt__c != 'ZDMO'&&
                            ordem.OrderTypeTxt__c != 'ZDND'&&
                            ordem.OrderTypeTxt__c != 'ZDOI'&&
                            ordem.OrderTypeTxt__c != 'ZREB'&&
                            ordem.OrderTypeTxt__c != 'ZDES'&&
                            ordem.OrderTypeTxt__c != 'ZEOP'&&
                            ordem.OrderTypeTxt__c != 'ZD2S'&&
                            ordem.OrderTypeTxt__c != 'ZD2M'&&
                            ordem.OrderTypeTxt__c != 'ZD3F'&&
                            ordem.OrderTypeTxt__c != 'ZD3E'&&
                            ordem.OrderTypeTxt__c != 'ZDNR'&&
                            ordem.OrderTypeTxt__c != 'ZDNS'&&
                            ordem.OrderTypeTxt__c != 'ZRU2'&&
                            ordem.OrderTypeTxt__c != 'ZDU2'&&
                            ordem.OrderTypeTxt__c != 'ZDOP'&&
                            (ordem.OrderTypeTxt__c != 'ZRES') &&
                            (ordem.OrderTypeTxt__c != 'ZROS') &&
                            (ordem.OrderTypeTxt__c != 'ZROB') &&
                            (ordem.OrderTypeTxt__c != 'ZDIR') &&
                            (ordem.OrderTypeTxt__c != 'ZDCS') &&
                            (ordem.OrderTypeTxt__c != 'ZDCM') &&
                            (ordem.OrderTypeTxt__c != 'ZDRF') &&
                            (ordem.OrderTypeTxt__c != 'ZDRE') &&
                            (ordem.OrderTypeTxt__c != 'ZDNP') &&
                            (ordem.OrderTypeTxt__c != 'ZDNQ') &&
                            (ordem.OrderTypeTxt__c != 'ZDEP') &&
                            (ordem.OrderTypeTxt__c != 'ZDR0') &&
                            (ordem.OrderTypeTxt__c != 'ZDUB') &&
                            (ordem.OrderTypeTxt__c != 'ZDSO') &&
                            (ordem.OrderTypeTxt__c != 'ZDMO') &&
                            (ordem.OrderTypeTxt__c != 'ZDND') &&
                            (ordem.OrderTypeTxt__c != 'ZDOI') &&
                            (ordem.OrderTypeTxt__c != 'ZREB') &&
                            (ordem.OrderTypeTxt__c != 'ZDES') &&
                            (ordem.OrderTypeTxt__c != 'ZEOP') &&
                            (ordem.OrderTypeTxt__c != 'ZD2S') &&
                            (ordem.OrderTypeTxt__c != 'ZD2M') &&
                            (ordem.OrderTypeTxt__c != 'ZD3F') &&
                            (ordem.OrderTypeTxt__c != 'ZD3E') &&
                            (ordem.OrderTypeTxt__c != 'ZDNR') &&
                            (ordem.OrderTypeTxt__c != 'ZDNS') &&
                            (ordem.OrderTypeTxt__c != 'ZRU2') &&
                            (ordem.OrderTypeTxt__c != 'ZDU2') &&
                            (ordem.OrderTypeTxt__c != 'ZDOP'))
                        {
                            currentCase.Status = 'Ordem de refaturamento criada';
                            currentCase.SalesOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            if (currentCase.SalesOrderStatusTxt__c.equals('Processado completamente') && currentCase.DevolutionOrderStatusTxt__c.equals('Processado completamente'))
                            {
                                currentCase.Status = 'Aguardando encerramento';
                            }
                            
                            updateCase = true;
                        }
                    }
                    else if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (currentCase.SalesOrderStatusTxt__c.equals('Processado completamente') && currentCase.DevolutionOrderStatusTxt__c.equals('Processado completamente'))
                        {
                            currentCase.Status = 'Aguardando encerramento';
                        }
                        
                        updateCase = true;
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Substituição'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZSUB'||
                            ordem.OrderTypeTxt__c == 'ZSUI'||
                            ordem.OrderTypeTxt__c == 'ZSVO')
                        {
                            if (currentCase.NewOrderReplacementTxt__c == null)
                            {
                                // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                                //currentCase.NewOrderReplacementTxt__c = ordem.Name;
                                currentCase.NewOrderReplacementTxt__c = ordem.CustomIDTxt__c;
                            }
                        }
                        else if (currentCase.DevolutionOrderTxt__c == null)
                        {
                            // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                            //currentCase.DevolutionOrderTxt__c = ordem.Name;
                            currentCase.DevolutionOrderTxt__c = ordem.CustomIDTxt__c;
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                        }
                    }
                    
                    if(!currentCase.Status.equals('Cancelado') && 
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('Ordem de devolução criada') &&
                       !currentCase.Status.equals('Ordem de substituição criada') &&
                       !currentCase.Status.equals('QM em andamento') &&
                       !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZSUB'||
                            ordem.OrderTypeTxt__c == 'ZSUI'||
                            ordem.OrderTypeTxt__c == 'ZSVO')
                        {    					    					
                            currentCase.Status = 'Ordem de substituição criada';
                                                       
                            updateCase = true;
                        }
                    }
                    else if (!currentCase.Status.equals('Cancelado') && 
                             !currentCase.Status.equals('Encerrado') &&
                             !currentCase.Status.equals('Ordem de devolução criada') &&
                             !currentCase.Status.equals('QM em andamento') &&
                             !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZSUB'&&
                            ordem.OrderTypeTxt__c != 'ZSUI'&&
                            ordem.OrderTypeTxt__c != 'ZSVO')
                        {    					    					
                            currentCase.Status = 'Ordem de devolução criada';
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                    else if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZSUB'&&
                            ordem.OrderTypeTxt__c != 'ZSUI'&&
                            ordem.OrderTypeTxt__c != 'ZSVO')
                        {
                            if (ordem.OrderStatusTxt__c.equals('Processado completamente') && currentCase.DeliveryDateInvoiceCreatedDte__c != null)
                            {
                                currentCase.Status = 'Aguardando encerramento';
                            }
                            
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Sinistro') && currentCase.SinisterTxt__c.equals('Parcial'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZROB'||
                            ordem.OrderTypeTxt__c == 'ZDIR'||
                            ordem.OrderTypeTxt__c == 'ZDCS'||
                            ordem.OrderTypeTxt__c == 'ZDCM'||
                            ordem.OrderTypeTxt__c == 'ZDRF'||
                            ordem.OrderTypeTxt__c == 'ZDRE'||
                            ordem.OrderTypeTxt__c == 'ZDNP'||
                            ordem.OrderTypeTxt__c == 'ZDNQ'||
                            ordem.OrderTypeTxt__c == 'ZDEP'||
                            ordem.OrderTypeTxt__c == 'ZDR0'||
                            ordem.OrderTypeTxt__c == 'ZDUB'||
                            ordem.OrderTypeTxt__c == 'ZDSO'||
                            ordem.OrderTypeTxt__c == 'ZDMO'||
                            ordem.OrderTypeTxt__c == 'ZDND'||
                            ordem.OrderTypeTxt__c == 'ZDOI'||
                            ordem.OrderTypeTxt__c == 'ZREB'||
                            ordem.OrderTypeTxt__c == 'ZDES'||
                            ordem.OrderTypeTxt__c == 'ZEOP'||
                            ordem.OrderTypeTxt__c == 'ZD2S'||
                            ordem.OrderTypeTxt__c == 'ZD2M'||
                            ordem.OrderTypeTxt__c == 'ZD3F'||
                            ordem.OrderTypeTxt__c == 'ZD3E'||
                            ordem.OrderTypeTxt__c == 'ZDNR'||
                            ordem.OrderTypeTxt__c == 'ZDNS'||
                            ordem.OrderTypeTxt__c == 'ZRU2'||
                            ordem.OrderTypeTxt__c == 'ZDU2'||
                            ordem.OrderTypeTxt__c == 'ZDOP')
                        {
                            if (currentCase.DevolutionOrderTxt__c == null)
                            {
                               // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                                //currentCase.DevolutionOrderTxt__c = ordem.Name;
                                currentCase.DevolutionOrderTxt__c = ordem.CustomIDTxt__c;
                            }
                        }
                        else if (currentCase.NewSalesOrder__c == null)
                        {
                            // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                            //currentCase.NewSalesOrder__c = ordem.Name;
                            currentCase.NewSalesOrder__c = ordem.CustomIDTxt__c;
                        }
                    }
                    
                    if(!currentCase.Status.equals('Cancelado') && 
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('Ordem de devolução criada') &&
                       !currentCase.Status.equals('QM em andamento') &&
                       !currentCase.Status.equals('Ordem de venda criada') &&
                       !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZROB'||
                            ordem.OrderTypeTxt__c == 'ZDIR'||
                            ordem.OrderTypeTxt__c == 'ZDCS'||
                            ordem.OrderTypeTxt__c == 'ZDCM'||
                            ordem.OrderTypeTxt__c == 'ZDRF'||
                            ordem.OrderTypeTxt__c == 'ZDRE'||
                            ordem.OrderTypeTxt__c == 'ZDNP'||
                            ordem.OrderTypeTxt__c == 'ZDNQ'||
                            ordem.OrderTypeTxt__c == 'ZDEP'||
                            ordem.OrderTypeTxt__c == 'ZDR0'||
                            ordem.OrderTypeTxt__c == 'ZDUB'||
                            ordem.OrderTypeTxt__c == 'ZDSO'||
                            ordem.OrderTypeTxt__c == 'ZDMO'||
                            ordem.OrderTypeTxt__c == 'ZDND'||
                            ordem.OrderTypeTxt__c == 'ZDOI'||
                            ordem.OrderTypeTxt__c == 'ZREB'||
                            ordem.OrderTypeTxt__c == 'ZDES'||
                            ordem.OrderTypeTxt__c == 'ZEOP'||
                            ordem.OrderTypeTxt__c == 'ZD2S'||
                            ordem.OrderTypeTxt__c == 'ZD2M'||
                            ordem.OrderTypeTxt__c == 'ZD3F'||
                            ordem.OrderTypeTxt__c == 'ZD3E'||
                            ordem.OrderTypeTxt__c == 'ZDNR'||
                            ordem.OrderTypeTxt__c == 'ZDNS'||
                            ordem.OrderTypeTxt__c == 'ZRU2'||
                            ordem.OrderTypeTxt__c == 'ZDU2'||
                            ordem.OrderTypeTxt__c == 'ZDOP')
                        {
                            currentCase.Status = 'Ordem de devolução criada';
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                    else if (!currentCase.Status.equals('Cancelado') && 
                             !currentCase.Status.equals('Encerrado') &&
                             !currentCase.Status.equals('Ordem de venda criada') &&
                             !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZROB'&&
                            ordem.OrderTypeTxt__c != 'ZDIR'&&
                            ordem.OrderTypeTxt__c != 'ZDCS'&&
                            ordem.OrderTypeTxt__c != 'ZDCM'&&
                            ordem.OrderTypeTxt__c != 'ZDRF'&&
                            ordem.OrderTypeTxt__c != 'ZDRE'&&
                            ordem.OrderTypeTxt__c != 'ZDNP'&&
                            ordem.OrderTypeTxt__c != 'ZDNQ'&&
                            ordem.OrderTypeTxt__c != 'ZDEP'&&
                            ordem.OrderTypeTxt__c != 'ZDR0'&&
                            ordem.OrderTypeTxt__c != 'ZDUB'&&
                            ordem.OrderTypeTxt__c != 'ZDSO'&&
                            ordem.OrderTypeTxt__c != 'ZDMO'&&
                            ordem.OrderTypeTxt__c != 'ZDND'&&
                            ordem.OrderTypeTxt__c != 'ZDOI'&&
                            ordem.OrderTypeTxt__c != 'ZREB'&&
                            ordem.OrderTypeTxt__c != 'ZDES'&&
                            ordem.OrderTypeTxt__c != 'ZEOP'&&
                            ordem.OrderTypeTxt__c != 'ZD2S'&&
                            ordem.OrderTypeTxt__c != 'ZD2M'&&
                            ordem.OrderTypeTxt__c != 'ZD3F'&&
                            ordem.OrderTypeTxt__c != 'ZD3E'&&
                            ordem.OrderTypeTxt__c != 'ZDNR'&&
                            ordem.OrderTypeTxt__c != 'ZDNS'&&
                            ordem.OrderTypeTxt__c != 'ZRU2'&&
                            ordem.OrderTypeTxt__c != 'ZDU2'&&
                            ordem.OrderTypeTxt__c != 'ZDOP')
                        {
                            currentCase.Status = 'Ordem de venda criada';
                            
                            updateCase = true;
                        }
                    }
                    else if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZROB'||
                            ordem.OrderTypeTxt__c == 'ZDIR'||
                            ordem.OrderTypeTxt__c == 'ZDCS'||
                            ordem.OrderTypeTxt__c == 'ZDCM'||
                            ordem.OrderTypeTxt__c == 'ZDRF'||
                            ordem.OrderTypeTxt__c == 'ZDRE'||
                            ordem.OrderTypeTxt__c == 'ZDNP'||
                            ordem.OrderTypeTxt__c == 'ZDNQ'||
                            ordem.OrderTypeTxt__c == 'ZDEP'||
                            ordem.OrderTypeTxt__c == 'ZDR0'||
                            ordem.OrderTypeTxt__c == 'ZDUB'||
                            ordem.OrderTypeTxt__c == 'ZDSO'||
                            ordem.OrderTypeTxt__c == 'ZDMO'||
                            ordem.OrderTypeTxt__c == 'ZDND'||
                            ordem.OrderTypeTxt__c == 'ZDOI'||
                            ordem.OrderTypeTxt__c == 'ZREB'||
                            ordem.OrderTypeTxt__c == 'ZDES'||
                            ordem.OrderTypeTxt__c == 'ZEOP'||
                            ordem.OrderTypeTxt__c == 'ZD2S'||
                            ordem.OrderTypeTxt__c == 'ZD2M'||
                            ordem.OrderTypeTxt__c == 'ZD3F'||
                            ordem.OrderTypeTxt__c == 'ZD3E'||
                            ordem.OrderTypeTxt__c == 'ZDNR'||
                            ordem.OrderTypeTxt__c == 'ZDNS'||
                            ordem.OrderTypeTxt__c == 'ZRU2'||
                            ordem.OrderTypeTxt__c == 'ZDU2'||
                            ordem.OrderTypeTxt__c == 'ZDOP')
                        {
                            if (ordem.OrderStatusTxt__c.equals('Processado completamente') && currentCase.DeliveryDateInvoiceCreatedDte__c != null)
                            {
                                currentCase.Status = 'Aguardando encerramento';
                                
                                updateCase = true;
                            }
                            
                            currentCase.OrderDevolutionStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Produto trocado') && currentCase.Type.equals('Quantidades iguais'))
                {
                    if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZSUB'|| ordem.OrderTypeTxt__c == 'ZSUI'|| ordem.OrderTypeTxt__c == 'ZSVO')
                        {
                            if (currentCase.NewOrderReplacementTxt__c == null)
                            {
                                // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                                //currentCase.NewOrderReplacementTxt__c = ordem.Name;
                                currentCase.NewOrderReplacementTxt__c = ordem.CustomIDTxt__c;
                            }
                        }
                        else if (currentCase.DevolutionOrderTxt__c == null)
                        {
                           // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                            //currentCase.DevolutionOrderTxt__c = ordem.Name;
                            currentCase.DevolutionOrderTxt__c = ordem.CustomIDTxt__c;
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                        }
                    }
                    
                    if(!currentCase.Status.equals('Cancelado') && 
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('Ordem de devolução criada') &&
                       !currentCase.Status.equals('Ordem de substituição criada') &&
                       !currentCase.Status.equals('QM em andamento') &&
                       !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c == 'ZSUB'|| ordem.OrderTypeTxt__c == 'ZSUI'|| ordem.OrderTypeTxt__c == 'ZSVO')
                        {    					    					
                            currentCase.Status = 'Ordem de substituição criada';
                            
                            updateCase = true;
                        }
                    }
                    else if (!currentCase.Status.equals('Cancelado') && 
                             !currentCase.Status.equals('Encerrado') &&
                             !currentCase.Status.equals('Ordem de devolução criada') &&
                             !currentCase.Status.equals('QM em andamento') &&
                             !currentCase.Status.equals('Aguardando encerramento'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZSUB'&&
                            ordem.OrderTypeTxt__c != 'ZSUI'&&
                            ordem.OrderTypeTxt__c != 'ZSVO')
                        {    					    					
                            currentCase.Status = 'Ordem de devolução criada';
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                    else if(!currentCase.Status.equals('Cancelado') && !currentCase.Status.equals('Encerrado'))
                    {
                        if (ordem.OrderTypeTxt__c != 'ZSUB'&&
                            ordem.OrderTypeTxt__c != 'ZSUI'&&
                            ordem.OrderTypeTxt__c != 'ZSVO')
                        {    				
                            if (ordem.OrderStatusTxt__c.equals('Processado completamente') && currentCase.InvoiceReplacementTxt__c != null)
                            {
                                currentCase.Status = 'Aguardando encerramento';
                            }
                            
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                    }
                }
                else if (currentCase.RecordTypeId == recordMap.get('Produto trocado') && currentCase.Type.equals('Quantidades diferentes')) 
                {
                    if(!currentCase.Status.equals('Cancelado') &&
                       !currentCase.Status.equals('Encerrado') &&
                       !currentCase.Status.equals('Aguardando encerramento')) 
                    {
                        // Rotina para atualização dos dados do cabeçalho.
                        if(ordem.OrderTypeTxt__c == null || ordem.OrderTypeTxt__c == '') 
                        {
                            
                        }
                        
                        if((ordem.OrderTypeTxt__c == 'ZNOV') || (ordem.OrderTypeTxt__c == 'ZREF')) 
                        {
                            
                            if((currentCase.Status != 'QM em andamento') &&
                               ((currentCase.NewSalesOrder__c == null) || (currentCase.NewSalesOrder__c == ''))) 
                            {	
                                currentCase.Status = 'Ordem de refaturamento criada';
                            }
                            
                            // RSILV 16/01/18 - Alterar de Númeração SF para SAP
                            //currentCase.NewSalesOrder__c = ordem.Name;
                            currentCase.NewSalesOrder__c = ordem.CustomIDTxt__c;
                            currentCase.SalesOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                        else if((ordem.OrderTypeTxt__c == 'ZRES') || (ordem.OrderTypeTxt__c == 'ZROB')) 
                        {
                            if((currentCase.Status != 'QM em andamento') &&
                               ((currentCase.DevolutionOrderTxt__c == null) || (currentCase.DevolutionOrderTxt__c == ''))) 
                            {
                                currentCase.Status = 'Ordem de devolução criada';
                            }
                            
                            // RSILV 16/01/18 - Alterar de Númeração SF para SAP 
                            //currentCase.DevolutionOrderTxt__c = ordem.Name;
                            currentCase.DevolutionOrderTxt__c = ordem.CustomIDTxt__c;
                            currentCase.DevolutionOrderStatusTxt__c = ordem.OrderStatusTxt__c;
                            
                            updateCase = true;
                        }
                        else if((ordem.OrderTypeTxt__c == 'ZREP')) 
                        {
                            if((currentCase.Status != 'QM em andamento') &&
                               ((currentCase.ReplacementOrderTxt__c == null) || (currentCase.ReplacementOrderTxt__c == ''))) 
                            {	
                                currentCase.Status = 'Ordem de reposição criada';
                            }
                            
                            // RSILV 16/01/18 - Alterar de Númeração SF para SAP
                            //currentCase.ReplacementOrderTxt__c = ordem.Name;
                            currentCase.ReplacementOrderTxt__c = ordem.CustomIDTxt__c;
                            
                            updateCase = true;
                        }
                        
                        // Rotina para avançar o status do caso para “Aguardando encerramento”.
                        if(checkForAwaitingClosure(currentCase, qmMapProdutosTrocados)) 
                        {
                            currentCase.Status = 'Aguardando encerramento';
                        }
                    }
                }
                
                // Caso o caso corrente deva ser atualizado, adiciona-se este à lista para atualização.
                if(updateCase) 
                {
                    caseToUpdateSet.add(currentCase);
                }
            }
            
            // Updating cases.
            for(Case caseToUpdate : caseToUpdateSet) { System.debug('>>> caseToUpdate: ' + caseToUpdate); }
            update new List<Case>(caseToUpdateSet);
        }
    }

    public static boolean checkForAwaitingClosure(Case currentCase, Map<String, Integer> qmMapProdutosTrocados) 
    {
    	Boolean finishCase = true;

	    if((qmMapProdutosTrocados.get(currentCase.Id) > 0) && (currentCase.Status != 'QM criado Salesfoce')) 
	    {
	    	if(currentCase.ReplacementOrderTxt__c != null) 
	    	{
	    		if((currentCase.InvoiceCreatedTxt__c == null) || (currentCase.DeliveryDateInvoiceCreatedDte__c == null)) 
	    		{
	    			finishCase = false;
	    		}
	    	}

	    	if(currentCase.NewSalesOrder__c != null) 
	    	{
	    		if(currentCase.SalesOrderStatusTxt__c != 'Processado completamente') 
	    		{
	    			finishCase = false;
	    		}
	    	}

	    	if(currentCase.DevolutionOrderTxt__c != null) 
	    	{
	    		if(currentCase.DevolutionOrderStatusTxt__c != 'Processado completamente') 
	    		{
	    			finishCase = false;
	    		}
    		}
		}
		else 
		{
			finishCase = false;
		}

		return finishCase;
    }
    
    //get profle from current user
    private String getProfile() 
    {
        Id profId = UserInfo.getProfileId();
        Profile profile = ProfileDAO.getNameFromId(profId);
        return profile.Name;
    }
}