global class Batch_QuotaDailyUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts{
    
    private List<Date> getQuarterMonths(Date refDate){
        System.debug(refDate);
        
        List<Date> dateList = new List<Date>();
        Integer quarter = Math.ceil(refDate.month()/3.0).intValue();
        System.debug(quarter);
        
        if(quarter == 1){
            dateList.add(Date.newInstance(refDate.year(), 1, 1));
            dateList.add(Date.newInstance(refDate.year(), 2, 1));
            dateList.add(Date.newInstance(refDate.year(), 3, 1));
        }else if(quarter == 2){
            dateList.add(Date.newInstance(refDate.year(), 4, 1));
            dateList.add(Date.newInstance(refDate.year(), 5, 1));
            dateList.add(Date.newInstance(refDate.year(), 6, 1));           
        }else if(quarter == 3){
            dateList.add(Date.newInstance(refDate.year(), 7, 1));
            dateList.add(Date.newInstance(refDate.year(), 8, 1));
            dateList.add(Date.newInstance(refDate.year(), 9, 1));           
        }else if(quarter == 4){
            dateList.add(Date.newInstance(refDate.year(), 10, 1));
            dateList.add(Date.newInstance(refDate.year(), 11, 1));
            dateList.add(Date.newInstance(refDate.year(), 12, 1));           
        }
        
        return dateList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){       
        return Database.getQueryLocator(
            //'SELECT Id, SellerNumberNmb__c FROM SELLER__C WHERE SellerNumberNmb__c =\'6522\''
            'SELECT Id, SellerNumberNmb__c, UserLkp__c FROM SELLER__c WHERE SellerNumberNmb__c != \'\' AND UserLkp__c != null AND UserLkp__r.IsActive = True'
            //'SELECT Id FROM SELLER__C WHERE SellerNumberNmb__c != \'\' LIMIT 5'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Seller__c> scope){      
        //List<Date> dateList = new List<Date>();
        //dateList.add(Date.newInstance(2016, 9, 1));
        //dateList.add(Date.newInstance(2016, 10, 1));        

		List<Date> dateList = getQuarterMonths(Date.today());
        List<Date> lastQuarterList = getQuarterMonths(Date.today().addMonths(-3));
        List<Date> nextQuarterList = getQuarterMonths(Date.today().addMonths(3));
        
        //List<Date> dateList = getQuarterMonths(Date.newInstance(2016,9,1));
        //List<Date> lastQuarterList = getQuarterMonths(Date.newInstance(2016,9,1).addMonths(-3));
        //List<Date> nextQuarterList = getQuarterMonths(Date.newInstance(2016,9,1).addMonths(3));
        
        System.debug(dateList);
        System.debug(lastQuarterList);
		System.debug(nextQuarterList);
        
        dateList.addAll(lastQuarterList);
        dateList.addAll(nextQuarterList);

        System.debug(dateList);
        
        //System.debug(trimestre);
		//System.debug(trimestre.intValue());
        
        if(!System.Test.isRunningTest()){
            QuotaIntegrationUtils.getQuota(scope, dateList);
        }
    }
    
    global void finish(Database.BatchableContext bc){
    	System.debug('Batch_QuotaDailyUpdate Finalizada');
    }
}