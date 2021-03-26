global class Batch_CreditNoteUpdate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	//'SELECT Id, Name FROM Account WHERE Name = \'RODOBENS\' OR Name = \'SODIMAC\' OR Name = \'ROSCHEL\''
            'SELECT Id, Name, (SELECT Id, Name FROM SalesAreas__r) FROM ACCOUNT WHERE RecordTypeId = \'0123D0000000tVsQAI\''
        );   
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        List<Id> cmpGroupIdList = neW List<Id>();
        for(Account acc : scope){
            cmpGroupIdList.add(acc.Id);
        }
        CreditNoteIntegrationUtils.updateGroupAvaiableCredit(cmpGroupIdList);
    }
    global void finish(Database.BatchableContext bc){       

    }	
}