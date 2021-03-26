public class QuotaIntegrationUtils {
    
    @AuraEnabled
    public static void execBatchApex(){
        System.debug('AAAAAAAAAAA');
        Batch_QuotaDailyUpdate myBatch = new Batch_QuotaDailyUpdate();
        Database.executeBatch(myBatch);
    }
    
    public static void getQuota(List<Seller__c> sellerList, List<Date> dateList){
        System.debug('LISTA VENDEDORES '+sellerList.size()+' registros');
        //System.debug(sellerList);
        
        List<String> sellerCodeList = new List<String>();
        List<Id> sellerIdList = new List<Id>();
        List<String> dateStringList = new List<String>();
        Map<String, Seller__c> sellerMap = new Map<String, Seller__c>();
        
        for(Seller__c seller : sellerList){
            String sellerCode = seller.SellerNumberNmb__c.leftPad(8, '0');
        	sellerCodeList.add(sellerCode);
			sellerIdList.add(seller.Id);
            sellerMap.put(sellerCode, seller);
        }
        
        //sellerCodeList.add('00001700');
        
        for(Date dte : dateList){
            String strDate = dte.year() + String.valueOf(dte.month()).leftPad(2, '0');
            dateStringList.add(strDate);
        }
        
        HTTPResponse res = SAPInteg.getQuotas(sellerCodeList, dateStringList);
        System.debug('RECEBIDO DO SAP: ');
        System.debug(res.getBody());
        System.debug('##########STATUS:'+res.getStatusCode());
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String,Object> quotas = (Map<String,Object>)jsonObj.get('T_ZPH_PREM_OUT');        
            //System.debug(quotas);
            
            List<Object> quotaListJSON = (List<Object>) quotas.get('item');
            //System.debug(quotaListJSON);
            
            List<Quota__c> quotaList = new List<Quota__c>();
            
            for(Object quotaJSON : quotaListJSON){
                Map<String, Object> quotaMap = (Map<String, Object>) quotaJSON;
                //System.debug(quotaJSON);
                
                Quota__c quota = new Quota__c();
                quota.OrderBacklogNmb__c = quotaMap.get('VLCART') instanceof String ? Decimal.valueOf((String)quotaMap.get('VLCART')) : (Decimal)quotaMap.get('VLCART');
                quota.QuotaTypeTxt__c = (String)quotaMap.get('TIPOPREM');
                
                Decimal quotaRevenue = quotaMap.get('REALIZADO') instanceof String ? Decimal.valueOf((String)quotaMap.get('REALIZADO')) : (Decimal)quotaMap.get('REALIZADO');
                Decimal quotaTotalValue = quotaMap.get('PREVISTO') instanceof String ? Decimal.valueOf((String)quotaMap.get('PREVISTO')) : (Decimal)quotaMap.get('PREVISTO');
    
                quota.RevenueNmb__c = quotaRevenue;
                quota.TotalValueNmb__c = quotaTotalValue;
                
                String quotaDate = String.valueOf((Decimal)quotaMap.get('SPMON'));
                String quotaYear = quotaDate.substring(0, 4);
                String quotaMonth = quotaDate.substring(4, 6);
                quota.CurrentMonthTxt__c = quotaMonth;
                quota.CurrentYearTxt__c = quotaYear;
                    
                String sellerSAPCode = (String)quotaMap.get('PERNR');
                sellerSAPCode = sellerSAPCode.replaceFirst('^0+', '');
                
                String sellerSAPCodeWith0 = (String)quotaMap.get('PERNR');
                if(sellerMap.containsKey(sellerSAPCodeWith0)){
                    //quota.SellerLkp__r = sellerMap.get(sellerSAPCodeWith0);
                    quota.SellerLkp__c = sellerMap.get(sellerSAPCodeWith0).Id;
                    quota.OwnerId = sellerMap.get(sellerSAPCodeWith0).UserLkp__c;
                }
                else{
                    System.debug('Não achou o Id do Vendedor com Cod SAP = '+sellerSAPCodeWith0);
                }
                
                String quotaIdentifier = sellerSAPCode + ' ' + quota.QuotaTypeTxt__c + ' ' + quota.CurrentMonthTxt__c + ' ' + quota.CurrentYearTxt__c;
                quota.IdentifierTxt__c = quotaIdentifier;
                
                //System.debug(quota);
                quotaList.add(quota);
            }
            System.debug('Recebido do SAP: '+quotaList.size()+' cotas de vendedores para os períodos');
            /*
            List<Quota__c> currentQuotaList = [SELECT Id, IdentifierTxt__c, CurrentMonthTxt__c, CurrentYearTxt__c, SellerLkp__c, SellerLkp__r.SellerNumberNmb__c 
                                               FROM Quota__c 
                                               WHERE SellerLkp__c IN :sellerIdList];
            
            Map<String, Quota__c> currentQuotaMap = new Map<String, Quota__c>();
            
            for(Quota__c currQuota: currentQuotaList){
                currentQuotaMap.put(currQuota.IdentifierTxt__c, currQuota);
            }
            
            System.debug('MAPA DE COTAS EXISTENTES:');
            for (String key : currentQuotaMap.keySet()) {
                Quota__c c = currentQuotaMap.get(key);
                System.debug(key + ' - '+c);
            }
            
            Integer quotaAtualizacao = 0;
            for(Quota__c quota: quotaList){
                String quotaKey = quota.IdentifierTxt__c;
                
                if (currentQuotaMap.containsKey(quotaKey)){
                    quota.Id = currentQuotaMap.get(quotaKey).Id;
                    System.debug('ESSA COTA JÁ EXISTE. DEVE ATUALIZAR '+quota.Id);
                    quotaAtualizacao++;
                }
                currentQuotaMap.put(quotaKey, quota);
            } 
            
            System.debug('Deve atualizar '+quotaAtualizacao+' cotas');
            */
            //System.debug(quotaList);
            Integer I = 0;
            System.debug('MAPA DE COTAS PARA O UPSERT:');
            for (Quota__c q : quotaList) {
                I++;
                System.debug('['+I+'] SellerId = '+q.SellerLkp__c+' ; OwnerId = '+q.OwnerId);
                
            }
            
            try{
                upsert quotaList IdentifierTxt__c;    
            }
            catch (DmlException e) {
                System.debug(e.getTypeName()+' - '+e.getMessage()+' - '+e.getStackTraceString());
            }            
        }
        else{
            
        }
    }
}