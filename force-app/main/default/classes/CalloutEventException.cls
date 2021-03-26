public class CalloutEventException extends Exception {

	public String response {get;set;}

	public CalloutEventException( Dom.Document response, String message){
		this(message);
		this.response = response.toXmlString(); 
	}

	public CalloutEventException( String response, String message){
		this(message);
		this.response = response; 
	}

	public CalloutEventException( Dom.Document response, Exception cause){
		this(cause);
		this.response = response.toXmlString(); 
	}

}