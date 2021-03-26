public interface IQMConfigurator {

	String getRecordTypeDevName();
	QM__c configure(QM__c qm, Case cse);
	
}