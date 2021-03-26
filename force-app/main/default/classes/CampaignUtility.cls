public with sharing class CampaignUtility {
    @AuraEnabled
    public static void executeCampaignBatch(){
        Batch_CampaignCalculation myBatch = new Batch_CampaignCalculation();
		Id batchiD = Database.executeBatch(myBatch, 1);
    }
    
    public static void resetCalculation(Id campaignId){
     
    	List<AccountGoal__c> metas = [SELECT ID FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :campaignId];
        
        for (AccountGoal__c accGoal : metas){
            accGoal.CreatedCreditNote__c = false;
           	accGoal.Status__c = '';
            accGoal.FlexValueNmb__c = 0;
            accGoal.Realized__c = 0;
            accGoal.CalculationBasis__c = 0;
        }
        
        update metas;            
    }
    
    public static void cleanAccountGoals(Id campaignId){
        cleanRealizedResults(campaignId);
    	
        List<AccountGoal__c> metas = [SELECT ID FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :campaignId];
        
        for (AccountGoal__c accGoal : metas){
            accGoal.CalculationBasis__c = 0;
            accGoal.Goal__c = 0;
            accGoal.CreatedCreditNote__c = false;
           	accGoal.Status__c = '';
        }
        
        update metas;        
    }
    
    public static string formatdate(Date d){
        Integer day = d.day();
        Integer month = d.month();
        Integer year = d.year();
        
        return d.year() + '-' + String.valueOf(month).leftPad(2, '0') + '-' + String.valueOf(day).leftPad(2, '0');
    }
    
	public static void cleanRealizedResults(Id campaignId){
    	List<AccountGoal__c> metas = [SELECT ID FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :campaignId];
        
        for (AccountGoal__c accGoal : metas){
            accGoal.Realized__c = 0;
            accGoal.FlexValueNmb__c = 0;
        }
        
        update metas;
    }
    
    public static void deleteCampaignGoals(Id campaignId){
		List<AccountGoal__c> metas = [SELECT ID FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :campaignId];
        
        delete metas;
        
        Campaign__c cmp = [SELECT ID FROM CAMPAIGN__C WHERE ID = :campaignId];
        
        cmp.Active__c = false;
        
        update cmp;
    }
    
    @AuraEnabled
    public static void startCampaign(Id campaignId){
    	orderCalculation(campaignId); 
        
        List<Campaign__c> cmpList = [SELECT Id, Name FROM Campaign__c WHERE Id = :campaignId];
        for(Campaign__c cmp: cmpList){
        	cmp.Active__c = True;   
        }
        update cmpList;
        //generateCampaignGoals(campaignId);
    }
    
    public static void orderCalculation(Id campaignId){
        List<CampaignCalculation__c> listCalc = [SELECT STARTDATE__C, ENDDATE__C FROM CAMPAIGNCALCULATION__C 
                                                 WHERE CAMPAIGNLKP__C = :campaignId ORDER BY STARTDATE__C];
        Integer I = 1;
        for (CampaignCalculation__c calc : listCalc){
        	calc.Position__c = I;
            I++; 
        }
        update listCalc;
    }
    
    @AuraEnabled
    public static void generateCampaignGoals(Id campaignId){       
        List<AccountGoal__c> accountGoals = new List<AccountGoal__c>();
        List<MonthlyGoal__c> monthlyGoals = new List<MonthlyGoal__c>();
        
        Campaign__c cmp= [SELECT Name, 
                          (SELECT StartDate__c, EndDate__c FROM CAMPAIGNCALCULATIONS__R), 
                          (SELECT AccountLkp__r.Id, AccountLkp__r.MainSalesAreaLkp__r.SellerLkp__r.UserLkp__c FROM CAMPAIGNACCOUNTS__R), 
                          (SELECT ID, CampaignIndicatorLkp__c, Percentage__c, CalculationCriteria__c FROM CAMPAIGNMECHANICS__R),
                          (SELECT ID, CampaignCalculationLkp__c, AccountLkp__c, CampaignMechanicsLkp__c FROM ACCOUNTGOALS__R)
                          FROM CAMPAIGN__C WHERE Id = :campaignId];
        
        Map<String, AccountGoal__c> mapCurrentAccGoal = new Map<String, AccountGoal__c>();
        
        for(AccountGoal__c accGoal: cmp.AccountGoals__r){
            String key = accGoal.AccountLkp__c + ' - ' + accGoal.CampaignCalculationLkp__c + ' - ' + accGoal.CampaignMechanicsLkp__c;
            mapCurrentAccGoal.put(key, accGoal);
        }
      
        //System.debug('CampaignAccounts__r = '+cmp.CampaignAccounts__r.size());
        //System.debug('CampaignCalculations__r = '+cmp.CampaignCalculations__r.size());
        //System.debug('CampaignMechanics__r = '+cmp.CampaignMechanics__r.size());
        
        for(CampaignAccount__c cmpAcc : cmp.CampaignAccounts__r){
            for(CampaignCalculation__c cmpCal : cmp.CampaignCalculations__r){
                for(CampaignMechanics__c cmpMec : cmp.CampaignMechanics__r){
					String key = cmpAcc.AccountLkp__r.Id + ' - ' + cmpCal.Id + ' - ' + cmpMec.Id;
                    
                    if (!mapCurrentAccGoal.containsKey(key)){
                        Integer nMonths = cmpCal.StartDate__c.monthsBetween(cmpCal.EndDate__c) + 1; //Adds 1 to consider the starting month 
                        
                        AccountGoal__c accGoalReference = new AccountGoal__c(ExternalIdTxt__c = cmpAcc.AccountLkp__r.Id + ' - ' + cmpCal.Id + ' - ' + cmpMec.Id);
                        
                        for(Integer I = 0 ; I < nMonths; I++){
                            MonthlyGoal__c monGoal = new MonthlyGoal__c();
                            monGoal.CampaignLkp__c = cmp.Id;
                            monGoal.GoalNmb__c = 0;
                            monGoal.RevenueNmb__c = 0;
                            monGoal.BenefitPercentageNmb__c = cmpMec.Percentage__c;
                            monGoal.DescriptionTxt__c = cmpMec.CalculationCriteria__c;
                            monGoal.CampaignMechanicsLkp__c = cmpMec.Id;
                            monGoal.AccountMdt__c = cmpAcc.AccountLkp__c;
                            monGoal.CampaignCalculationLkp__c = cmpCal.Id;
                            monGoal.BenefitRevenueNmb__c = 0;
                            monGoal.AccountGoalMdt__r = accGoalReference;
                            monGoal.MonthNmb__c = cmpCal.StartDate__c.month() + I;
                            monGoal.MonthDte__c = cmpCal.StartDate__c.addMonths(I);
                            monthlyGoals.add(monGoal);
                        }
                        
                        AccountGoal__c accGoal = new AccountGoal__c();
                        accGoal.CampaignLkp__c = cmp.Id;
                        accGoal.BenefitPercentage__c = cmpMec.Percentage__c;
                        accGoal.Description__c = cmpMec.CalculationCriteria__c;
                        accGoal.CampaignMechanicsLkp__c = cmpMec.Id;
                        accGoal.AccountLkp__c = cmpAcc.AccountLkp__c;
                        accGoal.CampaignCalculationLkp__c = cmpCal.Id;
                        accGoal.ExternalIdTxt__c = cmpAcc.AccountLkp__r.Id + ' - ' + cmpCal.Id + ' - ' + cmpMec.Id;
                        accountGoals.add(accGoal);   
                    }
                }
            }
        }
        
        /*List<SObject> lista = new List<SObject>();
        lista.addAll(accountGoals);
        lista.addAll(monthlyGoals);
		for(SObject item : lista){
        	System.debug(item);    
        }
        
        insert lista;*/
        //Database.SaveResult[] results = Database.insert(new SObject[] {accountGoals, monthlyGoals});

        insert accountGoals;
        upsert monthlyGoals;
    }

    public static void computeRealized(Id campaignId, Date refDate){     
        Campaign__c cmp = [SELECT Id, 
                           (SELECT Id, CampaignIndicatorLkp__r.Criteria__c, BenefitCriteriaLkp__r.Criteria__c, PaymentTypeTxt__c from CampaignMechanics__r), 
                           (SELECT Id, StartDate__c, EndDate__c FROM CampaignCalculations__r  WHERE StartDate__c <= :refDate AND EndDate__c >= :refDate),
                           (SELECT AccountMdt__c, CampaignMechanicsLkp__c, RevenueNmb__c, BenefitRevenueNmb__c, CampaignCalculationLkp__c, MonthDte__c, AccountGoalMdt__c,
                            CampaignMechanicsLkp__r.BenefitCriteriaLkp__c, GoalNmb__c, CampaignMechanicsLkp__r.PaymentTypeTxt__c FROM MonthlyGoals__r
                            WHERE CampaignCalculationLkp__r.StartDate__c <= :refDate AND CampaignCalculationLkp__r.EndDate__c >= :refDate) 
                           FROM CAMPAIGN__C WHERE Id = :campaignId];
        
        Map<String, MonthlyGoal__c> mapMonGoal = new Map<String, MonthlyGoal__c>();
       
        for(MonthlyGoal__c monGoal : cmp.MonthlyGoals__r){
        	mapMonGoal.put(monGoal.AccountMdt__c+' - '+monGoal.CampaignMechanicsLkp__c+' - '+monGoal.MonthDte__c, monGoal);	    
        }
       
        System.debug('cmp.MonthlyGoals__r.size() = '+cmp.MonthlyGoals__r.size());
        System.debug('cmp.CampaignCalculations__r.size() = '+cmp.CampaignCalculations__r.size());
        System.debug('cmp.CampaignMechanics__r.size() = '+cmp.CampaignMechanics__r.size());
       
        Map<Id, CampaignMechanics__c> mapMechanics = new Map<Id, CampaignMechanics__c>();
        for(CampaignMechanics__c cmpMech : cmp.CampaignMechanics__r){
            mapMechanics.put(cmpMech.CampaignIndicatorLkp__c, cmpMech);
        }

        List<Date> listDate = new List<Date>();
        for(CampaignCalculation__c cmpCalc : cmp.CampaignCalculations__r){
            Integer nMonths = cmpCalc.StartDate__c.monthsBetween(cmpCalc.EndDate__c) + 1; //Adds 1 to consider the starting month
            for(Integer I = 0 ; I < nMonths; I++){
                listDate.add(cmpCalc.StartDate__c.addMonths(I));
            }            
        }
        System.debug(listDate);
        
        for(CampaignMechanics__c cmpMech : cmp.CampaignMechanics__r){
            for(Date dte : listDate){
                String criteria = cmpMech.CampaignIndicatorLkp__r.Criteria__C;
                List<String> filter = new List<String>();
                filter.add(formatDate(dte));
                filter.add(formatDate(dte));
                String criteriaSQL = String.format(criteria, filter); System.debug('Criteria SQL: '+criteriaSQL);
                                
                AggregateResult[] groupedResults = Database.query(criteriaSQL); System.debug(groupedResults);   
                
                for(AggregateResult agg : groupedResults){
                    String key = agg.get('Id')+' - '+cmpMech.Id+' - '+dte;
                    if(mapMonGoal.containsKey(key)){
                        mapMonGoal.get(key).RevenueNmb__c = (Double)agg.get('expr0');  System.debug('Critério Sumarização Apurado: '+(Double)agg.get('expr0')); 
                    }
                }
            }
        }
        
        for(CampaignMechanics__c cmpMech : cmp.CampaignMechanics__r){
            //Atualiza o valor de base de cálculo
            if(cmpMech.PaymentTypeTxt__c == 'FATU' && cmpMech.BenefitCriteriaLkp__r.Criteria__c != null){
                for(Date dte: listDate){
                    String criteria = cmpMech.CampaignIndicatorLkp__r.Criteria__C;
                    List<String> filter = new List<String>();
                    filter.add(formatDate(dte));
                    filter.add(formatDate(dte));
                    String criteriaSQL = String.format(cmpMech.BenefitCriteriaLkp__r.Criteria__c, filter); System.debug('Benefit Criteria SQL: '+criteriaSQL);
                    
                    AggregateResult[] groupedPayments = Database.query(criteriaSQL); 
                    for(AggregateResult agg : groupedPayments){
                        String key = agg.get('Id')+' - '+cmpMech.Id+' - '+dte;
                        if(mapMonGoal.containsKey(key)){
                            mapMonGoal.get(key).BenefitRevenueNmb__c = (Double)agg.get('expr0');
                            System.debug('Base de Cálculo Apurada: '+(Double)agg.get('expr0'));
                        }
                    }
                }             
            }else if(cmpMech.PaymentTypeTxt__c == 'META'){
                for(MonthlyGoal__c monGoal : cmp.MonthlyGoals__r){
                    if(monGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'META'){
                        String monGoalKey = monGoal.AccountMdt__c + ' - ' + monGoal.CampaignMechanicsLkp__c + ' - ' + monGoal.MonthDte__c;
                        Id benefitId = monGoal.CampaignMechanicsLkp__r.BenefitCriteriaLkp__c;
                        if(mapMechanics.containsKey(benefitId)){
                            CampaignMechanics__c cmpMechAux = mapMechanics.get(benefitId);
                            String benefitGoalKey = monGoal.AccountMdt__c + ' - ' + cmpMechAux.Id + ' - ' + monGoal.MonthDte__c;
                            if(mapMonGoal.containsKey(benefitGoalKey)){
                                System.debug('Achou a meta do benefício: '+benefitGoalKey);   
                                MonthlyGoal__c monGoalAux = mapMonGoal.get(benefitGoalKey);
                                System.debug('Meta: '+ monGoalAux.GoalNmb__c);  
                                mapMonGoal.get(monGoalKey).BenefitRevenueNmb__c = mapMonGoal.get(benefitGoalKey).GoalNmb__c;
                            }else{
                                System.debug('Nao achou '+benefitGoalKey+' no mapAccGoal');
                                System.debug('Meta: '+ mapMonGoal.get(monGoalKey).GoalNmb__c);  
                                mapMonGoal.get(monGoalKey).BenefitRevenueNmb__c = mapMonGoal.get(monGoalKey).GoalNmb__c;
                            }
                        }else{
                            System.debug('Nao achou '+benefitId+' no mapMechanics');
                            System.debug('Meta: '+ mapMonGoal.get(monGoalKey).GoalNmb__c);
                            mapMonGoal.get(monGoalKey).BenefitRevenueNmb__c = mapMonGoal.get(monGoalKey).GoalNmb__c;                       
                        }                        
                    }
                }               
            }
        }
        
        /*
        for(Date dte : listDate){
            for(CampaignMechanics__c cmpMech : cmp.CampaignMechanics__r){
                
                String criteria = cmpMech.CampaignIndicatorLkp__r.Criteria__C;
                List<String> filter = new List<String>();
                filter.add(formatDate(dte));
                filter.add(formatDate(dte));
                String criteriaSQL = String.format(criteria, filter);
                
                System.debug('Criteria SQL: '+criteriaSQL);
                
        		AggregateResult[] groupedResults = Database.query(criteriaSQL);   
                
                System.debug(groupedResults);

                for(AggregateResult agg : groupedResults){
                    String key = agg.get('Id')+' - '+cmpMech.Id+' - '+dte;
                    if(mapMonGoal.containsKey(key)){
                        mapMonGoal.get(key).RevenueNmb__c = (Double)agg.get('expr0');
                       	System.debug('Critério Sumarização Apurado: '+(Double)agg.get('expr0')); 
                    }
                }
                
                if(cmpMech.BenefitCriteriaLkp__r.Criteria__c != null){
                    criteria = cmpMech.BenefitCriteriaLkp__r.Criteria__c;
                    criteriaSQL = String.format(criteria, filter);
                    System.debug('Benefit Criteria SQL: '+criteriaSQL);
                    
                    AggregateResult[] groupedPayments = Database.query(criteriaSQL); 
                    
                    for(AggregateResult agg : groupedPayments){
                        String key = agg.get('Id')+' - '+cmpMech.Id+' - '+dte;
                        if(mapMonGoal.containsKey(key)){
                            mapMonGoal.get(key).BenefitRevenueNmb__c = (Double)agg.get('expr0');
                            System.debug('Base de Cálculo Apurada: '+(Double)agg.get('expr0'));
                        }
                    }
                }
            }
        }*/
        
        update mapMonGoal.values();
    }
  	
    public static void createCreditNote(Id campaignId, Date refDate){
        List<CreditNote__c> creditList = new List<CreditNote__c>();
        
        Campaign__c cmp = [SELECT Id, 
                           (SELECT Id, Bond__c, CampaignIndicatorLkp__c FROM CampaignMechanics__r), 
                           (SELECT Id, AccountLkp__c, CampaignMechanicsLkp__c, CampaignMechanicsLkp__r.Bond__c, BenefitPercentage__c, 
                            CreatedCreditNote__c, CampaignCalculationLkp__c, RealizedPercentage__c, CalculationBasisRlp__c, Status__c,
                            CampaignMechanicsLkp__r.PaymentTypeTxt__c, GoalRlp__c, FixedCreditValue__c, CampaignMechanicsLkp__r.BenefitCriteriaLkp__c
                            FROM AccountGoals__r
                            WHERE CampaignCalculationLkp__r.EndDate__c <= :refDate AND CreatedCreditNote__c = FALSE)
                           FROM Campaign__c WHERE Id = :campaignId];
        
        Map<Double, List<CampaignMechanics__c>> mapBond = new Map<Double, List<CampaignMechanics__c>>();
        Map<Id, CampaignMechanics__c> mapMechanics = new Map<Id, CampaignMechanics__c>();
        
        for (CampaignMechanics__c cmpMech : cmp.CampaignMechanics__r){
            if (cmpMech.Bond__c != null){
                if(mapBond.containsKey(cmpMech.Bond__c)){
                    List<CampaignMechanics__c> listMech = mapBond.get(cmpMech.Bond__c);
                    listMech.add(cmpMech);
                    mapBond.put(cmpMech.Bond__c, listMech);
                }else{
                    List<CampaignMechanics__c> newListMech = new List<CampaignMechanics__c>();
                    newListMech.add(cmpMech);
                    mapBond.put(cmpMech.Bond__c, newListMech);
                }
            } 
            mapMechanics.put(cmpMech.CampaignIndicatorLkp__c, cmpMech);
        }
        
        
        System.debug(mapBond);
        System.debug('------>Map Mecanicas:');
       	System.debug(mapMechanics);
        Map<String, AccountGoal__c> mapAccGoal = new Map<String, AccountGoal__c>();
        for(AccountGoal__c accGoal : cmp.AccountGoals__r){
            String mapKey = accGoal.CampaignMechanicsLkp__c + ' - ' + accGoal.CampaignCalculationLkp__c + ' - ' + accGoal.AccountLkp__c;
            mapAccGoal.put(mapKey, accGoal);
        }
        
        for(AccountGoal__c accGoal : cmp.AccountGoals__r){
            
            //if((accGoal.BenefitPercentage__c != null) && (accGoal.CampaignMechanicsLkp__r.Bond__c == null)
            if((accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c != null) && (accGoal.CampaignMechanicsLkp__r.Bond__c == null)
               && (accGoal.RealizedPercentage__c >= 100 || accGoal.Status__c == 'Recuperado')){
                   Double creditAmount;
                   /*if(accGoal.CampaignMechanicsLkp__r.PayUsingGoal__c){
                       creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.GoalRlp__c;    
                   }else{
                       creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;    
                   }*/
                   System.debug(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c);
                   if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'FATU'){
                       System.debug('Porcentagem do Beneficio: '+ accGoal.BenefitPercentage__c);
                       System.debug('Base de Calculo: '+ accGoal.CalculationBasisRlp__c);
                       creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;
                   }else if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'META'){
                       System.debug('Porcentagem do Beneficio: '+ accGoal.BenefitPercentage__c);
                       System.debug('Base de Calculo (Meta): '+ accGoal.CalculationBasisRlp__c);
                       creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;              
                   }else if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'FIXO'){
                       System.debug('Valor Fixo: '+ accGoal.FixedCreditValue__c);
                       creditAmount = accGoal.FixedCreditValue__c;
                   }
                   
                   System.debug('A ser pago : '+creditAmount);
                   
                   if(creditAmount > 0){
                       CreditNote__c credNote = new CreditNote__c();
                       credNote.Value__c = creditAmount;
                       credNote.AccountGoalLkp__c = accGoal.Id;
                       credNote.AccountLkp__c = accGoal.AccountLkp__c;
                       credNote.Date__c = Date.today();
                       credNote.Status__c = 'Aprovado';
                       credNote.Type__c = 'Crédito Campanha';
                       creditList.add(credNote);
                       
                       String mapKey = accGoal.CampaignMechanicsLkp__c + ' - ' + accGoal.CampaignCalculationLkp__c + ' - ' + accGoal.AccountLkp__c;
                       mapAccGoal.get(mapKey).CreatedCreditNote__c = true;
                       System.debug('Bateu a meta e pagou o beneficio de '+creditAmount);
                   }  
            }
            //else if((accGoal.BenefitPercentage__c != null) && (accGoal.RealizedPercentage__c >= 100 || accGoal.Status__c == 'Recuperado')){
            else if((accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c != null) && (accGoal.RealizedPercentage__c >= 100 || accGoal.Status__c == 'Recuperado')){
                if(mapBond.containsKey(accGoal.CampaignMechanicsLkp__r.Bond__c)){
                    List<CampaignMechanics__c> listMech = mapBond.get(accGoal.CampaignMechanicsLkp__r.Bond__c);
                    
                    Integer achievedGoals = 0;
                    for(Integer i = 0; i < listMech.size(); i++){
                        String mapKey = listMech.get(i).Id + ' - ' + accGoal.CampaignCalculationLkp__c + ' - ' + accGoal.AccountLkp__c;
                        AccountGoal__c bondGoal = mapAccGoal.get(mapKey);
                        if (bondGoal.RealizedPercentage__c >= 100 || bondGoal.Status__c == 'Recuperado'){
                            achievedGoals++;
                            System.debug('Bateu a meta '+listMech.get(i).Id);
                        }
                        else{
                         	System.debug('Não bateu a meta '+listMech.get(i).Id);   
                        }
                    }
                    if (achievedGoals == listMech.size()){
                        System.debug('Porcentagem do Beneficio: '+ accGoal.BenefitPercentage__c);
                        System.debug('Base de Calculo: '+ accGoal.CalculationBasis__c);
                        Double creditAmount;
                        /*if(accGoal.CampaignMechanicsLkp__r.PayUsingGoal__c){
                            creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.GoalRlp__c;    
                        }else{
                            creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;    
                        }*/
                        
                        if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'FATU'){
                            creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;
                        }else if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'META'){
                            System.debug('Porcentagem do Beneficio: '+ accGoal.BenefitPercentage__c);
                            System.debug('Base de Calculo (Meta): '+ accGoal.CalculationBasisRlp__c);
                            creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasisRlp__c;  
                        }else if(accGoal.CampaignMechanicsLkp__r.PaymentTypeTxt__c == 'FIXO'){
                            creditAmount = accGoal.FixedCreditValue__c;
                        }
                        
                        System.debug('A ser pago : '+creditAmount);
                        
                        if(creditAmount > 0){
                            CreditNote__c credNote = new CreditNote__c();
                            credNote.Value__c = creditAmount;
                            credNote.AccountGoalLkp__c = accGoal.Id;
                            credNote.AccountLkp__c = accGoal.AccountLkp__c;
                            credNote.Date__c = Date.today();
                            credNote.Status__c = 'Aprovado';
                            credNote.Type__c = 'Crédito Campanha';
                            creditList.add(credNote);      
                            
                            String mapKey = accGoal.CampaignMechanicsLkp__c + ' - ' + accGoal.CampaignCalculationLkp__c + ' - ' + accGoal.AccountLkp__c;
                            mapAccGoal.get(mapKey).CreatedCreditNote__c = true;     
                            System.debug('Bateu '+achievedGoals+' metas e pagou o beneficio de '+creditAmount);
                        }                                             
                    }
                }        
            }
        }
        
        insert creditList;
        update mapAccGoal.values();
    }    
    
    //Based on a CampaignId, returns all Account Goals - LPGB: 31/10/2017
    @AuraEnabled
    public static List<AccountGoal__c> getAccountGoalList(Id campaignId){
        System.debug('getAccountGoalList: '+campaignId);
        
      	return [SELECT Id, CampaignCalculationLkp__r.Name, AccountLkp__r.Name, Description__c, Goal__c, Realized__c, RealizedPercentage__c, CampaignMechanicsLkp__c,
                CampaignCalculationLkp__r.Position__c, BenefitPercentage__c, CreatedCreditNote__c, FlexValueNmb__c, FlexValueRlp__c, RevenueRlp__c, GoalRlp__c, CampaignMechanicsLkp__r.PaymentTypeTxt__c,
                RealizedRlp__c, Status__c
                FROM AccountGoal__c 
                WHERE CampaignLkp__c = :campaignId
               	ORDER BY AccountLkp__r.Name, CampaignCalculationLkp__r.Name, Description__c]; 
    }
    
    @AuraEnabled
    public static List<AccountGoal__c> getAccountGoalToFlexList(Id campaignId){
        System.debug('getAccountGoalToFlexList: '+campaignId);
        
        return [SELECT Id, CampaignCalculationLkp__r.Name, AccountLkp__r.Name, Description__c, GoalRlp__c, RevenueRlp__c, RealizedPercentage__c, CampaignMechanicsLkp__c,
                CampaignCalculationLkp__r.Position__c, CampaignCalculationLkp__r.StartDate__c, CampaignCalculationLkp__r.EndDate__c, BenefitPercentage__c, CreatedCreditNote__c, 
                FlexValueNmb__c, CalculationBasis__c, FlexValueRlp__c, CalculationBasisRlp__c, CampaignMechanicsLkp__r.PaymentTypeTxt__c, RealizedRlp__c, FixedCreditValue__c
                FROM AccountGoal__c 
                WHERE CampaignLkp__c = :campaignId AND CampaignCalculationLkp__r.StartDate__c <= TODAY
               	ORDER BY AccountLkp__r.Name, CampaignCalculationLkp__r.Name, Description__c];
    }
    
    //Performs account goal flexibilization - LPGB: 01/11/2017
    @AuraEnabled
    public static String flexAccountGoals(Id campaignId, String flexAccGoalJson){
        System.debug('flexAccountGoals - campaignId: '+campaignId);
 		System.debug(flexAccGoalJson);
        
        //List<AccountGoal__c> lista = (List<AccountGoal__c>)System.JSON.deserializeStrict(flexAccGoalList, List<AccountGoal__c>.Class);
        List<AccountGoal__c> flexAccGoalList = (List<AccountGoal__c>)JSON.deserialize(flexAccGoalJson, List<AccountGoal__c>.class);
        List<Id> flexIdList = new List<Id>();
        for(AccountGoal__c accGoal : flexAccGoalList){
            flexIdList.add(accGoal.Id);
            System.debug('accGoal = '+accGoal.AccountLkp__r.Id+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(accGoal.CampaignCalculationLkp__r.Position__c));
        } 

        System.debug(flexIdList);
        
        List<MonthlyGoal__c> monGoalList = [SELECT Id, Name, GoalNmb__c, FlexValueNmb__c, AccountGoalMdt__c, MonthDte__c, RevenueNmb__c
                                            FROM MonthlyGoal__c WHERE CampaignLkp__c = :campaignId];
        System.debug(monGoalList);
        
        List<AccountGoal__c> accGoalList = getAccountGoalList(campaignId);
        
       	Map<String, AccountGoal__c> mapAccGoal = new Map<String, AccountGoal__c>();
        for(AccountGoal__c accGoal : accGoalList){
            String aux = accGoal.AccountLkp__r.Id+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(accGoal.CampaignCalculationLkp__r.Position__c);
            System.debug('aux key = '+aux);
            mapAccGoal.put(aux, accGoal);
        }
        for (String key : mapAccGoal.keySet()) {
            System.debug(mapAccGoal.get(key));
        }
        
        Map<String, MonthlyGoal__c> mapMonGoal = new Map<String, MonthlyGoal__c>();
        for(MonthlyGoal__c monGoal: monGoalList){
            String key = monGoal.AccountGoalMdt__c + ' - ' + monGoal.MonthDte__c;
            System.debug('monGoal key = '+key);
            mapMonGoal.put(key, monGoal);
        }
        
        for(AccountGoal__C accGoal : flexAccGoalList){
            String currentPeriodKey = accGoal.AccountLkp__r.Id+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(accGoal.CampaignCalculationLkp__r.Position__c.intValue());
            System.debug('key flexList = '+currentPeriodKey);
            if(mapAccGoal.containsKey(currentPeriodKey)){
                
                //mapAccGoal.get(currentPeriodKey).Goal__c = accGoal.GoalRlp__c;
                mapAccGoal.get(currentPeriodKey).Status__c = 'Flexibilizado';
                //mapAccGoal.get(currentPeriodKey).FlexValueNmb__c = accGoal.FlexValueRlp__c;
                
                //System.debug('Nova Meta do Período Atual = '+mapAccGoal.get(currentPeriodKey).Goal__c);
                //System.debug('Valor flexibilizado = '+mapAccGoal.get(currentPeriodKey).FlexValueRlp__c);
                
                Integer nMonthsCurrentPeriod = accGoal.CampaignCalculationLkp__r.StartDate__c.monthsBetween(accGoal.CampaignCalculationLkp__r.EndDate__c) + 1;
                for(Integer I = 0 ; I < nMonthsCurrentPeriod; I++){
                    String monGoalKey = mapAccGoal.get(currentPeriodKey).Id + ' - ' + accGoal.CampaignCalculationLkp__r.StartDate__c.addMonths(I);
                    mapMonGoal.get(monGoalKey).FlexValueNmb__c = mapMonGoal.get(monGoalKey).GoalNmb__c - mapMonGoal.get(monGoalKey).RevenueNmb__c;
                    mapMonGoal.get(monGoalKey).GoalNmb__c = mapMonGoal.get(monGoalKey).RevenueNmb__c;
                    System.debug(mapMonGoal.get(monGoalKey).FlexValueNmb__c);
                    System.debug('Nova Meta do Mês '+mapMonGoal.get(monGoalKey).MonthDte__c+' = '+mapMonGoal.get(monGoalKey).GoalNmb__c);
                }            
                
                Integer nextPeriodPosition = accGoal.CampaignCalculationLkp__r.Position__c.intValue() + 1;
                String nextPeriodKey = accGoal.AccountLkp__r.Id+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(nextPeriodPosition);
                System.debug('nextPeriodKey = '+nextPeriodKey);
                if(mapAccGoal.containsKey(nextPeriodKey)){
                    //mapAccGoal.get(nextPeriodKey).GoalRlp__c =  mapAccGoal.get(nextPeriodKey).GoalRlp__c + accGoal.FlexValueNmb__c;
                    //System.debug('Nova Meta do Próximo Período = '+mapAccGoal.get(nextPeriodKey).Goal__c);
                    
                    Integer nMonthsNextPeriod = accGoal.CampaignCalculationLkp__r.StartDate__c.monthsBetween(accGoal.CampaignCalculationLkp__r.EndDate__c) + 1;
                    Double monthFlexValue = accGoal.FlexValueRlp__c / nMonthsNextPeriod;
                    System.debug(accGoal.FlexValueRlp__c);
                    System.debug('Valor a ser flexibilizado para cada mês = '+monthFlexValue);
                    for(Integer I = 0 ; I < nMonthsNextPeriod; I++){
                        String monGoalKey = mapAccGoal.get(nextPeriodKey).Id + ' - ' + accGoal.CampaignCalculationLkp__r.StartDate__c.addMonths(nMonthsCurrentPeriod+I);
                        System.debug('monGoalKey = '+monGoalKey);
                        if(mapMonGoal.containsKey(monGoalKey)){
                            mapMonGoal.get(monGoalKey).GoalNmb__c = mapMonGoal.get(monGoalKey).GoalNmb__c + monthFlexValue;
                            System.debug('Nova Meta do Mês '+mapMonGoal.get(monGoalKey).MonthDte__c+' = '+mapMonGoal.get(monGoalKey).GoalNmb__c);                           
                        }
                    }      
                }
                
            	//Double flexValue = mapAccGoal.get(key).Goal__c - accGoal.Goal__c; 
                //mapAccGoal.get(key).Goal__c = accGoal.Goal__c;
                //mapAccGoal.get(key).Status__c = 'Flexibilizado';
                //mapAccGoal.get(key).CreatedCreditNote__c = true;
                /*System.debug('Nova Meta do Período Atual = '+mapAccGoal.get(key).Goal__c);
                mapAccGoal.get(key).FlexValueNmb__c = flexValue;
                System.debug('Valor flexibilizado = '+mapAccGoal.get(key).FlexValueNmb__c);
                Integer nextPeriodPosition = accGoal.CampaignCalculationLkp__r.Position__c.intValue() + 1;
                String nextPeriodKey = accGoal.AccountLkp__r.Id+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(nextPeriodPosition);
                System.debug('nextPeriodKey = '+nextPeriodKey);
                if(mapAccGoal.containsKey(nextPeriodKey)){
                    mapAccGoal.get(nextPeriodKey).Goal__c =  mapAccGoal.get(nextPeriodKey).Goal__c + flexValue;
                    System.debug('Nova Meta do Próximo Período = '+mapAccGoal.get(nextPeriodKey).Goal__c);
                }*/
            }
        }
        
        try{
        	update mapAccGoal.values();
            update mapMonGoal.values();
            System.debug('flexAccountGoals SUCESS');
            return 'SUCCESS';           
        }
        catch(Exception e){
            System.debug('flexAccountGoals '+e.getMessage()); 
            return e.getMessage();       	    
        }     	

        return '';
    }    

    public static void campaignRecovery(Id campaignId){
        List<AccountGoal__c> listAccGoal = getAccountGoalList(campaignId);
        List<CreditNote__c> listCredNote = new List<CreditNote__C>();
        
        Map<String, AccountGoal__c> mapAccGoal = new Map<String, AccountGoal__c>();
        
        for(AccountGoal__c accGoal : listAccGoal){
        	mapAccGoal.put(accGoal.AccountLkp__c+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(accGoal.CampaignCalculationLkp__r.Position__c), accGoal);	    
        }
        
        Double realizedExtra;
        Integer prevPeriodPosition;
        String prevPeriodKey;
        
        for(AccountGoal__c accGoal : listAccGoal){
            if (accGoal.RealizedPercentage__c >= 100){
                realizedExtra = accGoal.RevenueRlp__c - accGoal.GoalRlp__c;
                System.debug('Bateu o período com um extra de '+realizedExtra);
                
                prevPeriodPosition = accGoal.CampaignCalculationLkp__r.Position__c.intValue() - 1;
                prevPeriodKey = accGoal.AccountLkp__c+' - '+accGoal.CampaignMechanicsLkp__c+' - '+String.valueOf(prevPeriodPosition);                
                
                if(mapAccGoal.containsKey(prevPeriodKey) && (mapAccGoal.get(prevPeriodKey).RealizedPercentage__c < 100) && 
                   (mapAccGoal.get(prevPeriodKey).CampaignMechanicsLkp__r.PaymentTypeTxt__c != null) && (mapAccGoal.get(prevPeriodKey).CreatedCreditNote__c == false)){
                   //(mapAccGoal.get(prevPeriodKey).BenefitPercentage__c != null) && (mapAccGoal.get(prevPeriodKey).CreatedCreditNote__c == false)){
                       
                   	AccountGoal__c accGoalPrev = mapAccGoal.get(prevPeriodKey);
                    Double gap = accGoalPrev.GoalRlp__c - accGoalPrev.RevenueRlp__c;
                    System.debug('Faltou '+gap+' para bater o período anterior');
                    
                    if(realizedExtra >= gap){
                        mapAccGoal.get(prevPeriodKey).Status__c = 'Recuperado';
                    }
                    else{
                     	System.debug('Não realiza a criação da nota de crédito');   
                    }
                }
            }
        }
        update mapAccGoal.values();
    }

    public static void getNCDiscount(Id campaignId, Date refDate){
        Integer refDateMonth = refDate.month();
                
        List<MonthlyGoal__c> monGoalList = [SELECT Id, Name, CampaignCalculationLkp__r.Name, DescriptionTxt__c, AccountMdt__c, AccountMdt__r.Name, MonthNmb__c,
                                            CampaignMechanicsLkp__r.ApplyDiscountBln__c, CampaignMechanicsLkp__r.ApplyDiscountBenefitBln__c
                                            FROM MonthlyGoal__c 
                                            WHERE (CampaignMechanicsLkp__r.ApplyDiscountBln__c = True OR CampaignMechanicsLkp__r.ApplyDiscountBenefitBln__c = True)
                                            AND CampaignCalculationLkp__r.StartDate__c <= :refDate AND CampaignCalculationLkp__r.EndDate__c >= :refDate AND MonthNmb__c = :refDateMonth 
                                            AND CampaignLkp__c = :campaignId];

        Map<Id, Double> sumGroupDiscountMap = new Map<Id, Double>();
        
        Set<Id> campaignGroupIdSet = new Set<Id>();
        for(MonthlyGoal__c monGoal : monGoalList){
            sumGroupDiscountMap.put(monGoal.AccountMdt__c, 0);
        }
        
        List<Account> accList = [SELECT Id, Name, 
                                 (SELECT Id, Name, SAPCodeFml__c, CodeSalesOrganizationTxt__c, CampaignGroupLkp__c FROM SalesAreas__r)
                                 FROM Account
                                 WHERE Id IN :sumGroupDiscountMap.keySet()];
        
        List<AccountAreaSales__c> avList = new List<AccountAreaSales__c>();
        
        for(Account acc : accList){
            for(AccountAreaSales__c av : acc.SalesAreas__r){
                avList.add(av);
            }
        }
        
        Date startDate = refDate.toStartOfMonth();
        Date endDate = startDate.addMonths(1).addDays(-1);
        
        System.debug(refDate+': De '+startDate+' a '+endDate);
                
        HTTPResponse res = SAPInteg.getNCDiscount(avList, startDate, endDate);
        
        if(res.getStatusCode() == 200){
            System.debug('mock body');
            System.debug(res.getBody());
            Map<String, Double> sumAVDiscountMap = new Map<String, Double>();
            
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('ET_BAPIRET2');        
            Boolean executionError = false;
            if(SAPIntegUtils.getType(msgs.get('item')) == 'Object'){
                Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    executionError = true;
                }
            }
            else{
                List<Object> listRet = (List<Object>) msgs.get('item');
                system.debug(listRet);
                for(Object ret : listRet){
                    Map<String, Object> returnMap = (Map<String, Object>) ret;
                    if((String)returnMap.get('TYPE') == 'E'){
                        system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                        executionError = true;
                    }
                }
            }
            
            if(!executionError){
                if(SAPIntegUtils.getType(jsonObj.get('ET_NC_COMP_OUT')) == 'Object'){
                    Map<String,Object> ncDiscountMap = (Map<String,Object>)jsonObj.get('ET_NC_COMP_OUT');  
                    if (ncDiscountMap.containsKey('item')){
                        if(SAPIntegUtils.getType(ncDiscountMap.get('item')) == 'Object'){
                            Map<String, Object> ncDiscount = (Map<String, Object>) ncDiscountMap.get('item');
                            String accSAPCode = StringUtils.removeLeftPadZeros((String)ncDiscount.get('KUNNR'));
                            String mapKey = StringUtils.removeLeftPadZeros((String)ncDiscount.get('KUNNR')) + ' - ' +  StringUtils.removeLeftPadZeros((String)ncDiscount.get('VKORG'));
                            //System.debug(ncDiscount.get('KUNNR'));
                            //System.debug(ncDiscount.get('DMBTR'));
                            //System.debug(mapKey); 
                            
                            if(sumAVDiscountMap.containsKey(mapKey)){
                                Double sumNCDiscount = sumAVDiscountMap.get(mapKey);
                                sumNCDiscount = sumNCDiscount + (Double) ncDiscount.get('DMBTR');
                                sumAVDiscountMap.put(mapKey, sumNCDiscount);
                            }else{
                                sumAVDiscountMap.put(mapKey, (Double) ncDiscount.get('DMBTR'));
                            }
                        }
                        else{
                            List<Object> ncDiscountList = (List<Object>) ncDiscountMap.get('item');
                            for(Object ncDiscountJSON: ncDiscountList){
                                Map<String, Object> ncDiscount = (Map<String, Object>) ncDiscountJSON;
                                String accSAPCode = StringUtils.removeLeftPadZeros((String)ncDiscount.get('KUNNR'));
                                String mapKey = StringUtils.removeLeftPadZeros((String)ncDiscount.get('KUNNR')) + ' - ' +  StringUtils.removeLeftPadZeros((String)ncDiscount.get('VKORG'));
                                //System.debug(ncDiscount.get('KUNNR'));
                                //System.debug(ncDiscount.get('DMBTR'));
                                //System.debug(mapKey); 
                                
                                if(sumAVDiscountMap.containsKey(mapKey)){
                                    Double sumNCDiscount = sumAVDiscountMap.get(mapKey);
                                    sumNCDiscount = sumNCDiscount + (Double)ncDiscount.get('DMBTR');
                                    sumAVDiscountMap.put(mapKey, sumNCDiscount);
                                }else{
                                    sumAVDiscountMap.put(mapKey, (Double)ncDiscount.get('DMBTR'));
                                }               
                            }
                        }
                    }            
                }else{
                    System.debug('Não existem NCs de preço compensadas para os clientes');
                }            
                
                for(AccountAreaSales__c av : avList){
                    String mapKey = av.SAPCodeFml__c + ' - ' + av.CodeSalesOrganizationTxt__c;
                    if(sumAVDiscountMap.containsKey(mapKey)){
                        System.debug(av.SAPCodeFml__c+' = '+sumAVDiscountMap.get(mapKey));
                        if(sumGroupDiscountMap.containsKey(av.CampaignGroupLkp__c)){
                            Double groupSum = sumGroupDiscountMap.get(av.CampaignGroupLkp__c);
                            sumGroupDiscountMap.put(av.CampaignGroupLkp__c, groupSum + sumAVDiscountMap.get(mapKey));
                        }
                    }
                    else{
                        System.debug('Não encontrou '+mapKey);
                    }
                }
                
                for(MonthlyGoal__c monGoal : monGoalList){
                    if(sumGroupDiscountMap.containsKey(monGoal.AccountMdt__c)){
                        if(monGoal.CampaignMechanicsLkp__r.ApplyDiscountBln__c)
                            monGoal.NCDiscountsNmb__c = sumGroupDiscountMap.get(monGoal.AccountMdt__c);
                        if(monGoal.CampaignMechanicsLkp__r.ApplyDiscountBenefitBln__c)
                            monGoal.NCDiscountsBenefitNmb__c = sumGroupDiscountMap.get(monGoal.AccountMdt__c);
                        System.debug('TOTAL DESCONTOS PARA O GRUPO '+monGoal.AccountMdt__r.Name+' PARA O MES: '+monGoal.MonthNmb__c+': '+sumGroupDiscountMap.get(monGoal.AccountMdt__c));
                        System.debug('APLICAR DESCONTO: '+monGoal.CampaignMechanicsLkp__r.ApplyDiscountBln__c);
                        System.debug('APLICAR DESCONTO PARA O BENEFICIO: '+monGoal.CampaignMechanicsLkp__r.ApplyDiscountBenefitBln__c);
                    }
                }
                
                upsert monGoalList;
                
                System.debug(avList);
                System.debug(sumGroupDiscountMap);                        
                
            }    
        }
        
        //CHECAR CÓDIGO HTTP
        //CHECAR MENSAGENS DE ERRO
        
        //Chamada do SAP
        //String strSAP = '{"T_ZPH_CRED_OUT":{"item":[{"BUKR":"2190","KUNNR":"209819","AUGDT":"2017-10-10","DMBTR":"10000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"209819","AUGDT":"2017-10-10","DMBTR":"20000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"209820","AUGDT":"2017-10-10","DMBTR":"40000.00","VKORG":"AM01"}]}}';
        //String strSAP = '{"T_ZPH_CRED_OUT":{"item":[{"BUKR":"2190","KUNNR":"209819","AUGDT":"2017-10-10","DMBTR":"10000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"209819","AUGDT":"2017-10-10","DMBTR":"20000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"138999","AUGDT":"2017-10-10","DMBTR":"40000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"138999","AUGDT":"2017-10-10","DMBTR":"10000.00","VKORG":"AM01"},{"BUKR":"2190","KUNNR":"999999","AUGDT":"2017-10-20","DMBTR":"80000.00","VKORG":"AM01"}]}}';
        //String strSAP = '{"T_ZPH_CRED_OUT":{"item":{"BUKR":"2190","KUNNR":"209819","AUGDT":"2017-10-10","DMBTR":"10000.00","VKORG":"AM01"}}}';
    }
    
}