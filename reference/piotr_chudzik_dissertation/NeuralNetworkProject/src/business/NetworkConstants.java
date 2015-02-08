package business;

public class NetworkConstants {

	/**
	 *  We will be using only models with 3 layers ( 1 input, 1 hidden and 1 output).
	 */
	public static final int INPUT_LAYER_INDEX = 0;
	public static final int HIDDEN_LAYER_INDEX = 1;
	public static final int OUTPUT_LAYER_INDEX = 2;
	
	/**
	 *  For all ANN models there will be only 1 output neuron and 1 output value
	 */
	
	public static final int NUMBER_OF_OUTPUTS = 1;
	
	/**
	 * Special neurons names
	 */
	public static final String BIAS_NEURON_NAME = "Bias";
	public static final String ELMAN_NEURON_NAME = "Elman";
	public static final String JORDAN_NEURON_NAME = "Jordan";
	
	public static final double MAX_PERCENTAGE_INCREASE = 100;
	public static final double MIN_PERCENTAGE_INCREASE = -100;
	
	/**
	 * This is a default value of Evaluation stage MSE and R squared.
	 */
	public static final int DEFAULT_EVALUATION_STAT_VALUE = -1000;
	
}
