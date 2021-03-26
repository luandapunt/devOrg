public class OrderSummaryController {    
    
    @AuraEnabled
    public static string getSystems(Id orderId){
        
        Order__c o = [SELECT Id, ErrorMessageTxt__c, AccountLkp__c, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.ChannelLkp__c, OrderTypeLkp__c FROM Order__c WHERE Id =: orderId];
        
        
        AggregateResult [] systemTotals = [SELECT		ProductLkp__r.ProductSystemTxt__c systemCode,                                                        				
                                           Count(Id) itemCount,                                                                        
                                           SUM(TotalNetWeightKgNmb__c) weight,
                                           SUM(ValueROBFml__c) grossAmountIPI,
                                           SUM(ValueROBNoIPIFml__c) grossAmountWOIPI,
                                           SUM(ValueROLFml__c) amountWTaxes
                                           // definir AmountWTaxes -> valor sem impostos
                                           FROM		OrderItem__c
                                           WHERE		OrderMdt__c =: orderId
                                           GROUP BY	ProductLkp__r.ProductSystemTxt__c
                                          ];
                
        List <Product2> orderProducts = [SELECT ProductSystemTxt__c, toLabel(ProductSystemTxt__c) systDesc
                                         FROM Product2
                                         WHERE Id IN (SELECT ProductLkp__c 
                                                      FROM OrderItem__c 
                                                      WHERE OrderMdt__c =: orderId
                                                     )
                                        ];
        
        Map<String,String> systMap = new Map<String,String>();
        
        for (Product2 prod : orderProducts){
            systMap.put(prod.ProductSystemTxt__c, (string)prod.get('systDesc'));
        }
        
        system.debug('Sistemas: '+ systMap);
        
        List<prodSystem> systemSummary = new List<prodSystem>();
        
        for (AggregateResult res: systemTotals){            
            prodSystem syst = new prodSystem();            
            syst.systemCode = (String)res.get('systemCode');
            syst.systemDscrp = systMap.get(syst.systemCode);
            syst.itemCount = (Integer)res.get('itemCount');
            syst.weight = (Decimal)res.get('weight');
            syst.grossAmountIPI = (Decimal)res.get('grossAmountIPI');
            syst.grossAmountWOIPI = (Decimal)res.get('grossAmountWOIPI');
            syst.amountWTaxes = (Decimal)res.get('amountWTaxes'); //utilizar definição de AmountWTaxes
            systemSummary.add(syst);
        }
        
        system.debug(JSON.serialize(systemSummary));                       
        
        return JSON.serialize(systemSummary);
        
    }
    
    @AuraEnabled
    public static string getGroups(Id orderId){
        
        Order__c o = [SELECT Id, ErrorMessageTxt__c, AccountLkp__c, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.ChannelLkp__c, OrderTypeLkp__c FROM Order__c WHERE Id =: orderId];                
        
        AggregateResult [] groupTotals = [SELECT	ProductLkp__r.MaterialGroup__c groupCode,                                                                                                        
                                          Count(Id) itemCount,
                                          SUM(TotalNetWeightKgNmb__c) weight,
                                          SUM(ValueROBFml__c) grossAmountIPI,
                                          SUM(ValueROBNoIPIFml__c) grossAmountWOIPI,
                                          SUM(ValueROLFml__c) amountWTaxes                                        				
                                          FROM		OrderItem__c
                                          WHERE	OrderMdt__c =: orderId
                                          GROUP BY	ProductLkp__r.MaterialGroup__c
                                         ];
        system.debug(groupTotals);                       
        
        List <Product2> orderProducts = [SELECT MaterialGroup__c, toLabel(MaterialGroup__c) groupDesc
                                         FROM Product2
                                         WHERE Id IN (SELECT ProductLkp__c 
                                                      FROM OrderItem__c 
                                                      WHERE OrderMdt__c =: orderId
                                                     )
                                        ];
        
        Map<String,String> groupMap = new Map<String,String>();
        
        for (Product2 prod : orderProducts){
            groupMap.put(prod.MaterialGroup__c, (string)prod.get('groupDesc'));
        }
        
        system.debug('Grupos: '+ groupMap);
        
        List<prodGroup> groupSummary = new List<prodGroup>();                
        
        for (AggregateResult res: groupTotals){            
            prodGroup grp = new prodGroup();            
            grp.groupCode = (String)res.get('groupCode');
            grp.groupDscrp = groupMap.get(grp.groupCode);
            grp.itemCount = (Integer)res.get('itemCount');
            grp.weight = (Decimal)res.get('weight');
            grp.grossAmountIPI = (Decimal)res.get('grossAmountIPI');
            grp.grossAmountWOIPI = (Decimal)res.get('grossAmountWOIPI');
            grp.amountWTaxes = (Decimal)res.get('amountWTaxes'); //utilizar definição de AmountWTaxes
            groupSummary.add(grp);
            
        }                             
        
        system.debug(JSON.serialize(groupSummary));                       
        
        return JSON.serialize(groupSummary);        

    }
        
    @AuraEnabled
    public static string getNotTubes(Id orderId){
        
        Order__c o = [SELECT Id, ErrorMessageTxt__c, AccountLkp__c, AccountAreaSalesLkp__c, AccountAreaSalesLkp__r.ChannelLkp__c, OrderTypeLkp__c FROM Order__c WHERE Id =: orderId];                
        
        AggregateResult [] groupTotals = [SELECT	ProductLkp__r.MaterialGroup__c groupCode,                                                                                                        
                                          Count(Id) itemCount,
                                          SUM(TotalNetWeightKgNmb__c) weight,
                                          SUM(ValueROBFml__c) grossAmountIPI,
                                          SUM(ValueROBNoIPIFml__c) grossAmountWOIPI,
                                          SUM(ValueROLFml__c) amountWTaxes                                        				
                                          FROM		OrderItem__c
                                          WHERE	OrderMdt__c =: orderId
                                          AND ProductLkp__r.MaterialGroup__c != '01'
                                          AND ProductLkp__r.MaterialGroup__c != '06'
                                          GROUP BY	ProductLkp__r.MaterialGroup__c
                                         ];

        List <Product2> orderProducts = [SELECT MaterialGroup__c, toLabel(MaterialGroup__c) groupDesc
                                         FROM Product2
                                         WHERE Id IN (SELECT ProductLkp__c 
                                                      FROM OrderItem__c 
                                                      WHERE OrderMdt__c =: orderId
                                                     )
                                        ];
        
        Map<String,String> groupMap = new Map<String,String>();
        
        for (Product2 prod : orderProducts){
            groupMap.put(prod.MaterialGroup__c, (string)prod.get('groupDesc'));
        }
        
        system.debug('Grupos: '+ groupMap);

        prodNotTubes notTubes = new prodNotTubes();

        for (AggregateResult res: groupTotals){            
            prodGroup grp = new prodGroup();            
            grp.groupCode = (String)res.get('groupCode');
            grp.groupDscrp = groupMap.get(grp.groupCode);
            grp.itemCount = (Integer)res.get('itemCount');
            grp.weight = (Decimal)res.get('weight');
            grp.grossAmountIPI = (Decimal)res.get('grossAmountIPI');
            grp.grossAmountWOIPI = (Decimal)res.get('grossAmountWOIPI');
            grp.amountWTaxes = (Decimal)res.get('amountWTaxes'); //utilizar definição de AmountWTaxes            

            if(grp.groupCode != '01' && grp.groupCode != '06'){
                notTubes.notTubesItemCount 	+= (grp.itemCount != null ? grp.itemCount : 0);
                notTubes.notTubesWeight 	+= (grp.weight != null ? grp.weight : 0);
                notTubes.notTubesROB 		+= (grp.grossAmountIPI != null ? grp.grossAmountIPI : 0);
                notTubes.notTubesROBwoIPI 	+= (grp.grossAmountWOIPI != null ? grp.grossAmountWOIPI : 0);                
                notTubes.notTubesROL 		+= (grp.amountWTaxes != null ? grp.amountWTaxes : 0);                 
            }            
        }

        system.debug(JSON.serialize(notTubes));
        
		return JSON.serialize(notTubes);		        
        
    }
    
    
    private class prodSystem{
        public string systemCode;
        public string systemDscrp;
        public integer itemCount;
        public decimal weight;
        public decimal grossAmountIPI;
        public decimal grossAmountWOIPI;
        public decimal amountWTaxes;            
    }
    
    
    private class prodGroup{
        public string groupCode;
        public string groupDscrp;
        public integer itemCount;
        public decimal weight;
        public decimal grossAmountIPI;
        public decimal grossAmountWOIPI;
        public decimal amountWTaxes;		       
    }
    
    private class prodNotTubes{
        public integer notTubesItemCount 	= 0;
        public decimal notTubesWeight 		= 0;
        public decimal notTubesROBwoIPI 	= 0;
        public decimal notTubesROB 			= 0;
        public decimal notTubesROL 			= 0; 
    }
    
}