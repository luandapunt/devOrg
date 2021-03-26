/*
    Classe de testes para a classe: Batch_Invoice   
*/

@isTest
public class Teste_Batch_Invoice{

    static testMethod void teste(){
        Account acc = Teste_Util.newAccount('testAcc');
        
        Order__c ordem = Teste_Util.newOrder(acc.Id);
                
        Remittance__c remessa = Teste_Util.newRemittance(ordem.Id);
        
        Invoice__c nota = Teste_Util.newInvoice(remessa.Id);

        Case caso = Teste_Util.newCase(ordem.Id, nota.Id, acc.Id);
        
        Batch_Invoice ba = new  Batch_Invoice();
        database.executeBatch(ba);
    }
}