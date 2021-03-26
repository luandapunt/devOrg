public class SalesPlanUtil {
    
    public static void processSummarizedRevenue(List<SummarizedRevenue__c> records){
        //Based on a list of SummarizedRevenue__c, updates Sales Planning records
        List<Id> areaSalesIdList = new List<Id>();
        Set<Date> dateSet = new Set<Date>(); 
        
        for(SummarizedRevenue__c s : records){
            areaSalesIdList.add(s.SalesAreaLkp__c);
            dateSet.add(s.DateDt__c);
        }
        
        List<SalesPlanning__c> salesPlanningList = [SELECT Id, Name, AccountAreaSalesLkp__c, CurrentMonthTxt__c, CurrentYearTxt__c
                                                    FROM SALESPLANNING__C WHERE AccountAreaSalesLkp__c IN :areaSalesIdList];

        List<Id> areaSalesWithPlanIdLIst = new List<Id>();
        
        for(SalesPlanning__c s: salesPlanningList){
            areaSalesWithPlanIdList.add(s.AccountAreaSalesLkp__c);
        }

        Map<String, Double> aggResultMap = new Map<String, Double>();
        for(Date d : dateSet){
            AggregateResult[] groupedResults = [SELECT 
                                                SUM(ROBNmb__c) sum, SalesAreaLkp__c 
                                                FROM SUMMARIZEDREVENUE__c 
                                                WHERE SalesAreaLkp__c IN :areaSalesWithPlanIdLIst AND DateDt__c = :d
                                                GROUP BY SalesAreaLkp__c];  
            
            System.debug(groupedResults);
            
            for(AggregateResult agg: groupedResults){
            	String key = String.valueOf(d.month()).leftPad(2, '0') + ' - ' + d.year() + ' - ' + agg.get('SalesAreaLkp__c');
                System.debug('CHAVE A PARTIR DO AGG RESULT: '+key);
                aggResultMap.put(key, (Double)agg.get('sum'));	    
                System.debug('VALOR SUMARIZADO: '+(Double)agg.get('sum'));
            }
        }
        
        for(SalesPlanning__c salesPlan : salesPlanningList){
            String key = salesPlan.CurrentMonthTxt__c + ' - ' + salesPlan.CurrentYearTxt__c + ' - ' + salesPlan.AccountAreaSalesLkp__c;
            System.debug('CHAVE A PARTIR DO PLANEJAMENTO: '+key);
            
            if(aggResultMap.containsKey(key)){
                salesPlan.RevenueNmb__c = aggResultMap.get(key);
                System.debug(salesPlan.Id);
                System.debug('NOVO VALOR REGISTRO: '+salesPlan.RevenueNmb__c);
            }
        }
        
        upsert salesPlanningList;        
    }
}