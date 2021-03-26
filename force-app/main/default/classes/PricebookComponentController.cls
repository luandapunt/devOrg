public  without sharing class PricebookComponentController {
    
    @AuraEnabled
    public static Product2 getProduct(Id productId){
        Product2 p = [SELECT Id, Name, ProductCodeTxt__c, InstructionsTxt__c, ImageFml__c, ImageTxt__c, ImageExtensionTxt__c FROM Product2 WHERE Id = :productId];
        return p;
    }
    
    @AuraEnabled
    public static List<CatalogElement__c> getElementList(Id pricebookId, Id orderId, Id elementId){
        Id pbId;        
        if(pricebookId != null)
            pbId = pricebookId;
        if(orderId != null){
            Order__c o = [SELECT PricebookLkp__c FROM Order__c WHERE Id = :orderId];
            pbId = o.PricebookLkp__c;
        }
        if(pbId == null && elementId == null)
            return new List<CatalogElement__c>();
        if(elementId == null ){
            return [SELECT Id, Name
                    FROM CatalogElement__c 
                    WHERE PricebookLkp__c = :pbId
                    ORDER BY IndexNmb__c ASC NULLS LAST, Name
                   ];
        }
        else{
            return [SELECT Id, Name
                    FROM CatalogElement__c 
                    WHERE ParentElementLkp__c = :elementId
                    ORDER BY IndexNmb__c ASC NULLS LAST, Name
                   ];
        }
    }
    
    @AuraEnabled
    public static List<Product2> getProducts(Id pricebookId, Id elementId, String searchString, Id orderId){
        Id pbId;        
        if(pricebookId != null)
            pbId = pricebookId;
        if(orderId != null){
            Order__c o = [SELECT PricebookLkp__c FROM Order__c WHERE Id = :orderId];
            pbId = o.PricebookLkp__c;
        }
        if(pbId == null && elementId == null)
            return new List<Product2>();
        system.debug('pbId: ' + pbId);
        system.debug('elementId: ' + elementId);
        system.debug('searchString: ' + searchString);
        String query = 'SELECT Id, Name, ProductCodeTxt__c, StandardPackageAmountNmb__c ';
        query += 'FROM Product2 ';
        query += 'WHERE ID IN ';
        if (elementId == null){
            query += '(SELECT ProductLkp__c FROM ElementProduct__c WHERE CatalogElementLkp__r.PricebookLkp__c = \''+ pbId +'\') ';
        }
        else {
            query += '(SELECT ProductLkp__c FROM ElementProduct__c WHERE CatalogElementLkp__c = \''+ elementId +'\') ';
        }
        if(searchString != null){
            query += 'AND (Name LIKE \'%' + searchString + '%\' OR ProductCodeTxt__c LIKE \'%' + searchString + '%\') ';
        }
        query += 'ORDER BY Name';
        system.debug(query);
        return Database.query(query);
    }
    
    @AuraEnabled
    public static String findProductsPricebook(Id pricebookId){
        Pricebook__c pb = [SELECT Id, IsActiveBln__c FROM Pricebook__c WHERE Id = :pricebookId];
        if(pb.IsActiveBln__c == true){
            return 'Catálogo já ativado';
        }
        Map<Id, CatalogElement__c> mapElem = new Map<Id, CatalogElement__c>([SELECT Id, PricebookLkp__c, (SELECT Id, ProductLkp__c FROM ElementProducts__r), (SELECT Id FROM ChildElements__r)
                                  FROM CatalogElement__c WHERE PricebookLkp__c = :pricebookId OR ParentElementLkp__c != null]);
        for(CatalogElement__c elem : mapElem.Values()){
            if(elem.PricebookLkp__c == pricebookId){
                findProducts(elem.Id, mapElem);
            }
        }
        pb.IsActiveBln__c = true;
        try{
            update pb;
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    public static List<ElementProduct__c> findProducts(Id elementId, Map<Id, CatalogElement__c> mapElem){
        CatalogElement__c elem = mapElem.get(elementId);
        List<ElementProduct__c> listElem = new List<ElementProduct__c>();
        List<ElementProduct__c> listElemCreate = new List<ElementProduct__c>();
        
        if(elem.ElementProducts__r.size() != 0){
            listElem.addAll(elem.ElementProducts__r);
            return listElem;
        }
        else{
            for(CatalogElement__c child : elem.ChildElements__r){
                listElem.addAll(findProducts(child.Id, mapElem));
            }
            for(ElementProduct__c newElem : listElem){
                listElemCreate.add(new ElementProduct__c(CatalogElementLkp__c = elementId, ProductLkp__c = newElem.ProductLkp__c));
            }
            insert listElemCreate;
            return listElemCreate;
        }
        
    }
    
    @AuraEnabled
    public static String addProduct(Id idProduct, Id idOrder, Decimal amount, Boolean usePackage){
        Order__c o = [SELECT Id, ErrorMessageTxt__c, AccountLkp__c, CustomIdTxt__c,
                      AccountAreaSalesLkp__r.ChannelLkp__c, OrderTypeLkp__c, OrderTypeLkp__r.OrderIrrigationBln__c,
                      (SELECT Id, OrderQuantityNmb__c FROM Itens_da_Ordem__r WHERE ProductLkp__c = :idProduct)
                      FROM Order__c WHERE Id = :idOrder];
        
        List<BlockedItem__c> listBlock = [SELECT Id, 
                                          MasterPackageAmountNmb__c, 
                                          RecordType.DeveloperName 
                                          FROM BlockedItem__c 
                                          WHERE 
                                          (ProductLkp__c = :idProduct AND AccountLkp__c = :o.AccountLkp__c AND RecordType.DeveloperName = 'MasterPackageRT') OR
                                          (ChannelPvcLkp__c = :o.AccountAreaSalesLkp__r.ChannelLkp__c AND OrderTypeLkp__c = :o.OrderTypeLkp__c AND RecordType.DeveloperName = 'PackageSeparationRT')
                                         ];
                
        Product2 prod = [SELECT Id, StandardPackageAmountNmb__c, UMTxt__c, IrrigationItemBln__c, ProductCodeTxt__c FROM Product2 WHERE Id = :idProduct];
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
        
        if(prod.ProductCodeTxt__c == '20109' || prod.ProductCodeTxt__c == '20159')
            packageAmt = 1;
        
        try{
            amount = Integer.valueOf(amount) * ((usePackage && prod.StandardPackageAmountNmb__c !=  0) ? (Integer)prod.StandardPackageAmountNmb__c : 1);
            
        	Integer division = amount.intValue() / packageAmt; 
            
            
            if(o.OrderTypeLkp__r.OrderIrrigationBln__c && !prod.IrrigationItemBln__c){
                return 'Item não está disponível para ordens de Irrigação.';
            }
            if(division * packageAmt != amount){
                return 'Item sendo vendido fora da Embalagem Padrão/Master. Favor negociar em múltiplos de ' + packageAmt;
            }
        }
        catch(Exception e){
            System.debug('EXCEPTION');
            return 'Ocorreu um erro ao adicionar o item. Digite uma quantidade válida.';              
        }
        
        OrderItem__c oItem = new OrderItem__c ();
        if(o.Itens_da_Ordem__r.size() == 0){
            oItem.OrderQuantityNmb__c = amount;
            oItem.ProductLkp__c = idProduct;
            oItem.OrderMdt__c = idOrder;
            oItem.LiquidNmb__c = Integer.valueOf(amount);
        }
        else{
            //oItem = o.Itens_da_Ordem__r[0];
            //oItem.OrderQuantityNmb__c += Integer.valueOf(amount);
            return 'Produto já inserido no pedido';
        }
        
        if(o.ErrorMessageTxt__c != null && o.CustomIDTxt__c == null){
            return o.ErrorMessageTxt__c;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            upsert oItem;
            if(!Test.isRunningTest()){
                OrderIntegrationUtils.createItemOnSAPFuture(idOrder, oItem.Id);
            }
            o.ShippingSplitDoneBln__c = false;
            update o;
            
            List<ComplementaryProduct__c> listComp = [SELECT ID, ProductLkp__c, ComplementaryLkp__c, ComplementaryLkp__r.ProductCodeTxt__c, ComplementaryLkp__r.Name 
                                                      FROM ComplementaryProduct__c
                                                      WHERE ProductLkp__c = :idProduct];
            
            String compProduct = ':';
            if(listComp.size() > 0){
               compProduct = ':O produto '+listComp[0].ComplementaryLkp__r.ProductCodeTxt__c+' é complementar do item inserido'; 
            }
            
            return 'SUCCESS'+compProduct;
        }
        catch(Exception e){
            Database.rollback( sp );
            return e.getMessage() + ': ' + e.getStackTraceString();
        }
        
    }
    
    
    @AuraEnabled
    public static List<Product2> suggestedProduct(Id orderId){
        Order__c ord =[SELECT 
                       AccountLkp__r.ChannelLkp__c,
                       AccountAreaSalesLkp__r.ChannelLkp__c,
                       AccountAreaSalesLkp__r.SalesOfficeTxt__c,
                       SuggestedDoneBln__c
                       FROM Order__c
                       Where Id =: orderId];
        
        if(!ord.SuggestedDoneBln__c){
            ord.SuggestedDoneBln__c = true;
            update ord;
        }
        
        return [SELECT ID, 
                Name,
                StandardPackageAmountNmb__c,
                ProductCodeTxt__c
                FROM Product2 
                WHERE Id IN 
                (SELECT ProductLkp__c 
                 FROM SuggestedProduct__c 
                 WHERE ChannelLkp__c = :ord.AccountAreaSalesLkp__r.ChannelLkp__c
                AND SalesOfficeTxt__c = :ord.AccountAreaSalesLkp__r.SalesOfficeTxt__c) 
                AND ID NOT IN 
                (SELECT ProductLkp__c 
                 FROM OrderItem__c 
                 WHERE OrderMdt__c = :orderId)
               ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<Product2> productTypeList(ID orderId, String listType){
        List<Product2> emptyList = new List<Product2>();
        system.debug('listType: ' + listType);
        if(listType=='CPE'){
            return [SELECT ID, 
                    Name,
                    StandardPackageAmountNmb__c,
                    ProductCodeTxt__c
                    FROM Product2
                    WHERE SpecialProductBln__c = True
                    ORDER BY Name];
        }
    
        else if(listType=='MIXIrriga'){
            return [SELECT ID, 
                    Name,
                    StandardPackageAmountNmb__c,
                    ProductCodeTxt__c
                    FROM Product2
                    WHERE IrrigationBln__c = True
                    ORDER BY Name];
        }
    
        else if(listType=='Irrigation'){
            return [SELECT ID, 
                    Name,
                    StandardPackageAmountNmb__c,
                    ProductCodeTxt__c
                    FROM Product2
                    WHERE IrrigationItemBln__c = True
                    ORDER BY Name];
        }

        else if(listType=='Release'){
            return [SELECT ID, 
                    Name,
                    StandardPackageAmountNmb__c,
                    ProductCodeTxt__c
                    FROM Product2
                    WHERE ReleaseBln__c = True
                    ORDER BY Name];
        }	
        else if(listType=='Complementary'){
            return complementaryProduct(orderId);
        }
        else if(listType=='MasterPackage'){
            Order__c OrderAccount = [SELECT ID,
                                     AccountLkp__c
                                     FROM Order__c
                                     WHERE ID =: orderId Limit 1];
            return [SELECT ID, 
                    Name,
                    StandardPackageAmountNmb__c,
                    ProductCodeTxt__c
                    FROM Product2
                    WHERE ID IN (SELECT ProductLkp__C FROM BlockedItem__c WHERE AccountLkp__c = :OrderAccount.AccountLkp__c AND RecordType.DeveloperName = 'MasterPackageRT')
                    ORDER BY Name];
        }
        else{
            return emptyList;
        }
    }
    
    @AuraEnabled
    public static List<Product2> complementaryProduct(ID orderId){
        List<OrderItem__c> ordItems = [SELECT ID, ProductLkp__c
                                       FROM OrderItem__c
                                       WHERE OrderMdt__c =: orderId];
        List<ID> listExistingProds = new List<ID>();
        for(OrderItem__c oItem : ordItems){
            listExistingProds.add(oItem.ProductLkp__c);
        }
        
        List<ID> listComplementary = new List<ID>();
        for(ComplementaryProduct__c cmp : [
            SELECT ID, ProductLkp__c, ComplementaryLkp__c 
            FROM ComplementaryProduct__c
            WHERE ProductLkp__c IN :listExistingProds
            //OR ComplementaryLkp__c IN :listExistingProds
        ]){
            //listComplementary.add(cmp.ProductLkp__c);
            listComplementary.add(cmp.ComplementaryLkp__c);
        }
        
        return [SELECT ID, 
                Name,
                StandardPackageAmountNmb__c,
                ProductCodeTxt__c
                FROM Product2
                WHERE ID IN :listComplementary
                AND ID NOT IN :listExistingProds
               ORDER BY Name];
    }
    
}