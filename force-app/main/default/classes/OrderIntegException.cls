public with sharing class OrderIntegException extends Exception {
    public OrderIntegException(Exception ex, String mensagemPersonalizada) {
		initCause(ex);
		setMessage(mensagemPersonalizada);
	}
}