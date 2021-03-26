public class PendingActions {
    public AccountAreaSales__c accAreaSales 	{get;set;}
    public AccountAreaSales__c refAccAreaSales	{get;set;}
	public List<CustomerSurvey__c> pendingCustomerSurveys {get;set;}
    
    public PendingActions(ApexPages.StandardController controller){
       	refAccAreaSales = (AccountAreaSales__c)controller.getRecord();
        this.accAreaSales = [SELECT Id 
                             FROM 	AccountAreaSales__c 
                             WHERE 	Id =: refAccAreaSales.Id];
        
        pendingCustomerSurveys = [SELECT 	Id, Name, LimitDateDte__c, StatusTxt__c, TradeMktSurveyLkp__c, TradeMktSurveyLkp__r.Name 
                                  FROM		CustomerSurvey__c 
                                  WHERE 	AccountAreaSalesLkp__c =: accAreaSales.Id 
                                  AND 		StatusTxt__c = 'Incompleta' 
                                  //AND 		LimitDateDte__c >: system.today()
                                 ];
    }

}