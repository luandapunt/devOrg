public without sharing class CSECaseBO 
{	
    private Map<Id, List<Attachment>> attachmentMap;
    private Map<Id, String> ownerEmailMap;
    
    //GOLIVEIRA 19/01/2018
    public void setAreaSalesData(List<Case> records){
        List<Id> listIds = new List<Id>();
        List<Id> listAccIds = new List<Id>();
        List<Id> listAvIds = new List<Id>();
        Map<Id, String> mapAccCodes = new Map<Id, String>();
        Map<String, List<AccountAreaSales__c>> mapSalesAreaByAccount = new Map<String, List<AccountAreaSales__c>>();
        for(Case c : records){
            system.debug('account: ' + c.AccountId);
            if(c.AccountId == null || c.AccountAreaSalesLkp__c == null){
                listIds.add(c.Id);
                if(c.AccountId != null) listAccIds.add(c.AccountId);
                if(c.AccountAreaSalesLkp__c != null) listAvIds.add(c.AccountAreaSalesLkp__c);
            }
        }
        
        if(listIds.size() > 0){
            for(Account acc : [SELECT CodeCustomerTxt__c FROM Account WHERE Id IN :listAccIds AND CodeCustomerTxt__c != null]){
                mapAccCodes.put(acc.Id, acc.CodeCustomerTxt__c + '%');
            }
        }
        
        if(listIds.size() > 0){
            Map<Id, AccountAreaSales__c> mapAv = new Map<Id, AccountAreaSales__c>([
                SELECT Id, 
                AccountLkp__c, 
                CustomIdTxt__c,
                CodeSalesOrganizationTxt__c, 
                SellerLkp__c, 
                SellerLkp__r.UserLkp__c 
                //OwnerId 
                FROM AccountAreaSales__c 
                WHERE CustomIdTxt__c != null
                AND (AccountLkp__c IN :listAccIds 
                OR Id IN :listAvIds
                OR CustomIdTxt__c LIKE :mapAccCodes.values())
            ]);
            for(AccountAreaSales__c av : mapAv.values()){
                List<AccountAreaSales__c> listAux = new List<AccountAreaSales__c>();
                if(mapSalesAreaByAccount.containsKey(av.CustomIdTxt__c.substring(0,6))){
                    listAux = mapSalesAreaByAccount.get(av.CustomIdTxt__c.substring(0,6));
                }
                listAux.add(av);
                mapSalesAreaByAccount.put(av.CustomIdTxt__c.substring(0,6), listAux);
            }
            for(Case c : records){
                if(c.AccountId == null && c.AccountAreaSalesLkp__c == null){
                    //c.addError('A conta ou área de vendas devem estar selecionadas');
                }
                else if(c.AccountId == null){
                    c.AccountId = mapAv.get(c.AccountAreaSalesLkp__c).AccountLkp__c;
                    
                }
                else if(c.AccountAreaSalesLkp__c == null && c.SalesOrganizationTxt__c != null && mapAccCodes.containsKey(c.AccountId)){
                    if(mapSalesAreaByAccount.containsKey(mapAccCodes.get(c.AccountId).substring(0,6))){
                        List<AccountAreaSales__c> listAux = mapSalesAreaByAccount.get(mapAccCodes.get(c.AccountId).substring(0,6));
                        for(AccountAreaSales__c av : listAux){
                            if(c.SalesOrganizationTxt__c == av.CodeSalesOrganizationTxt__c)
                                c.AccountAreaSalesLkp__c = av.Id;
                        }
                        if(c.AccountAreaSalesLkp__c == null)
                            c.addError('Esse cliente não possui Área de Vendas para essa Organização, favor revisar');
                        /*if(listAux.size() == 1){
                            c.AccountAreaSalesLkp__c = listAux[0].Id;
                        }
                        else{
                            c.addError('Existe mais de uma Área de Vendas possível para esse cliente, favor selecionar');
                        }
*/
                    }	
                }
                
            }
        }
    }
    
    //RSILVA 10/01/2018
   public void setInvoiceData(List<Case> records){
        List<Id> listIds = new List<Id>();
       List<Id> listIdsO = new List<Id>();
        
        Map<String, Id> recordMap = new Map<String, Id> ();
        
        List<RecordType> recordType = [SELECT Id, Name FROM RecordType where SobjectType = 'Case'];
        for (RecordType rec: recordType) {
            recordMap.put(rec.Name, rec.Id);
        }
        
        for (Case cse: records) {
            
            if(cse.InvoiceLkp__c != null){
                listIds.add(cse.InvoiceLkp__c);   
            }
			if(cse.OrderLkp__c != null){
                listIdsO.add(cse.OrderLkp__c);   
            }
        }
        
        Map<Id, Invoice__c> mapInvoices = new Map<Id, Invoice__c>([SELECT Id,Name,AccountLkp__c,OrderLkp__c,CarrierLkp__c,RemittanceLkp__c,CarrierLkp__r.EmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c  FROM Invoice__c WHERE Id IN :ListIds]);
		Map<Id, Order__c> mapOrders = new Map<Id, Order__c>([SELECT Id,Name,AccountLkp__c,SellerLkp__r.SellerEmailTxt__c,SellerLkp__r.CoordinatorEmailTxt__c  FROM Order__c WHERE Id IN :ListIdsO]);
        for(Case cse : records){
            if(cse.InvoiceLkp__c != null){
                if( mapInvoices.get(cse.InvoiceLkp__c).Id != null && (cse.RecordTypeId == recordMap.get('Reposição')||cse.RecordTypeId == recordMap.get('Produto trocado')||cse.RecordTypeId == recordMap.get('Prorrogação')||cse.RecordTypeId == recordMap.get('Refaturamento')||cse.RecordTypeId == recordMap.get('Sinistro')||cse.RecordTypeId == recordMap.get('Substituição')||cse.RecordTypeId == recordMap.get('Sustação')||cse.RecordTypeId == recordMap.get('Transtorno na entrega')||cse.RecordTypeId == recordMap.get('Extravio de nota fiscal')) ){
                    if(cse.AccountId == null)
                    	cse.AccountId = mapInvoices.get(cse.InvoiceLkp__c).AccountLkp__c;
                    cse.CarrierEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).CarrierLkp__r.EmailTxt__c;
                    cse.SellerEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c;
                }else if ( mapInvoices.get(cse.InvoiceLkp__c).Id != null && cse.RecordTypeId == recordMap.get('Devolução')){
                    if(cse.AccountId == null)
                        cse.AccountId = mapInvoices.get(cse.InvoiceLkp__c).AccountLkp__c;
                    cse.CarrierEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).CarrierLkp__r.EmailTxt__c;
                    cse.SellerEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c;
                    cse.CarrierLkp__c = mapInvoices.get(cse.InvoiceLkp__c).CarrierLkp__c;
                    cse.SellerLkp__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__c;
                    cse.ManagerEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c;
                    cse.CoordinatorSellerEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c;
                }else if ( mapInvoices.get(cse.InvoiceLkp__c).Id != null && cse.RecordTypeId == recordMap.get('Carta de correção')){
                    if(cse.AccountId == null)
                        cse.AccountId = mapInvoices.get(cse.InvoiceLkp__c).AccountLkp__c;
                    cse.CarrierEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).CarrierLkp__r.EmailTxt__c;
                    cse.SellerEmailEml__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c;
                    cse.SellerLkp__c = mapInvoices.get(cse.InvoiceLkp__c).RemittanceLkp__r.OrderLkp__r.SellerLkp__c;
					cse.CarrierLkp__c = mapInvoices.get(cse.InvoiceLkp__c).CarrierLkp__c;
                }
            }if(cse.OrderLkp__c != null){
                if( mapOrders.get(cse.OrderLkp__c).Id != null && (cse.RecordTypeId == recordMap.get('Consulta de pedido')||cse.RecordTypeId == recordMap.get('Alteração de pedido')||cse.RecordTypeId == recordMap.get('Cancelamento de pedido')||cse.RecordTypeId == recordMap.get('Reclamação contra o vendedor')) ){
                    if(cse.AccountId == null)
                        cse.AccountId = mapOrders.get(cse.OrderLkp__c).AccountLkp__c;
                    cse.SellerEmailEml__c = mapOrders.get(cse.OrderLkp__c).SellerLkp__r.SellerEmailTxt__c;
					cse.CoordinatorSellerEmailEml__c = mapOrders.get(cse.OrderLkp__c).SellerLkp__r.CoordinatorEmailTxt__c;
                }
        }
    }
}
  
    
    public void sendEmail(List<Case> caseOldList, List<Case> caseNewList) 
    {
        Map<Id, Case> caseOldMap = new Map<Id, Case>();
        Map<String, Id> recordMap = new Map<String, Id>();
        Map<String, Id> contatoMap = new Map<String, Id>();
        Map<String, Id> templateMap = new Map<String, Id>();
        List<EmailQueue.EmailVO> emailList = new List<EmailQueue.EmailVO>();
        
        // Mapenado caseOld.
        for (Case caseOld : caseOldList) 
        { 
            if(caseOld.Id == null) { continue; }
            caseOldMap.put(caseOld.Id, caseOld); 
        }
        
        // Mapeando record type.
        List<RecordType> recordType = [SELECT Id, Name FROM RecordType where SobjectType = 'Case'];
        for (RecordType rec : recordType) { recordMap.put(rec.Name, rec.Id); }
        //system.debug('MAPEANDORECORDTYPE');
        // Mapeando contato.
        List<Contact> direito = [SELECT Id, Name FROM Contact where Name = 'MailUserCase' limit 1];
        for (Contact contact : direito) { contatoMap.put(contact.Name, contact.Id); }
        
        // Mapeando template de email.
        List<EmailTemplate> emailTemplateList = [SELECT Id, Name FROM EmailTemplate];
        for (EmailTemplate emailTemplate: emailTemplateList) { templateMap.put(emailTemplate.Name, emailTemplate.Id); }
        //system.debug('-MAPEANDOTEMPLATE');
        // Mapeando endereços de email dos proprietários dos casos.
        this.ownerEmailMap = mapOwnerEmails(caseNewList);
        
        // Mapeando anexos.
        this.attachmentMap = mapAttachments(caseNewList);
        
        // Id do contato do cliente.
        Id Contato = contatoMap.get('MailUserCase');
        
        // Lista de endereços de email.
        List<String> emails = new List<String>();
        String templateName;
        List<Attachment> attachmentList = null;
        List<Contact> contactList = new List<Contact>();
        
        for(Case caseNew : caseNewList)
        {
            // Confirmando necessidade do envio de email.
            if(caseNew.NotSendemailBln__c == true) { continue; }		    
            
            // Preparando emails para envio.
            if (caseNew.RecordTypeId == recordMap.get('Abatimento de crédito')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    templateName = '[Caso] Abatimento de crédito - Encerrado';
                    attachmentList = getAttachments(caseNew.Id, null);
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Alteração de pedido')) 
            {//RSilv 22/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                {
                    Set<Id> caseIdSet = new Set<Id>{ caseNew.Id };
                        
                        // Adicionando endereço de email do vendedor.
                        if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email do coordenador do vendedor.
                    if (caseNew.CoordinatorSellerEmailEml__c != null) { emails.add(caseNew.CoordinatorSellerEmailEml__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Alteração de pedido - Encerrado';
                    attachmentList = getAttachments(caseNew.Id, null);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Caminhão retido')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando cliente/vendedor')) 
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailIndicationFml__c != null) { emails.add(caseNew.SellerEmailIndicationFml__c); }
                    
                    // Adicionando endereço de email do coordenador.
                    if (caseNew.EmailCoordinatorIndicationFml__c != null) { emails.add(caseNew.EmailCoordinatorIndicationFml__c); }
                    
                    templateName = '[Caso] Caminhão retido';
                    attachmentList = getAttachments(caseNew.Id, null);
                    contactList = getContacts(caseNew.ContactId);
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando cliente/vendedor/gerente')) 
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailIndicationFml__c != null) { emails.add(caseNew.SellerEmailIndicationFml__c); }
                    
                    // Adicionando endereço de email do coordenador.
                    if (caseNew.EmailCoordinatorIndicationFml__c != null) { emails.add(caseNew.EmailCoordinatorIndicationFml__c); }
                    
                    // Adicionando endereço de email do gerente.
                    if (caseNew.ManagerEmailIndicationFml__c != null) { emails.add(caseNew.ManagerEmailIndicationFml__c); }
                    
                    templateName = '[Caso] Caminhão retido - Gerente';
                    attachmentList = getAttachments(caseNew.Id, null);
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Cancelamento de pedido')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando parecer do setor') && caseNew.Type == 'Cancelamento com remessa') 
                {
                    // Adicionando endereço de email do responsável pelo setor.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                    
                    templateName = '[Caso] Cancelamento de pedido - Aguardando parecer do setor';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.Type == 'Cancelamento com remessa')
                {
                    // Adicionando endereço de email do responsável pelo setor.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                    
                    templateName = '[Caso] Cancelamento de pedido - Encerrado';
                } //RSilv 22/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                else if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.Type == 'Cancelamento sem remessa')
                {
                    templateName = '[Caso] Cancelamento de pedido - Encerrado';
                }
                else { continue; }
                
                // Adicionando endereço de email do vendedor.
                if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                
                // Adicionando endereço de email do coordenador do vendedor.
                if (caseNew.CoordinatorSellerEmailEml__c != null) { emails.add(caseNew.CoordinatorSellerEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Carta de correção')) 
            {//RSilv 22/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                //System.debug('>>> caseOldMap.get(caseNew.Id): ' + caseOldMap.get(caseNew.Id) + ' caseNew.Reason: ' + caseNew.Reason + ' caseNew: ' + caseNew);
                if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando parecer do setor')&& caseNew.Reason == 'Endereço de entrega' )
                { 
                    Set<Id> caseIdSet = new Set<Id>{ caseNew.Id };
                        
                        // Adicionando endereço de email do vendedor.
                        if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email do responsável fiscal.
                    if (caseNew.EmailResponsibleTaxEml__c != null) { emails.add(caseNew.EmailResponsibleTaxEml__c); }
                    
                    // Adicionando endereço de email do responsável da logística.
                    if (caseNew.EmailResponsibleLogisticEml__c != null) { emails.add(caseNew.EmailResponsibleLogisticEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    system.debug(caseNew.CarrierEmailEml__c);
                    templateName = '[Caso] Carta de correção - Aguardando parecer do setor';
                    attachmentList = getAttachments(caseNew.Id, null);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Devolução')) 
            {   //RSILV 27/12/17 - aDICIONADO '&& caseOldMap.get(caseNew.Id) != null' PARA NÃO DISPARAR EMAIL INCORRETO AO CRIAR CASO.
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.DeliveryTxt__c == 'Pós' && caseOldMap.get(caseNew.Id) != null)
                {
                    templateName = '[Caso] Devolução 2 - Aguardando nota fiscal devolução';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de devolução criada') && caseNew.DeliveryTxt__c == 'Pós'&& caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    templateName = '[Caso] Devolução 2 - Ordem de devolução criada';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.DeliveryTxt__c == 'Pós'&& caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    templateName = '[Caso] Devolução 2 - Encerrado';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno vendedor') && caseNew.Type == 'Total' && caseNew.DeliveryTxt__c == 'Ato')
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Devolução - Ato - Agurdando retorno vendedor';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.DeliveryTxt__c == 'Ato' && (caseNew.ClouseReasonTxt__c == 'Revertido vendedor' || caseNew.ClouseReasonTxt__c == 'Revertido analista') && caseNew.Type == 'Total'&& caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                        templateName = '[Caso] Devolução - Ato - Revertido vendedor';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de devolução simbólica criada') && caseNew.DeliveryTxt__c == 'Ato' && caseNew.Type == 'Total' && caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Devolução - Ato - Ordem de devolução criada';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de devolução criada') && caseNew.DeliveryTxt__c == 'Ato' && caseNew.Type == 'Total' && caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Devolução - Ato - Ordem de devolução criada';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Revertido vendedor') && caseNew.DeliveryTxt__c == 'Ato' && caseNew.Type == 'Parcial' && caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Devolução 3 - Revertido vendedor';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno vendedor') && caseNew.DeliveryTxt__c == 'Ato' && caseNew.Type == 'Parcial' && caseOldMap.get(caseNew.Id) != null)
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Devolução - Ato Parcial - Aguardando retorno vendedor';
                    attachmentList = getAttachments(caseNew.Id, 'ITM');
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno vendedor') && caseNew.DeliveryTxt__c == 'Pós')
                {
                    // Adicionando endereço de email do gerente do vendedor.
                    if (caseNew.ManagerEmailEml__c != null) { emails.add(caseNew.ManagerEmailEml__c); }
                    
                    templateName = '[Caso] Devolução - Totalv Pós - Aguardando retorno vendedor';
                    attachmentList = getAttachments(caseNew.Id, 'Comunicação');
                }
                else { continue; }
                
                // Adicionando endereço de email do vendedor.
                if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                
                // Adicionando endereço de email do coordenador do vendedor.
                if (caseNew.CoordinatorSellerEmailEml__c != null) { emails.add(caseNew.CoordinatorSellerEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Extravio de nota fiscal')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora'))
                {
                    templateName = '[Caso] Extravio de nota fiscal - Aguardando retorno da transportadora';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado'))
                {
                    // Adicionando endereço do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    templateName = '[Caso] Extravio de nota fiscal - Encerrado';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de venda criada'))
                {
                    templateName = '[Caso] Extravio de nota fiscal - QM em andamento';
                    attachmentList = getAttachments(caseNew.Id, null);
                }
                else { continue; }
                
                // Adicionando endereço de email do responsável pelo setor
                if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                
                // Adicionando endereço de email da transportadora.
                if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            }
            else if (caseNew.RecordTypeId == recordMap.get('Indicação BNDES')) 
            {  
                //RSilv 26/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                { 
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email alternativo da conta.
                    if (caseNew.EmailAccountAlternativeTxt__c != null) { emails.add(caseNew.EmailAccountAlternativeTxt__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Indicação BNDES';
                    attachmentList = getAttachments(caseNew.Id, null);
                    contactList = getContacts(caseNew.ContactId);
                    
                } 
                //RSilv 26/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                else if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Cancelado')) 
                {
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Indicação BNDES - Cancelado';
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            }
            else if (caseNew.RecordTypeId == recordMap.get('Indicação de vendedor')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Em análise')) 
                {
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Indicação de vendedor - Em análise';
                    contactList = getContacts(caseNew.ContactId);           		    
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Negociação de débito')) 
            {            
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                {        
                    templateName = '[Caso] Negociação de débito';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Portal neogrid')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.IsRegisterNeogridTxt__c == 'Não')
                {
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Portal NeoGrid - sem cadastro';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.IsRegisterNeogridTxt__c == 'Sim')
                {
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Portal NeoGrid - com cadastro';
                }
                else { continue; }
                
                // Adicionando endereço de email alternativo.
                if (caseNew.EmailAccountAlternativeTxt__c != null) { emails.add(caseNew.EmailAccountAlternativeTxt__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Produto trocado'))
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora') && caseNew.Type == 'Quantidades diferentes')
                { //System.debug (caseNew.CarrierEmailEml__c);//RSILV 1
                 // Adicionando endereço de email da transportadora.
                 if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                 
                 templateName = '[Caso] Produto trocado - Aguardando retorno da transportadora';
                } 
                
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora') && caseNew.Type == 'Quantidades iguais')
                {
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Produto trocado - Aguardando retorno transportadora';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.Type == 'Quantidades iguais')
                {
                    templateName = '[Caso] Produto trocado - Aguardando nota fiscal do cliente';
                    contactList = getContacts(caseNew.ContactId);
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.Type == 'Quantidades diferentes')
                {
                    templateName = '[Caso] Produto trocado - Aguardando nota fiscal do cliente - Qtd diferente';
                    contactList = getContacts(caseNew.ContactId);
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de substituição criada') && caseNew.Type == 'Quantidades iguais')
                {
                    // Adicionando endereço de email do responsável pelo setor.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                    
                    templateName = '[Caso] Produto trocado - Ordem de substituição criada';
                }
                else { continue; }
                
                // Adicionando endereço de email do vendedor.
                if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Prorrogação')) 
            {  //RSilv 28/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'QM em andamento') && caseNew.Type != 'Negociação comercial')
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email do coordenador do vendedor.				
                    emails.add('atendimento.financeiro@mexichem.com'); 
                    //emails.add('guilherme.oliveira@harpiacloud.com.br'); 
                    
                    templateName = '[Caso] Prorrogação - QM em andamento';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                    contactList = getContacts(caseNew.ContactId);
                } 
                else if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.Type != 'Negociação comercial')
                {
                    templateName = '[Caso] Prorrogação - Encerrado';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                    contactList = getContacts(caseNew.ContactId);
                } 
                else if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Cancelado') && caseNew.ClouseReasonTxt__c == 'Reclamação não procede')
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email do coordenador do vendedor.
                    if (caseNew.CoordinatorSellerEmailEml__c != null) { emails.add(caseNew.CoordinatorSellerEmailEml__c); }
                    
                    templateName = '[Caso] Prorrogação - Encerrado negociação comercial';
                }
                else { continue; }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Prorrogação por fluxo de caixa')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                {
                    templateName = '[Caso] Prorrogação por fluxo de caixa';
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Reclamação')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Improcedente') 
                {
                    // Adicionando endereço de email do responsável técnico.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    // Adicionando endereço de email do proprietário do caso.
                    emails.add(this.ownerEmailMap.get(caseNew.OwnerId));
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Reclamação - Encerrado - Improcedente';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando parecer de campo')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    // Adicionando endereço de email do proprietário do caso.
                    emails.add(this.ownerEmailMap.get(caseNew.OwnerId));
                    
                    templateName = '[Caso] Reclamação - Aguardando parecer do campo';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando amostra')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    // Adicionando endereço de email do proprietário do caso.
                    emails.add(this.ownerEmailMap.get(caseNew.OwnerId));
                    
                    templateName = '[Caso] Reclamação - Aguardando amostra';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Enviado para laboratório')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    // Adicionando endereço de email do proprietário do caso.
                    emails.add(this.ownerEmailMap.get(caseNew.OwnerId));
                    
                    // Adicionando endereço de email do laboratório.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.LabEmailEml__c); }
                    
                    templateName = '[Caso] Reclamação - Enviado para laboratório';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Análise amostra em andamento')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    // Adicionando endereço de email do proprietário do caso.
                    emails.add(this.ownerEmailMap.get(caseNew.OwnerId));
                    
                    templateName = '[Caso] Reclamação - Análise amostra em andamento';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Análise amostra encerrada')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    templateName = '[Caso] Reclamação - Análise amostra encerrada';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando documentos do campo')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    templateName = '[Caso] Reclamação - Aguardando documentos do campo';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando cadastro do cliente')) 
                {
                    // Adicionando endereço de email do técnico responsável
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.EmailTecnicianResponsibleFml__c); }
                    
                    templateName = '[Caso] Reclamação - Aguardando cadastro do cliente';
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Reclamação contra o vendedor')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado'))
                {
                    Set<Id> caseIdSet = new Set<Id>{ caseNew.Id };
                        
                        // Adicionando endereço de email do vendedor.
                        if (caseNew.SellerEmailIndicationFml__c != null) { emails.add(caseNew.SellerEmailIndicationFml__c); }
                    
                    // Adicionando endereço de email do coordenador.
                    if (caseNew.EmailCoordinatorIndicationFml__c != null) { emails.add(caseNew.EmailCoordinatorIndicationFml__c); }
                    
                    // Adicionando endereço de email do gerente.
                    if (caseNew.ManagerEmailIndicationFml__c != null) { emails.add(caseNew.ManagerEmailIndicationFml__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Reclamação contra o vendedor';
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Refaturamento')) 
            {//RSilv 22/12/2017 - ALteração método de checkStatus para checkStatusFalseOnInsert.
                if (checkStatusFalseOnInsert(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução'))
                {
                    Set<Id> caseIdSet = new Set<Id>{ caseNew.Id };
                        
                        // Adicionando endereço de email do vendedor.
                        if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Refaturamento - Aguardando nota fiscal de devolução';
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Reposição')) 
            {  
                //RSilv 22/12/2017 - Adicionando no método de checkStatus '&& caseOldMap.get(caseNew.Id) != null' para todos status exceto aguardando retorno trasportadora.
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Cancelado') && caseNew.ClouseReasonTxt__c == 'Reclamação não procede' && caseNew.Type == 'Volume' && caseOldMap.get(caseNew.Id) != null) 
                {
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição-Reprovada reposição';
                    attachmentList = getAttachments(caseNew.Id, 'Comprovante');
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Cancelado') && caseNew.ClouseReasonTxt__c == 'Reposição reprovada' && caseNew.Type == 'Item' && caseOldMap.get(caseNew.Id) != null) 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição 2 - Reposição reprovada';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.Type  == 'Volume' && caseOldMap.get(caseNew.Id) != null && caseOldMap.get(caseNew.Id) != null)
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição-Aguardando nota fiscal de devolução';
                    attachmentList = getAttachments(caseNew.Id, 'ITM');
                    
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.Reason == 'Produto Faltante' ) 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição- Produto faltante - Aguardando nota fiscal de devolução';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando nota fiscal de devolução') && caseNew.Reason != 'Produto Faltante' && caseOldMap.get(caseNew.Id) != null) 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição 2 - Aguardando nota fiscal de devolução';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de reposição criada') && caseNew.Type == 'Volume' && caseOldMap.get(caseNew.Id) != null) 
                {
                    templateName = '[Caso] Reposição-Ordem de reposição criada';
                    
                    // Adicionando endereço de email do setor responsável.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de reposição criada') && caseNew.Type == 'Item' && caseOldMap.get(caseNew.Id) != null) 
                {
                    templateName = '[Caso] Reposição 2 - Ordem de reposição criada';                
                    
                    // Adicionando endereço de email do setor responsável.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora') && caseNew.Type == 'Volume') 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição-Aguardando retorno transportadora';
                    
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Em análise') && caseNew.Type == 'Volume' && caseOldMap.get(caseNew.Id) != null) 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição-Em análise';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Em análise') && caseNew.Type == 'Item' && caseOldMap.get(caseNew.Id) != null) 
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição 2 - Em análise';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Nota fiscal entregue' && caseNew.Type == 'Volume' && caseOldMap.get(caseNew.Id) != null)
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição - Encerrado - Reposição efetuada';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Crédito liberado' && caseNew.Type == 'Item' && caseOldMap.get(caseNew.Id) != null)
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição 2 - Encerrado Crédito Liberado';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Nota fiscal entregue' && caseNew.Type == 'Item' && caseOldMap.get(caseNew.Id) != null)
                { 
                    contactList = getContacts(caseNew.ContactId);
                    templateName = '[Caso] Reposição - Encerrado - Reposição efetuada';                
                } //RSILV 26/12/17 ALTERADO DE IF PARA ELSE IF
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Crédito liberado' && caseNew.Type == 'Volume' && caseOldMap.get(caseNew.Id) != null)
                { 
                    templateName = '[Caso] Reposição-Encerrado devolução crédito liberado';
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
                
                // Adicionando endereço de email do vendedor.
                if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            }    		    
            else if (caseNew.RecordTypeId == recordMap.get('Sinistro')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportes')) 
                {
                    templateName = '[Caso] Sinistro - Parcial - Aguardando retorno transportes';
                }
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.SinisterTxt__c == 'Total')
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Sinistro total - Encerrado';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.SinisterTxt__c == 'Parcial')
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Sinistro parcial - Encerrado';
                }
                else { continue; }
                
                // Adicionando endereço de email do responsável pelo setor
                if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Solicitação de boleto')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado')) 
                {
                    // Adicionando endereço de email do vendedor.
                    if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                    
                    templateName = '[Caso] Solicitação de boletos';
                    attachmentList = getAttachments(caseNew.Id, null);
                    contactList = getContacts(caseNew.ContactId);
                }
                else { continue; }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Substituição')) 
            {     
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora') && caseNew.DamageTypeTxt__c == 'Transportadora')
                {
                    // Adicionando endereço de email da transportadora
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    templateName = '[Caso] Substituição - Aguardando retorno transportadora';
                    contactList = getContacts(caseNew.ContactId);
                } //RSILV 26/12/17 Alterado de if para else if
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Encerrado') && caseNew.ClouseReasonTxt__c == 'Reclamação procede - valor baixo')
                {
                    // Adicionando endereço de email do coordenador do vendedor.
                    if (caseNew.CoordinatorSellerEmailEml__c != null) { emails.add(caseNew.CoordinatorSellerEmailEml__c); }
                    
                    templateName = '[Caso] Substituição - Encerrado reclamação procede - valor baixo';
                } 
                else if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Ordem de substituição criada')) 
                {
                    // Adicionando endereço de email do responsável pelo setor.
                    if (caseNew.SectorEmailEml__c != null) { emails.add(caseNew.SectorEmailEml__c); }
                    
                    templateName = '[Caso] Produto trocado - Ordem de substituição criada';
                }
                else { continue; }
                
                // Adicionando endereço de email do vendedor.
                if (caseNew.SellerEmailEml__c != null) { emails.add(caseNew.SellerEmailEml__c); }
                
                // Adicionando endereço de emails alternativos.
                if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
            } 
            else if (caseNew.RecordTypeId == recordMap.get('Sustação')) 
            {
                if (checkStatus(caseOldMap.get(caseNew.Id), caseNew, 'Aguardando retorno transportadora')) 
                {
                    // Adicionando endereço de email da transportadora.
                    if (caseNew.CarrierEmailEml__c != null) { emails.add(caseNew.CarrierEmailEml__c); }
                    
                    // Adicionando endereço de emails alternativos.
                    if (caseNew.AlternativeEmail1Eml__c != null) { emails.add(caseNew.AlternativeEmail1Eml__c); }
                    if (caseNew.AlternativeEmail2Eml__c != null) { emails.add(caseNew.AlternativeEmail2Eml__c); }
                    
                    templateName = '[Caso] Sustação - Aguardando retorno transportadora';
                }
                else { continue; }
            }
            else { continue; }
            
            // Adicionando email à lista de envio.
            system.debug('>>>> enviar email automático');
            EmailQueue.EmailVO email = new EmailQueue.EmailVO();
            email.templateId = templateMap.get(templateName);
            email.caseId = caseNew.Id;
            email.senderId = (contactList == null || contactList.isEmpty()) ? Contato : contactList[0].Id;
            email.emails = emails;
            email.attachments = attachmentList;
            email.ownerId = caseNew.OwnerId;
            
            system.debug('>>>>>email automático: '+email);
            
            emailList.add(email);
        }
        
        // Enviando emails assíncronamente.
        System.enqueueJob(new EmailQueue(emailList));
    }
    
    public void setInitialStatusReposicao(List<Case> records) {
        
        Map<String, Id> recordMap = new Map<String, Id> ();
        
        List<RecordType> recordType = [SELECT Id, Name FROM RecordType where SobjectType = 'Case'];
        for (RecordType rec: recordType) {
            recordMap.put(rec.Name, rec.Id);
        }
        
        for (Case cse: records) {
            
            if (cse.RecordTypeId == recordMap.get('Reposição') && cse.Reason != 'Produto faltante') {
                
                if (cse.Type == 'Item') {
                    
                    cse.Status = 'Aberto';
                    
                } else if (cse.Type == 'Volume' && cse.Reason != 'Produto faltante') {
                    
                    cse.Status = 'Aguardando retorno transportadora';
                    
                } //else if (cse.Type == 'Volume' && cse.Reason != 'Produto faltante' ){
                
                //cse.Status = 'Aguardando retorno transportadora'; 
                
                //}
            }
        }
    }
    
    public void setEntitlement(List<Case> records) {
        
        Map<String, Id> recordMap = new Map<String, Id> ();
        
        List<RecordType> recordType = [SELECT Id, Name FROM RecordType where SobjectType = 'Case'];
        for (RecordType rec: recordType) {
            recordMap.put(rec.Name, rec.Id);
        }
        
        Map<String, Id> direitodMap = new Map<String, Id> ();
        
        List<Entitlement> direito = [SELECT Id, Name FROM Entitlement];
        for (Entitlement dir: direito) {
            direitodMap.put(dir.Name, dir.Id);
        }
        
        for (Case cse: records) {
            
            if (cse.RecordTypeId == recordMap.get('Reposição')) {
                
                cse.EntitlementId = direitodMap.get('Reposição');
                
            } else if (cse.RecordTypeId == recordMap.get('Substituição')) {
                
                cse.EntitlementId = direitodMap.get('Substituição');
                
            } else if (cse.RecordTypeId == recordMap.get('Devolução')) {
                
                cse.EntitlementId = direitodMap.get('Devolução');
                
            } else if (cse.RecordTypeId == recordMap.get('Consulta de pedido')) {
                
                cse.EntitlementId = direitodMap.get('Consulta de pedido');
                
            } else if (cse.RecordTypeId == recordMap.get('Extravio de nota fiscal')) {
                
                cse.EntitlementId = direitodMap.get('Extravio de nota fiscal');
                
            } else if (cse.RecordTypeId == recordMap.get('Sinistro')) {
                
                cse.EntitlementId = direitodMap.get('Sinistro');
                
            } else if (cse.RecordTypeId == recordMap.get('Sustação')) {
                
                cse.EntitlementId = direitodMap.get('Sustação');
                
            } else if (cse.RecordTypeId == recordMap.get('Refaturamento')) {
                
                cse.EntitlementId = direitodMap.get('Refaturamento');
                
            } else if (cse.RecordTypeId == recordMap.get('Carta de correção')) {
                
                cse.EntitlementId = direitodMap.get('Carta de correção');
                
            } else if (cse.RecordTypeId == recordMap.get('Alteração de pedido')) {
                
                cse.EntitlementId = direitodMap.get('Alteração de pedido');
                
            } else if (cse.RecordTypeId == recordMap.get('Indicação de vendedor')) {
                
                cse.EntitlementId = direitodMap.get('Indicação de vendedor');
                
            } else if (cse.RecordTypeId == recordMap.get('Indicação BNDES')) {
                
                cse.EntitlementId = direitodMap.get('Indicação de BNDES');
                
            } else if (cse.RecordTypeId == recordMap.get('Reclamação')) {
                
                cse.EntitlementId = direitodMap.get('Reclamação');
                
            } else if (cse.RecordTypeId == recordMap.get('Dúvida técnica')) {
                
                cse.EntitlementId = direitodMap.get('Dúvida técnica');
                
            } else if (cse.RecordTypeId == recordMap.get('Caminhão retido')) {
                
                cse.EntitlementId = direitodMap.get('Caminhão retido');
                
            } else if (cse.RecordTypeId == recordMap.get('Dúvidas tributárias')) {
                
                cse.EntitlementId = direitodMap.get('Dúvidas tributárias');
                
            } else if (cse.RecordTypeId == recordMap.get('Solicitação de boleto')) {
                
                cse.EntitlementId = direitodMap.get('Solicitação de boleto');
                
            } else if (cse.RecordTypeId == recordMap.get('Prorrogação por fluxo de caixa')) {
                
                cse.EntitlementId = direitodMap.get('Prorrogação por fluxo de caixa');
                
            } else if (cse.RecordTypeId == recordMap.get('Abatimento de crédito')) {
                
                cse.EntitlementId = direitodMap.get('Abatimento de crédito');
                
            } else if (cse.RecordTypeId == recordMap.get('Negociação de débito')) {
                
                cse.EntitlementId = direitodMap.get('Negociação de débito');
                
            } else if (cse.RecordTypeId == recordMap.get('Portal neogrid')) {
                
                cse.EntitlementId = direitodMap.get('Portal neogrid');
                
            } else if (cse.RecordTypeId == recordMap.get('Produto trocado')) {
                
                cse.EntitlementId = direitodMap.get('Produto trocado');
            }
        }
    }
    
    public void setExternalId(Set<Id> caseIdSet) {
        CSECaseSelector caseSelector = new CSECaseSelector();
        List<Case> caseList = caseSelector.selectById(caseIdSet);
        
        for (Case cse: caseList) {
            cse.CustomIDTxt__c = cse.CaseNumber;
            //System.debug('Case num: ' + StringUtil.leftTrim(cse.CaseNumber));
        }
        update caseList;
    }
    //RSilv 22/12/2017 - Replicado método checkStatus tratando insert null. 
    private Boolean checkStatusFalseOnInsert(Case caseOld, Case caseNew, string status)
    {
        if(caseOld == null)
        {
            return false;
        }
        
        if(!caseOld.Status.equals(status) && caseNew.Status.equals(status))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    private Boolean checkStatus(Case caseOld, Case caseNew, string status)
    {
        if(caseOld == null)
        {
            return true;
        }
        
        if(!caseOld.Status.equals(status) && caseNew.Status.equals(status))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    private Map<Id, List<Attachment>> mapAttachments(List<Case> caseNewList)
    {
        // Criando set com ids dos casos.
        Set<Id> caseIdSet = new Set<Id>();
        
        for(Case caseNew : caseNewList)
        {
            caseIdSet.add(caseNew.Id);
        }
        
        // Recuperando od anexos dos casos.
        List<Attachment> attachmentList = new CSEAttachmentSelector().selectByCase(caseIdSet);
        
        // Mapeando os anexos aos ids dos casos
        Map<Id, List<Attachment>> attachmentMap = new Map<Id, List<Attachment>>();
        
        for (Attachment attachment : attachmentList)
        {
            // Verificando se a lista já existe no mapa.
            if(attachmentMap.get(attachment.ParentId) == null)
            {
                attachmentMap.put(attachment.ParentId, new List<Attachment>());
            }
            
            // Adicionando anexo à respectiva lista.
            attachmentMap.get(attachment.ParentId).add(attachment);
        }
        
        return attachmentMap;
    }
    
    private Map<Id, String> mapOwnerEmails(List<Case> caseNewList)
    {
        Map<Id, String> result = new Map<Id, String>();
        Set<Id> ownerIdSet = new Set<Id>();
        
        for(Case caseNew : caseNewList) 
        { 
            ownerIdSet.add(caseNew.OwnerId);
        }
        
        List<User> userEmailList = [SELECT Id, Email FROM User WHERE Id = : ownerIdSet];
        
        for(User userEmail : userEmailList) 
        {
            result.put(userEmail.Id, userEmail.Email);
        }
        
        return result;
    }
    
    private List<Attachment> getAttachments(Id caseId, string prefix)
    {
        List<Attachment> listAllAttachments = this.attachmentMap.get(caseId);
        List<Attachment> result = new List<Attachment>();
        
        if((listAllAttachments == null) || (listAllAttachments.isEmpty()))
        {
            return new List<Attachment>();
        }
        
        if(prefix == null)
        {
            for (Attachment attachment: listAllAttachments) 
            { 
                result.add(attachment); 
            }
        }
        else
        {
            for (Attachment attachment: listAllAttachments) 
            {
                if (attachment.Name.startsWith('prefix')) 
                { 
                    result.add(attachment); 
                }
            }
        }
        
        return result;
    }
    
    private List<Contact> getContacts(Id contactId)
    {
        List<Contact> result = new CSEContactSelector().selectById(new Set<Id>{ contactId });
        
        return result;
    }
}