package activation;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 * This class models Hiperbolic Activation Function. Compared to Sigmoid Activation Function, Hyperbolic 
 * Activation Function can return negative values.
 */
public class HyperbolicFunction implements ActivationFunction{

	public static final String NAME = "Hyperbolic";
	
	private static HyperbolicFunction instance = new HyperbolicFunction();
	
	
	public static HyperbolicFunction getInstance(){
		return instance;
	}
	
	@Override
	public double activateFunction(double value) {
		return (Math.exp(value*2.0)-1.0)/
			   (Math.exp(value*2.0)+1.0);
	}

	@Override
	public double activateFunctionDerivative(double value) {
		return( 1.0-Math.pow(activateFunction(value), 2.0) );
	}
	
	@Override
	public String getName(){
		return NAME;
	}
}
