/*
    Classe de testes para a classe: DAO_Case
*/

@isTest
public class Teste_DAO_Case{

    static testMethod void teste(){
        Account acc = Teste_Util.newAccount('testAcc');
        
        Order__c ordem = Teste_Util.newOrder(acc.Id);
                
        Remittance__c remessa = Teste_Util.newRemittance(ordem.Id);
        
        Invoice__c nota = Teste_Util.newInvoice(remessa.Id);

        Case caso = Teste_Util.newCase(ordem.Id, nota.Id, acc.Id);
        
        Set<Id> ids = DAO_Case.getOrdersIdInCase();
        ids = DAO_Case.getOrdersIdInCaseLast30DAYS();
        
        //System.assertEquals(pedido.Id, pedidoAux.Id);
        //System.assertEquals(pedido.Name, pedidoAux.Name);
    }
}