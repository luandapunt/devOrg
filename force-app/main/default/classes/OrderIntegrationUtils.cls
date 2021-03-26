public class OrderIntegrationUtils {
    @AuraEnabled
    public static String resendItems(Id orderId){
        List<OrderItem__c> oItemList = [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :orderId AND TotalGrossCostNmb__c = null];
        if(oItemList.size() == 0){
            return 'SUCCESS';
        }
        List<Id> oItemIds = new List<Id>();
        for(OrderItem__c oItem : oItemList){
            oItemIds.add(oItem.Id);
        }
        
        return createItemListOnSAP(orderId, oItemIds);
    }
    
    public static String getLog(Id orderId){
        String response = 'SUCCESS';
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        Order__c o = [SELECT Id, SAPGUIDTxt__c, ErrorMessageTxt__c FROM Order__c WHERE Id = :orderId];
        if(o.SAPGUIDTxt__c == null){
            return 'NO_GUID';
        }
        else{
            HttpResponse res = SAPInteg.GetLog(o.SAPGUIDTxt__c);
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug(res.getBody());
            Map<String, Object> logObj = (Map<String, Object>) jsonObj.get('ES_LOG');
            system.debug(logObj.get('DOCUMENTO'));
            if(logObj.get('DOCUMENTO') == null || logObj.get('DOCUMENTO') == '') return 'PROCESSING';
            
            Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('T_MSG');        
            system.debug(msgs);
            
            
            if(getType(msgs.get('item')) == 'Object'){
                Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MSGTY'));
                    o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MSGTY');
                }
            }
            else{
                List<Object> listRet = (List<Object>) msgs.get('item');
                system.debug(listRet);
                for(Object ret : listRet){
                    Map<String, Object> returnMap = (Map<String, Object>) ret;
                    if((String)returnMap.get('TYPE') == 'E'){
                        system.debug('ERRO: ' + (String)returnMap.get('MSGTY'));
                        o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MSGTY');
                        break;
                    }
                }
            }
            if(o.ErrorMessageTxt__c == null){
                o.CustomIDTxt__c =  StringUtils.removeLeftPadZeros((String)logObj.get('DOCUMENTO'));
                
                
                List<OrderItem__c> listItem = [SELECT Id, Name, ItemNumberTxt__c FROM OrderItem__c WHERE OrderMdt__c = :orderId];
                
                for(OrderItem__c item: listItem){
                    item.CustomIdTxt__c = StringUtils.removeLeftPadZeros((String)logObj.get('DOCUMENTO'))+StringUtils.removeLeftPadZeros(item.ItemNumberTxt__c);
                }
                
                skipVal.Skip__c = true;
                update skipVal;                
                
                update listItem;
                
            }
            else response = o.ErrorMessageTxt__c;
            o.SAPGUIDTxt__c = null;
            //o.CustomIdTxt__c = (String)jsonObj.get('SALESDOCUMENT');
            update o;
            
            skipVal.Skip__c = false;
            update skipVal;
            
        }
        return response;
    }
    
    @AuraEnabled
    public static Order__c getOrder(Id orderId) {
        return [SELECT Name, ErrorMessageTxt__c, CustomIDTxt__c, (SELECT Id, ErrorMessageTxt__c FROM Itens_da_Ordem__r) FROM Order__c WHERE Id = :orderId];
    }
    
    @AuraEnabled
    public static void resendQuoteHeader(Id orderId){
        System.debug('####resendQuoteHeader: '+orderId);
        createQuoteOnSAPFuture(orderId);
    }
    
    @future(callout=true)
    public static void createQuoteOnSAPFuture(Id orderId){
        createQuoteOnSAP(orderId);
    }
    
    public static void createQuoteOnSAP(Id orderId){
        Order__c o = [SELECT Id, CustomIdTxt__c, ErrorMessageTxt__c FROM Order__c WHERE Id =: orderId];
        
        HttpResponse res = SapInteg.createQuotation(orderId);
        system.debug(res.getBody());
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
            }
        }
        else{
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                    break;
                }
            }
        }
        if(o.ErrorMessageTxt__c == null)
            o.CustomIDTxt__c =  StringUtils.removeLeftPadZeros((String)jsonObj.get('SALESDOCUMENT')); 
            //o.CustomIdTxt__c = (String)jsonObj.get('SALESDOCUMENT');
        update o;
        
    }
    
    @future(callout=true)
    public static void createItemOnSAPFuture(Id orderId, Id oItemId){
        createItemOnSap(orderId, oItemId);
    }
    
    public static void createItemOnSAP(Id orderId, Id oItemId){
        Order__c o = [SELECT ID, PVCStringTxt__c, 
                      YPVO__c,
                      YPME__c,
                      YPSO__c,
                      YPXI__c,
                      YVJ1__c,
                      ErrorMessageTxt__c FROM Order__c WHERE Id = :orderId];
        OrderItem__c oItem = [SELECT Id, OrderMdt__r.CustomIdTxt__c, OrderQuantityNmb__c, ErrorMessageTxt__c, ProductLkp__r.ProductCodeTxt__c FROM OrderItem__c WHERE Id=:oItemId];
        List<Id> oItemIds = new List<Id>();
        oItemIds.add(oItem.Id);
        Decimal zpvc = 0;
        
        HttpResponse res = SapInteg.quotationChange(orderId, oItemIds, false);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                oItem.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
            }
        }
        else{
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    oItem.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                    break;
                }
            }
        }
        if(oItem.ErrorMessageTxt__c == null){
            List<String> conditionList = new List<String>{'YPRO', 'YCOT', 'ZMIN', 'YPMI', 
                'ZPVC', 'BX41', 'BX23', 'BX13', 'IPVA', 'ICVA', 'ISTS', 'ZCPG', 'ZGAB', 'ZGAN'};
                    res = SapInteg.getDetails(orderId, conditionList, oItem.Id); 
            
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                        
            
            Map<String, Object> conditionItem = (Map<String, Object>) jsonObj.get('ORDER_CONDITIONS_OUT');
            List<Object> listCondition = (List<Object>) conditionItem.get('item');
            for(Object condition : listCondition){
                Map<String, Object> conditionMap = (Map<String, Object>) condition;
                String conditionName = (String)conditionMap.get('COND_TYPE');
                String conditionValueType = getType(conditionMap.get('COND_VALUE'));
                if(conditionValueType == 'String'){
                    try{
                        if(conditionName == 'ZCPG')
                            oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                        else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13' || conditionName == 'ZGAB')
                            oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('CONDVALUE')));
                        else
                            oItem.put(conditionName+'__c', Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE'))));
                        system.debug('conditionName: ' + conditionName + '; condition_Percent: ' + conditionMap.get('COND_VALUE'));
                        system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                    }
                    catch (Exception e){
                        system.debug('ERROR: conditionName: ' + conditionName + '; condition_Percent: ' + conditionMap.get('COND_VALUE'));
                        system.debug('ERROR: conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                    }
                    if(conditionName == 'ZPVC') zpvc = Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                }
                else if(conditionValueType == 'Decimal' || conditionValueType == 'Integer'){
                    try{
                        if(conditionName == 'ZCPG')
                            oItem.put(conditionName+'__c', (Decimal)conditionMap.get('COND_VALUE'));
                        else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13')
                            oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('CONDVALUE')));
                        else
                            oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('COND_VALUE')));
                        
                        system.debug('conditionName: ' + conditionName + '; condition_Percent: ' + conditionMap.get('COND_VALUE'));
                        system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                    }
                    catch(Exception e){
                        system.debug('ERROR: conditionName: ' + conditionName + '; condition_Percent: ' + conditionMap.get('COND_VALUE'));
                        system.debug('ERROR: conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                    }
                    if(conditionName == 'ZPVC') zpvc = Math.abs((Decimal)conditionMap.get('COND_VALUE'));
                }
                
                
            }
            
            Map<String, Object> itemsItem = (Map<String, Object>) jsonObj.get('ORDER_ITEMS_OUT');
            Map<String, Object> itemMap = (Map<String, Object>) itemsItem.get('item');
            oItem.CustomIDTxt__c = StringUtils.removeLeftPadZeros((String)itemMap.get('DOC_NUMBER'))+StringUtils.removeLeftPadZeros((String)itemMap.get('ITM_NUMBER'));
            //oItem.CustomIDTxt__c = (String)itemMap.get('OBJ_NR_IT');
            //[LGrillo]: 29/01/2018
            //oItem.ItemNumberTxt__c = oItem.CustomIdTxt__c.right(6);
            oItem.ItemNumberTxt__c = (String)itemMap.get('ITM_NUMBER');
            //oItem.LiquidNmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'))/oItem.OrderQuantityNmb__c).setScale(4);
            //oItem.LiquidIPINmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'))/oItem.OrderQuantityNmb__c).setScale(4);
            oItem.LiquidNmb__c = getType(itemMap.get('SUBTOT_PP2')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP2')) : 0; 
            oItem.TotalGrossCostNmb__c = getType(itemMap.get('SUBTOT_PP5')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP5')) : 0;
            oItem.OriginalROBNoIPINmb__c = getType(itemMap.get('SUBTOT_PP5')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP1')) : 0;
            
            oItem.OriginalQuantityNmb__c = oItem.OrderQuantityNmb__c;
            String expCenterCode = (String)itemMap.get('SHIP_POINT');
            if(expCenterCode != null)
                oItem.ExpeditionCenterLkp__r = new ExpeditionCenter__c (CustomIdTxt__c = expCenterCode);
            oItem.DistributionCenterTxt__c = (String)itemMap.get('PLANT');
/*
            oItem.PVCPriceNmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
            oItem.PVCPriceNmb__c = o.YPME__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceNmb__c;
            oItem.PVCPriceNmb__c = o.YPSO__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceNmb__c;
            oItem.PVCPriceNmb__c = o.YPXI__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceNmb__c;
            oItem.PVCPriceNmb__c = o.YVJ1__c != null ? oItem.PVCPriceNmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceNmb__c;
            
            oItem.PVCPriceIPINmb__c = o.YPVO__c != null ? oItem.LiquidIPINmb__c * (1 - o.YPVO__c/100) : oItem.LiquidIPINmb__c;
            oItem.PVCPriceIPINmb__c = o.YPME__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceIPINmb__c;
            oItem.PVCPriceIPINmb__c = o.YPSO__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceIPINmb__c;
            oItem.PVCPriceIPINmb__c = o.YPXI__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceIPINmb__c;
            oItem.PVCPriceIPINmb__c = o.YVJ1__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceIPINmb__c;
*/

            oItem.ZPVO__c = o.YPVO__c;
            oItem.ZPME__c = o.YPME__c;
            oItem.ZPSO__c = o.YPSO__c;
            oItem.ZPXI__c = o.YPXI__c;
            oItem.ZVJ1__c = o.YVJ1__c;
            
            
            //oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c;
            //oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c;
            oItem.ZPRO__c = 0;
            oItem.ZCOT__c = 0;
            oItem.XXES__c = 0;
            
            if((getType(jsonObj.get('ORDER_COND_VAL_SCALE')) == 'Object' || zpvc != 0) && o.PVCStringTxt__c == null){
                o.PVCStringTxt__c = getPVC(jsonObj, zpvc);
            }
            
            res = SapInteg.getBottleneck(oItem.DistributionCenterTxt__c, oItem.ProductLkp__r.ProductCodeTxt__c);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('T_ZPH_FCUR_OUT')) == 'Object'){
                Map<String, Object> mainObj = (Map<String, Object>) jsonObj.get('T_ZPH_FCUR_OUT');
                if(getType(mainObj.get('item')) == 'Object'){
                    Map<String, Object> itemObj = (Map<String, Object>) mainObj.get('item');
                    system.debug(itemObj);
                    if(itemObj.get('ZGARGA') != null)
                        oItem.BottleneckDaysNmb__c = getType(itemObj.get('ZGARGA')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZGARGA')) : (Decimal) itemObj.get('ZGARGA');
                }
            }
            
            res = SapInteg.getLastPrice(oItemIds);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('E_S666')) == 'Object'){
                Map<String, Object> itemObj = (Map<String, Object>) jsonObj.get('E_S666');
                Integer lastAmount = 1;
                Decimal totalPrice = 0;
                if(itemObj.get('KWMENG') != null){
                    lastAmount = getType(itemObj.get('KWMENG')) == 'String' ? Integer.valueOf((String)itemObj.get('KWMENG')) : (Integer) itemObj.get('KWMENG');
                    if(lastAmount != 0)
                    	oItem.LastPurchaseAmountNmb__c = lastAmount;
                }
                if(lastAmount != 0){
                    if(itemObj.get('ZV_B_S_IPI') != null){
                        totalPrice = getType(itemObj.get('ZV_B_S_IPI')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZV_B_S_IPI')) : (Decimal) itemObj.get('ZV_B_S_IPI');
                        oItem.LastPurchaseLiquidNmb__c = totalPrice / lastAmount;
                    }
                    if(itemObj.get('SPTAG') != null){
                        try{
                            oItem.LastPurchaseDateDte__c = getType(itemObj.get('SPTAG')) == 'String' ? Date.valueOf((String)itemObj.get('SPTAG')) : null;
                        }
                        catch(Exception e){
                            system.debug(e.getMessage());
                        }
                    }
                }
            }

        }
        update o;
        update oItem;
        
    }
    
    @future(callout=true)
    public static void createItemListOnSAPFuture(Id orderId, List<Id> oItemIds){
        createItemListOnSAP(orderId, oItemIds);
    }
    
    @AuraEnabled
    public static String createItemListOnSAP(Id orderId, List<Id> oItemIds){
        Order__c o = [SELECT ID, PVCStringTxt__c, 
                      YPVO__c,
                      YPME__c,
                      YPSO__c,
                      YPXI__c,
                      YVJ1__c,
                      ErrorMessageTxt__c, 
                      PaymentTermLkp__c,
                      (SELECT Id, ItemNumberTxt__c, OrderMdt__c, OrderMdt__r.CustomIdTxt__c, OrderQuantityNmb__c, ErrorMessageTxt__c, ProductLkp__r.ProductCodeTxt__c
                       FROM Itens_da_Ordem__r) 
                      FROM Order__c WHERE Id = :orderId];
        Decimal zpvc = 0;
        String errorMsg = '';
        system.debug('itens: ' + o.Itens_da_Ordem__r);
        system.debug(oItemIds);
        List<OrderItem__c> oItems = new List<OrderItem__c>();
        
        if(oItemIds != null && oItemIds.size() > 0){
            oItems = [SELECT Id, ItemNumberTxt__c, OrderMdt__r.CustomIdTxt__c, OrderQuantityNmb__c, ErrorMessageTxt__c, ProductLkp__r.ProductCodeTxt__c FROM OrderItem__c WHERE Id IN :oItemIds];            
        } else{
        	oItems = o.Itens_da_Ordem__r;
        }
        system.debug('Items da ordem: '+oItems);
        
        oItemIds = new List<Id>();
        //Cria Map<ItemNumber, Item> e popula
        Map<String, OrderItem__c> oItemsMap = new Map<String, OrderItem__c>();
        for(OrderItem__c oItem: oItems){
            oItemIds.add(oItem.Id);
            oItem.ErrorMessageTxt__c = null;
            oItemsMap.put(oItem.ItemNumberTxt__c, oItem);
        }
        //o.ErrorMessageTxt__c = null;
        system.debug('Mapa Itens: '+oItemsMap);
        
        HttpResponse res = SapInteg.quotationChange(orderId, oItemIds, false);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            Boolean itemError = false;
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                errorMsg = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                for(OrderItem__c item : oItemsMap.values()){
                    if(errorMsg.indexOf(item.ProductLkp__r.ProductCodeTxt__c) != -1){
                        item.ErrorMessageTxt__c = errorMsg;
                        itemError = true;
                        break;
                    }
                }
                if(!itemError) o.ErrorMessageTxt__c = errorMsg;
            }
        }
        else{
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Boolean itemError = false;
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    errorMsg = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                    for(OrderItem__c item : oItemsMap.values()){
                        if(errorMsg.indexOf(item.ProductLkp__r.ProductCodeTxt__c) != -1){
                            item.ErrorMessageTxt__c = errorMsg;
                            itemError = true;
                            break;
                        }
                    }
                    if(!itemError) o.ErrorMessageTxt__c = errorMsg;
                    break;
                }
            }
        }
        if(errorMsg == ''){
            List<String> conditionList = new List<String>{'YPRO', 'YCOT', 'ZMIN', 'YPMI', 
                'ZPVC', 'BX41', 'BX23', 'BX13', 'IPVA', 'ICVA', 'ISTS', 'ZCPG', 'ZGAB', 'ZGAN'};
                res = SapInteg.getDetails(orderId, conditionList, null);
            
            
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            Map<String, Object> conditionItem = (Map<String, Object>) jsonObj.get('ORDER_CONDITIONS_OUT');
            List<Object> listCondition = (List<Object>) conditionItem.get('item');
            for(Object condition : listCondition){
                OrderItem__c oItem = new OrderItem__c();
                Map<String, Object> conditionMap = (Map<String, Object>) condition;
                String num = (String)conditionMap.get('ITM_NUMBER');
                //usa itemNum pra dar get no map e achar oItem
                oItem = oItemsMap.get(num);
                if(oItem != null){
                    String conditionName = (String)conditionMap.get('COND_TYPE');
                    String conditionValueType = getType(conditionMap.get('COND_VALUE'));
                    if(conditionValueType == 'String'){
                        try{
                            if(conditionName == 'ZCPG')
                                oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                            else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13' || conditionName == 'ZGAB')
                                oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('CONDVALUE')));
                            else
                                oItem.put(conditionName+'__c', Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE'))));
                        }
                        catch (Exception e){
                            
                        }
                        if(conditionName == 'ZPVC') zpvc = Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                    }
                    else if(conditionValueType == 'Decimal' || conditionValueType == 'Integer'){
                        try{
                            if(conditionName == 'ZCPG')
                                oItem.put(conditionName+'__c', (Decimal)conditionMap.get('COND_VALUE'));
                            else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13')
                                oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('CONDVALUE')));
                            else
                                oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('COND_VALUE')));
                        }
                        catch(Exception e){
                            
                        }
                        if(conditionName == 'ZPVC') zpvc = Math.abs((Decimal)conditionMap.get('COND_VALUE'));
                    }
                    
                    system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('COND_VALUE'));
                    system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                }
            }
            Map<String, Object> itemsItem = (Map<String, Object>) jsonObj.get('ORDER_ITEMS_OUT');
            System.debug(itemsItem.get('item'));
            List<Object> itemList = (List<Object>) itemsItem.get('item');
            for(Object item : itemList){
                OrderItem__c oItem = new OrderItem__c();
                Map<String, Object> itemMap = (Map<String, Object>) item;
                String itemNum = (String)itemMap.get('ITM_NUMBER');
                //usa itemNum para achar oItem
                oItem = oItemsMap.get(itemNum);
                if(oItem != null){
                    oItem.CustomIDTxt__c = (String)itemMap.get('OBJ_NR_IT');
                    oItem.ItemNumberTxt__c = oItem.CustomIdTxt__c.right(6);
                    //oItem.LiquidNmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'))/oItem.OrderQuantityNmb__c).setScale(4);
                    //oItem.LiquidIPINmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'))/oItem.OrderQuantityNmb__c).setScale(4);
                    oItem.LiquidNmb__c = getType(itemMap.get('SUBTOT_PP2')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP2')) : 0; 
                    oItem.TotalGrossCostNmb__c = getType(itemMap.get('SUBTOT_PP5')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP5')) : 0;
                    oItem.OriginalROBNoIPINmb__c = getType(itemMap.get('SUBTOT_PP5')) == 'String' ? Decimal.valueOf((String)itemMap.get('SUBTOT_PP1')) : 0;
                    
                    oItem.OriginalQuantityNmb__c = oItem.OrderQuantityNmb__c;
                    
                    String expCenterCode = (String)itemMap.get('SHIP_POINT');
                    if(expCenterCode != null)
                        oItem.ExpeditionCenterLkp__r = new ExpeditionCenter__c (CustomIdTxt__c = expCenterCode);
                    oItem.DistributionCenterTxt__c = (String)itemMap.get('PLANT');
                    oItem.PVCPriceNmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceNmb__c = o.YPME__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPSO__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPXI__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YVJ1__c != null ? oItem.PVCPriceNmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceNmb__c;
                    
                    oItem.PVCPriceIPINmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPME__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPSO__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPXI__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YVJ1__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceIPINmb__c;
                    
                    oItem.ZPVO__c = o.YPVO__c;
                    oItem.ZPME__c = o.YPME__c;
                    oItem.ZPSO__c = o.YPSO__c;
                    oItem.ZPXI__c = o.YPXI__c;
                    oItem.ZVJ1__c = o.YVJ1__c;
                    
                    
                    oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c;
                    oItem.UnitPriceNmb__c = oItem.LiquidNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.LiquidIPINmb__c;
                    oItem.ZPRO__c = 0;
                    oItem.ZCOT__c = 0;
                    oItem.XXES__c = 0;
                    oItemsMap.put(itemNum, oItem);
                }
                
            }
            
            
            if((getType(jsonObj.get('ORDER_COND_VAL_SCALE')) == 'Object' || zpvc != 0) && o.PVCStringTxt__c == null){
                o.PVCStringTxt__c = getPVC(jsonObj, zpvc);
                
            }
            /*
            res = SapInteg.getBottleneck(oItem.DistributionCenterTxt__c, oItem.ProductLkp__r.ProductCodeTxt__c);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('T_ZPH_FCUR_OUT')) == 'Object'){
                Map<String, Object> mainObj = (Map<String, Object>) jsonObj.get('T_ZPH_FCUR_OUT');
                if(getType(mainObj.get('item')) == 'Object'){
                    Map<String, Object> itemObj = (Map<String, Object>) mainObj.get('item');
                    system.debug(itemObj);
                    if(itemObj.get('ZGARGA') != null)
                        oItem.BottleneckDaysNmb__c = getType(itemObj.get('ZGARGA')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZGARGA')) : (Decimal) itemObj.get('ZGARGA');
                }
            }
            
            res = SapInteg.getLastPrice(oItemIds);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('E_S666')) == 'Object'){
                Map<String, Object> itemObj = (Map<String, Object>) jsonObj.get('E_S666');
                if(itemObj.get('ZV_B_S_IPI') != null)
                    oItem.LastPurchaseLiquidNmb__c = getType(itemObj.get('ZV_B_S_IPI')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZV_B_S_IPI')) : (Decimal) itemObj.get('ZV_B_S_IPI');
            }
			*/
        }
        else{
            for(OrderItem__c oItem : oItemsMap.values()){
                if (oItem.ErrorMessageTxt__c == errorMsg){
                    update oItem;
                }
            }
            update o;
            return errorMsg;
        } 
            
        try{
            update oItemsMap.values();
            update o;
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
        
    }
    
    @future(callout=true)
    public static void recalculatePricesFuture(Id orderId){
        recalculatePrices(orderId);
    }
    
    public static String recalculatePrices(Id orderId){
        Order__c o = [SELECT ID, PVCStringTxt__c, 
                      YPVO__c,
                      YPME__c,
                      YPSO__c,
                      YPXI__c,
                      YVJ1__c,
                      ErrorMessageTxt__c, 
                      PaymentTermLkp__c,
                      (SELECT Id, ItemNumberTxt__c, OrderMdt__c, OrderMdt__r.CustomIdTxt__c, OrderQuantityNmb__c, ErrorMessageTxt__c, ProductLkp__r.ProductCodeTxt__c
                       FROM Itens_da_Ordem__r) 
                      FROM Order__c WHERE Id = :orderId];
        Decimal zpvc = 0;
        String errorMsg = '';
        system.debug('itens: ' + o.Itens_da_Ordem__r);
       
        List<OrderItem__c> oItems = o.Itens_da_Ordem__r;
        
        system.debug('Items da ordem: '+oItems);
        
        List<Id> oItemIds = new List<Id>();
        //Cria Map<ItemNumber, Item> e popula
        Map<String, OrderItem__c> oItemsMap = new Map<String, OrderItem__c>();
        for(OrderItem__c oItem: oItems){
            oItemIds.add(oItem.Id);
            oItem.ErrorMessageTxt__c = null;
            oItemsMap.put(oItem.ItemNumberTxt__c, oItem);
        }
        //o.ErrorMessageTxt__c = null;
        system.debug('Mapa Itens: '+oItemsMap);
        
        HttpResponse res = SapInteg.quotationChangePricing(orderId, oItemIds);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            Boolean itemError = false;
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                errorMsg = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                for(OrderItem__c item : oItemsMap.values()){
                    if(errorMsg.indexOf(item.ProductLkp__r.ProductCodeTxt__c) != -1){
                        item.ErrorMessageTxt__c = errorMsg;
                        itemError = true;
                        break;
                    }
                }
                if(!itemError) o.ErrorMessageTxt__c = errorMsg;
            }
        }
        else{
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Boolean itemError = false;
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    errorMsg = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                    for(OrderItem__c item : oItemsMap.values()){
                        if(errorMsg.indexOf(item.ProductLkp__r.ProductCodeTxt__c) != -1){
                            item.ErrorMessageTxt__c = errorMsg;
                            itemError = true;
                            break;
                        }
                    }
                    if(!itemError) o.ErrorMessageTxt__c = errorMsg;
                    break;
                }
            }
        }
        if(errorMsg == ''){
            List<String> conditionList = new List<String>{'YPRO', 'YCOT', 'ZMIN', 'YPMI', 
                'ZPVC', 'BX41', 'BX23', 'BX13', 'IPVA', 'ICVA', 'ISTS', 'ZCPG', 'ZGAB', 'ZGAN'};
                res = SapInteg.getDetails(orderId, conditionList, null);
            
            
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            Map<String, Object> conditionItem = (Map<String, Object>) jsonObj.get('ORDER_CONDITIONS_OUT');
            List<Object> listCondition = (List<Object>) conditionItem.get('item');
            for(Object condition : listCondition){
                OrderItem__c oItem = new OrderItem__c();
                Map<String, Object> conditionMap = (Map<String, Object>) condition;
                String num = (String)conditionMap.get('ITM_NUMBER');
                //usa itemNum pra dar get no map e achar oItem
                oItem = oItemsMap.get(num);
                if(oItem != null){
                    String conditionName = (String)conditionMap.get('COND_TYPE');
                    String conditionValueType = getType(conditionMap.get('COND_VALUE'));
                    if(conditionValueType == 'String'){
                        try{
                            if(conditionName == 'ZCPG')
                                oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                            else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13' || conditionName == 'ZGAB')
                                oItem.put(conditionName+'__c', Decimal.valueOf((String)conditionMap.get('CONDVALUE')));
                            else
                                oItem.put(conditionName+'__c', Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE'))));
                        }
                        catch (Exception e){
                            
                        }
                        if(conditionName == 'ZPVC') zpvc = Math.abs(Decimal.valueOf((String)conditionMap.get('COND_VALUE')));
                    }
                    else if(conditionValueType == 'Decimal' || conditionValueType == 'Integer'){
                        try{
                            if(conditionName == 'ZCPG')
                                oItem.put(conditionName+'__c', (Decimal)conditionMap.get('COND_VALUE'));
                            else if(conditionName == 'BX41' || conditionName == 'BX23' || conditionName == 'BX13')
                                oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('CONDVALUE')));
                            else
                                oItem.put(conditionName+'__c', Math.abs((Decimal)conditionMap.get('COND_VALUE')));
                        }
                        catch(Exception e){
                            
                        }
                        if(conditionName == 'ZPVC') zpvc = Math.abs((Decimal)conditionMap.get('COND_VALUE'));
                    }
                    
                    system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('COND_VALUE'));
                    system.debug('conditionName: ' + conditionName + '; conditionValue: ' + conditionMap.get('CONDVALUE'));
                }
            }
            Map<String, Object> itemsItem = (Map<String, Object>) jsonObj.get('ORDER_ITEMS_OUT');
            System.debug(itemsItem.get('item'));
            
            if(getType(itemsItem.get('item')) == 'Object'){
                OrderItem__c oItem = new OrderItem__c();
                Map<String, Object> itemMap = (Map<String, Object>) itemsItem.get('item');
                String itemNum = (String)itemMap.get('ITM_NUMBER');
                //usa itemNum para achar oItem
                oItem = oItemsMap.get(itemNum);
                if(oItem != null){
                    oItem.CustomIDTxt__c = (String)itemMap.get('OBJ_NR_IT');
                    oItem.ItemNumberTxt__c = oItem.CustomIdTxt__c.right(6);
                    //oItem.LiquidNmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'))/oItem.OrderQuantityNmb__c).setScale(4);
                    //oItem.LiquidIPINmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'))/oItem.OrderQuantityNmb__c).setScale(4);
                    oItem.LiquidNmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP2'));
                    oItem.TotalGrossCostNmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'));
                    oItem.OriginalROBNoIPINmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'));
                    
                    oItem.OriginalQuantityNmb__c = oItem.OrderQuantityNmb__c;
                    
                    String expCenterCode = (String)itemMap.get('SHIP_POINT');
                    if(expCenterCode != null)
                        oItem.ExpeditionCenterLkp__r = new ExpeditionCenter__c (CustomIdTxt__c = expCenterCode);
                    oItem.DistributionCenterTxt__c = (String)itemMap.get('PLANT');
                    oItem.PVCPriceNmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceNmb__c = o.YPME__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPSO__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPXI__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YVJ1__c != null ? oItem.PVCPriceNmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceNmb__c;
                    
                    oItem.PVCPriceIPINmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPME__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPSO__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPXI__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YVJ1__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceIPINmb__c;
                    
                    /*oItem.ZPVO__c = o.YPVO__c;
                    oItem.ZPME__c = o.YPME__c;
                    oItem.ZPSO__c = o.YPSO__c;
                    oItem.ZPXI__c = o.YPXI__c;
                    oItem.ZVJ1__c = o.YVJ1__c;
                    */
                    
                    oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c;
                    oItem.UnitPriceNmb__c = oItem.LiquidNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.LiquidIPINmb__c;
                    oItem.ZPRO__c = 0;
                    oItem.ZCOT__c = 0;
                    oItem.XXES__c = 0;
                    oItemsMap.put(itemNum, oItem);
                }
            }
            else{
            List<Object> itemList = (List<Object>) itemsItem.get('item');
            for(Object item : itemList){
                OrderItem__c oItem = new OrderItem__c();
                Map<String, Object> itemMap = (Map<String, Object>) item;
                String itemNum = (String)itemMap.get('ITM_NUMBER');
                //usa itemNum para achar oItem
                oItem = oItemsMap.get(itemNum);
                if(oItem != null){
                    oItem.CustomIDTxt__c = (String)itemMap.get('OBJ_NR_IT');
                    oItem.ItemNumberTxt__c = oItem.CustomIdTxt__c.right(6);
                    //oItem.LiquidNmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'))/oItem.OrderQuantityNmb__c).setScale(4);
                    //oItem.LiquidIPINmb__c = (Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'))/oItem.OrderQuantityNmb__c).setScale(4);
                    oItem.LiquidNmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP2'));
                    oItem.TotalGrossCostNmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP5'));
                    oItem.OriginalROBNoIPINmb__c = Decimal.valueOf((String)itemMap.get('SUBTOT_PP1'));
                    
                    oItem.OriginalQuantityNmb__c = oItem.OrderQuantityNmb__c;
                    
                    String expCenterCode = (String)itemMap.get('SHIP_POINT');
                    if(expCenterCode != null)
                        oItem.ExpeditionCenterLkp__r = new ExpeditionCenter__c (CustomIdTxt__c = expCenterCode);
                    oItem.DistributionCenterTxt__c = (String)itemMap.get('PLANT');
                    /*
                    oItem.PVCPriceNmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceNmb__c = o.YPME__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPSO__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YPXI__c != null ? oItem.PVCPriceNmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceNmb__c;
                    oItem.PVCPriceNmb__c = o.YVJ1__c != null ? oItem.PVCPriceNmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceNmb__c;
                    
                    oItem.PVCPriceIPINmb__c = o.YPVO__c != null ? oItem.LiquidNmb__c * (1 - o.YPVO__c/100) : oItem.LiquidNmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPME__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPME__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPSO__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPSO__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YPXI__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YPXI__c/100) : oItem.PVCPriceIPINmb__c;
                    oItem.PVCPriceIPINmb__c = o.YVJ1__c != null ? oItem.PVCPriceIPINmb__c * (1 - o.YVJ1__c/100) : oItem.PVCPriceIPINmb__c;
                    */
                    /*oItem.ZPVO__c = o.YPVO__c;
                    oItem.ZPME__c = o.YPME__c;
                    oItem.ZPSO__c = o.YPSO__c;
                    oItem.ZPXI__c = o.YPXI__c;
                    oItem.ZVJ1__c = o.YVJ1__c;
                    */
                    
                    oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c;
                    oItem.UnitPriceNmb__c = oItem.LiquidNmb__c;
                    oItem.UnitPriceIPINmb__c = oItem.LiquidIPINmb__c;
                    oItem.ZPRO__c = 0;
                    oItem.ZCOT__c = 0;
                    oItem.XXES__c = 0;
                    oItem.RemittanceGroupTxt__c = null;
                    oItemsMap.put(itemNum, oItem);
                }
                
            }
            }
            
            /*if(getType(jsonObj.get('ORDER_COND_VAL_SCALE')) == 'Object' && o.PVCStringTxt__c == null){
                o.PVCStringTxt__c = getPVC(jsonObj, zpvc);
                
            }*/
            /*
            res = SapInteg.getBottleneck(oItem.DistributionCenterTxt__c, oItem.ProductLkp__r.ProductCodeTxt__c);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('T_ZPH_FCUR_OUT')) == 'Object'){
                Map<String, Object> mainObj = (Map<String, Object>) jsonObj.get('T_ZPH_FCUR_OUT');
                if(getType(mainObj.get('item')) == 'Object'){
                    Map<String, Object> itemObj = (Map<String, Object>) mainObj.get('item');
                    system.debug(itemObj);
                    if(itemObj.get('ZGARGA') != null)
                        oItem.BottleneckDaysNmb__c = getType(itemObj.get('ZGARGA')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZGARGA')) : (Decimal) itemObj.get('ZGARGA');
                }
            }
            
            res = SapInteg.getLastPrice(oItemIds);
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(getType(jsonObj.get('E_S666')) == 'Object'){
                Map<String, Object> itemObj = (Map<String, Object>) jsonObj.get('E_S666');
                if(itemObj.get('ZV_B_S_IPI') != null)
                    oItem.LastPurchaseLiquidNmb__c = getType(itemObj.get('ZV_B_S_IPI')) == 'String' ? Decimal.valueOf((String)itemObj.get('ZV_B_S_IPI')) : (Decimal) itemObj.get('ZV_B_S_IPI');
            }
			*/
        }
        else{
            for(OrderItem__c oItem : oItemsMap.values()){
                if (oItem.ErrorMessageTxt__c == errorMsg){
                    update oItem;
                }
            }
            update o;
            return errorMsg;
        } 
            
        try{
            update oItemsMap.values();
            update o;
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
        
        return 'SUCCESS';
    }
    
    @future(callout=true)
    public static void deleteItemOnSAPFuture(Id orderId, List<Id> oItemIds){
        deleteItemOnSAP(orderId, oItemIds);
    }
    
    public static void deleteItemOnSAP(Id orderId, List<Id> oItemIds){
        Order__c o = [SELECT ID FROM Order__c WHERE Id = :orderId];
        
        
        HttpResponse res = SapInteg.quotationChange(orderId, oItemIds, true);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
            }
        }
        else{
            
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                }
            }
        }
        
    }
    
    @future(callout=true)
    public static void convertQuoteIntoOrderFuture(Id orderId){
        convertQuoteIntoOrder(orderId);
    }
    
    public static String convertQuoteIntoOrder(Id orderId){
        Order__c o = [SELECT ID, ErrorMessageTxt__c, OrderStatusTxt__c, CustomIDTxt__c FROM Order__c WHERE Id = :orderId];
        String response = '';
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        List<String> conditionList = new List<String>{'ZPRO', 'ZCOT', 'ZPVO', 'ZPME', 'ZPSO', 'ZPXI', 'YRVO', 'YRME', 'YRSO', 'YRXI', 'XXES', 'ZVJ1'};
        //List<String> conditionList = new List<String> {'XXES'};
            HttpResponse res = SapInteg.convertQuote(orderId, conditionList);
        system.debug(res.getBody());
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        /*
        Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('RETURN');        
        system.debug(msgs);
        o.ErrorMessageTxt__c = null;
        
        
        if(getType(msgs.get('item')) == 'Object'){
            Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
            if((String)returnMap.get('TYPE') == 'E'){
                system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
            }
        }
        else{
            List<Object> listRet = (List<Object>) msgs.get('item');
            system.debug(listRet);
            for(Object ret : listRet){
                Map<String, Object> returnMap = (Map<String, Object>) ret;
                if((String)returnMap.get('TYPE') == 'E'){
                    system.debug('ERRO: ' + (String)returnMap.get('MESSAGE'));
                    o.ErrorMessageTxt__c = 'ERRO: ' + (String)returnMap.get('MESSAGE');
                    break;
                }
            }
        }
*/
        if(o.ErrorMessageTxt__c == null){
            //o.CustomIdTxt__c = (String)jsonObj.get('SALESDOCUMENT');
            //o.CustomIDTxt__c =  StringUtils.removeLeftPadZeros((String)jsonObj.get('SALESDOCUMENT'));
            o.SAPGUIDTxt__c = (String)jsonObj.get('GUID');
            
            
            /*List<OrderItem__c> listItem = [SELECT Id, Name, ItemNumberTxt__c FROM OrderItem__c WHERE OrderMdt__c = :orderId];
            
            for(OrderItem__c item: listItem){
                item.CustomIdTxt__c = StringUtils.removeLeftPadZeros((String)jsonObj.get('SALESDOCUMENT'))+StringUtils.removeLeftPadZeros(item.ItemNumberTxt__c);
            }
            */
            skipVal.Skip__c = true;
            update skipVal;
            o.OrderStatusTxt__c = 'SentToSAP';
            
            response = 'SUCCESS';
            
            //update listItem;
            //OrderService.getInvoiceListByOrderNumber(o.CustomIDTxt__c);
        }
        update o;
       
        skipVal.Skip__c = false;
        update skipVal;
        
        return response;
        
    }
    
    public static String getPVC(Map<String, Object> jsonObj, Decimal zpvc){
        List<PVCCondition> PVCStructure = new List<PVCCondition>();
        Map<String, List<PVCScale>> mapScalesByNum = new Map<String, List<PVCScale>>();
        if(zpvc != 0){
            PVCCondition zpvcCondition = new PVCCondition();
            zpvcCondition.Code = 'ZPVC';
            zpvcCondition.Description = setDescription('ZPVC');
            zpvcCondition.sortOrder = setSortOrder('ZPVC');
            List<PVCScale> listscales = new List<PVCScale>();
            PVCScale scaleAux = new PVCScale();
            scaleAux.Target = 0;
            scaleAux.Amount = zpvc;
            listscales.add(scaleAux);
            zpvcCondition.scale = listScales;
            PVCStructure.add(zpvcCondition);
        }
        if(getType(jsonObj.get('ORDER_COND_VAL_SCALE')) == 'Object'){
            Map<String, Object> conditionItem = (Map<String, Object>) jsonObj.get('ORDER_COND_VAL_SCALE');
            system.debug(conditionItem);
            List<Object> listCondition = (List<Object>) conditionItem.get('item');
            for(Object condition : listCondition){
                Map<String, Object> conditionMap = (Map<String, Object>) condition;
                String conditionNum = (String)conditionMap.get('COND_NO');
                Decimal conditionAmount = conditionMap.get('CURRENCY') instanceof String ? Decimal.valueOf((String)conditionMap.get('CURRENCY')) : (Decimal)conditionMap.get('CURRENCY');
                Decimal conditionTarget = conditionMap.get('SCALE_VAL') instanceof String ? Decimal.valueOf((String)conditionMap.get('SCALE_VAL')) : (Decimal)conditionMap.get('SCALE_VAL');
                List<PVCScale> listAux = new List<PVCScale>();
                if(mapScalesByNum.containsKey(conditionNum)){
                    listAux = mapScalesByNum.get(conditionNum);
                }
                PVCScale scale = new PVCScale();
                scale.target = conditionTarget;
                scale.amount = conditionAmount < 0 ? -1 * conditionAmount : conditionAmount;
                listAux.add(scale);
                mapScalesByNum.put(conditionNum, listAux);
            }
            system.debug(mapScalesByNum);
            List<String> conditionNums = new List<String>();
            conditionNums.addAll(mapScalesByNum.keySet());
            system.debug(conditionNums);
            HttpResponse res = SAPInteg.getConditionNames(new List<String>(mapScalesByNum.keyset()));
            system.debug(res.getBody());
            jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            conditionItem = (Map<String, Object>) jsonObj.get('T_KONH');
            
            if(getType(conditionItem.get('item')) == 'Object'){
                Map<String, Object> conditionMap = (Map<String, Object>) conditionItem.get('item');
                String knumh = (String)conditionMap.get('KNUMH');
                String conditionName = (String) conditionMap.get('KSCHL');
                Decimal accessSequence = (Decimal) conditionMap.get('KOTABNR');
                List<PVCScale> listAux = mapScalesByNum.get(knumh);
                if(conditionName != 'YPMX') listAux = sortScales(listAux);
                PVCCondition pvc = new PVCCondition();
                pvc.Code = conditionName;
                pvc.Description = setDescription(conditionName);
                pvc.sortOrder = setSortOrder(conditionName);
                pvc.accessSequence = accessSequence;
                pvc.Scale = new List<PVCScale>(listAux);
                PVCStructure.add(pvc);
            }
            else{
                listCondition = (List<Object>) conditionItem.get('item');
                for(Object condition : listCondition){
                    Map<String, Object> conditionMap = (Map<String, Object>) condition;
                    String knumh = (String)conditionMap.get('KNUMH');
                    String conditionName = (String) conditionMap.get('KSCHL');
                    Decimal accessSequence = (Decimal) conditionMap.get('KOTABNR');
                    List<PVCScale> listAux = mapScalesByNum.get(knumh);
                    if(conditionName != 'YPMX') listAux = sortScales(listAux);
                    PVCCondition pvc = new PVCCondition();
                    pvc.Code = conditionName;
                    pvc.Description = setDescription(conditionName);
                    pvc.sortOrder = setSortOrder(conditionName);
                    pvc.accessSequence = accessSequence;
                    pvc.Scale = new List<PVCScale>(listAux);
                    PVCStructure.add(pvc);
                }
            }
        }
        PVCStructure = sortConditions(PVCStructure);
        String response = JSON.serialize(PVCStructure);
        system.debug(response);
        return response;
    }
    
    private static String getType(Object o){
        
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'String';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets
    }
    
    private static String setDescription(String conditionName){
        if(conditionName == 'YPVO') return 'Desc. Volume';
        if(conditionName == 'YPME') return 'Desc. Meta Conex';
        if(conditionName == 'YPSO') return 'Desc. CPE';
        if(conditionName == 'YVJ1' || conditionName == 'ZPVC') return 'Desc. Canal';
        if(conditionName == 'YPXI') return 'Desc. Mix Irriga';
        if(conditionName == 'YPMX') return 'Produtos Runner';
        return 'Desconto de Política';
    }
    
    private static Decimal setSortOrder(String conditionName){
        if(conditionName == 'YVJ1' || conditionName == 'ZPVC') return 1;
        if(conditionName == 'YPVO') return 2;
        if(conditionName == 'YPME') return 3;
        if(conditionName == 'YPSO') return 4;
        if(conditionName == 'YPXI') return 5;
        if(conditionName == 'YPMX') return 6;
        return 999;
    }
    
    private static List<PVCCondition> sortConditions(List<PVCCondition> listConditions){
        Map<Decimal, PVCCondition> mapSortOrder = new Map<Decimal, PVCCondition>();
        List<PVCCondition> sortedList = new List<PVCCondition>();
        for(PVCCondition pvcCond : listConditions){
            if(!mapSortOrder.containsKey(pvcCond.sortOrder))
                mapSortOrder.put(pvcCond.sortOrder, pvcCond);
            else{
                PVCCondition oldCond = mapSortOrder.get(pvcCond.sortOrder);
                if(pvcCond.accessSequence < oldCond.accessSequence)
                    mapSortOrder.put(pvcCond.sortOrder, pvcCond);
            }
        }
        List<Decimal> listKeys = new List<Decimal>();
        listKeys.addAll(mapSortOrder.keySet());
        listKeys.sort();
        
        for(Decimal currKey : listKeys){
            sortedList.add(mapSortOrder.get(currKey));
        }
        
        return sortedList;
    }
    
    private static List<PVCScale> sortScales(List<PVCScale> listToSort){
        List<PVCScale> sortedList = new List<PVCScale>();
        Boolean shiftList = false;
        for(Integer i = 0; i < listToSort.size(); i++){
            PVCScale oldScale = listToSort[i];
            PVCScale newScale = new PVCScale();
            newScale.target = oldScale.target;
            newScale.amount = oldScale.amount;
            if(i == 0){
                if(oldScale.amount == 0){
                    shiftList = true;
                    newScale.amount = listToSort[i+1].amount;
                }
                sortedList.add(newScale);
            }
            else if(shiftList && i < (listToSort.size() - 1)){
                newScale.amount = listToSort[i+1].amount;
                sortedList.add(newScale);
            }
            else if(!shiftList) sortedList.add(newScale);
            
        }
        
        return sortedList;
    }
    
    private class PVCScale{
        public Decimal Target;
        public Decimal Amount;
        public PVCScale(){
            this.Target = 0;
            this.Amount = 0;
        }
    }
    
    private class PVCCondition{
        public Decimal sortOrder;
        public Decimal accessSequence;
        public String Code;
        public String Description;
        public List<PVCScale> Scale;
        public PVCCondition(){
            this.sortOrder = 999;
            this.accessSequence = 999;
            this.Code = '';
            this.Description= '';
            this.Scale = new List<PVCScale>();
        }
    }
}