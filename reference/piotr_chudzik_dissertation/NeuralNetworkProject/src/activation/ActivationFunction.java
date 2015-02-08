package activation;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 */
public interface ActivationFunction {

	/**
	 * A function that provides a treshold for a neural network neurons net values.
	 
	 * @param net value of a neuron ( weighted sum of all weights in a previous layer multiplied by 
	 * output values of those neurons)
	 * @return normalised value using a chosen mathematical function
	 */
	public double activateFunction(double value);
	
	/**
	 * Some formulas (e.g. error calculation in the backpropagation algorithm)
	 * require a derivative of a given activation function.
	 * @param net value of a neuron ( weighted sum of all weights in a previous layer multiplied by 
	 * output values of those neurons
	 * @return normalised value using a chosen mathematical function
	 */
	public double activateFunctionDerivative(double value);
	
	/**
	 * Return name of the activation function.
	 * 
	 * This method is overwritten in all subclasses.
	 * 
	 * @return name of the activation function
	 */
	public String getName();
	
}
