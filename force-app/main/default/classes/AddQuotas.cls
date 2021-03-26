public class AddQuotas {    
    /*
    public Quota__c quota;
    public Quota__c refQuota;
    public Quota__c del;    
    public Quota__c newQuota;
    public List<User> usersList = new List<User>();    
    public List<Quota__c> quotaList {get;set;}
    public List<Quota__c> addQuotaList {get;set;}       
    public Integer rowIndex {get;set;}
    public double value = 0;
    public double sumValue {get;set;}
    public double remainingAmount;
    
    public AddQuotas(ApexPages.StandardController controller) {                
        
        refQuota = (Quota__c) controller.getRecord();
        this.quota = [Select Id, Owner.UserRoleId, TotalValueNmb__c, CurrentMonthTxt__c, CurrentYearTxt__c From Quota__c Where id =: refQuota.id];                                                     
        
        quotaList = new List<Quota__c>();
        
        quotaList = [SELECT Id, TotalValueNmb__c, CurrentMonthTxt__c, CurrentYearTxt__c, OwnerId
                     FROM Quota__c 
        
                    ];
        
        usersList = [SELECT Id, Name, UserRoleId, Profile.Name
                     FROM User
                     WHERE IsActive = true
                     AND UserRoleId IN (SELECT Id
                                         FROM UserRole
                                         Where ParentRoleId =: quota.Owner.UserRoleId
                                        )
                     AND Id NOT IN (SELECT OwnerId
                                    FROM Quota__c

                                    )
                    ];                                        
        
        set<User> usersSet = new set<User>();
        usersSet.addAll(usersList);
        system.debug('usuários:' +usersSet);
        
        
        
                       
        if(usersSet.size() > 0){
            for(user childUser : usersSet){
                Quota__c childQuota = new Quota__c();
                childQuota.OwnerId = childUser.Id;            
                childQuota.CurrentMonthTxt__c = quota.CurrentMonthTxt__c;
                childQuota.CurrentYearTxt__c = quota.CurrentYearTxt__c; 
                
                if(childUser.Profile.Name == 'Vendedor' || childUser.Profile.Name == 'Representante' ||childUser.Profile.Name == 'Partner Community User' || childUser.Profile.Name == 'Representante Partner'){
                    childQuota.RecordTypeId = Schema.SObjectType.Quota__c.getRecordTypeInfosByName().get('Cota de Vendas').getRecordTypeId();
                } else {
                    childQuota.RecordTypeId = Schema.SObjectType.Quota__c.getRecordTypeInfosByName().get('Cota de Coordenador').getRecordTypeId();
                }
                quotaList.add(childQuota);
            }                
            
            
            else { 
                childQuota.CurrentMonthTxt__c = quota.CurrentMonthTxt__c;
                childQuota.CurrentYearTxt__c = quota.CurrentYearTxt__c;                                   
                quotaList.add(childQuota);
            }
            
        }

    }
    
    public void addRow() {        
        
        addQuotaList = new List<Quota__c> ();
        newQuota = new Quota__c();        
        newQuota.CurrentMonthTxt__c = quota.CurrentMonthTxt__c;
        newQuota.CurrentYearTxt__c = quota.CurrentYearTxt__c;
       
        quotaList.add(newQuota);
        
    }
    
    public void deleteRow() {
        
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        del = quotaList.remove(rowIndex);        
        
    }
    
    public void save() {           
        
        try{    
            for (Quota__c quotaValue: quotaList){            
                if(quotaValue.TotalValueNmb__c != null){
                    value = value + quotaValue.TotalValueNmb__c;
                } else {
                    quotaValue.TotalValueNmb__c = 0;
                }
            }
            
            if(value == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Insira um valor para as cotas distribuídas.'));    
            }
            
            if(value > quota.TotalValueNmb__c){
                upsert quotaList;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'O valor total das cotas distribuídas é maior do que a sua cota.'));                    
                value = 0;                       
            }
            
            if(value < quota.TotalValueNmb__c && value != 0)    {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sua cota não foi totalmente distribuída. Não foram criadas novas cotas.'));
                value = 0;            
            }                                
            
            if (value == quota.TotalValueNmb__c){
                for (integer i = 0; i < quotaList.size(); i++){            
                    if(quotaList.get(i).TotalValueNmb__c == 0){                  
                        quotaList.remove(i);
                        i=i-1;
                    }        
                } 
                upsert quotaList;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Sua cota foi distribuída com sucesso!'));
                value = 0;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);             
            }
        
    }
    
    public Double getRemainingAmount(){
        
        sumValue = 0;
        analisa os valores dos planejamentos que estão sendo criados.            
        for (Quota__c quotaValue: quotaList){            
            if(quotaValue.TotalValueNmb__c != null){
                sumValue = sumValue + quotaValue.TotalValueNmb__c;
            } else {
                quotaValue.TotalValueNmb__c = 0;
                sumValue = sumValue + quotaValue.TotalValueNmb__c;
            }
        }
        system.debug('run');
        remainingAmount = quota.TotalValueNmb__c - sumValue;        
        
        return remainingAmount;
    }    
    
    public PageReference returnToQuota(){
        
        PageReference pageRef = new PageReference('/apex/AddQuotasPage');
        pageRef.getParameters().put('id',quota.Id);               
        PageReference pageRef2 = new PageReference('/' + quota.Id);                               
        value = 0;
        //return pageRef;
                    
        return pageRef2;
    }
	*/
}