package activation;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 */
public class SigmoidFunction implements ActivationFunction{

	public static final String NAME = "Sigmoid";
	
	private static SigmoidFunction instance = new SigmoidFunction();
	
	public static SigmoidFunction getInstance(){
		return instance;
	}
	
	@Override
	public double activateFunction(double value) {
		 return (1.0/(1+Math.exp(-1.0 * value)));
	}

	@Override
	public double activateFunctionDerivative(double value) {
		 return value * (1-value);
	}
	
	@Override
	public String getName(){
		return NAME;
	}
}
