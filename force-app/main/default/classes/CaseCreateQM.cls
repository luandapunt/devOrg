public with sharing class CaseCreateQM {
        
    @AuraEnabled
    public static Case getcaso(Id caseId) {
        system.debug('caseId'+ caseId);
        Case caso = [
      
            SELECT AccountId,ContactId,InvoiceLkp__c,OrderLkp__c,SellerLkp__c,TecnicianLkp__c,RecordTypeId,Status, CaseNumber,  SinisterTxt__c, DevolutionOrderTxt__c,
            InvoiceLkp__r.Name, InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id, Account.Name,  TecnicianLkp__r.Name, Contact.Name, RecordType.Name
            FROM Case
            WHERE Id = :caseId
        ];
      
       system.debug('caso' + caso);
       return caso;
       
   }
    
    @AuraEnabled
    public static QM__c getqm(Id caseId) {
        system.debug('caseId'+ caseId);
        List<QM__c> qm = [
      
            SELECT Id
            FROM QM__c
            WHERE CaseLkp__c = :caseId
            LIMIT 1
        ];
      
        system.debug('qm'+qm);
        if(qm.size()>0)
       		return qm[0];
        else
            return null;   
       
   }
    
    @AuraEnabled
    public static Order__c getorder(Id caseId) {
        system.debug('caseId'+ caseId);
        List<Order__c> order = [
      
            SELECT Id,OrderTypeTxt__c, Name, SellerLkp__c, SellerLkp__r.Name
            FROM Order__c
            WHERE CaseLkp__c = :caseId
            LIMIT 1
        ];
      
       system.debug('order'+ order);
       if(order.size()>0)
       		return order[0];
        else
            return null;  
       
   }
    
    @AuraEnabled
    public static Order__c getorderdev (String namedev) {
        system.debug('namedev'+ namedev);
        List <Order__c> orderdev = [
      
            SELECT Id, Name
            FROM Order__c
            WHERE Name = :namedev
            LIMIT 1
        ];
      
       system.debug('ordemdevolucao'+ orderdev);
       if(orderdev.size()>0)
       		return orderdev[0];
        else
            return null;
       
   }
    
    @AuraEnabled
    public static CaseItem__c getcaseitem (Id caseId) {
        system.debug('caseId'+ caseId);
       List<CaseItem__c> caseitem = [
      
            SELECT Id, Name
            FROM CaseItem__c
            WHERE CaseMdt__c  = :caseId
            
        ];
      
       system.debug('caseitem'+caseitem);
       if(caseitem.size()>0)
       		return caseitem[0];
        else
            return null;  
   }
    @AuraEnabled
    public static Order__c getorderNRO(String NRO) {
        system.debug('NRO'+ NRO);
        List<Order__c> orderNRO = [
      
            SELECT Id, Name, SellerLkp__c, SellerLkp__r.Name
            FROM Order__c
            WHERE Id = :NRO
            LIMIT 1
        ];
      
       system.debug('orderNRO'+ orderNRO);
       if(orderNRO.size()>0)
       		return orderNRO[0];
        else
            return null;  
       
   }
    
    @AuraEnabled
    public static RecordType getqmrecordtype() {
        List<RecordType> qmrecordtype = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SobjectType = :'QM__c'
        ];
        system.debug('qmrecordtype'+ qmrecordtype);
        return qmrecordtype[0];
    }
    
}