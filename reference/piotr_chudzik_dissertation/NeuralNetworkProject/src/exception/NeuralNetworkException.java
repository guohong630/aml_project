package exception;

public class NeuralNetworkException extends Exception{
    
	private static final long serialVersionUID = 1L;

	public NeuralNetworkException() {}

    public NeuralNetworkException(String message){
       super(message);
    }
}
