/*
    Classe de testes para a classe: Batch_RemittanceItem   
*/

@isTest
public class Teste_Batch_RemittanceItem {
    
    static testMethod void teste(){
        Account acc = Teste_Util.newAccount('testAcc');
        
        Order__c ordem = Teste_Util.newOrder(acc.Id);
                
        Remittance__c remessa = Teste_Util.newRemittance(ordem.Id);
        
        RemittanceItem__c itemRemessa = Teste_Util.newRemittanceItem(remessa.Id);
        
        Invoice__c nota = Teste_Util.newInvoice(remessa.Id);

        Case caso = Teste_Util.newCase(ordem.Id, nota.Id, acc.Id);
        
        Schedule_RemittanceItem sri = new Schedule_RemittanceItem();    
        SchedulableContext sc;
        
        Schedule_RemittanceItem.scheduleJob();
        sri.execute(sc);
    }
}