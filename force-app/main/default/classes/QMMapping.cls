public with sharing class QMMapping {
	
	public class QMMappingException extends Exception {}

	private Map<Id, RecordType> recordTypeMap;

	private List<IQMConfigurator> configList = new List<IQMConfigurator>{
			new QMCfgDevolucaoParcial(),
			new QMCfgDevolucaoTotal(),
			new QMCfgExtravioNotaFiscal(),
			new QMCfgInformacoesGerais(),
			//new QMCfgProdutoTrocadoI(), (Registro excluido)
			new QMCfgProdutoTrocadoII(),
			new QMCFGProrrogacao(),
			new QMCfgQMReposicaoItemI(),
			new QMCfgReclamacao(),
			//new QMCfgRefaturamento(), (Registro excluido)
			new QMCfgReposicaoItemII(),
			new QMCfgReposicaoVolume(),
			new QMCfgSinistro(),
			new QMCfgSustacao(),
			new QMCfgDevolucaoTotalCliente(),
			new QMCfgSinistroParcial(),
			new QMCfgTranstornoNaEntrega()
	};
	
	public QMMapping() {
		this.recordTypeMap = new Map<Id, RecordType>(RecordTypeDAO.getBySObjectName('QM__c'));
	}

	/*
		Returns QM configurator by record type id
	*/
	public IQMConfigurator findByRecordTypeId(Id recTypeId){
		return findByRecordTypeDevName(this.recordTypeMap.get(recTypeId).DeveloperName);
	}
	
	/*
		Returns QM configurator by record type dev name
	*/
	public IQMConfigurator findByRecordTypeDevName(String devName){
		
		IQMConfigurator implCfg = null;
		for (IQMConfigurator cfg : configList) {
			if (cfg.getRecordTypeDevName() == devName) {
				implCfg = cfg;
			} else if (cfg.getRecordTypeDevName() == null) {
				throw new QMMappingException(cfg + ' has no getRecordTypeDevName() method implemented.');
			}
		}
		return implCfg;
	}
	
}