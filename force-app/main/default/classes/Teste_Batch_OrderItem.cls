/*
    Classe de testes para a classe: Batch_OrderItem   
*/

@isTest
public class Teste_Batch_OrderItem {
    
    static testMethod void teste(){
        Account acc = Teste_Util.newAccount('testAcc');
        
        Order__c ordem = Teste_Util.newOrder(acc.Id);
        
        OrderItem__c itemOrdem = Teste_Util.newOrderItem(ordem.Id);
                
        Remittance__c remessa = Teste_Util.newRemittance(ordem.Id);
        
        Invoice__c nota = Teste_Util.newInvoice(remessa.Id);

        Case caso = Teste_Util.newCase(ordem.Id, nota.Id, acc.Id);
        
        Schedule_OrderItem soi = new Schedule_OrderItem();    
        SchedulableContext sc;
        
        Schedule_OrderItem.scheduleJob();
        soi.execute(sc);
    }
}