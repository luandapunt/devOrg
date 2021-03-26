/*
    Classe de apoio para classes testes
    Data: 24/01/2017
*/

@isTest
public class Teste_Util{

    public static Account newAccount(String name){
        Account acc = new Account(Name=name);
        acc.SalesOrganizationTxt__c = 'AM01';
        acc.CNPJTxt__c = '44149954000136';
        acc.BillingStreet = 'Rua Test';
        acc.BillingStateCode = 'SC';
        acc.BillingState = 'Santa Catarina';
        acc.BillingCity = 'TestCity';
        acc.BillingCountryCode = 'BR';
        acc.BillingCountry = 'Brasil';
        acc.BillingPostalCode = '04060-120';
        insert acc;
        return acc;
    }
    
    public static Order__c newOrder(id accId){
        Channel__c channel = TestData.createChannel('TES', null); 
        
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(accId, channel.Id, null);
        
        Order__c ordem = new Order__c();
        ordem.OrderDateDte__c = System.today();
        ordem.CustomIDTxt__c = '01';
        ordem.AccountLkp__c = accId;
    
        insert ordem;
        return ordem;
    }
    
    public static OrderItem__c newOrderItem(id ordemId){
        OrderItem__c itemOrdem = new OrderItem__c();
        itemOrdem.OrderMdt__c = ordemId;
        itemOrdem.CustomIDTxt__c = '123456';
        insert itemOrdem;
        return itemOrdem;
    }
    
    public static Remittance__c newRemittance(id ordemId){
        Remittance__c remessa = new Remittance__c();
        remessa.OrderLkp__c = ordemId;
        remessa.CustomIDTxt__c = '01';
        insert remessa;  
        return remessa;
    }
    
    public static RemittanceItem__c newRemittanceItem(id remessaId){
        RemittanceItem__c itemRemessa = new RemittanceItem__c();
        itemRemessa.Name = 'testeItemRemessa';
        itemRemessa.RemittanceMdt__c = remessaId;
        itemRemessa.CustomIDTxt__c = '123456';
        insert itemRemessa;  
        return itemRemessa;
    }
    
    public static Invoice__c newInvoice(Id remessaId){
        Invoice__c nota = new Invoice__c();
        nota.RemittanceLkp__c = remessaId;
        insert nota;
        return nota;
    }
    
    public static Case newCase(Id ordemId, Id notaId){
        Case caso = new Case();
        caso.OrderLkp__c = ordemId;
        caso.InvoiceLkp__c = notaId;
        insert caso;
        return caso;
    }   
    public static Case newCase(Id ordemId, Id notaId, Id accId){
        Case caso = new Case();
        caso.OrderLkp__c = ordemId;
        caso.InvoiceLkp__c = notaId;
        caso.AccountId = accId;
        insert caso;
        return caso;
    }   
}