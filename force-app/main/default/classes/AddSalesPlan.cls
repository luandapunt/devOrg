global with sharing class AddSalesPlan {
    
    public Quota__c quota;
    public String quotaId {get;set;}
    public Quota__c refQuota;
    public SalesPlanning__c del;    
    public SalesPlanning__c newPlan;    
    //public List<Account> accounts {get;set;}//= new List<Account>();
    public List<AccountAreaSales__c> areasSales {get;set;}    
    public List<SalesPlanning__c> masterPlanList;	    
    public List<SalesPlanning__c> planList;
    public List<SalesPlanning__c> addPlanList {get;set;}     
    public List<SalesPlanWrapper> planHistories;
    public Map <Id,CampaignAccount__c> campaignMap;
    private List<Event> listEvt;    
    public Integer pageNum {get;set;}
    public Integer pageSize {get;set;}
    public Integer maxPages {get;set;}
    public Integer rowIndex;    
    public double sumValue {get;set;}
    public double remainingAmount;  
    public double existingTotalValue {get;set;}
    public string city {get;set;}
    public string uiTheme {get;set;}    
    public string planFilter {get;set;}
    public string planFilterValue {get;set;}
    public Date quarterMonth1 {get;set;}
    public Date quarterMonth2 {get;set;}    
    public Date quarterMonth3 {get;set;}
    public string strQuarter1 {get;set;}
    public string strQuarter2 {get;set;}
    public string strQuarter3 {get;set;}
    public string searchInput {get;set;}
    
    public Integer summaryCurrentMonthClients {get;set;}
    public Integer summaryLastMonthClients {get;set;}
    public Decimal summaryLastMonthRevenue {get;set;}
    public Integer summaryLast3MonthClients {get;set;}
    public Decimal summaryLast3MonthRevenue {get;set;}
    public Integer summaryLast6MonthClients {get;set;}
    public Decimal summaryLast6MonthRevenue {get;set;}
    
    public integer summaryTotalClientsPlan {get;set;}
    public integer summaryClientsPlanCampaign {get;set;}
    public integer summaryClientsPlanFIOC {get;set;}
    public integer summaryClientsPlanPE {get;set;}
    public integer summaryClientsPlanCANORE {get;set;}
    public Decimal summaryTotalRolPlan {get;set;}
    public Decimal summaryRolPlanCampaign {get;set;}
    public Decimal summaryRolPlanFIOC {get;set;}
    public Decimal summaryRolPlanPE {get;set;}
    public Decimal summaryRolPlanCANORE {get;set;}
    
    public integer summaryTotalClientsWOPlan {get;set;}
    public integer summaryClientsWOPlanCampaign {get;set;}
    public integer summaryClientsWOPlanFIOC {get;set;}
    public integer summaryClientsWOPlanPE {get;set;}
    public integer summaryClientsWOPlanCANORE {get;set;}
    public Decimal summaryTotalRolWOPlan {get;set;}
    public Decimal summaryRolWOPlanCampaign {get;set;}
    public Decimal summaryRolWOPlanFIOC {get;set;}
    public Decimal summaryRolWOPlanPE {get;set;}
    public Decimal summaryRolWOPlanCANORE {get;set;}
    
    public List<Lead> sellerNewClients {get;set;}
    
    
    public AddSalesPlan(ApexPages.StandardController controller) {                                                        
        pageNum = 1;
        pageSize = 100;       
        
        refQuota = (Quota__c) controller.getRecord();                
        
        this.quota = [Select Id, Owner.UserRoleId, TotalValueNmb__c, CurrentDateFml__c, CurrentMonthTxt__c, CurrentYearTxt__c, SellerLkp__c, SellerLkp__r.UserLkp__c 
                      From Quota__c 
                      Where Id =: refQuota.Id
                     ];     
        quotaId = quota.Id;
        
        //Lista de leads do vendedor da cota: utilizada em Comparativo > Outros Clientes : Sem Planejamento
        sellerNewClients = [SELECT Id, SellerLkp__c FROM Lead WHERE SellerLkp__c =: quota.SellerLkp__c AND IsConverted = FALSE];                
        
        if(Quota.CurrentDateFml__c.month()==1 || Quota.CurrentDateFml__c.month()==2 || Quota.CurrentDateFml__c.month()==3){
            quarterMonth1 = Date.newInstance(quota.CurrentDatefml__c.year()-1,1,1);
        }
        if(Quota.CurrentDateFml__c.month()==4 || Quota.CurrentDateFml__c.month()==5 || Quota.CurrentDateFml__c.month()==6){
            quarterMonth1 = Date.newInstance(quota.CurrentDatefml__c.year()-1,4,1);
        }
        if(Quota.CurrentDateFml__c.month()==7 || Quota.CurrentDateFml__c.month()==8 || Quota.CurrentDateFml__c.month()==9){
            quarterMonth1 = Date.newInstance(quota.CurrentDatefml__c.year()-1,7,1);
        }
        if(Quota.CurrentDateFml__c.month()==10 || Quota.CurrentDateFml__c.month()==11 || Quota.CurrentDateFml__c.month()==12){
            quarterMonth1 = Date.newInstance(quota.CurrentDatefml__c.year()-1,10,1);
        }
        
        quarterMonth2 = quarterMonth1.addmonths(1);
        quarterMonth3 = quarterMonth1.addmonths(2);
        
        strQuarter1 = parseDate(quarterMonth1);
        strQuarter2 = parseDate(quarterMonth2);
        strQuarter3 = parseDate(quarterMonth3);
        
        this.uiTheme = UserInfo.getUiTheme();
        populateMasterList();
        maxPages = Integer.valueOf(masterPlanList.size()/pageSize) + 1;
        getPlanList();
        this.planHistories = getPlanHistories();
        //system.debug(planHistories.size());
    }            
    
    private string parseDate (date d){
        if (d.month()==1){
            return 'Jan/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==2){
            return 'Fev/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==3){
            return 'Mar/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==4){
            return 'Abr/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==5){
            return 'Mai/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==6){
            return 'Jun/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==7){
            return 'Jul/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==8){
            return 'Ago/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==9){
            return 'Set/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==10){
            return 'Out/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==11){
            return 'Nov/' + string.valueof(Math.mod(d.year(), 100));
        }
        if (d.month()==12){
            return 'Dez/' + string.valueof(Math.mod(d.year(), 100));
        }
        else{
            return null;
        }
    }    
    
    private void populateMasterList(){        
        
        masterPlanList = new List<SalesPlanning__c>();        		        
        
        masterPlanList = [Select Id, TotalValueNmb__c, QuotaLkp__c, QuotaLkp__r.Name, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.Name , AccountAreaSalesLkp__r.ChannelLkp__r.Name,
                          AccountAreaSalesLkp__r.AccountLkp__c, AccountAreaSalesLkp__r.AccountLkp__r.Name, AccountAreaSalesLkp__r.AccountLkp__r.CodeCustomerTxt__c,  AccountTxt__c,
                          AccountAreaSalesLkp__r.SellerLkp__c, AccountAreaSalesLkp__r.SellerLkp__r.UserLkp__c, AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c,
                          AccountAreaSalesLkp__r.SellerLkp__r.UserLkp__r.Name, AccountAreaSalesLkp__r.CampaignGroupLkp__c,
                          CampaignLkp__c, CampaignLkp__r.Name, CurrentMonthTxt__c, CurrentYearTxt__c, AccountCityTxt__c, AccountPostalCodeTxt__c, 
                          VisitDateDte__c, CodeCustomerTxt__c, ChannelPVCTxt__c, RevenueNmb__c, FidelityTxt__c, GuestLkp__c
                          From SalesPlanning__c 
                          Where QuotaLkp__c =: quota.Id
                          Order by AccountPostalCodeTxt__c                   
                         ];        
        
        /*preenchimento resumo: Comparativo -> Clientes Com Planejamento
        summaryTotalClientsPlan = masterPlanList.size();
        for(SalesPlanning__c p: masterPlanList){
            if(p.CampaignLkp__c != null){
                summaryClientsPlanCampaign +=1;
            } else{
                if(p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c == 'FI'|| p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c =='OC')
                    summaryClientsPlanFIOC += 1;
                if(p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c == 'PE')
                    summaryClientsPlanPE +=1;
                if(p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c == 'CA'|| p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c =='NO' ||
                   p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c == 'RE'|| p.AccountAreaSalesLkp__r.AccountLkp__r.FidelityTxt__c == Null)
                    summaryClientsPlanCANORE +=1;
            }
        }*/
        
        
        areasSales = [  SELECT Id, AccountLkp__c, AccountLkp__r.Name, AccountLkp__r.BillingCity, AccountLkp__r.BillingState, AccountLkp__r.BillingStateCode, AccountLkp__r.BillingPostalCode, 
                      AccountLkp__r.FidelityTxt__c, CampaignGroupLkp__c, ChannelLkp__r.Name, SellerLkp__c, SellerLkp__r.UserLkp__c, AccountLkp__r.CodeCustomerTxt__c, AccountNameFml__c,
                      AccountLkp__r.RecordType.DeveloperName, InactiveBln__c
                      FROM AccountAreaSales__c
                      WHERE SellerLkp__r.UserLkp__c =: quota.OwnerId
                      AND SellerLkp__c =: quota.SellerLkp__c
                      AND Id NOT IN(
                          SELECT AccountAreaSalesLkp__c
                          FROM SalesPlanning__c
                          WHERE QuotaLkp__c =: quota.Id
                      )
                      AND AccountLkp__r.CodeCustomerTxt__c !=: InactiveAccounts__c.getInstance().InactiveAccountsCodeTxt__c
                      AND InactiveBln__c = false
                      AND AccountLkp__r.Name != null
                      AND AccountLkp__r.RecordType.DeveloperName != 'AccountPartner'
                      AND AccountLkp__r.RecordType.DeveloperName != 'CompetitionAccount'
                      ORDER BY AccountLkp__r.BillingPostalCode
                     ];                
        
        //premissa: os planejamentos de venda só poderão ser criados pelos donos da conta
        
        map<Id,String> accCityMap = new Map<Id,String>();                
        
        for(AccountAreaSales__c areaSls: areasSales){
            if(areaSls.AccountLkp__r.BillingState != null && areaSls.AccountLkp__r.BillingCity != null){
                accCityMap.put(areaSls.Id, areaSls.AccountLkp__r.BillingStateCode + ' - ' + areaSls.AccountLkp__r.BillingCity);
            }
        }
        
        map<Id,String> accPostalCodeMap = new Map<Id,String>();                
        
        for(AccountAreaSales__c areaSls: areasSales){
            if(areaSls.AccountLkp__r.BillingPostalCode != null){
                accPostalCodeMap.put(areaSls.Id, areaSls.AccountLkp__r.BillingPostalCode);
            }
        }                
        
        List<AccountAreaSales__c> campaignAreaSales = [SELECT Id, CampaignGroupLkp__c 
                                                       FROM AccountAreaSales__c 
                                                       WHERE SellerLkp__r.UserLkp__c =: quota.OwnerId 
                                                       AND SellerLkp__c =: quota.SellerLkp__c];
        
        List<CampaignAccount__c> campaigns = new List<CampaignAccount__c>();
        
        campaigns = [SELECT Id, AccountLkp__c, CampaignLkp__c, CampaignLkp__r.Name
                     FROM CampaignAccount__c
                     WHERE CampaignLkp__r.Active__c = TRUE
                     AND CampaignLkp__r.Type__c = 'Fixa'
                     AND CampaignLkp__r.StartDate__c <= :quota.CurrentDateFml__c
                     AND CampaignLkp__r.EndDate__c > :quota.CurrentDateFml__c
                     AND AccountLkp__c IN (SELECT CampaignGroupLkp__c FROM AccountAreaSales__c WHERE Id IN : campaignAreaSales)
                    ];
        
        //Map <Id,CampaignAccount__c> 
        campaignMap = new Map <Id, CampaignAccount__c>();
        
        for(CampaignAccount__c camp: campaigns){
            campaignMap.put(camp.AccountLkp__c, camp);            
        }                
        
        /*preenchimento resumo: Comparativo -> Clientes Sem Planejamento
        summaryTotalClientsWOPlan = areasSales.size();
        
        for(AccountAreaSales__c accArea: areasSales){
            if(campaignMap.containsKey(accArea.CampaignGroupLkp__c)){
                summaryClientsWOPlanCampaign +=1;
            }else{
                if(accArea.AccountLkp__r.FidelityTxt__c == 'FI' || accArea.AccountLkp__r.FidelityTxt__c == 'OC')
                    summaryClientsWOPlanFIOC +=1;
                if(accArea.AccountLkp__r.FidelityTxt__c == 'PE')
                    summaryClientsWOPlanPE +=1;                
                if(accArea.AccountLkp__r.FidelityTxt__c == 'CA'|| accArea.AccountLkp__r.FidelityTxt__c =='NO' ||
                   accArea.AccountLkp__r.FidelityTxt__c == 'RE'|| accArea.AccountLkp__r.FidelityTxt__c == Null)
                    summaryClientsWOPlanCANORE +=1;
            }
        }*/
        
        
        Map<String,String> fidelityMap = new Map<String,String>();
        
        Schema.DescribeFieldResult fieldResult = Account.FidelityTxt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f: ple){
            fidelityMap.put(f.getValue(), f.getLabel());
        }
        
        existingTotalValue = 0;
        
        if(areasSales.size() > 0){ 
            for(AccountAreaSales__c area : areasSales){
                SalesPlanning__c childPLan = new SalesPlanning__c();
                childPlan.AccountAreaSalesLkp__r = area;                
                childPlan.AccountAreaSalesLkp__c = area.Id;
                childPlan.AccountTxt__c = area.AccountLkp__r.Name;
                childPlan.CodeCustomerTxt__c = area.AccountLkp__r.CodeCustomerTxt__c;
                childPlan.ChannelPVCTxt__c = area.ChannelLkp__r.Name;
                childPlan.AccountCityTxt__c = accCityMap.get(area.Id);
                childPlan.AccountPostalCodeTxt__c = accPostalCodeMap.get(area.Id);                
                childPlan.QuotaLkp__c = quota.Id;
                //string acc = area.AccountLkp__c.Id
                if(campaignMap.get(area.CampaignGroupLkp__c) != null){
                    childPlan.CampaignLkp__c = campaignMap.get(area.CampaignGroupLkp__c).CampaignLkp__c;
                    childPlan.CampaignLkp__r = new Campaign__c(Id = childPlan.CampaignLkp__c, Name = campaignMap.get(area.CampaignGroupLkp__c).CampaignLkp__r.Name);
                }                
                childPlan.CurrentMonthTxt__c = quota.CurrentMonthTxt__c;
                childPlan.CurrentYearTxt__c = quota.CurrentYearTxt__c;
                childPlan.FidelityTxt__c = fidelityMap.get(area.AccountLkp__r.FidelityTxt__c);
                masterPlanList.add(childPlan);                
            }
        }                
        
    }
    
    public List<SalesPlanning__c> getPlanList(){          
        
        List<SalesPlanning__c> filteredList = new List<SalesPlanning__c>();
        
        Map<String,SalesPlanning__c> sortPlanMap = new Map<String,SalesPlanning__c>();
        
        for(SalesPlanning__c plan : masterPlanList){            
            sortPlanMap.put(plan.AccountPostalCodeTxt__c + plan.AccountAreaSalesLkp__c, plan);            
        }                
        
        List<String> plansPostalCodes = new List<String>();
        plansPostalCodes.addAll(sortPlanMap.keySet());
        plansPostalCodes.sort();
        
        system.debug('pageNum' + pageNum);
        Integer addedPlans = 0;
        //for(Integer i = (pageNum - 1) * pageSize; i <  plansPostalCodes.size() && addedPlans < pageSize; i++){
        for(string sortKey : plansPostalCodes){
            //String sortKey = plansPostalCodes[i];
            if(planFilter == null || planFilter == '' || planFilterValue == null || planFilterValue == '' || sortPlanMap.get(sortKey).get(planFilter) == planFilterValue){                
                if(searchInput == null || searchInput == '' || 
                   (searchInput != null && searchInput != '' &&
                    sortPlanMap.get(sortKey).AccountAreaSalesLkp__r.AccountLkp__r.Name != null &&                    
                    sortPlanMap.get(sortKey).AccountAreaSalesLkp__r.AccountLkp__r.Name.Contains(searchInput.toUpperCase())) ||
                   (searchInput != null && searchInput != '' &&
                    sortPlanMap.get(sortKey).AccountAreaSalesLkp__r.AccountLkp__r.CodeCustomerTxt__c != null &&                    
                    sortPlanMap.get(sortKey).AccountAreaSalesLkp__r.AccountLkp__r.CodeCustomerTxt__c.Contains(searchInput.toUpperCase()))){
                        filteredList.add(sortPlanMap.get(sortKey));
                        //addedPlans++;                  
                    }
            }
            //else i--;
        }                
        if(planFilter == null || planFilter == '' || planFilterValue == null || planFilterValue == ''){
            this.maxPages = masterPlanList.size()/pageSize + 1;
        }
        else{
            this.pageNum = 1;
            this.maxPages = (filteredList.size()/pageSize) + 1;
        }       
        
        return filteredList;        
        
    }
    
    public List<SalesPlanWrapper> getPlanHistories(){
        
        summaryCurrentMonthClients 	= 0;
        summaryLastMonthClients 	= 0;
        summaryLastMonthRevenue  	= 0;
        summaryLast3MonthClients  	= 0;
        summaryLast3MonthRevenue  	= 0;
        summaryLast6MonthClients  	= 0;
        summaryLast6MonthRevenue  	= 0;
        
        summaryTotalClientsPlan		= 0;
        summaryClientsPlanCampaign 	= 0;
        summaryClientsPlanFIOC 		= 0;
        summaryClientsPlanPE 		= 0;
        summaryClientsPlanCANORE 	= 0;
        
        summaryTotalClientsWOPlan		= 0;
        summaryClientsWOPlanCampaign	= 0;
        summaryClientsWOPlanFIOC 		= 0;
        summaryClientsWOPlanPE 			= 0;
        summaryClientsWOPlanCANORE		= 0;
        
        summaryTotalRolPlan		= 0;
        summaryRolPlanCampaign	= 0;
        summaryRolPlanFIOC		= 0;
        summaryRolPlanPE		= 0;
        summaryRolPlanCANORE	= 0;
        
        summaryTotalRolWOPlan		= 0;
        summaryRolWOPlanCampaign	= 0;
        summaryRolWOPlanFIOC		= 0;
        summaryRolWOPlanPE			= 0;
        summaryRolWOPlanCANORE		= 0;
        
        List<AccountAreaSales__c> listAreaSalesWithPlan = [	SELECT Id, AccountLkp__c, AccountLkp__r.FidelityTxt__c, CampaignGroupLkp__c, AccountLkp__r.CodeCustomerTxt__c
                                                           	FROM AccountAreaSales__c 
                                                           	WHERE Id IN (SELECT AccountAreaSalesLkp__c 
                                                                        	FROM SalesPlanning__c 
                                                                        	WHERE QuotaLkp__c =: quota.Id)                                                            	
                                                          ];        
        
        Map<Id,AccountAreaSales__c> areasSalesWithPlan = new Map<Id,AccountAreaSales__c>();
        areasSalesWithPlan.putAll(listAreaSalesWithPlan);
        
        for(AccountAreaSales__c aasWithPlan: listAreaSalesWithPlan){
            summaryTotalClientsPlan += 1;
            if(campaignMap.containsKey(aasWithPlan.CampaignGroupLkp__c)){
                summaryClientsPlanCampaign +=1;
            }else{
                if(aasWithPlan.AccountLkp__r.FidelityTxt__c == 'FI' || aasWithPlan.AccountLkp__r.FidelityTxt__c == 'OC')
                    summaryClientsPlanFIOC +=1;
                if(aasWithPlan.AccountLkp__r.FidelityTxt__c == 'PE')
                    summaryClientsPlanPE +=1;                
                if(aasWithPlan.AccountLkp__r.FidelityTxt__c == 'CA' || aasWithPlan.AccountLkp__r.FidelityTxt__c =='NO' || aasWithPlan.AccountLkp__r.FidelityTxt__c =='RE' ||
                   aasWithPlan.AccountLkp__r.FidelityTxt__c == 'ME' || aasWithPlan.AccountLkp__r.FidelityTxt__c == Null)                
                    summaryClientsPlanCANORE +=1;
            }

        }
        
        List<AccountAreaSales__c> listAreaSalesWOPlan = [	SELECT Id, AccountLkp__c, AccountLkp__r.FidelityTxt__c, CampaignGroupLkp__c, AccountLkp__r.CodeCustomerTxt__c, InactiveBln__c
                                                            FROM AccountAreaSales__c
                                                            WHERE SellerLkp__r.UserLkp__c =: quota.OwnerId
                                                            AND SellerLkp__c =: quota.SellerLkp__c
                                                            AND Id NOT IN(
                                                                SELECT AccountAreaSalesLkp__c
                                                                FROM SalesPlanning__c
                                                                WHERE QuotaLkp__c =: quota.Id
                                                            )
                                                            AND AccountLkp__r.CodeCustomerTxt__c !=: InactiveAccounts__c.getInstance().InactiveAccountsCodeTxt__c
                                                         	AND InactiveBln__c = false
                                                            AND AccountLkp__r.Name != null
                                                            AND AccountLkp__r.RecordType.DeveloperName != 'AccountPartner'
                                                         	AND AccountLkp__r.RecordType.DeveloperName != 'CompetitionAccount'
                                                        ];
        Map<Id,AccountAreaSales__c> areasSalesWOPlan = new Map<Id,AccountAreaSales__c>();
        areasSalesWOPlan.putAll(listAreaSalesWOPlan);

        for(AccountAreaSales__c aasWOPlan: listAreaSalesWOPlan){
            summaryTotalClientsWOPlan += 1;
            if(campaignMap.containsKey(aasWOPlan.CampaignGroupLkp__c)){
                    summaryClientsWOPlanCampaign +=1;
                }else{
                    if(aasWOPlan.AccountLkp__r.FidelityTxt__c == 'FI' || aasWOPlan.AccountLkp__r.FidelityTxt__c == 'OC')
                        summaryClientsWOPlanFIOC +=1;
                    if(aasWOPlan.AccountLkp__r.FidelityTxt__c == 'PE')
                        summaryClientsWOPlanPE +=1;                
                    if(aasWOPlan.AccountLkp__r.FidelityTxt__c == 'CA' || aasWOPlan.AccountLkp__r.FidelityTxt__c =='NO' || aasWOPlan.AccountLkp__r.FidelityTxt__c == 'RE'|| 
                       aasWOPlan.AccountLkp__r.FidelityTxt__c == 'ME' || aasWOPlan.AccountLkp__r.FidelityTxt__c == Null)                    
                        summaryClientsWOPlanCANORE +=1;
                }            
        }        
        
        List<AccountAreaSales__c> listAllAreaSales = new List<AccountAreaSales__c>();
        listAllAreaSales.addAll(listAreaSalesWithPlan);
        listAllAreaSales.addAll(listAreaSalesWOPlan);
        
        listEvt = [SELECT Id, WhatId, StartDateTime 
                   FROM Event 
                   WHERE WhatId IN :listAllAreaSales 
                   AND StartDateTime >= :this.quota.CurrentDateFml__c
                   AND StartDateTime < :this.quota.CurrentDateFml__c.addMonths(1)
                  ];        
        Map<Id, List<Event>> mapEvents = new Map<Id, List<Event>>();
        
        for(Event evt : listEvt){
            List<Event> listEvtAux = new List<Event>();
            if(mapEvents.containsKey(evt.WhatId))
                listEvtAux = mapEvents.get(evt.WhatId);
            listEvtAux.add(evt);
            mapEvents.put(evt.WhatId, listEvtAux);
        }
        
        Map<Id,SalesPlanWrapper> revenueMap = new Map<Id,SalesPlanWrapper>();
        
        List<SalesPlanWrapper> results = new List<SalesPlanWrapper>();                
        
        //for (SalesPlanning__c pln: getPlanList()){
        for(SalesPlanning__c pln : masterPlanList){
            SalesPlanWrapper wrp = new SalesPlanWrapper(pln);
            if(mapEvents.containsKey(pln.AccountAreaSalesLkp__c)){
                system.debug('Entrou aqui');
                wrp.evt = mapEvents.get(pln.AccountAreaSalesLkp__c)[0];
                wrp.hasEvt = true;
            }
            revenueMap.put(pln.AccountAreaSalesLkp__c, wrp);
        }
        
        
        //MÉDIA DE COMPRA DOS ÚLTIMOS 3 MESES
        Date startDtQuarter = quota.CurrentDateFml__c.addMonths(-3);
        Date startMonthQuarter = Date.newInstance(startDtQuarter.year(), startDtQuarter.month(), 1);
        for(AggregateResult quarterRes :  [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                           FROM SummarizedRevenue__c 
                                           WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                           AND DateDt__c > :startMonthQuarter
                                           GROUP BY SalesAreaLkp__c]){            
                                               SalesPlanWrapper wrapperAux = revenueMap.get((Id)quarterRes.get('av'));
                                               wrapperAux.quarterAvgRevenue = quarterRes.get('rev') != null ? (Decimal)quarterRes.get('rev')/3 : 0;
                                               if(wrapperAux.quarterAvgRevenue != 0){
                                                   summaryLast3MonthClients  	+= 1;
                                                   summaryLast3MonthRevenue  	+= wrapperAux.quarterAvgRevenue;
                                               }
                                               revenueMap.put((Id)quarterRes.get('av'), wrapperAux);
                                           }
        
        
        //MÉDIA DE COMPRA DOS ÚLTIMOS 12 MESES 
        Date startDtYear = quota.CurrentDateFml__c.addYears(-1);
        Date startMonthYear = Date.newInstance(startDtYear.year(), startDtYear.month(), 1);
        for(AggregateResult yearRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                       FROM SummarizedRevenue__c 
                                       WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                       AND DateDt__c > :startMonthYear
                                       GROUP BY SalesAreaLkp__c]){            
                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)yearRes.get('av'));
                                           wrapperAux.yearAvgRevenue = yearRes.get('rev') != null ? (Decimal)yearRes.get('rev')/12 : 0;
                                           revenueMap.put((Id)yearRes.get('av'), wrapperAux);
                                       }
        
        //MÉDIA DE COMPRA DOS ÚLTIMOS 6 MESES 
        Date startDtSemester = quota.CurrentDateFml__c.addMonths(-6);
        Date startMonthSemester = Date.newInstance(startDtSemester.year(), startDtSemester.month(), 1);
        for(AggregateResult semesterRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                           FROM SummarizedRevenue__c 
                                           WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                           AND DateDt__c > :startMonthSemester
                                           GROUP BY SalesAreaLkp__c]){            
                                               SalesPlanWrapper wrapperAux = revenueMap.get((Id)semesterRes.get('av'));
                                               wrapperAux.semesterAvgRevenue = semesterRes.get('rev') != null ? (Decimal)semesterRes.get('rev')/6 : 0;
                                               if(wrapperAux.semesterAvgRevenue != 0){
                                                   summaryLast6MonthClients  	+= 1;
                                                   summaryLast6MonthRevenue  	+= wrapperAux.semesterAvgRevenue;                                               
                                               }
                                               revenueMap.put((Id)semesterRes.get('av'), wrapperAux);
                                           }
        
        //COMPRA MÊS ANTERIOR
        Date startDtLastMonth = quota.CurrentDateFml__c.addMonths(-1);
        Date startMonthLastMonth = Date.newInstance(startDtLastMonth.year(), startDtLastMonth.month(), 1);
        Date endDtLastMonth = quota.CurrentDateFml__c;
        Date endMonthLastMonth = Date.newInstance(endDtLastMonth.year(), endDtLastMonth.month(), 1);
        
        for(AggregateResult lastMonthRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                            FROM SummarizedRevenue__c 
                                            WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                            AND DateDt__c >= :startMonthLastMonth
                                            AND DateDt__c < :endMonthLastMonth
                                            GROUP BY SalesAreaLkp__c]){
                                                SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastMonthRes.get('av'));                                                        
                                                wrapperAux.lastMonthRevenue = lastMonthRes.get('rev') != null ? (Decimal)lastMonthRes.get('rev') : 0;
                                                if(wrapperAux.lastMonthRevenue != 0){
                                                    summaryLastMonthClients 	+= 1;
                                                    summaryLastMonthRevenue  	+= wrapperAux.lastMonthRevenue;                                                    
                                                }
                                                revenueMap.put((Id)lastMonthRes.get('av'), wrapperAux);
                                            }      
        
        
        //COMPRA MÊS ATUAL
        for(AggregateResult thisMonthRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                            FROM SummarizedRevenue__c 
                                            WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                            AND DateDt__c >= :endMonthLastMonth
                                            AND DateDt__c < :endMonthLastMonth.addMonths(1)
                                            GROUP BY SalesAreaLkp__c]){
                                                SalesPlanWrapper wrapperAux = revenueMap.get((Id)thisMonthRes.get('av')); 
                                                wrapperAux.salesPlan.RevenueNmb__c = thisMonthRes.get('rev') != null ? (Decimal)thisMonthRes.get('rev') : 0;
                                                wrapperAux.currentMonthRevenue = thisMonthRes.get('rev') != null ? (Decimal)thisMonthRes.get('rev') : 0;
                                                
                                                if(wrapperAux.currentMonthRevenue != 0 || wrapperAux.currentMonthRevenue != null){
                                                    summaryCurrentMonthClients += 1;
                                                    
                                                    if(areasSalesWithPlan.containsKey((Id)thisMonthRes.get('av'))){
                                                        summaryTotalRolPlan += wrapperAux.currentMonthRevenue;
                                                        
                                                        if(campaignMap.containsKey(areasSalesWithPlan.get((Id)thisMonthRes.get('av')).CampaignGroupLkp__c)){
                                                            summaryRolPlanCampaign += wrapperAux.currentMonthRevenue;
                                                            
                                                        } else {                                                        
                                                            if(areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'FI' ||
                                                               areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'OC')
                                                                summaryRolPlanFIOC += wrapperAux.currentMonthRevenue;
                                                            
                                                            if(areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'PE')
                                                                summaryRolPlanPE += wrapperAux.currentMonthRevenue;
                                                            
                                                            if(areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'CA' ||
                                                               areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'NO' ||
                                                               areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'RE' ||
                                                               areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'ME' ||
                                                               areasSalesWithPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == Null)                                                            
                                                                summaryRolPlanCANORE += wrapperAux.currentMonthRevenue;
                                                            
                                                        }
                                                    }
                                                    
                                                    if(areasSalesWOPlan.containsKey((Id)thisMonthRes.get('av'))){
                                                        summaryTotalRolWOPlan += wrapperAux.currentMonthRevenue;
                                                        
                                                        if(campaignMap.containsKey(areasSalesWOPlan.get((Id)thisMonthRes.get('av')).CampaignGroupLkp__c)){
                                                            summaryRolWOPlanCampaign += wrapperAux.currentMonthRevenue;
                                                            
                                                        } else {                                                        
                                                            if(areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'FI' ||
                                                               areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'OC')
                                                                summaryRolWOPlanFIOC += wrapperAux.currentMonthRevenue;
                                                            
                                                            if(areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'PE')
                                                                summaryRolWOPlanPE += wrapperAux.currentMonthRevenue;
                                                            
                                                            if(areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'CA' ||
                                                               areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'NO' ||
                                                               areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'RE' ||
                                                               areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == 'ME' ||
                                                               areasSalesWOPlan.get((Id)thisMonthRes.get('av')).AccountLkp__r.FidelityTxt__c == Null)                                                            
                                                            	summaryRolWOPlanCANORE += wrapperAux.currentMonthRevenue;
                                                            
                                                        }
                                                    }
                                                
                                                }
                                                system.debug(summaryCurrentMonthClients);
                                                revenueMap.put((Id)thisMonthRes.get('av'), wrapperAux);
                                            }   
        
        //COMPRA NO MESMO MÊS DO ANO ANTERIOR
        //COMPRA NOS MESES "AUXILIARES" TRIMESTRE ANO ANTERIOR
        Date endDtYear = quota.CurrentDateFml__c.addMonths(1);
        endDtYear = endDtYear.addYears(-1);
        
        Date endMonthYear = Date.newInstance(endDtYear.year(),endDtYear.month(), 1);
        
        
        if(quota.CurrentDateFml__c.month() == 1 || quota.CurrentDateFml__c.month() == 4 || quota.CurrentDateFml__c.month() == 7 || quota.CurrentDateFml__c.month() == 10){
            for(AggregateResult lastYearMonthRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                                    FROM SummarizedRevenue__c 
                                                    WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                                    AND DateDt__c >= :startMonthYear
                                                    AND DateDt__c < :endMonthYear
                                                    GROUP BY SalesAreaLkp__c]){            
                                                        SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearMonthRes.get('av'));
                                                        wrapperAux.quarterLastYearMonth1Revenue = (Decimal)lastYearMonthRes.get('rev');
                                                        wrapperAux.monthLastYearRevenue = (Decimal)lastYearMonthRes.get('rev');
                                                        revenueMap.put((Id)lastYearMonthRes.get('av'), wrapperAux);
                                                    } 
            for (AggregateResult lastYearTriAux1Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: endMonthYear
                                                       AND DateDt__c <: endMonthYear.addMonths(1)
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux1Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth2Revenue = (Decimal)lastYearTriAux1Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux1Res.get('av'), wrapperAux);
                                                       }
            for (AggregateResult lastYearTriAux2Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: endMonthYear.addMonths(1)
                                                       AND DateDt__c <: endMonthYear.addMonths(2)
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux2Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth3Revenue = (Decimal)lastYearTriAux2Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux2Res.get('av'), wrapperAux);
                                                       }                             
            
        }
        
        if(quota.CurrentDateFml__c.month() == 2 || quota.CurrentDateFml__c.month() == 5 || quota.CurrentDateFml__c.month() == 8 || quota.CurrentDateFml__c.month() == 11){
            
            for (AggregateResult lastYearTriAux2Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: startMonthYear.addMonths(-1)
                                                       AND DateDt__c <: startMonthYear
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux2Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth1Revenue = (Decimal)lastYearTriAux2Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux2Res.get('av'), wrapperAux);
                                                       }
            for(AggregateResult lastYearMonthRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                                    FROM SummarizedRevenue__c 
                                                    WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                                    AND DateDt__c >= :startMonthYear
                                                    AND DateDt__c < :endMonthYear
                                                    GROUP BY SalesAreaLkp__c]){            
                                                        SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearMonthRes.get('av'));
                                                        wrapperAux.quarterLastYearMonth2Revenue = (Decimal)lastYearMonthRes.get('rev');
                                                        wrapperAux.monthLastYearRevenue = (Decimal)lastYearMonthRes.get('rev');
                                                        revenueMap.put((Id)lastYearMonthRes.get('av'), wrapperAux);
                                                    } 
            for (AggregateResult lastYearTriAux1Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: endMonthYear
                                                       AND DateDt__c <: endMonthYear.addMonths(1)
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux1Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth3Revenue = (Decimal)lastYearTriAux1Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux1Res.get('av'), wrapperAux);
                                                       }
            
        } 
        
        if(quota.CurrentDateFml__c.month() == 3 || quota.CurrentDateFml__c.month() == 6 || quota.CurrentDateFml__c.month() == 9 || quota.CurrentDateFml__c.month() == 12){
            for (AggregateResult lastYearTriAux2Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: startMonthYear.addMonths(-2)
                                                       AND DateDt__c <: startMonthYear.addMonths(-1)
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux2Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth1Revenue = (Decimal)lastYearTriAux2Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux2Res.get('av'), wrapperAux);
                                                       }
            for (AggregateResult lastYearTriAux1Res : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev
                                                       FROM SummarizedRevenue__c
                                                       WHERE SalesAreaLkp__c IN : revenueMap.keySet()
                                                       AND DateDt__c >=: startMonthYear.addMonths(-1)
                                                       AND DateDt__c <: startMonthYear
                                                       GROUP BY SalesAreaLkp__c]){
                                                           SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearTriAux1Res.get('av'));
                                                           wrapperAux.quarterLastYearMonth2Revenue = (Decimal)lastYearTriAux1Res.get('rev');
                                                           revenueMap.put((Id)lastYearTriAux1Res.get('av'), wrapperAux);
                                                       }
            
            for(AggregateResult lastYearMonthRes : [SELECT SalesAreaLkp__c av, SUM(ROLRevenueNmb__c) rev 
                                                    FROM SummarizedRevenue__c 
                                                    WHERE SalesAreaLkp__c IN :revenueMap.keySet() 
                                                    AND DateDt__c >= :startMonthYear
                                                    AND DateDt__c < :endMonthYear
                                                    GROUP BY SalesAreaLkp__c]){            
                                                        SalesPlanWrapper wrapperAux = revenueMap.get((Id)lastYearMonthRes.get('av'));
                                                        wrapperAux.quarterLastYearMonth3Revenue = (Decimal)lastYearMonthRes.get('rev');
                                                        wrapperAux.monthLastYearRevenue = (Decimal)lastYearMonthRes.get('rev');
                                                        revenueMap.put((Id)lastYearMonthRes.get('av'), wrapperAux);
                                                    } 
            
        }
        
        
        
        
        //META DE CAMPANHA MÊS – meta do trimestre dividida por 3 e META DE CAMPANHA
        //QUANTO FALTA PARA ATINGIR META DO TRIMESTRE (GAP DO TRIMESTRE) – meta da campanha do trimestre atual menos soma do faturamento do trimestre atual
        List<AccountAreaSales__c> CpgGroupSalesAreas = [SELECT Id, CampaignGroupLkp__c 
                                                        FROM AccountAreaSales__c 
                                                        WHERE Id IN :revenueMap.keySet()
                                                       ];
        
       /* List<AccountGoal__c> quarterAccGoal = [	SELECT Id, Goal__c, Realized__c, CampaignLkp__c, AccountLkp__c, CampaignCalculationLkp__c
                                               FROM AccountGoal__c
                                               WHERE CampaignLkp__r.Type__c = 'Fixa'
                                               AND CampaignCalculationLkp__r.StartDate__c <= :quota.CurrentDateFml__c
                                               AND CampaignCalculationLkp__r.EndDate__c > :quota.CurrentDateFml__c
                                               AND CampaignMechanicsLkp__r.MainMechanic__c = TRUE
                                               AND AccountLkp__c IN (Select CampaignGroupLkp__c FROM AccountAreaSales__c WHERE Id IN :revenueMap.keySet())
                                              ];      
        
        for (AccountGoal__c qrtAccGoal: quarterAccGoal){
            for(AccountAreaSales__c slsArea: CpgGroupSalesAreas){
                if(slsArea.CampaignGroupLkp__c == qrtAccGoal.AccountLkp__c){
                    SalesPlanWrapper wrapperAux = revenueMap.get(slsArea.Id);
                    wrapperAux.avgAccGoal = (qrtAccGoal.Goal__c != null ? qrtAccGoal.Goal__c/3 : 0);
                    //wrapperAux.quarterAccGoal = qrtAccGoal.Goal__c;
                    //wrapperAux.accGoalQuarterGap = wrapperAux.quarterAccGoal - qrtAccGoal.Realized__c;
                    revenueMap.put(slsArea.Id,wrapperAux);
                }
            }
        }        */                          	        
        
        List<MonthlyGoal__C> monthlyGoals = [	SELECT Id, GoalNmb__c, RealizedFml__c, CampaignLkp__c, AccountMdt__c, CampaignCalculationLkp__c, MonthNmb__c
                                               FROM MonthlyGoal__c
                                               WHERE CampaignLkp__r.Type__c = 'Fixa'
                                               AND CampaignCalculationLkp__r.StartDate__c <= :quota.CurrentDateFml__c
                                               AND CampaignCalculationLkp__r.EndDate__c > :quota.CurrentDateFml__c
                                               AND CampaignMechanicsLkp__r.MainMechanic__c = TRUE
                                               AND AccountMdt__c IN (Select CampaignGroupLkp__c FROM AccountAreaSales__c WHERE Id IN :revenueMap.keySet())
                                              ];          
        
        for (MonthlyGoal__C monGoal: monthlyGoals){
            for(AccountAreaSales__c slsArea: CpgGroupSalesAreas){
                if((slsArea.CampaignGroupLkp__c == monGoal.AccountMdt__c) && (quota.CurrentDateFml__c.month() == monGoal.MonthNmb__c)){
                    SalesPlanWrapper wrapperAux = revenueMap.get(slsArea.Id);
                    wrapperAux.avgAccGoal = (monGoal.GoalNmb__c != null ? monGoal.GoalNmb__c : 0);
                    revenueMap.put(slsArea.Id,wrapperAux);
                }
            }
        }           
        //QUANTO FALTA PARA ATINGIR META YTD (GAP ACUMULADO DO ANO) – meta da campanha do Ano atual menos soma do faturamento do ano atual
        /*
Date startYearGoal = Date.newInstance(quota.CurrentDateFml__c.year(),1,1);
Date endYearGoal = Date.newInstance(quota.CurrentDateFml__c.year(),12,31); 

List<AggregateResult> yearGoalList = [	SELECT SUM(Goal__c) yearGoal, SUM(Realized__c) yearRev, AccountLkp__c acc                                                 
FROM AccountGoal__c
WHERE CampaignLkp__r.Type__c = 'Fixa'
AND CampaignCalculationLkp__r.StartDate__c >= :startYearGoal
AND CampaignCalculationLkp__r.EndDate__c <= :endYearGoal
AND AccountLkp__c IN (Select CampaignGroupLkp__c FROM AccountAreaSales__c WHERE Id IN :revenueMap.keySet()) 
GROUP BY AccountLkp__c
];


for(AggregateResult yearGoal: yearGoalList){                
for(AccountAreaSales__c slsArea: CpgGroupSalesAreas){
if(slsArea.CampaignGroupLkp__c == yearGoal.get('acc')){
SalesPlanWrapper wrapperAux = revenueMap.get(slsArea.Id);
wrapperAux.accGoalYearGap = (Decimal)yearGoal.get('yearGoal') - (Decimal)yearGoal.get('yearRev');
revenueMap.put(slsArea.Id,wrapperAux);
}
}
}                						        
*/
        
        List<SalesPlanning__c> auxPlnList = getPlanList();

		List<SalesPlanWrapper> auxResults = revenueMap.values();
        auxResults.sort();        
        
        
        Integer addedPlans = 0;                  
        
        //for(SalesPlanWrapper auxWrapper : auxResults){	
        for(Integer i = (pageNum - 1) * pageSize; i <  auxResults.size() && addedPlans < pageSize; i++){
			SalesPlanWrapper auxWrapper = auxResults[i];
            for(SalesPlanning__c auxSalesPlan : auxPlnList){
                if(auxWrapper.SalesPlan.AccountAreaSalesLkp__r.Id == auxSalesPlan.AccountAreaSalesLkp__r.Id){                    
                    results.add(auxWrapper);
                    addedPlans++;
                    break;
                }
            }
        }
        //results.addAll(revenueMap.values());
                         
        return results;
        
    }    
    
    public Double getRemainingAmount(){
        
        sumValue = 0;
        //analisa os valores dos planejamentos que estão sendo criados.            
        for (SalesPLanning__c planValue: masterPlanList){            
            if(planValue.TotalValueNmb__c != null){
                sumValue = sumValue + planValue.TotalValueNmb__c;
            } else {
                planValue.TotalValueNmb__c = 0;
                sumValue = sumValue + planValue.TotalValueNmb__c;
            }
        }
        system.debug('run');
        remainingAmount = quota.TotalValueNmb__c - sumValue;                             
        
        return remainingAmount;
        
    }    
    
    // Opções de Filtro
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> filterOptions = new List<SelectOption>();
        filterOptions.add(new SelectOption('','Nenhum'));
        filterOptions.add(new SelectOption('AccountCityTxt__c','Cidade'));
        filterOptions.add(new SelectOption('FidelityTxt__c', 'Fidelidade'));
        //filterOptions.add(new SelectOption('AccountPostalCodeTxt__c','CEP'));
        filterOptions.add(new SelectOption('CampaignLkp__c','Campanha'));
        filterOptions.add(new SelectOption('ChannelPVCTxt__c','Canal'));
        return filterOptions;
    }
    
    public List<SelectOption> getFilterValues() {
        
        List<SelectOption> filterValues = new List<SelectOption>();
        filterValues.add(new SelectOption('','Nenhum'));
        
        Set<String> fieldValues = new Set<String>();        
        
        if(planFilter == 'AccountCityTxt__c'){
            for(SalesPlanning__c plan: masterPlanList){
                fieldValues.add(plan.AccountCityTxt__c);
            }
            for(string value: fieldValues){
                if(value != null){
                    filterValues.add(new SelectOption(value,value));
                }            
            }
            return filterValues;
        }
        
        if(planFilter == 'AccountPostalCodeTxt__c'){
            for(SalesPlanning__c plan: masterPlanList){
                fieldValues.add(plan.AccountPostalCodeTxt__c);
            }
            for(string value: fieldValues){
                if(value != null){
                    filterValues.add(new SelectOption(value,value));
                }            
            }
            return filterValues;
        }
        
        if(planFilter == 'CampaignLkp__c'){
            Map<String, String> mapValues = new Map<String, String>();
            for(SalesPlanning__c plan: masterPlanList){
                mapValues.put(plan.CampaignLkp__c, plan.CampaignLkp__r.Name);
            }
            for(string value: mapValues.keySet()){
                if(value != null){
                    filterValues.add(new SelectOption(value,mapValues.get(value)));
                }       
            }     
            return filterValues;
        }
        
        if(planFilter == 'ChannelPVCTxt__c'){
            for(SalesPlanning__c plan: masterPlanList){
                fieldValues.add(plan.ChannelPVCTxt__c);
            }
            for(string value: fieldValues){
                if(value != null){
                    filterValues.add(new SelectOption(value,value));
                }            
            }
            return filterValues;
        }
        
        if(planFilter == 'FidelityTxt__c'){            
            for(SalesPlanning__c plan: masterPlanList){
                system.debug(plan.FidelityTxt__c);
                fieldValues.add(plan.FidelityTxt__c);
            }
            for(string value: fieldValues){
                if(value != null){
                    filterValues.add(new SelectOption(value,value));
                }            
            }
            return filterValues;
        }
        
        else{
            return null;
        }
    }
    
    public List<SelectOption> getPageNums(){
        List<SelectOption> listAux = new List<SelectOption>();
        /*filterValues.add(new SelectOption('','Nenhum'));

Set<String> fieldValues = new Set<String>();        

if(planFilter == 'AccountCityTxt__c'){
for(SalesPlanning__c plan: masterPlanList){
fieldValues.add(plan.AccountCityTxt__c);
}
for(string value: fieldValues){
if(value != null){
filterValues.add(new SelectOption(value,value));
}            
}
*/		
        system.debug(maxPages);
        for(Integer i = 1; i <= maxPages; i++){
            listAux.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return listAux;
    }
    /*
public void deleteRow() {

rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));        
del = planList.remove(rowIndex);

}*/
    
    public void doSave(){          
        
        List<SalesPlanning__c> upstPlanList = new List<SalesPlanning__c>();
        List<SalesPlanning__c> delPlanList = new List<SalesPlanning__c>();
        
        system.debug(planList);
        
        sumValue = 0;
        
        try{                                                                                              
            for(SalesPlanning__c plan : masterPlanList){
                if(plan.TotalValueNmb__c > 0){
                    upstPlanList.add(plan);
                    sumValue = sumValue + plan.TotalValueNmb__c;
                } else {
                    if(plan.Id != null){
                        delPlanList.add(plan);
                        plan.TotalValueNmb__c = 0;
                        sumValue = sumValue + plan.TotalValueNmb__c;      
                    }
                }
            }
            
            if(sumValue > quota.TotalValueNmb__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Os planejamentos de vendas criados tem valor total maior do que o da cota de origem.'));             
            }
            if(sumValue < quota.TotalValueNmb__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sua cota não foi completamente distribuída entre os planejamentos de vendas.'));             
            }
            if(sumValue == quota.TotalValueNmb__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Os planejamentos de vendas foram criados com sucesso!'));
            }
            
            upsert upstPlanList;
            delete delPlanList;
            for(SalesPlanning__c plan : delPlanList){
                plan.Id = null;
            }
            
        } catch (Exception ex){
            ApexPages.addMessages(ex);            
        }        
    }
    
    
    //Variáveis de Tarefa:        
    public SalesPlanning__c selectedPlan {get;set;}    
    public String planKey {get;set;}
    public Id selectedPlanId {get;set;}	            
    public DateTime eventDate {get;set;}
    public boolean isRecurrent {get;set;}
    public DateTime limitDate {get;set;}
    public String recurrenceTypeString {get;set;}
    public String trdMktActionString {get;set;}
    public String priority1String {get;set;}
    public String priority2String {get;set;}
    public String priority3String {get;set;}
    public String customerLossReasonString {get;set;}
    
    
    public PageReference setSelectedPlan(){
        
        //planKey = ApexPages.currentPage().getParameters().get('planningKey');
        system.debug(ApexPages.currentPage().getParameters().get('planningKey'));
        system.debug(planKey);
        
        Map<String, Id> createdPlansMap = new Map<String, Id>();
        
        for(SalesPlanning__c createdPlan: masterPlanList){
            createdPlansMap.put(createdPlan.AccountAreaSalesLkp__r.Name + createdPlan.QuotaLkp__r.Name, createdPlan.Id);
            system.debug('Planejamentos: '+createdPlan);
        }
        
        system.debug('Mapa de Planejamento: '+createdPlansMap);               
        
        selectedPlanId = createdPlansMap.get(planKey);
        return null;
    } 
    
    @RemoteAction
    global static String doSaveEventRemote(
        String salesAreaId, String dateTimeString, String durationString, String trdMktActionString, String priority1String, String priority2String,
        String priority3String, String customerLossReasonString, String guestId, Boolean isRecurrent, string recurrenceTypeString, string limitDateString)
    {
        AccountAreaSales__c salesArea = [SELECT Id, SellerLkp__r.UserLkp__c, AccountLkp__c, AccountLkp__r.Name, AccountLkp__r.BillingStreet, AccountLkp__r.BillingStateCode, 
                                         AccountLkp__r.BillingCountryCode, AccountLkp__r.BillingPostalCode
                                         FROM AccountAreaSales__c WHERE Id =: salesAreaId];
        system.debug(salesArea);
        system.debug(guestId);
        Integer durationNumber = durationString.isNumeric() ? Integer.valueOf(durationString) : 0;                
        
        if(durationNumber == 0){
            return 'Duração Inválida. Por favor insira um valor inteiro válido (em minutos)';
        }
        Boolean hasGuest = false;
        system.debug(dateTimeString);
        System.debug(limitDateString);
        DateTime eventDate = System.now();
		DateTime limitDate = System.now();
        system.debug(limitDate);
        try{
            System.debug(dateTimeString);
            dateTimeString = '"'+dateTimeString+'"';
            System.debug(dateTimeString);
            //eventDate = Datetime.valueOf(dateTimeString);
            eventDate = (DateTime)JSON.deserialize(dateTimeString,DateTime.class);
            System.debug(limitDateString);
            if(isRecurrent){
                limitDateString = '"'+limitDateString+'"';
                limitDate = (DateTime)JSON.deserialize(limitDateString,DateTime.class);
            	system.debug(limitDate);
            } else{
                limitDate = null;
            }
            //eventDate = DateTime.parse(dateTimeString);
        }
        catch(Exception e){
            return 'Data Inválida, favor revisar';
        }
        string eventDescription = 'Ação de Trade Marketing: ' + trdMktActionString + '\r\n' +
            'Prioridade 1: ' + priority1String + '\r\n' +
            'Prioridade 2: ' + priority2String + '\r\n' +
            'Prioridade 3: ' + priority3String + '\r\n' +
            'Motivo de Perda do Cliente: ' + customerLossReasonString;
        
        Event newEvt = new Event();
        newEvt.Subject = 'Visita Programada - ' + salesArea.AccountLkp__r.Name;
        //newEvt.Subject = 'Visita Programada - ' + salesArea.AccountLkp__r.Name;
        newEvt.Status__c = 'Planejada';        
        newEvt.OwnerId = salesArea.SellerLkp__r.UserLkp__c;
        newEvt.WhatId = salesArea.Id;
        newEvt.ActivityDateTime = eventDate;		    
        newEvt.DurationInMinutes = durationNumber;
        system.debug('recorrente: '+isRecurrent);
        newEvt.IsRecurrentBln__c = isRecurrent;
        newEvt.RecurrenceTypeTxt__c = recurrenceTypeString;
        newEvt.RecurrenceLimitDte__c = limitDate;        
        newEvt.AccountTxt__c = salesArea.AccountLkp__r.Name;
        newEvt.Location = salesArea.AccountLkp__r.BillingStreet + ' - ' + salesArea.AccountLkp__r.BillingStateCode + ' - ' + salesArea.AccountLkp__r.BillingCountryCode; 
        newEvt.Description = eventDescription;        
        try{
            newEvt.GuestUserLkp__c = guestId;
            hasGuest = true;
        }
        catch(exception e){
            hasGuest = false;
        }
        
        List<Event> listRecurrentEvents =  new List<Event>();                
        
        if (newEvt.isRecurrentBln__c == true && newEvt.RecurrenceCreatedBln__c == false){
            for(DateTime evntDate = getNextDate(newEvt.ActivityDateTime, newEvt.RecurrenceTypeTxt__c); evntDate < newEvt.RecurrenceLimitDte__c; evntDate = getNextDate(evntDate, newEvt.RecurrenceTypeTxt__c)){                
                Event recurringEvnt = new Event();
                recurringEvnt.Subject = newEvt.Subject;
                recurringEvnt.Status__c = 'Planejada';
                recurringEvnt.OwnerId = newEvt.OwnerId;
                recurringEvnt.WhatId = newEvt.WhatId;
                recurringEvnt.ActivityDateTime = evntDate;		    
                recurringEvnt.DurationInMinutes = newEvt.DurationInMinutes;              
                recurringEvnt.IsRecurrentBln__c = false;
                recurringEvnt.RecurrenceCreatedBln__c = true;
                recurringEvnt.RecurrenceTypeTxt__c = newEvt.RecurrenceTypeTxt__c;
                recurringEvnt.RecurrenceLimitDte__c = newEvt.RecurrenceLimitDte__c;        
                recurringEvnt.AccountTxt__c = newEvt.AccountTxt__c;
                recurringEvnt.Location = newEvt.Location; 
                recurringEvnt.Description = newEvt.Description;                
                
                listRecurrentEvents.add(recurringEvnt);
            }
        }
        
        system.debug(listRecurrentEvents);        
        
        
        
        try{           
            insert newEvt;                        
            
            insert listRecurrentEvents;
            
            if(hasGuest){
                EventRelation evRel = new EventRelation(EventId = newEvt.Id,
                                                        RelationId = guestId
                                                       );
                insert evRel;
            }
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'A visita foi agendada com sucesso! Para criar uma nova vista, altere os dados e clique novamente em "Criar Visita"'));
            return 'A <a href="/' + newEvt.Id + '" target="_blank">visita </a> foi agendada com sucesso! Para criar uma nova vista, altere os dados e clique novamente em Criar Visita';
        } catch (DmlException ex){
            return ex.getDmlMessage(0);
            //ApexPages.addMessages(ex);
        }
        
    }
    
    private static DateTime getNextDate(DateTime inicialDate, string recurrenceType){
        DateTime nextDate = inicialDate;
        if (recurrenceType == 'Semanal')
        	nextDate = Datetime.newInstance(inicialDate.year(), inicialDate.month(), inicialDate.day() + 7, inicialDate.hour(), inicialDate.minute(), inicialDate.second());
        if (recurrenceType == 'Quinzenal')
        	nextDate = Datetime.newInstance(inicialDate.year(), inicialDate.month(), inicialDate.day() + 14, inicialDate.hour(), inicialDate.minute(), inicialDate.second());
        if (recurrenceType == 'Mensal')
        	nextDate = Datetime.newInstance(inicialDate.year(), inicialDate.month() + 1, inicialDate.day(), inicialDate.hour(), inicialDate.minute(), inicialDate.second());
        if(recurrenceType == 'Trimestral')
            nextDate = Datetime.newInstance(inicialDate.year(), inicialDate.month() + 3, inicialDate.day(), inicialDate.hour(), inicialDate.minute(), inicialDate.second());
        
        return nextDate;        
    }
    
    
    /*public void doSaveEvent (){     
selectedPlanId = 'a173D000000ONM8QAO';
SalesPlanning__c selectedPlan = [SELECT Id, AccountAreaSalesLkp__r.AccountLkp__c, AccountAreaSalesLkp__r.AccountLkp__r.Name, QuotaLkp__r.SellerLkp__r.UserLkp__c,
QuotaLkp__r.SellerLkp__r.UserLkp__r.Name
FROM SalesPlanning__c
WHERE Id =: selectedPlanId
];        
eventDate = System.Now();
Event newEvent = new Event();
if(selectedPlanId != null){ 
newEvent.Subject = 'Visita Programada';        
newEvent.OwnerId = selectedPlan.QuotaLkp__r.SellerLkp__r.UserLkp__c;
newEvent.WhatId = selectedPlan.AccountAreaSalesLkp__r.AccountLkp__c;
newEvent.ActivityDateTime = eventDate;    
newEvent.DurationInMinutes = 120;
}

insert newEvent;
}*/
    
    public list<SelectOption> getTrdMktActions (){
        List<SelectOption> trdMktActions = new List<SelectOption>();
        trdMktActions.add(new SelectOption('Nenhum', 'Nenhum'));
        
        Schema.DescribeFieldResult fieldResult =
            SalesPlanning__c.TradeMktActionTxt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            trdMktActions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return trdMktActions;
    }
    
    public list<SelectOption> getPriority1 (){
        List<SelectOption> priority1 = new List<SelectOption>();        
        
        Schema.DescribeFieldResult fieldResult =
            SalesPlanning__c.Priority1Txt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            priority1.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return priority1;
    }
    
    public list<SelectOption> getPriority2 (){
        List<SelectOption> priority2 = new List<SelectOption>();
        priority2.add(new SelectOption('Nenhum', 'Nenhum'));        
        
        Schema.DescribeFieldResult fieldResult =
            SalesPlanning__c.Priority1Txt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            priority2.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return priority2;
    } 
    
    public list<SelectOption> getCustomerLossReason (){
        List<SelectOption> customerLossReason = new List<SelectOption>();
        customerLossReason.add(new SelectOption('Nenhum', 'Nenhum'));
        
        Schema.DescribeFieldResult fieldResult =
            SalesPlanning__c.CustomerLossReasonTxt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            customerLossReason.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return customerLossReason;
    }
    
    public list<SelectOption> getRecurrenceTypes (){
        List<SelectOption> recurrenceTypes = new List<SelectOption>();       
        
        Schema.DescribeFieldResult fieldResult =
            Event.RecurrenceTypeTxt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            recurrenceTypes.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return recurrenceTypes;
    }
    
    //Wrapper para Histórico
    public class SalesPlanWrapper implements Comparable {
        public Boolean hasEvt {get;set;}
        public Event evt{get;set;}
        public SalesPlanning__c salesPlan{get;set;}
        public Decimal quarterAvgRevenue{get;set;}
        public Decimal yearAvgRevenue{get;set;}
        public Decimal semesterAvgRevenue{get;set;}
        public Decimal lastMonthRevenue{get;set;}
        public Decimal monthLastYearRevenue{get;set;}
        //public Decimal quarterLastYearAux1Revenue {get;set;}
        //public Decimal quarterLastYearAux2Revenue {get;set;}
        public Decimal quarterLastYearMonth1Revenue {get;set;}
        public Decimal quarterLastYearMonth2Revenue {get;set;}
        public Decimal quarterLastYearMonth3Revenue {get;set;}
        public Decimal avgAccGoal{get;set;}
        public Decimal quarterAccGoal{get;set;}
        public Decimal accGoalQuarterGap{get;set;}
        public Decimal accGoalYearGap{get;set;}                
        public Decimal currentMonthRevenue{get;set;}
        
        public SalesPlanWrapper(SalesPlanning__c salesPlan){
            this.hasEvt = false;
            this.evt = new Event();
            this.salesPlan = salesPlan;
            this.quarterAvgRevenue = 0;
            this.yearAvgRevenue = 0;
            this.semesterAvgRevenue = 0;
            this.lastMonthRevenue = 0;
            this.monthLastYearRevenue = 0;
            this.quarterLastYearMonth1Revenue = 0;
            this.quarterLastYearMonth2Revenue = 0;
            this.quarterLastYearMonth3Revenue = 0;
            this.avgAccGoal = 0;
            this.quarterAccGoal = 0;
            this.accGoalQuarterGap = 0;
            this.accGoalYearGap = 0;
            this.currentMonthRevenue = salesPlan.RevenueNmb__c != null ? salesPlan.RevenueNmb__c : 0;
        }

        public integer compareTo(object obj){
            salesPlanWrapper sPWrapper = (salesPlanWrapper)(obj);
            if(this.semesterAvgRevenue > sPWrapper.semesterAvgRevenue){
                return -1;
            }
            if(this.semesterAvgRevenue == sPWrapper.semesterAvgRevenue){
                return 0;
            }
            
            return 1;                        
        }        
    }    
    
    
    /*@RemoteAction
global static void doSaveJS(Id quotaId, List<SalesPlanning__c> planList, Double existingTotalValue) {
try{
Quota__c quota = [SELECT Id FROM Quota__c WHERE Id = :quotaId];
Double sumValue = 0;
upsert planList;

for (SalesPLanning__c planValue: planList){            
if(planValue.TotalValueNmb__c != null){
sumValue = sumValue + planValue.TotalValueNmb__c;
} else {
planValue.TotalValueNmb__c = 0;
sumValue = sumValue + planValue.TotalValueNmb__c;
}
}                           
//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Os planejamentos de vendas foram criados com sucesso!'));            
//update quota;
} catch (Exception ex){
ApexPages.addMessages(ex);             
}         
}*/     
    
}