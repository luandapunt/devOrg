public with sharing class RMTRemittanceBO {
    
    public void verifyAndSetInvoiceToCase(Set<id> rmtIdSet) {
        system.debug('verifica invoice:: ');
    	
        String profileName = getProfile(); 
        if(profileName != 'Administrador do sistema' && profileName != 'Interface Salesforce') {
            return;
        }

        Set<Case> caseToUpdateSet = new Set<Case>();

        // Retrieving remittance objects.
    	RMTRemittanceSelector remittanceSelector = new RMTRemittanceSelector();
    	List<Remittance__c> remittanceList = remittanceSelector.selectById(rmtIdSet);
    	
        // Retrieving other objects related to remittence.
        Map<Id, Invoice__c> invoiceMap = getInvoiceMap(remittanceList);
    	Map<String, Id> recordMap = RecordTypeDAO.getRecordTypeMap('Case');
        List<Order__c> orderList = getOrderList(remittanceList);
        Map<Id, Case> caseMap = getCaseMap(orderList);

        // Parsing quantity of QMs per case. Used only when Produto trocado needs to be updated.
        Map<String, Integer> qmQuantityPerCase = getQmQuantityPerCase(orderList, caseMap, recordMap);

        for(Remittance__c remittance : remittanceList) {

            // Validating the existence of the remittance's order.
            if(remittance.OrderLkp__c == null) {

                continue;
            }

            // Validating the existence of the order's case.
            if(remittance.OrderLkp__r.CaseLkp__c == null) {

                continue;
            }

            // Validating the order's case status.
            if(remittance.OrderLkp__r.CaseLkp__r.Status.equals('Cancelado') ||
               remittance.OrderLkp__r.CaseLkp__r.Status.equals('Encerrado')) {

                continue;
            }

            // Storing record type Id of the case.
            String recordTypeId = remittance.OrderLkp__r.CaseLkp__r.RecordTypeId;

            // Storing the current case of the remittance.
            Case currentCase = caseMap.get(remittance.OrderLkp__r.CaseLkp__c);
	System.debug('OLHA AQUI: '+currentCase);
            // Validating the existence of the remittance's invoice.
            Invoice__c invoice = invoiceMap.get(remittance.Id);
            if(invoice == null) { continue; }

            if(recordTypeId.equals(recordMap.get('Reposicao')) ||
               recordTypeId.equals(recordMap.get('ExtravioNotaFiscal'))) {

                currentCase.InvoiceCreatedTxt__c = invoice.Name;
                currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                if(invoice.ShipmentDeliveredFml__c != null && currentCase.Status != 'Aguardando encerramento') {
                            
                    currentCase.Status = 'Aguardando encerramento';
                }

                caseToUpdateSet.add(currentCase);
            }
            else if(recordTypeId.equals(recordMap.get('Sinistro'))) {

                currentCase.InvoiceCreatedTxt__c = invoice.Name;
                currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                if(currentCase.SinisterTxt__c.equals('Total')) {
                            
                    currentCase.InvoiceCreatedTxt__c = invoice.Name;
                    currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                            
                    if((invoice.ShipmentDeliveredFml__c != null) &&
                       (currentCase.Status != 'Aguardando encerramento')) {
                                
                       currentCase.Status = 'Aguardando encerramento';
                    }                         
                } 
                else if(currentCase.SinisterTxt__c.equals('Parcial')) {
                            
                    currentCase.InvoiceCreatedTxt__c = invoice.Name;
                    currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                            
                    if((invoice.ShipmentDeliveredFml__c != null) &&
                       (currentCase.Status != 'Aguardando encerramento') &&
                       (currentCase.OrderDevolutionStatusTxt__c.equals('Processado completamente'))) {
                                
                        currentCase.Status = 'Aguardando encerramento';     
                    }
                }

                caseToUpdateSet.add(currentCase);
            }
            else if(recordTypeId.equals(recordMap.get('Refaturamento'))) {
			 //RSILVA 11/01/2018 - LINHAS DUPLICADAS COMENTADAS 
             //   currentCase.InvoiceCreatedTxt__c = invoice.Name;
             //   currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                currentCase.InvoiceCreatedTxt__c = invoice.Name;
                currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                if((invoice.ShipmentDeliveredFml__c != null) &&
                   (currentCase.Status != 'Aguardando encerramento') &&
                   (currentCase.OrderDevolutionStatusTxt__c.equals('Processado completamente'))){
                        
                    currentCase.Status = 'Aguardando encerramento';
                }
                                            
                caseToUpdateSet.add(currentCase);
            }
            else if(recordTypeId.equals(recordMap.get('Substituicao'))) {
				//RSILVA 10/01/2018 - LINHAS DUPLICADAS COMENTADAS 
                //currentCase.InvoiceCreatedTxt__c = invoice.Name;
                //currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                currentCase.InvoiceCreatedTxt__c = invoice.Name;
                currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                        
                if((invoice.ShipmentDeliveredFml__c != null) &&
                   (currentCase.Status != 'Aguardando encerramento') &&
                   (currentCase.OrderDevolutionStatusTxt__c != null) &&
                   (currentCase.OrderDevolutionStatusTxt__c.equals('Processado completamente'))) {
                            
                     currentCase.Status = 'Aguardando encerramento';
                }
                                            
                caseToUpdateSet.add(currentCase);
            }
            else if(recordTypeId.equals(recordMap.get('ProdutoTrocado'))) {

                if(currentCase.Type.equals('Quantidades iguais')) {
                            
                    currentCase.InvoiceReplacementTxt__c = invoice.Name;
                    currentCase.DeliveryDateInvoiceReplacementDte__c = invoice.ShipmentDeliveredFml__c;
                
                    if((invoice.ShipmentDeliveredFml__c != null) &&
                       (currentCase.Status != 'Aguardando encerramento') &&
                       (currentCase.DevolutionOrderStatusTxt__c!= null) &&
                       (currentCase.DevolutionOrderStatusTxt__c.equals('Processado completamente'))) {
                  
                            currentCase.Status = 'Aguardando encerramento';
                        }
                }
                else if(currentCase.Type.equals('Quantidades diferentes')) {

                    currentCase.InvoiceCreatedTxt__c = invoice.Name;
                    currentCase.DeliveryDateInvoiceCreatedDte__c = invoice.ShipmentDeliveredFml__c;
                            
                    // Rotina para avançar o status do caso para “Aguardando encerramento”.
                    if(CSEOrderBO.checkForAwaitingClosure(currentCase, qmQuantityPerCase)) {

                        currentCase.Status = 'Aguardando encerramento';
                    }
                }

                caseToUpdateSet.add(currentCase);
            }
        }

        // Updating all necessary cases.
        update new List<Case>(caseToUpdateSet);
    }

    //get profle from current user
    private String getProfile() {
        Id profId = UserInfo.getProfileId();
        Profile profile = ProfileDAO.getNameFromId(profId);
        return profile.Name;
    }

    // Retrives all invoices related to every remittance.
    private Map<Id, Invoice__c> getInvoiceMap(List<Remittance__c> remittanceList) {

        CSEInvoiceSelector invoiceSelector = new CSEInvoiceSelector();
        Set<Id> remittanceIdSet = new Set<Id>();
        Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>();

        for(Remittance__c remittance : remittanceList) {

            remittanceIdSet.add(remittance.Id);
        }

        List<Invoice__c> invoiceList = invoiceSelector.selectByRemittanceId2(remittanceIdSet);

        for(Invoice__c invoice : invoiceList) {

            invoiceMap.put(invoice.RemittanceLkp__c, invoice);
        }

        return invoiceMap;
    }

    // Retrives all orders related to every remittance.
    private List<Order__c> getOrderList(List<Remittance__c> remittanceList) {

        Set<Id> orderIdSet = new Set<Id>();
        List<Order__c> orderList = new List<Order__c>();

        for (Remittance__c remittance : remittanceList) {

            orderIdSet.add(remittance.OrderLkp__c);
        }

        orderList = [SELECT CaseLkp__c FROM Order__c WHERE Id IN :orderIdSet];

        return orderList;
    }

    // Retrives all cases related to every order.
    private Map<Id, Case> getCaseMap(List<Order__c> orderList) {

        CSECaseSelector caseSelector = new CSECaseSelector();

        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
    
        for(Order__c ordem : orderList) {
            caseIdSet.add(ordem.CaseLkp__c);
        }

        List<Case> caseList = caseSelector.selectById(caseIdSet);
        caseMap = new Map<Id, Case>(caseList);

        return caseMap;
    }

    // Retrives quantity of QMs per case.
    private Map<String, Integer> getQmQuantityPerCase(List<Order__c> orderList, Map<Id, Case> caseMap, Map<String, Id> recordMap) {
        
        Map<String, Integer> qmMap = new Map<String, Integer>();
        
        /* Validando parâmetros */
        if((orderList == null) || (caseMap == null) || (recordMap == null)) { return qmMap; }
        
        Set<Id> idSetCase = new Set<Id>();
        for(Order__c ordem : orderList) {

            if(ordem.CaseLkp__c == null) { continue; }

            Case currentCase = caseMap.get(ordem.CaseLkp__c);
            
            if(currentCase == null) { continue; }
            
            if (currentCase.RecordTypeId == recordMap.get('Produto trocado') &&
                currentCase.Type.equals('Quantidades diferentes')) {
                
                idSetCase.add(ordem.CaseLkp__c);
            }
        }

        List<QM__c> qmList = QMDAO.getByCaseId(idSetCase);
        
        if (qmList == null) { return qmMap; }

        /* Levantando QMs distintas */
        for(QM__c qm : qmList) {

            if(qmMap.get(qm.CaseLkp__c) == null) {

                qmMap.put(qm.CaseLkp__c, 0);
            }
        }

        /* Contando numero de QMs por caso */
        for(QM__c qm : qmList) {

            qmMap.put(qm.CaseLkp__c, qmMap.get(qm.CaseLkp__c) + 1);
        }

        return qmMap;
    }
}