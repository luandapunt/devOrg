public class PVCController {
    /*
@AuraEnabled
public static AccountAreaSales__c getAccountData(Id accId){
return [SELECT QuarterRevenueTotalNmb__c,
MonthlyRevenueTotalNmb__c,
QuarterRevenueConnectionNmb__c,
MonthlyRevenueConnectionNmb__c,
QuarterRevenueTubesNmb__c,
QuarterRevenueRunnerNmb__c,
MonthlyRevenueRunnerNmb__c,
QuarterRevenueIrrigationNmb__c,
MonthlyRevenueIrrigationNmb__c,
MonthlySpecialProducts__c,
Id FROM  AccountAreaSales__c WHERE Id =:accId];
}
*/
    @AuraEnabled
    public static String getAccountHistory(Id accId, Id orderId){
        Date startDt = System.today().addMonths(-3);
        system.debug(startDt);
        Date startMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        system.debug(startMonth);
        
        AccountAreaSales__c av = [SELECT Id, AccountGroupFml__c, ChannelLkp__c, CodeSalesOrganizationTxt__c FROM AccountAreaSales__c WHERE Id =: accId];
        
        List<Id> listSalesAreasId = new List<Id>();
        listSalesAreasId.add(av.Id);
        if(av.AccountGroupFml__c != null){
            for(AccountAreaSales__c groupAV : [SELECT Id FROM AccountAreaSales__c WHERE AccountGroupFml__c =: av.AccountGroupFml__c])
                listSalesAreasId.add(groupAV.Id);
        }
        
        List<SummarizedRevenue__c> listRevenues = [SELECT Id, SalesAreaLkp__c, 
                                                   DateDt__c, 
                                                   MaterialGroupTxt__c, 
                                                   ROBSpecialNmb__c, 
                                                   ROBRevenueNmb__c,
                                                   ROBsIPILancamentoPVCNmb__c, 
                                                   ROBIrrigationMixNmb__c, 
                                                   ROBRunnerNmb__c, 
                                                   ActivitySectorTxt__c
                                                   FROM SummarizedRevenue__c WHERE SalesAreaLkp__c IN :listSalesAreasId AND DateDt__c >= :Date.newInstance(startDt.year(), startDt.month(), 1)];
        AccountSummary summaryAccount = new AccountSummary();
        for(SummarizedRevenue__c revenue : listRevenues){
            system.debug('date: ' + revenue.DateDt__c);
            system.debug('value: ' + revenue.ROBRevenueNmb__c);
            if(revenue.DateDt__c < startMonth){
                summaryAccount.QuarterRevenueTotalNmb += (revenue.ROBRevenueNmb__c != null ? revenue.ROBRevenueNmb__c : 0);
                summaryAccount.QuarterRevenueConnectionNmb += revenue.MaterialGroupTxt__c == '02' ? (revenue.ROBRevenueNmb__c != null ? revenue.ROBRevenueNmb__c : 0) : 0;
                summaryAccount.QuarterRevenueTubesNmb += (revenue.MaterialGroupTxt__c == '01' && revenue.ActivitySectorTxt__c == 'PR') ? (revenue.ROBRevenueNmb__c != null ? revenue.ROBRevenueNmb__c : 0) : 0;
                summaryAccount.QuarterRevenueTubesNmb -= (revenue.MaterialGroupTxt__c == '01' && revenue.ActivitySectorTxt__c == 'PR') ? (revenue.ROBsIPILancamentoPVCNmb__c != null ? revenue.ROBsIPILancamentoPVCNmb__c : 0) : 0;
                //summaryAccount.QuarterRevenueRunnerNmb += (revenue.ROBRunnerNmb__c != null ? revenue.ROBRunnerNmb__c : 0);
                summaryAccount.QuarterRevenueIrrigationNmb += (revenue.ROBIrrigationMixNmb__c != null ? revenue.ROBIrrigationMixNmb__c : 0);
            }
            else{
                summaryAccount.MonthlyRevenueTotalNmb += (revenue.ROBRevenueNmb__c != null ? revenue.ROBRevenueNmb__c : 0);
                summaryAccount.MonthlyRevenueConnectionNmb += revenue.MaterialGroupTxt__c == '02' ? (revenue.ROBRevenueNmb__c != null ? revenue.ROBRevenueNmb__c : 0) : 0;
                //summaryAccount.MonthlyRevenueRunnerNmb += (revenue.ROBRunnerNmb__c != null ? revenue.ROBRunnerNmb__c : 0);
                summaryAccount.MonthlyRevenueIrrigationNmb += (revenue.ROBIrrigationMixNmb__c != null ? revenue.ROBIrrigationMixNmb__c : 0);
            }
        }
        List<AggregateResult> listSpecialItems = [SELECT Count(Id), ProductLkp__c FROM OrderItem__c 
                                                  WHERE OrderMdt__r.AccountAreaSalesLkp__c = :accId 
                                                  AND ProductLkp__r.SpecialProductBln__c = TRUE 
                                                  AND InvoiceAmountNmb__c > 0 
                                                  AND InvoiceDateDte__c >= :startMonth
                                                  GROUP BY ProductLkp__c];
        summaryAccount.MonthlySpecialProducts = listSpecialItems.size();
        
        List<OrderItem__c> listOrderItems = [SELECT YPMI__c FROM OrderItem__c WHERE OrderMdt__c = :orderId];
        if(listOrderItems.size() > 0){
            
            Decimal YPMI = listOrderItems[0].YPMI__c;
            system.debug('YPMI: ' + YPMI);
            system.debug('Tubes history: ' + summaryAccount.QuarterRevenueTubesNmb);
            if(YPMI != null){
                if(summaryAccount.QuarterRevenueTubesNmb < (YPMI * 3)){
                    summaryAccount.QuarterRevenueTubesNmb = (YPMI * 3);    
                }
            }
        }
        
        List<AggregateResult> sumRunner = [SELECT SUM(ValueROBNoIPIFml__c) runnerRev, 
                                           OrderMdt__r.AccountAreaSalesLkp__c 
                                           FROM OrderItem__c 
                                           WHERE OrderMdt__r.AccountAreaSalesLkp__c = :accId
                                           AND ProductLkp__r.RunnerBln__c = TRUE
                                           AND OrderMdt__c != :orderId
                                           AND OrderMdt__r.OrderDateDte__c = THIS_MONTH
                                           GROUP BY OrderMdt__r.AccountAreaSalesLkp__c];
        if(sumRunner.size() > 0)
            summaryAccount.MonthlyRevenueRunnerNmb = (Decimal)sumRunner[0].get('runnerRev');
                
        List<BlockedItem__c> listNoDiscount = [SELECT Id, NoDiscountRangeNmb__c, UsesZPVCBln__c, ChannelDiscountNmb__c 
                                               FROM BlockedItem__c 
                                               WHERE SalesOrganizationTxt__c = :av.CodeSalesOrganizationTxt__c
                                               AND ChannelPVCLkp__c = :av.ChannelLkp__c
                                               AND RecordType.DeveloperName = 'NoDiscountRange'
                                              ];
        if(listNoDiscount.size() > 0){
            summaryAccount.NoDiscountRange = listNoDiscount[0].NoDiscountRangeNmb__c / 
                (!listNoDiscount[0].UsesZPVCBln__c && listNoDiscount[0].ChannelDiscountNmb__c != null? 
                 (1 - listNoDiscount[0].ChannelDiscountNmb__c/100) : 
                 1);
            
        }
        system.debug(JSON.serialize(summaryAccount));
        return JSON.serialize(summaryAccount);
    }
    
    @AuraEnabled
    public static Decimal getOrderAmount(Id orderId, String conditionCode){
        Decimal orderAmount = 0;
        String whereClause = '';
        
        if(conditionCode == 'YPME')
            whereClause = ' AND ProductLkp__r.MaterialGroup__c = \'02\' ';
        if(conditionCode == 'YPSO')
            whereClause = ' AND ProductLkp__r.SpecialProductBln__c = true ';
        if(conditionCode == 'YPXI')
            whereClause = ' AND ProductLkp__r.IrrigationBln__c = true ';
        if(conditionCode == 'YPMX')
            whereClause = ' AND ProductLkp__r.RunnerBln__c = true ';
        
        String query = ' SELECT Id, ';
        query += 'OrderQuantityNmb__c, ';
        query += 'LiquidNmb__c, ';
        query += 'PVCPriceNmb__c, ';
        query += 'ValueROBNoIPIFml__c, ';
        query += 'ProductLkp__r.ReleaseBln__c, ';
        query += 'ProductLkp__r.RunnerBln__c, ';
        query += 'ProductLkp__r.IrrigationBln__c, ';
        query += 'ProductLkp__r.SpecialProductBln__c, ';
        query += 'ProductLkp__r.ProductCodeTxt__c, ';
        query += 'ProductLkp__r.MaterialGroup__c ';
        query += 'FROM OrderItem__c ';
        query += 'WHERE OrderMdt__c = \'' + orderId + '\' ';
        query += whereClause;
        
        List<OrderItem__c> oItemList = Database.query(query);
        
        if(conditionCode == 'YPSO'){
            Order__c o = [SELECT Id, AccountLkp__c, AccountAreaSalesLkp__c FROM Order__c WHERE Id = :orderId ];
            //Pega todos os itens CPE faturados no mês corrente para o cliente em questão, coloca num Set, soma somente os itens que não estiverem no Set
            List<OrderItem__c> listItem = [SELECT Id, ProductLkp__r.ProductCodeTxt__c 
                                           FROM OrderItem__c 
                                           WHERE OrderMdt__r.AccountAreaSalesLkp__c = :o.AccountAreaSalesLkp__c
                                           AND InvoiceAmountNmb__c > 0 
                                           AND InvoiceDateDte__c = THIS_MONTH
                                           AND ProductLkp__r.SpecialProductBln__c = true
                                          ];
            Set<String> setCodes = new Set<String>();
            for(OrderItem__c item : listItem){
                setCodes.add(item.ProductLkp__r.ProductCodeTxt__c);
            }
            for(OrderItem__c oItem : oItemList){
                if(!setCodes.contains(oItem.ProductLkp__r.ProductCodeTxt__c))
                    orderAmount += 1;          
            }
        }
        else{
            for(OrderItem__c oItem : oItemList){
                //orderAmount += oItem.OrderQuantityNmb__c * (oItem.PVCPriceNmb__c != null ? oItem.PVCPriceNmb__c : oItem.LiquidNmb__c);          
                orderAmount += oItem.ValueROBNoIPIFml__c;
            }
        }
        return orderAmount;
    }
    
    @AuraEnabled
    public static String applyDiscounts(Id orderId, String conditionCode, Decimal discountAmt, Decimal maxDiscount){
        try{
            List<OrderItem__c> oItemList = [SELECT Id, 
                                            LiquidNmb__c,
                                            LiquidIPINmb__c,
                                            ZPVC__c, 
                                            ZPVO__c,
                                            ZPME__c,
                                            ZPSO__c,
                                            ZPXI__c,
                                            ZPRO__c,
                                            ZCOT__c,
                                            XXES__c,
                                            ZVJ1__c
                                            FROM OrderItem__c
                                            WHERE OrderMdt__c = :orderId];
            System.debug('CONDITION CODE = '+conditionCode);
            String conditionApplied = conditionCode.replace('Y', 'Z') + '__c';
            System.debug('CONDITION APPLIED = '+conditionApplied);
            String conditionAllowed = conditionCode.replace('P', 'R') + '__c';
            System.debug('CONDITION ALLOWED = '+conditionAllowed);
            for(OrderItem__c oItem : oItemList){
                oItem.put(conditionApplied, discountAmt);
                oItem.put(conditionAllowed, maxDiscount);
                
                system.debug(oItem.get(conditionApplied));
                /*
                //oItem.PVCPriceNmb__c = oItem.ZPVC__c != null ? oItem.LiquidNmb__c * (1 - oItem.ZPVC__c/100) : oItem.LiquidNmb__c;
                oItem.PVCPriceNmb__c = oItem.ZPVO__c != null ? oItem.LiquidNmb__c * (1 - oItem.ZPVO__c/100) : oItem.LiquidNmb__c;
                oItem.PVCPriceNmb__c = oItem.ZPME__c != null ? oItem.PVCPriceNmb__c * (1 - oItem.ZPME__c/100) : oItem.PVCPriceNmb__c;
                oItem.PVCPriceNmb__c = oItem.ZPSO__c != null ? oItem.PVCPriceNmb__c * (1 - oItem.ZPSO__c/100) : oItem.PVCPriceNmb__c;
                oItem.PVCPriceNmb__c = oItem.ZPXI__c != null ? oItem.PVCPriceNmb__c * (1 - oItem.ZPXI__c/100) : oItem.PVCPriceNmb__c;
                oItem.PVCPriceNmb__c = oItem.ZVJ1__c != null ? oItem.PVCPriceNmb__c * (1 - oItem.ZVJ1__c/100) : oItem.PVCPriceNmb__c;
                
                //oItem.PVCPriceIPINmb__c = oItem.ZPVC__c != null ? oItem.LiquidIPINmb__c * (1 - oItem.ZPVC__c/100) : oItem.LiquidIPINmb__c;
                oItem.PVCPriceIPINmb__c = oItem.ZPVO__c != null ? oItem.LiquidIPINmb__c * (1 - oItem.ZPVO__c/100) : oItem.LiquidIPINmb__c;
                oItem.PVCPriceIPINmb__c = oItem.ZPME__c != null ? oItem.PVCPriceIPINmb__c * (1 - oItem.ZPME__c/100) : oItem.PVCPriceIPINmb__c;
                oItem.PVCPriceIPINmb__c = oItem.ZPSO__c != null ? oItem.PVCPriceIPINmb__c * (1 - oItem.ZPSO__c/100) : oItem.PVCPriceIPINmb__c;
                oItem.PVCPriceIPINmb__c = oItem.ZPXI__c != null ? oItem.PVCPriceIPINmb__c * (1 - oItem.ZPXI__c/100) : oItem.PVCPriceIPINmb__c;
                oItem.PVCPriceIPINmb__c = oItem.ZVJ1__c != null ? oItem.PVCPriceIPINmb__c * (1 - oItem.ZVJ1__c/100) : oItem.PVCPriceIPINmb__c;
                
                oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c * 
                    (1 - (oItem.ZPRO__c != null ? oItem.ZPRO__c/100 : 0)) * 
                    (1 - (oItem.ZCOT__c != null ? oItem.ZCOT__c/100 : 0)) * 
                    (1 - (oItem.XXES__c != null ? oItem.XXES__c/100 : 0));
                oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c * 
                    (1 - (oItem.ZPRO__c != null ? oItem.ZPRO__c/100 : 0)) * 
                    (1 - (oItem.ZCOT__c != null ? oItem.ZCOT__c/100 : 0)) * 
                    (1 - (oItem.XXES__c != null ? oItem.XXES__c/100 : 0));
*/
            }
            system.debug(oItemList);
            update oItemList;
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static Order__c getOrderData(Id orderId){
        Order__c o = [SELECT Id, PVCStringTxt__c, AccountAreaSalesLkp__c, OutdatedPVCBln__c, TotalLiquidPriceNmb__c FROM Order__c WHERE Id =: orderId];
        
        return o;
    }
    
    @AuraEnabled
    public static String resetPVCDiscounts(Id orderId){
        Order__c o = [SELECT Id, PVCStringTxt__c, AccountAreaSalesLkp__c, OutdatedPVCBln__c FROM Order__c WHERE Id =: orderId];
        List<OrderItem__c> oItemToUpdate = new List<OrderItem__c>();
        for(OrderItem__c oItem : [SELECT Id FROM OrderItem__c WHERE OrderMdt__c =: orderId]){
            oItem.ZPVO__c = 0;
            oItem.ZPME__c = 0;
            oItem.ZPSO__c = 0;
            oItem.ZVJ1__c = 0;
            oItem.ZPXI__c = 0;
            oItemToUpdate.add(oItem);
        }
        try{
            update oItemToUpdate;
            o.YPME__c = 0;
            o.YPSO__c = 0;
            o.YPVO__c = 0;
            o.YPXI__c = 0;
            o.YVJ1__c = 0;
            o.OutdatedPVCBln__c = false;
            update o;
        }
        catch(Exception e){
            return e.getMessage();
        }
        return 'SUCCESS';
    }
    
    private class AccountSummary{
        public Decimal QuarterRevenueTotalNmb;
        public Decimal MonthlyRevenueTotalNmb;
        public Decimal QuarterRevenueConnectionNmb;
        public Decimal MonthlyRevenueConnectionNmb;
        public Decimal QuarterRevenueTubesNmb;
        public Decimal QuarterRevenueRunnerNmb;
        public Decimal MonthlyRevenueRunnerNmb;
        public Decimal QuarterRevenueIrrigationNmb;
        public Decimal MonthlyRevenueIrrigationNmb;
        public Decimal MonthlySpecialProducts;
        public Decimal NoDiscountRange;
        public Decimal OrderTotal;
        public AccountSummary(){
            this.QuarterRevenueTotalNmb = 0;
            this.MonthlyRevenueTotalNmb = 0;
            this.QuarterRevenueConnectionNmb = 0;
            this.MonthlyRevenueConnectionNmb = 0;
            this.QuarterRevenueTubesNmb = 0;
            this.QuarterRevenueRunnerNmb = 0;
            this.MonthlyRevenueRunnerNmb = 0;
            this.QuarterRevenueIrrigationNmb = 0;
            this.MonthlyRevenueIrrigationNmb = 0;
            this.MonthlySpecialProducts = 0;
            this.NoDiscountRange = 0;
            this.OrderTotal = 0;
        }
    }
}