public with sharing class CSECaseSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.AccountId,
            Case.InvoiceLkp__c,
            Case.CarrierEmailEml__c,
            Case.SellerEmailEml__c,
            Case.RecordTypeId,
            Case.Status,
            Case.ContactId,
            Case.ClouseReasonTxt__c,
            Case.TaxclassificationTxt__c,
            Case.OwnerId,
            Case.Type,
            Case.OrderLkp__c,
            Case.SinisterTxt__c,
            Case.NewSalesOrder__c,
            Case.CaseNumber,
            Case.CustomIDTxt__c,
            Case.DevolutionOrderTxt__c,
            Case.OrderDevolutionStatusTxt__c,
            Case.NewOrderReplacementTxt__c,
            Case.DeliveryDateInvoiceCreatedDte__c,
            Case.ByPassBln__c,
            Case.DeliveryTxt__c,
            Case.Reason,
            Case.SalesOrderStatusTxt__c,
            Case.DevolutionOrderStatusTxt__c,
            Case.InvoiceCreatedTxt__c,
            Case.ReplacementOrderTxt__c,
            Case.InvoiceReplacementTxt__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Case.sObjectType;
    }
    
    public List<Case> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0} ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet',
            new List<String>{
                getFieldListString(),
                getSObjectName()                     
            }
        );  

        return (List<Case>)Database.query(query);       
    }
    
    public List<Case> selectByInvoice(Id invoiceId) {

        String query = String.format(
            ' SELECT {0} ' + 
            ' FROM {1}' +
            ' WHERE InvoiceLkp__c = :invoiceId',
            new List<String>{
                getFieldListString(),
                getSObjectName()                     
            }
        );  

        return (List<Case>)Database.query(query);       
    }
    
    public List<Case> selectByOrder(Id orderId) {

        String query = String.format(
            ' SELECT {0} ' + 
            ' FROM {1}' +
            ' WHERE OrderLkp__c = :orderId',
            new List<String>{
                getFieldListString(),
                getSObjectName()                     
            }
        );  

        return (List<Case>)Database.query(query);       
    }
}