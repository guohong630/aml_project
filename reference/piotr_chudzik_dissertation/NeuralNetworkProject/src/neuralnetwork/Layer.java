package neuralnetwork;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import business.NetworkConstants;

public class Layer implements Serializable{

	private static final long serialVersionUID = 1L;
	
	private List<Neuron> neurons;
	
	public List<Neuron> getNeurons() {
		return this.neurons;
	}

	public Layer() {}
	
	/**
	 *  Creates a single layer of neurons. Each layer has it's own id starting from 0.
	 * @param numberOfNeurons
	 * @param numberOfOutgoingWeights
	 * @param layerNumber
	 * @param numberOfJordanNeurons 
	 * @param numberOfElmanNeurons 
	 */
	public Layer(int numberOfNeurons, int numberOfOutgoingWeights, int layerNumber,
			int numberOfElmanNeurons, int numberOfJordanNeurons, double weightsScaleFactor, 
			double weightsShiftFactor){
		
		neurons = new ArrayList<Neuron>();
		
		//Standard neurons
		for( int i = 0 ; i < numberOfNeurons ; i++ ){
			neurons.add(new Neuron(numberOfOutgoingWeights, 0, layerNumber, i, "",
					weightsScaleFactor, weightsShiftFactor));
		}
		
		//Elman neurons (if present)
		for( int i = 0 ; i < numberOfElmanNeurons ; i++ ){
			neurons.add(new Neuron(numberOfOutgoingWeights, 0, layerNumber, 
					neurons.size(), NetworkConstants.ELMAN_NEURON_NAME+i,
					weightsScaleFactor, weightsShiftFactor));
		}
		
		for( int i = 0 ; i < numberOfJordanNeurons ; i++ ){
			neurons.add(new Neuron(numberOfOutgoingWeights, 0, layerNumber,
					neurons.size(), NetworkConstants.JORDAN_NEURON_NAME+i,
					weightsScaleFactor, weightsShiftFactor));
		}
				
		//Add Bias (excluding output layer)
		if(numberOfNeurons > 1){
			neurons.add(new Neuron(numberOfOutgoingWeights, 1,
					layerNumber, neurons.size(), NetworkConstants.BIAS_NEURON_NAME,
					weightsScaleFactor, weightsShiftFactor));
		}
	}
}
