package neuralnetwork;

import java.io.Serializable;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 * An object of this class holds information about a neural network morphology (number of input, hidden
 * and output neurons) and any recurrence (Elman or Jordan) present.
 */
public class NetworkConfiguration implements Serializable{

	private static final long serialVersionUID = 1L;


	/**
	 * All models will be using only 3 layers (input, hidden and output) so it is safe to use
	 * a constant number of layers here.
	 */
	private static final int NUMBER_OF_LAYERS = 3;
	
	
	private int numberOfInputNeurons;
	private int numberOfHiddenNeurons;
	private int numberOfOutputNeurons;
	private int inputWindowSize;
	
	private boolean isElmanRecurrent;
	private boolean isJordanRecurrent;
	private boolean isCtrnnNetwork;
	
	private double weightsScalingFactor;
	private double weightsShiftingFactor;
	
	public NetworkConfiguration(int numberOfInputNeurons, int numberOfHiddenNeurons, int numberOfOutputNeurons,
			int inputWindowSize, boolean isElmanRecurrent, boolean isJordanRecurrent, boolean isCtrnnNetwork,
			double weightsScalingFactor, double weightsShiftingFactor){
		
		this.numberOfInputNeurons = numberOfInputNeurons;
		this.numberOfHiddenNeurons = numberOfHiddenNeurons;
		this.numberOfOutputNeurons = numberOfOutputNeurons;
		this.inputWindowSize = inputWindowSize;
		
		this.isElmanRecurrent = isElmanRecurrent;
		this.isJordanRecurrent = isJordanRecurrent;
		this.isCtrnnNetwork = isCtrnnNetwork;
		
		this.weightsScalingFactor = weightsScalingFactor;
		this.weightsShiftingFactor = weightsShiftingFactor;
	}

	public int getNumberOfInputNeurons() {
		return numberOfInputNeurons;
	}

	public void setNumberOfInputNeurons(int numberOfInputNeurons) {
		this.numberOfInputNeurons = numberOfInputNeurons;
	}

	public int getNumberOfHiddenNeurons() {
		return numberOfHiddenNeurons;
	}

	public void setNumberOfHiddenNeurons(int numberOfHiddenNeurons) {
		this.numberOfHiddenNeurons = numberOfHiddenNeurons;
	}

	public int getNumberOfOutputNeurons() {
		return numberOfOutputNeurons;
	}

	public void setNumberOfOutputNeurons(int numberOfOutputNeurons) {
		this.numberOfOutputNeurons = numberOfOutputNeurons;
	}

	public boolean isElmanRecurrent() {
		return isElmanRecurrent;
	}

	public void setElmanRecurrent(boolean isElmanRecurrent) {
		this.isElmanRecurrent = isElmanRecurrent;
	}

	public boolean isJordanRecurrent() {
		return isJordanRecurrent;
	}

	public void setJordanRecurrent(boolean isJordanRecurrent) {
		this.isJordanRecurrent = isJordanRecurrent;
	}
	
	public int getNumberOfLayers() {
		return NUMBER_OF_LAYERS;
	}

	public double getWeightsScalingFactor() {
		return weightsScalingFactor;
	}

	public void setWeightsScalingFactor(double weightsScalingFactor) {
		this.weightsScalingFactor = weightsScalingFactor;
	}

	public double getWeightsShiftingFactor() {
		return weightsShiftingFactor;
	}

	public void setWeightsShiftingFactor(double weightsShiftingFactor) {
		this.weightsShiftingFactor = weightsShiftingFactor;
	}

	public boolean isCtrnnNetwork() {
		return isCtrnnNetwork;
	}

	public void setCtrnnNetwork(boolean isCtrnnNetwork) {
		this.isCtrnnNetwork = isCtrnnNetwork;
	}

	public int getInputWindowSize() {
		return inputWindowSize;
	}

	public void setInputWindowSize(int inputWindowSize) {
		this.inputWindowSize = inputWindowSize;
	}
}
