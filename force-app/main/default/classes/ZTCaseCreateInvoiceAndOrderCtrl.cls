@isTest
private class ZTCaseCreateInvoiceAndOrderCtrl
{
    static testMethod void testManipulateCaseCreateInvoiceAndOrder()
    {
    	RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
    	Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
    	insert account;    	
    	
    	Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Seller__c seller = new Seller__c(Name = 'Vendedor', SellerEmailTxt__c = 'vendedor@traportatudo.com.br');
    	insert seller;
        
        Channel__c channel = TestData.createChannel('TES', null); 
        
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(account.Id, channel.Id, null);  
    	
    	Order__c pedido = new Order__c(CustomIDTxt__c = 'abc123', SellerLkp__c = seller.Id);
        pedido.AccountLkp__c = account.Id;
        pedido.AccountAreaSalesLkp__c = salesArea.id;
    	insert pedido;
    	
    	Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id, OrderLkp__c = pedido.Id, AccountLkp__c = account.Id);
    	insert invoice;
    	
    
    	List<ApexRedirectMap__c> redirectMapList = new List<ApexRedirectMap__c>();
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CaseList', UrlSufix__c = '/500/o'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CreateCase', UrlSufix__c = '/500/e?retURL=%2F500%2Fo'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'InvoiceName', UrlSufix__c = 'CF00N55000000iEy3'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'OrderName', UrlSufix__c = 'CF00N55000000iGoF'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'OrderLkpCase', UrlSufix__c = '00N55000000iGoF_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'InvoiceLkpCase', UrlSufix__c = 'CF00N55000000iEy3_lkid'));
    	
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ContactCase', UrlSufix__c = 'cas11'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CoordinatorEmailCase', UrlSufix__c = '00N55000000iZtE'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerNameCase', UrlSufix__c = 'CF00N55000000iGXn'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CategoryCase', UrlSufix__c = '00N55000000ibw0'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierLkpCase', UrlSufix__c = 'CF00N55000000iGXi_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierNameCase', UrlSufix__c = 'CF00N55000000iGXi'));
    	
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerEmail', UrlSufix__c = '00N55000000iNsO'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierEmail', UrlSufix__c = '00N55000000iNvc'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ReasonCase', UrlSufix__c = 'cas6'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ManagerEmailCase', UrlSufix__c = '00N55000000iZzv'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerLkpCase', UrlSufix__c = 'C00N55000000iGXn_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'NatureCase', UrlSufix__c = '00N55000000ibvv'));
    	insert redirectMapList;
    	
    	Case caso = new Case();
		
		PageReference pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	ApexPages.StandardController sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Devolucao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	CaseCreateInvoiceAndOrderCtrl caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doNext();
    	
    	//reposicao
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Reposicao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//subtituicao
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Substituicao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//prorrogacao
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Prorrogacao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//produto trocado
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'ProdutoTrocado' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//extravio de nota fiscal
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'ExtravioNotaFiscal' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//sinistro
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Sinistro' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//sustacao
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Sustacao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//refaturamento
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'Refaturamento' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//carta de correcao
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'CartaCorrecao' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//transtorno na entrega
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'TranstornoNaEntrega' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.invoiceNumber = '02568';
    	caseCreateInvoiceAndOrderCtrl.findInvoice();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	    	
    	//consulta de pedido
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'ConsultaPedido' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.orderNumber = '12345';
    	caseCreateInvoiceAndOrderCtrl.findOrder();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//alteracao de pedido
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'AlteracaoPedido' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.orderNumber = '12345';
    	caseCreateInvoiceAndOrderCtrl.findOrder();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//cancelamento de pedido
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'CancelamentoPedido' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.orderNumber = '12345';
    	caseCreateInvoiceAndOrderCtrl.findOrder();
    	caseCreateInvoiceAndOrderCtrl.doBack();
    	
    	//reclamacao contra o vendedor
    	caso = new Case();
    	pageRef = Page.CaseCreateInvoiceAndOrder;
    	Test.setCurrentPage(pageRef);
    	sc = new ApexPages.StandardController(caso);
    	
    	Apexpages.currentPage().getParameters().put('inConsole', 'no');
    	Apexpages.currentPage().getParameters().put('reason', 'Negociação comercial');
    	Apexpages.currentPage().getParameters().put('def_account_id', String.valueOf(account.Id));	
    	
    	recordType = [Select Id from RecordType where DeveloperName = 'ReclamacaoContraVendedor' and SobjectType = 'Case'];
    	Apexpages.currentPage().getParameters().put('RecordType', String.valueOf(recordType.Id));
    	
    	caseCreateInvoiceAndOrderCtrl = new CaseCreateInvoiceAndOrderCtrl(sc);  	
    	caseCreateInvoiceAndOrderCtrl.orderNumber = '12345';
    	caseCreateInvoiceAndOrderCtrl.findOrder();
    	caseCreateInvoiceAndOrderCtrl.doNext();
    }
}