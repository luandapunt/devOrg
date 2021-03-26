public class CustomFileUploadController {
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<OrderItem__c> itensToUpload;
    public Order__c ord{get; set;}
    public String contentType{get; set;}
        

        
        

    public class ItemUpload{
        public String productCode;
        //public Double productQty;
        public Boolean productError;
        //public Double productPrice;
        public String productQty;
        public String productPrice;
        
        public ItemUpload(){
            this.productCode = '';
            this.productQty = '0';
            this.productError = false;
            this.productPrice = null;
        }
    }

    private List<String> checkItemUpload(List<ItemUpload> itemUploadList, Id orderId){
        Order__c ord = [SELECT Id, Name, 
                        OrderTypeLkp__r.OrderIrrigationBln__c, 
                        AccountLkp__c,
                        AccountAreaSalesLkp__r.ChannelLkp__c,
                        OrderTypeLkp__c
                        FROM Order__c WHERE Id = :orderId];

        List<ItemUpload> auxList = itemUploadList.clone();
        Boolean skipPackage = false;
        Map<String, Product2> productMap = new Map<String, Product2>();
        Map<String, Decimal> masterPackageMap = new Map<String, Decimal>();
        List<String> errorList = new List<String>();
        List<String> productCodeList = new List<String>();
        for(ItemUpload item : itemUploadList){
            productCodeList.add(item.ProductCode);
        }
        
        List<Product2> productList = [SELECT Id, Name, ProductCodeTxt__c, StandardPackageAmountNmb__c, IrrigationItemBln__c FROM Product2 WHERE ProductCodeTxt__c IN :productCodeList];
        
        
        for(Product2 p : productList){
            productMap.put(p.ProductCodeTxt__c, p);    
        }    
        
        List<BlockedItem__c> listBlock = [SELECT Id, 
                                          MasterPackageAmountNmb__c, 
                                          RecordType.DeveloperName,
                                          ProductLkp__r.ProductCodeTxt__c
                                          FROM BlockedItem__c 
                                          WHERE 
                                          (ProductLkp__r.ProductCodeTxt__c IN :productMap.keySet() AND AccountLkp__c = :ord.AccountLkp__c AND RecordType.DeveloperName = 'MasterPackageRT') OR
                                          (ChannelPvcLkp__c = :ord.AccountAreaSalesLkp__r.ChannelLkp__c AND OrderTypeLkp__c = :ord.OrderTypeLkp__c AND RecordType.DeveloperName = 'PackageSeparationRT')
                                         ];
        for(BlockedItem__c param : listBlock){
            if(param.RecordType.DeveloperName == 'PackageSeparationRT') 
                skipPackage = true;
            else{
                masterPackageMap.put(param.ProductLkp__r.ProductCodeTxt__c, param.MasterPackageAmountNmb__c);
            }
        }

        
        for(ItemUpload item : itemUploadList){
            item.productError = false;
            
            if(!productMap.containsKey(item.productCode)){
                errorList.add(item.productCode + ': Item não encontrado');
                item.productError = true;
            }else{
                Product2 prod = productMap.get(item.productCode);
                //Integer packageAmt = (prod.StandardPackageAmountNmb__c != null && prod.StandardPackageAmountNmb__c != 0) ? Integer.valueOf(prod.StandardPackageAmountNmb__c) : 1;
                Integer packageAmt = 1;
                if(!skipPackage){
                    if(masterPackageMap.containsKey(item.productCode))
                        packageAmt = Integer.valueOf(masterPackageMap.get(item.productCode));
                    else packageAmt = (prod.StandardPackageAmountNmb__c != null && prod.StandardPackageAmountNmb__c != 0) ? Integer.valueOf(prod.StandardPackageAmountNmb__c) : 1;
                }
                
                if(item.productQty.trim().isNumeric()){
                    System.debug(item.productQty.trim());
                    for(Integer J = 0; J < item.productQty.trim().length(); J++){
                        String aux = item.productQty.trim();
                        System.debug(J+' = '+aux.charAt(J));
                    }
                    Integer division = Integer.valueOf(item.productQty.trim()) / packageAmt;
                    if(division * packageAmt != Integer.valueOf(item.productQty.trim())){
                        errorList.add(item.productCode + ': Item fora da embalagem padrão/master. Favor negociar em múltiplo de '+packageAmt);      
                        item.productError = true;
                    }         
                }else{
                    errorList.add(item.productCode + ': '+item.productQty+' não é um valor válido para Quantidade');
                    item.productError = true;                    
                }                

                if((ord.OrderTypeLkp__r.OrderIrrigationBln__c) && (!prod.IrrigationItemBln__c)){
                    errorList.add(item.productCode + ': Item não disponível para irrigação');
                    item.productError = true;
                }
                
                if(item.productPrice != null){
                    try{
                        Double productPrice = Double.valueOf(item.productPrice);
                        /*if(productPrice == 0){
                            errorList.add(item.productCode + ': '+item.productPrice+' não é um valor válido para o preço');
                            item.productError = true;
                        }*/
                    }catch(TypeException e){
                        errorList.add(item.productCode + ': '+item.productPrice+' não é um valor válido para o preço');
                        item.productError = true;
                    }
                }
            }
        }
        
        return errorList;
    }
        
    public CustomFileUploadController(ApexPages.StandardController stdController) {
        this.ord = (Order__c)stdController.getRecord();
        this.ord = [SELECT Id, OrderTypeLkp__r.Category__c FROM Order__C WHERE Id = :ord.id];
    }
    
    public Pagereference AdjustDiscounts(){
        List<OrderItem__c> itemList = [SELECT Id, Name, ProductCode__c, CSVPriceNmb__c, ZCOT__c, YCOT__c, ZPRO__c, YPRO__c,
                                       ValueROBNoIPIFml__c, ValueROBFml__c, OrderQuantityNmb__c, OriginalQuantityNmb__c, SyncedSAPBln__c 
                                       FROM OrderItem__c 
                                       WHERE OrderMdt__c = :ord.Id];
        
        //Boolean zcotAcima = false;
        Boolean zproAcima = false;
        for(OrderItem__c item : itemList){
            if((item.CSVPriceNmb__c != null) && (item.ValueROBNoIPIFml__c > 0) && (item.OrderQuantityNmb__c > 0)){
                //Double newZCOT = (1 - (item.CSVPriceNmb__c/(item.ValueROBNoIPIFml__c / item.OrderQuantityNmb__c)))*100;
                Double newZPRO = (1 - (item.CSVPriceNmb__c/(item.ValueROBNoIPIFml__c / item.OrderQuantityNmb__c)))*100;
                
                System.debug('Comparar: '+ item.CSVPriceNmb__c + ' e ' + (item.ValueROBNoIPIFml__c / item.OrderQuantityNmb__c));  
                //System.debug('Desconto Calculado: '+newZCOT+'; Desconto Máximo: '+item.YCOT__c);
                System.debug('Desconto Calculado: '+newZPRO+'; Desconto Máximo: '+item.YPRO__c);
                
                if(newZPRO > item.YPRO__c){
                    item.ZPRO__c = item.YPRO__c;
                    zproAcima = true;
                }else{
                    item.ZPRO__c = newZPRO;
                }
                
                /*if(newZCOT > item.YCOT__c){
                    item.ZCOT__c = item.YCOT__c;
                	zcotAcima = true;
                }else{
                    item.ZCOT__c = newZCOT;
                }*/
            }
        }
        
        if(zproAcima){
           	//String str = 'Para um ou mais itens, o desconto de cotação máximo não é suficiente para atingir os valores carregados no CSV. Para esses casos foi utilizado o desconto de cotação máximo.';
            String str = 'Para um ou mais itens, o desconto promocional máximo não é suficiente para atingir os valores carregados no CSV. Para esses casos foi utilizado o desconto promocional máximo.';
            ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.severity.WARNING, str);
            ApexPages.addMessage(warningMessage);              
        }else{
            //ApexPages.Message sucessMsg = new ApexPages.Message(ApexPages.severity.INFO,'Os valores de desconto de cotação foram ajustados para que os valores de preço do CSV forem atingidos.');
            ApexPages.Message sucessMsg = new ApexPages.Message(ApexPages.severity.INFO,'Os valores de desconto promocional foram ajustados para que os valores de preço do CSV fossem atingidos.');
            ApexPages.addMessage(sucessMsg);                       
        }
        update itemList;
        
        return null;
    }
    
    public Pagereference ReadFile(){

     	System.debug(contentType);
        
        if(contentType == 'application/vnd.ms-excel'){
            nameFile = contentFile.toString();
            if(nameFile.indexOf(';') != -1){
                try{
                    filelines = nameFile.split('\n');
                    itensToUpload = new List<OrderItem__c>();
                    
                    List<ItemUpload> itemUploadList = new List<ItemUpload>();
                    
                    if(filelines.size() > 0){
                        String[] inputHeader = new String[]{};
                        inputHeader = filelines[0].split(';');
                        
                        
                        if((inputHeader.size() == 2)){
                            system.debug('Tipo de ordem');
                            system.debug(ord.OrderTypeLkp__r.Category__c);
                            for (Integer i=1;i<filelines.size();i++)
                            {
                                String[] inputvalues = new String[]{};
                                inputvalues = filelines[i].split(';');
                                System.debug(inputvalues);
                                
                                ItemUpload item = new ItemUpload();
                                item.productCode = inputvalues[0];
                                item.productQty = inputvalues[1];
                                
                                itemUploadList.add(item);
                            }
                        }else if(inputHeader.size() == 3){
                            System.debug('TRÊS COLUNAS');
                            for (Integer i=1;i<filelines.size();i++)
                            {
                                String[] inputvalues = new String[]{};
                                inputvalues = filelines[i].split(';');
                                System.debug(inputvalues);
                                
                                for(Integer J = 0 ; J < inputvalues.size(); J++){
                                    System.debug('['+I+', '+J+'] = '+inputvalues[J]);
                                }
                                
                                ItemUpload item = new ItemUpload();
                                item.productCode = inputvalues[0];
                                item.productQty = inputvalues[1];
                                
                                System.debug(inputValues[2].length());
                                if((inputvalues[2] != '') && (inputvalues[2] != '\n') && (inputvalues[2] != '\r')){
                                    String priceStr = inputvalues[2];
                                    priceStr = priceStr.replace(',', '.');
                                    item.productPrice = priceStr;
                                }
                                itemUploadList.add(item);
                            }                           
                        }
                    }
                    
                    System.debug('UploadList antes:');
                    System.debug(itemUploadList);
                    List<String> errorList = checkItemUpload(itemUploadList, ord.Id);
                    System.debug('UploadList depois:');
                    System.debug(itemUploadList);
                    
                    System.debug(errorList);
                    
                    for(ItemUpload item : itemUploadList){
                        if( !item.productError ){
                            OrderItem__c ordItem = new OrderItem__c();
                            ordItem.ProductLkp__r = new Product2(ProductCodeTxt__C = item.productCode);
                            ordItem.OrderQuantityNmb__c = Integer.valueOf(item.productQty.trim());
                            if(item.productPrice != null){
                                Double productPrice = Double.valueOf(item.productPrice);
                                if(productPrice != 0){
                                    ordItem.CSVPriceNmb__c = Double.valueOf(item.productPrice);
                                }
                            }
                            ordItem.OrderMdt__c = ord.Id;
                            
                            itensToUpload.add(ordItem);
                        }
                    }
                    System.debug('Serão inseridos:');
                    System.debug(itensToUpload);
                    Database.SaveResult[] srList = Database.insert(itensToUpload, false);
                    
                    Integer sucessCount = 0;
                    for(Database.SaveResult sr : srList){
                        if(sr.isSuccess()){
                            sucessCount++;
                        }else{               
                            for(Database.Error err : sr.getErrors()){
                                String errorMsg = err.getStatusCode()+': '+err.getMessage()+' - '+err.getFields();
                                errorList.add(errorMsg);
                            }                            
                        }
                    }
                    if(itemUploadList.size() == sucessCount){
                    	ApexPages.Message sucessMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Foram carregados '+sucessCount+' itens no pedido');
                        ApexPages.addMessage(sucessMsg);                        
                    }else{
                    	ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.severity.WARNING,'Dos '+itemUploadList.size()+' itens lidos a partir do CSV, foram carregados '+sucessCount+' no pedido');
                        ApexPages.addMessage(warningMessage);
                    }
                    
                    ord.ItemErrorMessageTxt__c = '';
                    for(Integer I = 0; I < errorList.size(); I++){
                        ord.ItemErrorMessageTxt__c = ord.ItemErrorMessageTxt__c + errorList[I]+'\n';
                    }
                    upsert ord;
                }
                catch (Exception e){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Erro na inclusão dos pedidos: '+e.getMessage());
                    ApexPages.addMessage(errormsg);
                }                      
            }else{
				ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Utilize um CSV separado com ponto e vírgula');
            	ApexPages.addMessage(errormsg);                      
            }
        }else{
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Formato de arquivo inválido. Utilize .CSV');
            ApexPages.addMessage(errormsg);            
        }
        return null;
    }
    
    public List<OrderItem__c> getuploadedAccounts()
    {
        if (itensToUpload != NULL)
            if (itensToUpload.size() > 0)
                return itensToUpload;
            else
                return null;                    
        else
            return null;
    }            

}