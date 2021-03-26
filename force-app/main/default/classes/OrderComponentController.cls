public with sharing class OrderComponentController {
    @AuraEnabled
    public static List<OrderItem__c> getOrderItems(Id orderId){
        return [SELECT Id,
                ProductNameFml__c,
                ProductLkp__r.MaterialGroup__c,
                LiquidNmb__c,
                LastPurchaseLiquidNmb__c,
                LastPurchaseDateDte__c,
                LastPurchaseAmountNmb__c,
                ProductCode__c,
                OrderQuantityNmb__c,
                PVCPriceNmb__c,
                UnitPriceNmb__c,
                PVCPriceIPINmb__c,
                UnitPriceIPINmb__c,
                ErrorMessageTxt__c,
                ZPRO__c,
                ZCOT__c,
                YCOT__c,
                YPRO__c,
                XXES__c,
                ValueIPI__c, 
                ValueICMS__c, 
                ValueST__c,
                ValueROBFml__c,
                ValueROBNoIPIFml__c,      
                ValueROLFml__c,
                FlagItemErrorFml__c,
                FlagBottleneckFml__c,
                FlagMinPriceFml__c,
                RemittanceGroupTxt__c,
                CSVPriceNmb__c
                FROM OrderItem__c 
                WHERE OrderMdt__c =: orderId ];
    }
    
    @AuraEnabled
    public static String saveDiscountGlobal(Id orderId, String discountType, Decimal discountValue){
        List<OrderItem__c> oItemList = [SELECT Id, ZPRO__c, ZCOT__c, XXES__c, 
                                        YPRO__c, YCOT__c,
                                        PVCPriceNmb__c, PVCPriceIPINmb__c FROM OrderItem__c WHERE OrderMdt__c = :orderId];
        
        for(OrderItem__c oItem : oItemList){
            if(discountType == 'ZPRO__c')
                oItem.ZPRO__c = Math.min(discountValue, oItem.YPRO__c);
            else if(discountType == 'ZCOT__c')
                oItem.ZCOT__c = Math.min(discountValue, oItem.YCOT__c);
            else if(discountType == 'XXES__c')
                oItem.XXES__c = Math.min(discountValue, 3);
            else return 'ERROR';
            
            if(oItem.PVCPriceNmb__c != null){
                oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c * 
                    (oItem.ZPRO__c != null ? (1 - oItem.ZPRO__c/100) : 1) * 
                    (oItem.ZCOT__c != null ? (1 - oItem.ZCOT__c/100) : 1) *
                    (oItem.XXES__c != null ? (1 - oItem.XXES__c/100) : 1);
            }
            if(oItem.PVCPriceIPINmb__c != null){
                oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c * 
                    (oItem.ZPRO__c != null ? (1 - oItem.ZPRO__c/100) : 1) *
                    (oItem.ZCOT__c != null ? (1 - oItem.ZCOT__c/100) : 1) *
                    (oItem.XXES__c != null ? (1 - oItem.XXES__c/100) : 1);
            }
        }
        try{
            update oItemList;
        }
        catch(Exception e){
            return e.getMessage();
        }
        
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String resendItems(Id orderId){
        List<OrderItem__c> oItemList = [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :orderId AND UnitPriceNmb__c = null];
        if(oItemList.size() == 0){
            return 'SUCCESS';
        }
        List<Id> oItemIds = new List<Id>();
        for(OrderItem__c oItem : oItemList){
            oItemIds.add(oItem.Id);
        }
        
        return OrderIntegrationUtils.createItemListOnSAP(orderId, oItemIds);
    }
    
    @AuraEnabled
    public static String applyDiscount(Id itemId, Decimal zpro, Decimal zcot, Decimal xxes, Decimal amount){
        if(amount == null || amount <= 0) return 'Quantidade Inválida, favor revisar';
        OrderItem__c oItem = [SELECT PVCPriceNmb__c, PVCPriceIPINmb__c, ZPRO__c, ZCOT__c, XXES__c, OrderMdt__c, ProductLkp__c FROM OrderItem__c WHERE Id = :itemId];
        Order__c o = [SELECT Id, ErrorMessageTxt__c, AccountLkp__c,
                      AccountAreaSalesLkp__r.ChannelLkp__c, OrderTypeLkp__c, OrderTypeLkp__r.OrderIrrigationBln__c,
                      (SELECT Id, OrderQuantityNmb__c FROM Itens_da_Ordem__r WHERE ProductLkp__c = :oItem.ProductLkp__c)
                      FROM Order__c WHERE Id = :oItem.OrderMdt__c];
        
        List<BlockedItem__c> listBlock = [SELECT Id, 
                                          MasterPackageAmountNmb__c, 
                                          RecordType.DeveloperName 
                                          FROM BlockedItem__c 
                                          WHERE 
                                          (ProductLkp__c = :oItem.ProductLkp__c AND AccountLkp__c = :o.AccountLkp__c AND RecordType.DeveloperName = 'MasterPackageRT') OR
                                          (ChannelPvcLkp__c = :o.AccountAreaSalesLkp__r.ChannelLkp__c AND OrderTypeLkp__c = :o.OrderTypeLkp__c AND RecordType.DeveloperName = 'PackageSeparationRT')
                                         ];
        
        Product2 prod = [SELECT Id, StandardPackageAmountNmb__c, UMTxt__c, IrrigationItemBln__c, ProductCodeTxt__c FROM Product2 WHERE Id = :oItem.ProductLkp__c];
        Integer packageAmt = (prod.StandardPackageAmountNmb__c != null && prod.StandardPackageAmountNmb__c != 0) ? Integer.valueOf(prod.StandardPackageAmountNmb__c) : 1;
        
        if(listBlock.size() > 0){
            for(BlockedItem__c block : listBlock){
                if(block.MasterPackageAmountNmb__c != null){
                    packageAmt = Integer.valueOf(block.MasterPackageAmountNmb__c);
                    break;
                }
                else if(block.RecordType.DeveloperName == 'PackageSeparationRT' && prod.UMTxt__c != 'M') packageAmt = 1;
            }
        }
        
        
        system.debug('zpro: ' + zpro + '; zcot: ' + zcot + '; xxes: ' + xxes);
        
        oItem.ZPRO__c = zpro != null ? zpro : 0;
        oItem.ZCOT__c = zcot != null ? zcot : 0;
        oItem.XXES__c = xxes != null ? xxes : 0;
        
        if(oItem.PVCPriceNmb__c != null){
            oItem.UnitPriceNmb__c = oItem.PVCPriceNmb__c * 
                (oItem.ZPRO__c != null ? (1 - oItem.ZPRO__c/100) : 1) * 
                (oItem.ZCOT__c != null ? (1 - oItem.ZCOT__c/100) : 1) *
                (oItem.XXES__c != null ? (1 - oItem.XXES__c/100) : 1);
        }
        if(oItem.PVCPriceIPINmb__c != null){
            oItem.UnitPriceIPINmb__c = oItem.PVCPriceIPINmb__c * 
                (oItem.ZPRO__c != null ? (1 - oItem.ZPRO__c/100) : 1) *
                (oItem.ZCOT__c != null ? (1 - oItem.ZCOT__c/100) : 1) *
                (oItem.XXES__c != null ? (1 - oItem.XXES__c/100) : 1);
        }
        
        Integer division = amount.intValue() / packageAmt; 
        
        if(division * packageAmt != amount){
            return 'Item sendo vendido fora da Embalagem Padrão/Master. Favor negociar em múltiplos de ' + packageAmt;
        }
        
        oItem.OrderQuantityNmb__c = amount != null ? amount : 0;
        
        try{
            update oItem;
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static String addProductFromCart(Id orderId, String productCode, Decimal quantity, Boolean usePackage){
        List<Product2> prodList = [SELECT Id FROM Product2 WHERE ProductCodeTxt__c = :productCode];
        
        if(prodList.size() == 0) return 'Não foi encontrado item para o código ' + productCode;
        else if(prodList.size() > 1) return 'Foi encontrada mais de uma correspondência de item para o código ' + productCode;
        else {
            return PricebookComponentController.addProduct(prodList[0].Id, orderId, quantity, usePackage);
        }
    }
    
    @AuraEnabled
    public static String deleteProduct(Id oItemId){
        try{
            delete new OrderItem__c(Id = oItemId);
            return 'SUCCESS';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<PaymentTerm__c> getPaymentTerms(Id orderId){
        Order__c o = [SELECT PaymentTermLkp__r.AverageTermNmb__c FROM Order__c WHERE Id = :orderId];
        Decimal avgTerm = o.PaymentTermLkp__r.AverageTermNmb__c;
        return [SELECT Id, CustomizedIdTxt__c, Name, InstallmentsNmb__c 
                FROM PaymentTerm__c 
                WHERE isActiveBln__c = TRUE 
                AND AverageTermNmb__c = :avgTerm 
                ORDER BY CustomizedIdTxt__c ];
    }
    
    @AuraEnabled
    public static String convertQuoteIntoOrderAsync(Id orderId){
        String response = validateErrors(orderId);
        if(response == ''){
            try{
                delete [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :orderId AND ErrorMessageTxt__c != null];
                if(!System.Test.isRunningTest())
                    Id jobID = System.enqueueJob(new ConvertOrderAsync(orderId));
            }
            catch (Exception e){
                response = e.getMessage();
            }
        }
        else return response;
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String getOrderLog(Id orderId){
        Order__c ord = [SELECT Id, CustomIdTxt__c, SAPGUIDTxt__c FROM Order__c WHERE Id =: orderId];
        if(ord.SAPGUIDTxt__c == null) return 'SUCCESS';
        
        String response = OrderIntegrationUtils.getLog(orderId);
        
        if(response == 'SUCCESS'){
            ord = [SELECT Id, CustomIdTxt__c, SAPGUIDTxt__c FROM Order__c WHERE Id =: orderId];
            Id jobID = System.enqueueJob(new UpdateOrderAsync(ord.CustomIDTxt__c));
        }
        
        return response;
    }
    
    @AuraEnabled
    public static String convertQuoteIntoOrder(Id orderId){
        String response = validateErrors(orderId);
        if(response == ''){
            try{
                delete [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :orderId AND ErrorMessageTxt__c != null];
                if(!System.Test.isRunningTest())
                	OrderIntegrationUtils.convertQuoteIntoOrderFuture(orderId);
            }
            catch (Exception e){
                response = e.getMessage();
            }
        }
        else return response;
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String alocateKits(Id orderId, String remessas){
        try{
            List<Remessa> listRem = (List<Remessa>)JSON.deserialize(remessas, List<Remessa>.class);
            List<OrderItem__c> oItemToInsert = new List<OrderItem__c>();
            Product2 prod20109 = new Product2(ProductCodeTxt__c = '20109');
            Product2 prod20159 = new Product2(ProductCodeTxt__c = '20159');
            for(Remessa rem : listRem){
                if(!containsKitItem('20159', rem.Items)){
                    oItemToInsert.add(new OrderItem__c(ProductLkp__r = prod20159, 
                                                       OrderMdt__c = orderId, 
                                                       OrderQuantityNmb__c = 1, 
                                                       RemittanceGroupTxt__c = String.valueOf(rem.numRem),
                                                       PaymentConditionTxt__c = rem.CondPagto,
                                                       Remittance1DateDte__c = rem.DataProg != null ? Date.valueOf(rem.DataProg) : null,
                                                       ExpeditionCenterLkp__r = new ExpeditionCenter__c(CustomIdTxt__c = rem.LocExped),
                                                       DistributionCenterTxt__c = rem.CentroFornecedor));
                }
                if(rem.CentroFornecedor == '0700'){
                    if(!containsKitItem('20109', rem.Items)){
                        oItemToInsert.add(new OrderItem__c(ProductLkp__r = prod20109, 
                                                           OrderMdt__c = orderId, 
                                                           OrderQuantityNmb__c = 3, 
                                                           RemittanceGroupTxt__c = String.valueOf(rem.numRem),
                                                           PaymentConditionTxt__c = rem.CondPagto,
                                                           Remittance1DateDte__c = rem.DataProg != null ? Date.valueOf(rem.DataProg) : null,
                                                           ExpeditionCenterLkp__r = new ExpeditionCenter__c(CustomIdTxt__c = rem.LocExped),
                                                           DistributionCenterTxt__c = rem.CentroFornecedor));
                    }
                }
            }
            if(oItemToInsert.size() > 0){
                insert oItemToInsert;
                List<Id> oItemListIds = new List<Id> ();
                for(OrderItem__c oItem : oItemToInsert){
                    oItemListIds.add(oItem.Id);
                }
                if(!System.Test.isRunningTest())
                    createItemListSAP(orderId, oItemListIds);
            }
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getStackTraceString();
        }
    }
    
    private static boolean containsKitItem(String productCode, List<ItemRemessa> itensRemessa){
        for(ItemRemessa itemRem : itensRemessa){
            if(itemRem.Cod == productCode)
                return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static String getRemessas(Id orderId, Boolean isGargalo){
        List<Id> listProdIds = new List<Id>();
        Map<String, Integer> mapPackageAmount = new Map<String, Integer>();
        Order__c o = [SELECT Id, 
                      ErrorMessageTxt__c, 
                      AccountLkp__c, 
                      AccountAreaSalesLkp__c, 
                      AccountAreaSalesLkp__r.ChannelLkp__c, 
                      OrderTypeLkp__c,
                      OrderTypeLkp__r.ShippingSplitBln__c,
                      OrderTypeLkp__r.OrderIrrigationBln__c
                      FROM Order__c WHERE Id = :orderId];
        if(o.AccountAreaSalesLkp__c == null){
            return 'Erro: a área de vendas selecionada não possui canal especificado. Contate o admininstrador do sistema';
        }
        Map<String, BlockedItem__c> mapBlock = new Map<String, BlockedItem__c>();
        for(BlockedItem__c block : [SELECT Id, 
                                    MasterPackageAmountNmb__c, 
                                    ProductLkp__c,
                                    AccountLkp__c,
                                    ChannelPvcLkp__c,
                                    OrderTypeLkp__c,
                                    RecordType.DeveloperName 
                                    FROM BlockedItem__c 
                                    WHERE 
                                    (AccountLkp__c = :o.AccountLkp__c AND RecordType.DeveloperName = 'MasterPackageRT') OR
                                    (ChannelPvcLkp__c = :o.AccountAreaSalesLkp__r.ChannelLkp__c AND OrderTypeLkp__c = :o.OrderTypeLkp__c AND RecordType.DeveloperName = 'PackageSeparationRT')
                                   ]
           ){
               if(block.RecordType.DeveloperName == 'MasterPackageRT')
                   mapBlock.put(String.valueOf(block.AccountLkp__c).substring(0,15) + String.valueOf(block.ProductLkp__c).substring(0,15), block);
               if(block.RecordType.DeveloperName == 'PackageSeparationRt')
                   mapBlock.put(String.valueOf(block.ChannelPvcLkp__c).substring(0,15) + String.valueOf(block.ChannelPvcLkp__c).substring(0,15), block);
           }
        List<OrderItem__c> oItemList = [SELECT Id, 
                                        OrderMdt__r.PaymentTermLkp__r.CustomizedIdTxt__c,
                                        OrderMdt__r.RemittanceDesiredDateDte__c,
                                        ProductLkp__r.UnitWeightTxt__c,
                                        ProductLkp__r.GrossWeightNmb__c,
                                        ProductLkp__r.LoadPercentageNmb__c,
                                        ProductLkp__r.StandardPackageAmountNmb__c,
                                        ProductNameFml__c, 
                                        ProductCode__c, 
                                        OrderQuantityNmb__c, 
                                        UnitPriceNmb__c,
                                        ValueROBNoIPIFml__c,
                                        DistributionCenterTxt__c, 
                                        BottleneckDaysNmb__c,
                                        Remittance1DateDte__c,
                                        PaymentConditionTxt__c,
                                        TOLABEL(DistributionCenterTxt__c) labelDist,
                                        ExpeditionCenterLkp__r.Name,
                                        ExpeditionCenterLkp__r.CustomIdTxt__c,
                                        ExpeditionCenterLkp__r.MeasureTypeTxt__c,
                                        RemittanceGroupTxt__c
                                        FROM OrderItem__c WHERE OrderMdt__c = :orderId
                                        //AND UnitPriceNmb__c != null
                                        AND DistributionCenterTxt__c != null
                                        AND ExpeditionCenterLkp__c != null
                                        AND ProductCode__c NOT IN ('20159', '20109')
                                        ORDER BY  ProductLkp__r.ProductCodeTxt__c, RemittanceGroupTxt__c, ExpeditionCenterLkp__r.CustomIdTxt__c
                                       ];
        
        Boolean hasNullRemittanceGroup = false;
        
        for(OrderItem__c oItem : oItemList){
            Integer packageAmount = Integer.valueOf(oItem.ProductLkp__r.StandardPackageAmountNmb__c);
            String keySeparation = String.valueOf(o.AccountAreaSalesLkp__r.ChannelLkp__c != null ? o.AccountAreaSalesLkp__r.ChannelLkp__c : o.AccountAreaSalesLkp__c).substring(0,15) + String.valueOf(o.OrderTypeLkp__c).substring(0,15);
            String keyMaster = String.valueOf(o.AccountLkp__c).substring(0,15) + String.valueOf(oItem.ProductLkp__c).substring(0,15);
            if(mapBlock.containsKey(keyMaster)){
                mapPackageAmount.put(oItem.Id, Integer.valueOf(mapBlock.get(keyMaster).MasterPackageAmountNmb__c));
            }
            else if(mapBlock.containsKey(keySeparation)){
                MapPackageAmount.put(oItem.Id, 1);
            }
            else mapPackageAmount.put(oItem.Id, packageAmount);
            
            if(oItem.RemittanceGroupTxt__c == null){
                hasNullRemittanceGroup = true;
            }
        }
        System.debug(oItemList);
        System.debug('###hasNullRemittanceGroup = '+hasNullRemittanceGroup);
        /*
List<BlockedItem__c> listBlock = [SELECT Id, 
MasterPackageAmountNmb__c, 
RecordType.DeveloperName 
FROM BlockedItem__c 
WHERE 
(RecordType.DeveloperName = 'MasterPackageRT') OR
(RecordType.DeveloperName = 'PackageSeparationRT')
];
Product2 prod = [SELECT Id, StandardPackageAmountNmb__c, UMTxt__c FROM Product2 WHERE Id = :idProduct];
Integer packageAmt = Integer.valueOf(prod.StandardPackageAmountNmb__c);

for(BlockedItem__c block : listBlock){
if(block.MasterPackageAmountNmb__c != null){
packageAmt = Integer.valueOf(block.MasterPackageAmountNmb__c);
break;
}
else if(block.RecordType.DeveloperName == 'PackageSeparationRT' && prod.UMTxt__c != 'M') packageAmt = 1;
}
*/
        Integer numeroRemessa = 1;
        
        List<Remessa> listRem = new List<Remessa>();
        Map<String, Remessa> remessaByExpedition = new Map<String, Remessa>();
        List<ItemRemessa> itemListAux = new List<ItemRemessa>();
        
        if(hasNullRemittanceGroup){
            for(OrderItem__c oItem : oItemList){
                String chaveGargalo = !isGargalo ? '' : 
                oItem.BottleneckDaysNmb__c == 0 || oItem.BottleneckDaysNmb__c == null ? '' :
                oItem.BottleneckDaysNmb__c > 0 && oItem.BottleneckDaysNmb__c <= 20 ? 'Yellow' :
                oItem.BottleneckDaysNmb__c > 20 && oItem.BottleneckDaysNmb__c <= 30 ? 'Red' : 
                oItem.BottleneckDaysNmb__c > 30  ? 'Black' : '';
                
                Remessa rem = new Remessa();
                if(!remessaByExpedition.containsKey(oItem.ExpeditionCenterLkp__r.CustomIdTxt__c + chaveGargalo)){
                    rem.LocExped = oItem.ExpeditionCenterLkp__r.CustomIdTxt__c;
                    rem.DescLocExped = oItem.ExpeditionCenterLkp__r.Name;
                    rem.CentroFornecedor = oItem.DistributionCenterTxt__c;
                    rem.DescCentroFornecedor = (String)oItem.get('labelDist');
                    rem.Qtde = 0;
                    rem.TotalSIpi = 0;
                    rem.CondPagto = oItem.PaymentConditionTxt__c != null ? oItem.PaymentConditionTxt__c : oItem.OrderMdt__r.PaymentTermLkp__r.CustomizedIdTxt__c;
                    rem.DataProg = oItem.Remittance1DateDte__c != null ? String.valueOf(oItem.Remittance1DateDte__c) : String.valueOf(oItem.OrderMdt__r.RemittanceDesiredDateDte__c);
                    rem.Tipo = oItem.ExpeditionCenterLkp__r.CustomIdTxt__c == '0020' ? 'K' : 'P';
                    rem.TotalKg = 0;
                    rem.MaxKg = rem.Tipo == 'K' ? 5000 : 100.1;
                    rem.items = new List<ItemRemessa>();
                    rem.numRem = numeroRemessa;
                    numeroRemessa++;
                }
                else{
                    rem = remessaByExpedition.get(oItem.ExpeditionCenterLkp__r.CustomIdTxt__c + chaveGargalo);
                }
                List<ItemRemessa> itemList = rem.items;
                rem.Qtde += oItem.OrderQuantityNmb__c;
                rem.TotalSIPI += oItem.ValueROBNoIPIFml__c;
                if(rem.Tipo == 'K')
                    rem.TotalKg += (oItem.ProductLkp__r.GrossWeightNmb__c != null ? oItem.ProductLkp__r.GrossWeightNmb__c : 0) * (oItem.ProductLkp__r.UnitWeightTxt__c == 'G' ? 0.001 : 1) * oItem.OrderQuantityNmb__c;
                else rem.TotalKg += (oItem.ProductLkp__r.LoadPercentageNmb__c != null ? oItem.ProductLkp__r.LoadPercentageNmb__c : 0) * oItem.OrderQuantityNmb__c;
                ItemRemessa itemAux = new ItemRemessa();
                itemAux.OrderItemId = oItem.Id;
                itemAux.Cod = oItem.ProductCode__c;
                itemAux.Description = oItem.ProductNameFml__c;
                itemAux.Qtde = oItem.OrderQuantityNmb__c;
                itemAux.CondPagto = oItem.PaymentConditionTxt__c != null ? oItem.PaymentConditionTxt__c : rem.CondPagto;
                itemAux.DataProg = oItem.Remittance1DateDte__c != null ? String.valueOf(oItem.Remittance1DateDte__c) : rem.DataProg;
                itemAux.UnitPrice = oItem.ValueROBNoIPIFml__c / oItem.OrderQuantityNmb__c;
                itemAux.numRem = rem.numRem;
                if(rem.Tipo == 'K')
                    itemAux.UnitKg = oItem.ProductLkp__r.GrossWeightNmb__c * (oItem.ProductLkp__r.UnitWeightTxt__c == 'G' ? 0.001 : 1);
                else itemAux.UnitKg = oItem.ProductLkp__r.LoadPercentageNmb__c;
                itemAux.PackageAmount = mapPackageAmount.get(oItem.Id);
                itemList.add(itemAux);
                rem.items = itemList;
                remessaByExpedition.put(oItem.ExpeditionCenterLkp__r.CustomIdTxt__c + chaveGargalo, rem);
            }            
        }else{
     		for(OrderItem__c oItem : oItemList){
                String chaveGargalo = !isGargalo ? '' : 
                oItem.BottleneckDaysNmb__c == 0 || oItem.BottleneckDaysNmb__c == null ? '' :
                oItem.BottleneckDaysNmb__c > 0 && oItem.BottleneckDaysNmb__c <= 20 ? 'Yellow' :
                oItem.BottleneckDaysNmb__c > 20 && oItem.BottleneckDaysNmb__c <= 30 ? 'Red' : 
                oItem.BottleneckDaysNmb__c > 30  ? 'Black' : '';
                
                Remessa rem = new Remessa();
                if(!remessaByExpedition.containsKey(oItem.RemittanceGroupTxt__c + chaveGargalo)){
                    rem.LocExped = oItem.ExpeditionCenterLkp__r.CustomIdTxt__c;
                    rem.DescLocExped = oItem.ExpeditionCenterLkp__r.Name;
                    rem.CentroFornecedor = oItem.DistributionCenterTxt__c;
                    rem.DescCentroFornecedor = (String)oItem.get('labelDist');
                    rem.Qtde = 0;
                    rem.TotalSIpi = 0;
                    rem.CondPagto = oItem.PaymentConditionTxt__c != null ? oItem.PaymentConditionTxt__c : oItem.OrderMdt__r.PaymentTermLkp__r.CustomizedIdTxt__c;
                    rem.DataProg = oItem.Remittance1DateDte__c != null ? String.valueOf(oItem.Remittance1DateDte__c) : String.valueOf(oItem.OrderMdt__r.RemittanceDesiredDateDte__c);
                    rem.Tipo = oItem.ExpeditionCenterLkp__r.CustomIdTxt__c == '0020' ? 'K' : 'P';
                    rem.TotalKg = 0;
                    rem.MaxKg = rem.Tipo == 'K' ? 5000 : 100.1;
                    rem.items = new List<ItemRemessa>();
                    rem.numRem = numeroRemessa;
                    numeroRemessa++;
                }
                else{
                    rem = remessaByExpedition.get(oItem.RemittanceGroupTxt__c + chaveGargalo);
                }
                List<ItemRemessa> itemList = rem.items;
                rem.Qtde += oItem.OrderQuantityNmb__c;
                rem.TotalSIPI += oItem.ValueROBNoIPIFml__c;
                if(rem.Tipo == 'K')
                    rem.TotalKg += oItem.ProductLkp__r.GrossWeightNmb__c * (oItem.ProductLkp__r.UnitWeightTxt__c == 'G' ? 0.001 : 1) * oItem.OrderQuantityNmb__c;
                else rem.TotalKg += oItem.ProductLkp__r.LoadPercentageNmb__c * oItem.OrderQuantityNmb__c;
                ItemRemessa itemAux = new ItemRemessa();
                itemAux.OrderItemId = oItem.Id;
                itemAux.Cod = oItem.ProductCode__c;
                itemAux.Description = oItem.ProductNameFml__c;
                itemAux.Qtde = oItem.OrderQuantityNmb__c;
                itemAux.CondPagto = oItem.PaymentConditionTxt__c != null ? oItem.PaymentConditionTxt__c : rem.CondPagto;
                itemAux.DataProg = oItem.Remittance1DateDte__c != null ? String.valueOf(oItem.Remittance1DateDte__c) : rem.DataProg;
                itemAux.UnitPrice = oItem.ValueROBNoIPIFml__c / oItem.OrderQuantityNmb__c;
                itemAux.numRem = rem.numRem;
                if(rem.Tipo == 'K')
                    itemAux.UnitKg = oItem.ProductLkp__r.GrossWeightNmb__c * (oItem.ProductLkp__r.UnitWeightTxt__c == 'G' ? 0.001 : 1);
                else itemAux.UnitKg = oItem.ProductLkp__r.LoadPercentageNmb__c;
                itemAux.PackageAmount = mapPackageAmount.get(oItem.Id);
                itemList.add(itemAux);
                rem.items = itemList;
                remessaByExpedition.put(oItem.RemittanceGroupTxt__c + chaveGargalo, rem);
            }                        
        }
        
        system.debug(JSON.serialize(remessaByExpedition.values()));
        if(o.OrderTypeLkp__c != null && o.OrderTypeLkp__r.ShippingSplitBln__c){
            List<Remessa> listRemAux = remessaByExpedition.values();
            listRemAux.sort();
            return JSON.serialize(listRemAux);
        }
       
        for(Remessa remAux : remessaByExpedition.values()){
            Boolean skipSplit = (remAux.TotalKg <= remAux.MaxKg) || (o.OrderTypeLkp__r.OrderIrrigationBln__c && remAux.LocExped == '0020');
            if(!skipSplit){
                Decimal numRem = Math.ceil(remAux.TotalKg/remAux.MaxKg);
                Map<Integer, ItemRemessa> itemMap = new Map<Integer, ItemRemessa>();
                for(Integer i = 0; i < remAux.items.size(); i++){
                    itemMap.put(i, remAux.items[i]);
                }
                Integer j = 0;
                Boolean isFirst = true;
                while(j < remAux.items.size()){
                    Remessa rem = new Remessa();
                    rem.LocExped = remAux.LocExped;
                    rem.DescLocExped = remAux.DescLocExped;
                    rem.CentroFornecedor = remAux.CentroFornecedor;
                    rem.DescCentroFornecedor = remAux.DescCentroFornecedor;
                    rem.Qtde = 0;
                    rem.TotalSIpi = 0;
                    rem.CondPagto = remAux.CondPagto;
                    rem.DataProg = remAux.DataProg;
                    rem.Tipo = remAux.Tipo;
                    rem.TotalKg = 0;
                    rem.MaxKg = remAux.MaxKg;
                    if(isFirst){
                        rem.numRem = remAux.numRem;
                        isFirst = false;
                    }
                    else{
                        rem.numRem = numeroRemessa;
                        numeroRemessa++;
                    }
                    rem.items = new List<ItemRemessa>();
                    while(j < remAux.items.size()){
                        ItemRemessa itemAux = remAux.items[j];
                        Decimal packageAmount = itemAux.PackageAmount != null ? itemAux.PackageAmount : 1;
                        Decimal maxInsert = rem.MaxKg - rem.TotalKg;
                        ItemRemessa item = new ItemRemessa();
                        item.OrderItemId = itemAux.OrderItemId;
                        item.Cod = itemAux.Cod;
                        item.Description = itemAux.Description;
                        item.CondPagto = itemAux.CondPagto;
                        if(item.CondPagto != rem.condPagto) rem.CondPagto = item.CondPagto;
                        item.DataProg = itemAux.DataProg;
                        if(item.DataProg != rem.DataProg) rem.DataProg = item.DataProg;
                        item.numRem = rem.numRem;
                        Decimal maxUnits = maxInsert/itemAux.UnitKg;
                        Decimal maxQtde = math.floor(maxUnits/packageAmount) * packageAmount; 
                        system.debug('maxQtde: ' + maxQtde);
                        
                        item.Qtde = Math.min(maxQtde, itemAux.Qtde);
                        item.UnitPrice = itemAux.UnitPrice;
                        item.UnitKg = itemAux.UnitKg;
                        item.PackageAmount = packageAmount;
                        
                        itemAux.Qtde -= item.Qtde;
                        system.debug('itemAux.Qtde: ' + itemAux.Qtde);
                        rem.Qtde += item.Qtde;
                        rem.TotalSIPI += item.UnitPrice != null ? (item.UnitPrice * item.Qtde) : 0;
                        rem.TotalKg += item.UnitKg * item.Qtde;
                        if(item.Qtde > 0)
                            rem.items.add(item);
                        if(itemAux.Qtde == 0) 
                            j++;
                        else break;
                    }
                    listRem.add(rem);
                }
                
            }
            else listRem.add(remAux);
        }
        if(!o.OrderTypeLkp__r.OrderIrrigationBln__c){
            listRem.sort();
            system.debug(JSON.serialize(listRem));
            return JSON.serialize(listRem);
        }
        system.debug(JSON.serialize(listRem));
        List<OrderItem__c> listKitItems = [SELECT Id, 
                                           OrderMdt__r.PaymentTermLkp__r.CustomizedIdTxt__c,
                                           OrderMdt__r.RemittanceDesiredDateDte__c,
                                           ProductLkp__r.UnitWeightTxt__c,
                                           ProductLkp__r.GrossWeightNmb__c,
                                           ProductLkp__r.LoadPercentageNmb__c,
                                           ProductLkp__r.StandardPackageAmountNmb__c,
                                           ProductNameFml__c, 
                                           ProductCode__c, 
                                           OrderQuantityNmb__c, 
                                           UnitPriceNmb__c,
                                           DistributionCenterTxt__c, 
                                           BottleneckDaysNmb__c,
                                           Remittance1DateDte__c,
                                           PaymentConditionTxt__c,
                                           TOLABEL(DistributionCenterTxt__c) labelDist,
                                           ExpeditionCenterLkp__r.Name,
                                           ExpeditionCenterLkp__r.CustomIdTxt__c,
                                           ExpeditionCenterLkp__r.MeasureTypeTxt__c,
                                           RemittanceGroupTxt__c
                                           FROM OrderItem__c 
                                           WHERE ProductCode__c IN ('20109', '20159')
                                           AND OrderMdt__c = :orderId];
        for(Remessa rem : listRem){
            for(OrderItem__c kitItem : listKitItems){
                if(kitItem.RemittanceGroupTxt__c != null && rem.numRem != null && kitItem.RemittanceGroupTxt__c.leftPad(4, '0') == String.valueOf(rem.numRem).leftPad(4,'0')){
                    ItemRemessa item = new ItemRemessa();
                    item.OrderItemId = kitItem.Id;
                    item.Cod = kitItem.ProductCode__c;
                    item.Description = kitItem.ProductNameFml__c;
                    item.CondPagto = rem.CondPagto;
                    item.DataProg = rem.DataProg;
                    item.numRem = rem.numRem;
                    item.Qtde =kitItem.OrderQuantityNmb__c;
                    item.UnitPrice = kitItem.UnitPriceNmb__c;
                    if(rem.Tipo == 'K')
                        item.UnitKg = kitItem.ProductLkp__r.GrossWeightNmb__c * (kitItem.ProductLkp__r.UnitWeightTxt__c == 'G' ? 0.001 : 1);
                    else item.UnitKg = kitItem.ProductLkp__r.LoadPercentageNmb__c;
                    item.PackageAmount = 1;
                    
                    rem.Qtde += item.Qtde;
                    rem.TotalSIPI += item.UnitPrice != null ? (item.UnitPrice * item.Qtde) : 0;
                    rem.TotalKg += item.UnitKg * item.Qtde;
                    rem.items.add(item);
                }
            }
            
        }
        listRem.sort();
        system.debug(JSON.serialize(listRem));
        return JSON.serialize(listRem);
    }
    
    @AuraEnabled
    public static String saveRemessas(Id orderId, String remessas){
        try{
            System.debug(remessas);
            Order__c o = [SELECT Id, OrderDateDte__c, AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c FROM Order__c WHERE Id =: orderId];
            Integer daysToAdd = o.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c == '0099' ? 180 : 30;
            List<Remessa> listRem = (List<Remessa>)JSON.deserialize(remessas, List<Remessa>.class);
            Date lastRemDate = Date.newInstance(1900, 1, 1);
            
            system.debug(listRem);
            
            String queryFields = 'ID,';
            for(Schema.FieldSetMember f : SObjectType.OrderItem__c.FieldSets.ClonedFields.getFields()){
                queryFields += f.getFieldPath() + ',';
            }
            queryFields = queryFields.removeEnd(',');
            String query = 'SELECT ' + queryFields + ' FROM OrderItem__c WHERE OrderMdt__c = \'' + orderId + '\'';
            query += ' AND TotalGrossCostNmb__c != null AND DistributionCenterTxt__c != null AND ExpeditionCenterLkp__c != null ';
            List<OrderItem__c> listItems = Database.query(query);
            Map<String, PaymentTerm__c> mapTerms = new Map<String, PaymentTerm__c>();
            for(PaymentTerm__c term : [SELECT Id, InstallmentsNmb__c, CustomizedIdTxt__c FROM PaymentTerm__c]){
                mapTerms.put(term.CustomizedIDTxt__c, term);
            }
            Map<Id, OrderItem__c> mapItem = new Map<Id, OrderItem__c>(listItems);
            Map<Id, List<ItemRemessa>> mapItemRemessa = new Map<Id, List<ItemRemessa>>();
            
            List<OrderItem__c> oItemListToInsert = new List<OrderItem__c>();
            List<OrderItem__c> oItemListToUpdate = new List<OrderItem__c>();
            
            for(Remessa rem : (List<Remessa>)listRem){
                if(rem.DataProg != null && Date.valueOf(rem.DataProg) > lastRemDate){
                    lastRemDate = Date.valueOf(rem.DataProg);
                }
                if(rem.DataProg != null && (Date.valueOf(rem.DataProg) > o.OrderDateDte__c.addDays(daysToAdd) || Date.valueOf(rem.DataProg) < o.OrderDateDte__c)){
                    string errorMsg  = 'Remessa número ' + rem.numRem + ' com data de programação inválida. Favor selecionar data entre ';
                    errorMsg += o.OrderDateDte__c.day() + '/' + o.OrderDateDte__c.month() + ' e ';
                    errorMsg += o.OrderDateDte__c.addDays(daysToAdd).day() + '/' +  o.OrderDateDte__c.addDays(daysToAdd).month();
                    return errorMsg; 
                }
                system.debug(rem);
                if((rem.TotalSIpi < 250) || rem.CondPagto != null && (rem.TotalSIpi / mapTerms.get(rem.CondPagto).InstallmentsNmb__c) < 250){
                    return 'Remessa número ' + rem.numRem + ' com valor da parcela inferior ao mínimo, favor revisar';
                }
                for(ItemRemessa itemRem : rem.items){
                    itemRem.CondPagto = rem.CondPagto;
                    itemRem.DataProg = rem.DataProg;
                    List<ItemRemessa> listItemAux = new List<ItemRemessa>();
                    if(mapItemRemessa.containsKey(itemRem.OrderItemId)){
                        listItemAux = mapItemRemessa.get(itemRem.OrderItemId);
                    }
                    listItemAux.add(itemRem);
                    mapItemRemessa.put(itemRem.OrderItemId, listItemAux);
                }
            }
            for(Id oItemId : mapItem.keySet()){
                OrderItem__c oItemAux = mapItem.get(oItemId);
                List<ItemRemessa> itemsRemAux = mapItemRemessa.get(oItemId);
                system.debug(itemsRemAux);
                if(itemsRemAux.size() == 1){
                    oItemAux.OrderQuantityNmb__c = itemsRemAux[0].Qtde;
                    oItemAux.PaymentConditionTxt__c = itemsRemAux[0].CondPagto;
                    oItemAux.Remittance1DateDte__c = itemsRemAux[0].DataProg != null ? Date.valueOf(itemsRemAux[0].DataProg) : null;
                    oItemAux.RemittanceGroupTxt__c = String.valueOf(itemsRemAux[0].numRem);
                    oItemListToUpdate.add(oItemAux);
                    continue;
                }
                for(Integer i = 0; i < itemsRemAux.size(); i++){
                    if(i == 0){
                        oItemAux.OrderQuantityNmb__c = itemsRemAux[i].Qtde;
                        oItemAux.PaymentConditionTxt__c = itemsRemAux[i].CondPagto;
                        oItemAux.Remittance1DateDte__c = itemsRemAux[i].DataProg != null ? Date.valueOf(itemsRemAux[i].DataProg) : null;
                        oItemAux.RemittanceGroupTxt__c = String.valueOf(itemsRemAux[i].numRem);
                        oItemListToUpdate.add(oItemAux);
                    }
                    else{
                        OrderItem__c oItem = oItemAux.clone(false, true, false, false);
                        oItem.OrderQuantityNmb__c = itemsRemAux[i].Qtde;
                        oItem.PaymentConditionTxt__c = itemsRemAux[i].CondPagto;
                        oItem.Remittance1DateDte__c = itemsRemAux[i].DataProg != null ? Date.valueOf(itemsRemAux[i].DataProg) : null;
                        oItem.RemittanceGroupTxt__c = String.valueOf(itemsRemAux[i].numRem);
                        oItemListToInsert.add(oItem);
                    }
                }
            }
            system.debug(oItemListToUpdate);
            if(oItemListToUpdate.size() > 0)
                update oItemListToUpdate;
            if(oItemListToInsert.size() > 0){
                insert oItemListToInsert;
            }
            system.debug(lastRemDate);
            update new Order__c(Id = orderId, 
                                ShippingSplitDoneBln__c = true, 
                                RemittanceDesiredDateDte__c = lastRemDate > Date.newInstance(1900, 1, 2) ? lastRemDate : null);
            return 'SUCCESS';
        }
        catch (Exception e){
            return e.getMessage();
        }
    }
	
    @AuraEnabled
    public static String modifyRemessas(String remessas, String itemId, Decimal oldRemessaNmb, Decimal newRemessaNmb){        
        Response methodResponse = new Response();

        List<Remessa> listRem = (List<Remessa>)JSON.deserialize(remessas, List<Remessa>.class);
        Integer indexOldRem = -1;
        Integer indexNewRem = -1;
        Integer indexOrderItem = -1;
        //Map<String, Remessa> mapRem = new Map<String, Remessa>();
        ItemRemessa itemToModify;
        
        System.debug(remessas);
        
        for(Integer I = 0; I < listRem.size(); I++){
            if(listRem[I].numRem == oldRemessaNmb){
                indexOldRem = I;
                
                for(Integer J = 0; J < listRem[I].items.size(); J++){
                    if(listRem[I].items[J].OrderItemId == itemId){
                    	indexOrderItem = J;    
                        break;
                    }
                }
            }else if(listRem[I].numRem == newRemessaNmb){
                indexNewRem = I;
            }
        }
        
        if(indexNewRem == -1){
            methodResponse.hasError = True;
            methodResponse.errorMsg = 'A remessa informada não existe.';      
        }else if(listRem[indexOldRem].LocExped != listRem[indexNewRem].LocExped){
        	methodResponse.hasError = True;
            methodResponse.errorMsg = 'Para mover itens entre remessas, elas devem possuir o mesmo local de expedição.';  	
        }else if(listRem[indexOldRem].items.size() == 1){
        	methodResponse.hasError = True;
            methodResponse.errorMsg = 'Não é possível mover o único item da remessa.';  	            
        }
        else{
            ItemRemessa itemRem = listRem[indexOldRem].items[indexOrderItem];
            System.debug('###Item Antes:');
            System.debug(itemRem);
            itemRem.numRem = newRemessaNmb;
            System.debug('###Item Depois:');
            System.debug(itemRem);
            
            listRem[indexNewRem].items.add(itemRem);
            listRem[indexOldRem].items.remove(indexOrderItem);
            
            listRem[indexNewRem].Qtde += itemRem.Qtde;
            listRem[indexNewRem].TotalSIpi += (itemRem.Qtde * itemRem.UnitPrice);
            listRem[indexNewRem].TotalKg += (itemRem.Qtde * itemRem.UnitKg);
            
            listRem[indexOldRem].Qtde -= itemRem.Qtde;
            listRem[indexOldRem].TotalSIpi -= (itemRem.Qtde * itemRem.UnitPrice);
            listRem[indexOldRem].TotalKg -= (itemRem.Qtde * itemRem.UnitKg);
            
            if(listRem[indexNewRem].TotalKg > listRem[indexNewRem].MaxKg){
                methodResponse.hasError = True;
                methodResponse.errorMsg = 'Não é possível mover o item para a remessa selecionada, pois não há espaço suficiente na remessa.';  	                
            }else{
                System.debug('###Remessas Antes:');
                System.debug(remessas);
                
                String modifiedString = JSON.serialize(listRem);
                System.debug('###Remessas Depois:');
                System.debug(modifiedString);
                
                methodResponse.hasError = false;
                methodResponse.remessas = modifiedString;                     
            }
        }
        
        System.debug(JSON.serialize(methodResponse));
        return JSON.serialize(methodResponse);
    }
    
    @AuraEnabled
    public static void createItemListSAP(Id orderId, List<Id> oItemIds){        
        OrderIntegrationUtils.createItemListOnSAPFuture(orderId, oItemIds);
    }
    
    private static String validateErrors(Id orderId){
        String response =  '';
        Order__c o = [SELECT Id, 
                      ItemsWithZCOT__c, 
                      OrderStatusTxt__c, 
                      SuggestedDoneBln__c,
                      OrderTypeLkp__r.SalesOrderTypeCodeTxt__c,
                      AccountAreaSalesLkp__r.ChannelLkp__c,
                      OutdatedPVCBln__c,
                      AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c,
                      ErrorMessageTxt__c
                      FROM Order__c WHERE Id = :orderId];
        
        if(o.OrderStatusTxt__c == 'SentToSap'){
            return 'Pedido já enviado ao SAP';
        }
        
        if((o.ErrorMessageTxt__c != '') && (o.ErrorMessageTxt__c != null)){
            return 'Não é possível finalizar o pedido de uma ordem que possua erros.\n'+o.ErrorMessageTxt__c;
        }
        
        if(!o.SuggestedDoneBln__c){
            return 'É necessário visualizar os produtos sugeridos antes de finalizar o pedido';
        }
        
        if(o.ItemsWithZCOT__c != 0 && o.OrderStatusTxt__c != 'Approved'){
            return 'Pedido com desconto de cotação deve passar por aprovação.';
        }
        if(o.OutdatedPVCBln__c){
            return 'PVC expirado, acesse a aba de PVC para revisar.';
        }
        OrderType__c orderType = [SELECT Id FROM OrderType__c WHERE CustomIdTxt__c = :o.OrderTypeLkp__r.SalesOrderTypeCodeTxt__c];
        
        List<BlockedItem__c> listBlock = [SELECT Id
                                          FROM BlockedItem__c 
                                          WHERE 
                                          (ChannelPvcLkp__c = :o.AccountAreaSalesLkp__r.ChannelLkp__c AND OrderTypeLkp__c = :orderType.Id AND RecordType.DeveloperName = 'PackageSeparationRT')
                                         ];
            
        for(OrderItem__c oItem : [SELECT Id, 
                                  ProductCode__c, 
                                  BottleneckDaysNmb__c, 
                                  RemittanceGroupTxt__c, 
                                  ErrorMessageTxt__c, 
                                  ZMIN__c, 
                                  UnitPriceNmb__c,
                                  OrderQuantityNmb__c,
                                  ProductLkp__r.StandardPackageAmountNmb__c,
                                  ProductLkp__r.ProductCodeTxt__c
                                  FROM OrderItem__c 
                                  WHERE OrderMdt__c = :orderId
                                 AND ErrorMessageTxt__c = null]
           )
        {
            //response += oItem.ErrorMessageTxt__c != null ? 'Erro no Item ' + oItem.ProductCode__c + ': ' + oItem.ErrorMessageTxt__c + '; ' : '';
            response += oItem.ZMIN__c > oItem.UnitPriceNmb__c ? 'Item ' + oItem.ProductCode__c + ' abaixo do preço mínimo (' + oItem.ZMIN__c + '); ' : '';
            if(oItem.ProductLkp__r.ProductCodeTxt__c != '20109' && oItem.ProductLkp__r.ProductCodeTxt__c != '20159'){
                Integer standardPackageAmt = (oItem.ProductLkp__r.StandardPackageAmountNmb__c != null && (Integer)oItem.ProductLkp__r.StandardPackageAmountNmb__c != 0) ?  (Integer)oItem.ProductLkp__r.StandardPackageAmountNmb__c : 1;
            	response += listBlock.size() == 0 && Math.mod((Integer)oItem.OrderQuantityNmb__c, standardPackageAmt) != 0 ? 'Item ' + oItem.ProductCode__c + ' sendo vendido fora da embalagem Padrão/Master. Favor negociar em múltiplos de ' + oItem.ProductLkp__r.StandardPackageAmountNmb__c : '';    
            }
            if(oItem.RemittanceGroupTxt__c == null && oItem.ErrorMessageTxt__c == null && o.AccountAreaSalesLkp__r.CodeSalesOrganizationTxt__c != '0099'){
                return 'Existem itens sem dados de remessa. Favor revisar.';
            }
        }
        return response;
    }
    
    private class ItemRemessa{
        public String Cod;
        public String Description;
        public Decimal Qtde;
        public Decimal UnitPrice;
        public Decimal UnitKg;
        public Decimal PackageAmount;
        public String OrderItemId;
        public String CondPagto;
        public String DataProg;
        public Decimal numRem;
        public ItemRemessa(){
            this.Cod = '';
            this.Description = '';
            this.Qtde = 0;
            this.UnitPrice = 0;
            this.CondPagto = '';
            this.DataProg = '';
            this.UnitKg = 0;
            this.PackageAmount = 0;
            this.OrderItemId = '';
            this.numRem = 0;
        }
    }
    
    private class Remessa implements Comparable{
        public String LocExped;
        public String DescLocExped;
        public String CentroFornecedor;
        public String DescCentroFornecedor;
        public Decimal Qtde;
        public Decimal TotalSIpi;
        public String CondPagto;
        public String DataProg;
        public String Tipo;
        public Decimal TotalKg;
        public Decimal MaxKg;
        public Decimal numRem;
        public List<ItemRemessa> items;
        
        public Remessa(){
            this.LocExped = '';
            this.DescLocExped = '';
            this.CentroFornecedor = '';
            this.DescCentroFornecedor = '';
            this.Qtde = 0;
            this.TotalSIpi = 0;
            this.CondPagto = '';
            this.DataProg = '';
            this.Tipo = '';
            this.TotalKg = 0;
            this.MaxKg = 0;
            this.numRem = 0;
        }
        
        public integer compareTo(object obj){
            Remessa rem = (Remessa)(obj);
            if(this.numRem < rem.numRem){
                return -1;
            }else if(this.numRem == rem.numRem){
                return 0;
            }else{
             	return 1;    
            }                       
        }  
    }
    
    private class Response{
        public Boolean hasError;
        public String errorMsg;
        public String remessas;
        
        public Response(){
            this.hasError = false;
            this.errorMsg = '';
            this.remessas = '';
        }
    }
}