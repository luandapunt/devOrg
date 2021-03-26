public with sharing class THQM extends TriggerHandler {

	public override void beforeInsert() {
  		//load and relate aditional data
  		new QM(trigger.new)
  			.enrich();
	}
	
  	public override void afterInsert() {
  		//send to sap
  		//QMService.sendToSAP(trigger.newMap.keySet());
  		
  		QM.setExternalIdQM(trigger.newMap.keySet());
  		
  		QM.setStatusInCase(trigger.new);
  	}
  	
  	public override void beforeUpdate() {
  		QM.checkSentStatus(trigger.new);
  	}
    
}