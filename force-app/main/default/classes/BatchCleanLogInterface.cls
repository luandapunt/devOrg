global class BatchCleanLogInterface implements Database.Batchable<sObject>{
	global final String Query;

	global BatchCleanLogInterface(Integer logIntDays)
	{
		Query= 'SELECT ID FROM LogInterface__c where CreatedDate < LAST_N_DAYS:' +  String.valueof(logIntDays);       
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		delete scope;
	}

   global void finish(Database.BatchableContext BC)
   {

   }
}