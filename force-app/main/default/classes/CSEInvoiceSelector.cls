public with sharing class CSEInvoiceSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Invoice__c.Id,
			Invoice__c.Name,
			Invoice__c.CarrierLkp__c,
			Invoice__c.DocumentDateDte__c,
			Invoice__c.RemittanceLkp__c,
			Invoice__c.ShipmentDeliveredFml__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Invoice__c.sObjectType;
	}
	
	public List<Invoice__c> selectById(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0}, OrderLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE Id IN :idSet' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<Invoice__c>)Database.query(query);       
    }
    
    public List<Invoice__c> selectByNumber(String invoiceNumber) {
		
        String query = String.format(
            ' SELECT {0}, OrderLkp__r.Name, CarrierLkp__r.EmailTxt__c, CarrierLkp__r.Name, OrderLkp__r.SellerLkp__r.Id, OrderLkp__r.SellerLkp__r.Name, OrderLkp__r.SellerLkp__r.SellerEmailTxt__c, OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c, OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c ' + 
            ' FROM {1}' +
            ' WHERE Name = :invoiceNumber' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug(query);
        return (List<Invoice__c>)Database.query(query);       
    }
    
    public List<Invoice__c> selectByNumberAndCustomer(String invoiceNumber, String accountId) {
		
		System.debug('**invoice number: ' + invoiceNumber + ' ***accountId: ' + accountId);
		
        String query = String.format(
            ' SELECT {0}, RemittanceLkp__r.OrderLkp__r.Name, RemittanceLkp__r.OrderLkp__c, CarrierLkp__r.EmailTxt__c, CarrierLkp__r.Name, RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Id, RemittanceLkp__r.OrderLkp__r.SellerLkp__r.Name, RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c, RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c, RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c ' + 
            ' FROM {1}' +
            ' WHERE Name = :invoiceNumber and AccountLkp__c = :accountId' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug('*** ' + query);
        return (List<Invoice__c>)Database.query(query);       
    }
    
    public List<Invoice__c> selectByOrderId(Id orderId) {
		
        String query = String.format(
            ' SELECT {0}, CarrierLkp__r.EmailTxt__c, CarrierLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE OrderLkp__c = :orderId' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug(query);
        return (List<Invoice__c>)Database.query(query);       
    }
    
    public List<Invoice__c> selectByRemittanceId(Id remittanceId) {
		
        String query = String.format(
            ' SELECT {0}, CarrierLkp__r.EmailTxt__c, CarrierLkp__r.Name ' + 
            ' FROM {1}' +
            ' WHERE OrderLkp__c = :orderId' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug(query);
        return (List<Invoice__c>)Database.query(query);       
    }
    
    public List<Invoice__c> selectByRemittanceId2(Id remittanceId) {
		
        String query = String.format(
            ' SELECT {0}' + 
            ' FROM {1}' +
            ' WHERE RemittanceLkp__c = :remittanceId' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug(query);
        return (List<Invoice__c>)Database.query(query);       
    }

    public List<Invoice__c> selectByRemittanceId2(Set<Id> remittanceIdList) {
        
        String query = String.format(
            ' SELECT {0}' + 
            ' FROM {1}' +
            ' WHERE RemittanceLkp__c in :remittanceIdList' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        System.debug(query);
        return (List<Invoice__c>)Database.query(query);       
    }
}