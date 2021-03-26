public class OrderItemTriggerHandler {

    public static void isBeforeInsert(List<OrderItem__c> oItemList, Map<Id, OrderItem__c> oldMap){
        List<StatusItemOrdem__c> listVal = StatusItemOrdem__c.getAll().Values();
        Map<String, Decimal> mapVal = new Map<String, Decimal>();
        Map<Integer, String> mapName = new Map<Integer, String>();
        for(StatusItemOrdem__c val : listVal){
            mapVal.put(val.Name, val.StatusValue__c);
            mapName.put(Integer.valueOf(val.StatusValue__c), val.Name);
        }
        List<String> listOrderId = new List<String>();
        Map<Id, Order__c> mapOrder = new Map<Id, Order__c>();
        Map<String, Decimal> mapOrderItemValue = new Map<String, Decimal>();
        for(OrderItem__c oItem : oItemList){
            if(mapVal.containsKey(oItem.StatusTxt__c)){
                oItem.StatusNumberNmb__c = mapVal.get(oItem.StatusTxt__c);
                listOrderId.add(oItem.OrderMdt__c);
                mapOrderItemValue.put(oItem.Id, oItem.StatusNumberNmb__c);
            }
        }
        if(!listOrderId.isEmpty()){
            mapOrder = new Map<Id, Order__c>([Select Id, ItemStatusNumberNmb__c, ItemStatus__c, 
                                              (Select StatusNumberNmb__c FROM Itens_da_Ordem__r)
                                              From Order__c
                                              Where Id IN :listOrderId]);
        }
        for(String ordKey : mapOrder.keyset()){
            Order__c ord = mapOrder.get(ordKey);
            Decimal minVal = 999;
            for(OrderItem__c item : ord.Itens_da_Ordem__r){
                if(mapOrderItemValue.containsKey(item.Id)){
                    item.StatusNumberNmb__c = mapOrderItemValue.get(item.Id);
                }
                if(item.StatusNumberNmb__c < minVal){
                    minVal = item.StatusNumberNmb__c;
                }
            }
            ord.ItemStatusNumberNmb__c = minVal;
            ord.ItemStatus__c = mapName.get(Integer.valueOf(ord.ItemStatusNumberNmb__c));
        }
        if(!mapOrder.isEmpty()){
            update mapOrder.values();
        }
    }
    
    public static void isBeforeUpdate(List<OrderItem__c> oItemList, Map<Id, OrderItem__c> oldMap, Map<Id, OrderItem__c> newMap){
        List<Id> oItemIds = new List<Id>();
        List<Id> oItemChangeCenter = new List<Id>();
        for(OrderItem__c oItem : oItemList){
            if(oItem.DistributionCenterTxt__c != oldMap.get(oItem.Id).DistributionCenterTxt__c && !oItem.SyncedSAPBln__c){
                oItemIds.add(oItem.Id);
                if(oldMap.get(oItem.Id).DistributionCenterTxt__c != null || oItem.TotalGrossCostNmb__c == null){
                    oItemChangeCenter.add(oItem.Id);
                }
                oItem.RemittanceGroupTxt__c = null;
            }
            if(oItem.OrderQuantityNmb__c != oldMap.get(oItem.id).OrderQuantityNmb__c && oItem.RemittanceGroupTxt__c == oldMap.get(oItem.id).RemittanceGroupTxt__c){
                oItem.RemittanceGroupTxt__c = null;
            }
        }
        if(oItemIds.size() > 0){
            validateBlockedProduct(oItemIds);
        }
        if(oItemChangeCenter.size() > 0){
            validateChangeCenter(oItemIds, newMap);
        }

        
        List<StatusItemOrdem__c> listVal = StatusItemOrdem__c.getAll().Values();
        Map<String, Decimal> mapVal = new Map<String, Decimal>();
        Map<Integer, String> mapName = new Map<Integer, String>();
        for(StatusItemOrdem__c val : listVal){
            mapVal.put(val.Name, val.StatusValue__c);
            mapName.put(Integer.valueOf(val.StatusValue__c), val.Name);
        }
        List<String> listOrderId = new List<String>();
        Map<Id, Order__c> mapOrder = new Map<Id, Order__c>();
        Map<String, Decimal> mapOrderItemValue = new Map<String, Decimal>();
        for(OrderItem__c oItem : oItemList){
            if(oItem.StatusTxt__c != oldMap.get(oItem.Id).StatusTxt__c){
                if(mapVal.containsKey(oItem.StatusTxt__c)){
                    oItem.StatusNumberNmb__c = mapVal.get(oItem.StatusTxt__c);
                    listOrderId.add(oItem.OrderMdt__c);
                    mapOrderItemValue.put(oItem.Id, oItem.StatusNumberNmb__c);
            	}
            }
        }
        if(!listOrderId.isEmpty()){
            mapOrder = new Map<Id, Order__c>([Select Id, ItemStatusNumberNmb__c, ItemStatus__c, 
                                              (Select StatusNumberNmb__c FROM Itens_da_Ordem__r)
                                              From Order__c
                                              Where Id IN :listOrderId]);
        }
        for(String ordKey : mapOrder.keyset()){
            Order__c ord = mapOrder.get(ordKey);
            Decimal minVal = 999;
            for(OrderItem__c item : ord.Itens_da_Ordem__r){
                if(mapOrderItemValue.containsKey(item.Id)){
                    item.StatusNumberNmb__c = mapOrderItemValue.get(item.Id);
                }
                System.debug('valor por item ' + item.StatusNumberNmb__c);
                if(item.StatusNumberNmb__c < minVal){
                    minVal = item.StatusNumberNmb__c;
                    system.debug('valores dos itens' + minVal);
                }               
            }
            ord.ItemStatusNumberNmb__c = minVal;
            system.debug('valor atualizado' + ord.ItemStatusNumberNmb__c);
            ord.ItemStatus__c = mapName.get(Integer.valueOf(ord.ItemStatusNumberNmb__c));
            system.debug('nome do status ' + ord.ItemStatus__c);
        }
        if(!mapOrder.isEmpty()){
            update mapOrder.values();
        }
        
    }
    
    public static void isAfterInsert(List<OrderItem__c> oItemList){
        List<Id> listOItemId = new List<Id>();
        for(OrderItem__c oItem : oItemList){
            if(oItem.ItemNumberTxt__c == null)
                listOItemId.add(oItem.Id);
        }
        processAutoNumber(listOItemId);
    }
    
    public static void isBeforeDelete(List<OrderItem__c> oItemList){
        List<Id> listOrderIds = new List<Id>();
        for(OrderItem__c oItem : oItemList){
            listOrderIds.add(oItem.OrderMdt__c);
        }
        for(Order__c o : [SELECT Id, OrderStatusTxt__c FROM Order__c WHERE Id IN :listOrderIds]){
            if(o.OrderStatusTxt__c != 'Rascunho') 
                oItemList[0].addError('Não é possível deletar itens de ordens que não são "Rascunho"');
        }
    }
    
    public static void isAfterDelete(List<OrderItem__c> oItemList){
        List<Id> listOItemId = new List<Id>();
        Set<Id> setOrderIds = new Set<Id>();
        for(OrderItem__c oItem : oItemList){
            if(oItem.CustomIdTxt__c != null){
                listOItemId.add(oItem.Id);
                setOrderIds.add(oItem.orderMdt__c);
            }
        }
        if(!setOrderIds.isEmpty() && !System.Test.isRunningTest()){
            if(setOrderIds.size() == 1){
                OrderIntegrationUtils.deleteItemOnSAPFuture(new List<Id>(setOrderIds)[0], listOItemId);
            }
            else oItemList[0].addError('Não é possível deletar itens de mais de uma Ordem de Vendas simultaneamente, se eles já estiverem no SAP');
        }
    }
    
    public static void processAutoNumber(list<Id> listIds){
        List<OrderItem__c> listItems = [SELECT Id, OrderMdt__c FROM OrderItem__c WHERE Id IN :listIds];
        List<OrderItem__c> listItemsToUpdate = new List<OrderItem__c>();
        List<Id> orderIds = new List<Id>();
        for(OrderItem__c oItem : listItems){
            orderIds.add(oItem.OrderMdt__c);
        }
        Map<Id, Order__c> mapOrders = new Map<Id, Order__c> ([SELECT Id, ItemCounterNmb__c FROM Order__c WHERE ID IN :orderIds]);
        Map<Id, List<OrderItem__c>> mapItemsByOrder = new Map<Id, List<OrderItem__c>>();
        
        for(OrderItem__c oItem : listItems){
            List<OrderItem__c> listAux = new List<OrderItem__c>();
            if(mapItemsByOrder.containsKey(oItem.OrderMdt__c)){
                listAux = mapItemsByOrder.get(oItem.OrderMdt__c);
            }
            listAux.add(oItem);
            mapItemsByOrder.put(oItem.OrderMdt__c, listAux);
        }
        
        for(Id orderId : mapItemsByOrder.keySet()){
            Order__c o = mapOrders.get(orderId);
            List<OrderItem__c> listAux = mapItemsByOrder.get(orderId);
            for(OrderItem__c oItem : listAux){
                o.ItemCounterNmb__c += 10;
                oItem.ItemNumberTxt__c = String.valueOf(o.ItemCounterNmb__c.intValue()).leftPad(6,'0');
                listItemsToUpdate.add(oItem);
            }
        }
        update mapOrders.values();
        update listItemsToUpdate;
        
    }
    
    public static void validateBlockedProduct(List<Id> listIds){
        List<OrderItem__c>oItemList = [SELECT Id, DistributionCenterTxt__c, ProductLkp__c, OrderMdt__r.OrderTypeLkp__c, OrderMdt__r.OrderTypeLkp__r.OrderIrrigationBln__c FROM OrderItem__c WHERE Id IN :listIds];
        List<Id> listProdIds = new List<Id>();
        List<Id> listTypeIds = new List<Id>();
        List<String> listCenters = new List<String>();
        for(OrderItem__C oItem : oItemList){
            listProdIds.add(oItem.Id);
            listTypeids.add(oItem.OrderMdt__r.OrderTypeLkp__c);
            listCenters.add(oItem.DistributionCenterTxt__c);
        }
        List<BlockedItem__c> listBlock = [SELECT Id, CenterCodeTxt__c, ProductLkp__c, OrderTypeLkp__c 
                                          FROM BlockedItem__c 
                                          WHERE ProductLkp__c IN :listProdIds 
                                          AND OrderTypeLkp__c IN :listTypeIds
                                          AND CenterCodeTxt__c IN :listCenters
                                          AND RecordType.DeveloperName = 'ProductBlockRT'];
        for(OrderItem__c oItem : oItemList){
            for(BlockedItem__c block : listBlock){
                if(oItem.DistributionCenterTxt__c == block.CenterCodeTxt__c && oItem.OrderMdt__r.OrderTypeLkp__c == block.OrderTypeLkp__c && oItem.ProductLkp__c == block.ProductLkp__c){
                    oItem.ErrorMessageTxt__c = 'Produto bloqueado para venda para esse tipo de ordem.';
                }
            }
        }
    }
    
    public static void validateChangeCenter(List<Id> oItemIds, Map<Id, OrderItem__c> newMap){
        Map<String, Id> mapExpeditionCenters = new Map<String, Id>();
        for(ExpeditionCenter__c exp : [SELECT Id, CustomIdTxt__C FROM ExpeditionCenter__c]){
            mapExpeditionCenters.put(exp.CustomIdTxt__c, exp.Id);
        }
        for(OrderItem__c oItem : [
            SELECT Id, OrderMdt__c, 
            OrderMdt__r.OrderTypeLkp__c, 
            OrderMdt__r.OrderTypeLkp__r.OrderIrrigationBln__c, 
            TotalGrossCostNmb__c,
            DistributionCenterTxt__c 
            FROM OrderItem__c 
            WHERE Id IN :oItemIds
        ]){
            if(oItem.OrderMdt__r.OrderTypeLkp__c == null || !oItem.OrderMdt__r.OrderTypeLkp__r.OrderIrrigationBln__c ){
                OrderItem__c actualOrderItem = newMap.get(oItem.Id);
                actualOrderItem.addError('Não é possível alterar o Centro de Distribuição para esse tipo de ordem');
            }
            if(oItem.TotalGrossCostNmb__c == null){
                OrderItem__c actualOrderItem = newMap.get(oItem.Id);
                actualOrderItem.addError('Esse item ainda não foi precificado. Aguarde comunicação com SAP.');
            }
            else{
                OrderItem__c actualOrderItem = newMap.get(oItem.Id);
                if(actualOrderItem.DistributionCenterTxt__c == '0870'){
                    actualOrderItem.ExpeditionCenterLkp__c = mapExpeditionCenters.get('0870');
                }
                else if(actualOrderItem.DistributionCenterTxt__c == '0700'){
                    actualOrderItem.ExpeditionCenterLkp__c = mapExpeditionCenters.get('0020');
                }
                else if(actualOrderItem.DistributionCenterTxt__c == '0900'){
                    actualOrderItem.ExpeditionCenterLkp__c = mapExpeditionCenters.get('0095');
                }
                else if(actualOrderItem.DistributionCenterTxt__c == '0100'){
                    actualOrderItem.ExpeditionCenterLkp__c = mapExpeditionCenters.get('0070');
                }
                else {
                    actualOrderItem.addError('Esse centro de distribuição não está disponível para esse tipo de ordem');
                }
            }
        }
    }
    
}