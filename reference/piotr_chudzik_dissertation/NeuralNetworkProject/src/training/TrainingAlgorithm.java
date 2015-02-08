package training;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Stack;

import exception.NeuralNetworkException;
import exception.TrainingException;

import utils.DataUtils;
import utils.Tuple;

import activation.ActivationFunction;
import activation.SigmoidFunction;
import business.NetworkConstants;

import neuralnetwork.Layer;
import neuralnetwork.Network;
import neuralnetwork.Neuron;
import neuralnetwork.Synapse;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 * Superclass of all training algorithm which contains method that are used across all training algorithms.
 */

public class TrainingAlgorithm implements Training {
	
	protected String trainingAlgorithmName;
	
	public List<Tuple<List<Double>, List<Double>>> evaluateNetwork
		(Network network, List<Tuple<List<Double>, List<Double>>> evaluationData, boolean isTimeSeriesData,
		boolean isExpectedOutputNeeded, ActivationFunction activationFunction, boolean isPercentageData) 
		throws TrainingException, NeuralNetworkException{
	
	if(evaluationData == null){
		throw new NeuralNetworkException("Unable to evaluate because evaluation data is empty");
	}
	List<Tuple<List<Double>, List<Double>>> outputs = calculateOutputs(network, evaluationData, 0,
			isTimeSeriesData, true, isExpectedOutputNeeded, activationFunction, isPercentageData);
	
		return outputs;
	}
	
	/**
	 *  Calculate outputs of neural network for all training examples (single epoch).
	 * @param isExpectedOutputNeeded 
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	protected List<Tuple<List<Double>, List<Double>>> calculateOutputs
				(Network network, List<Tuple<List<Double>, List<Double>>> inputData, int epochNumber,
				boolean isTimeSeriesData, boolean isEvaluationMode, boolean isExpectedOutputNeeded, 
				ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException, NeuralNetworkException {
		
		/**
		 *  A List of expected and actual outputs.
		 *  Each Tuple contains a list of expected outcomes and a list of actual outcomes per single 
		 *  training example
		 */
		
		List<Tuple<List<Double>, List<Double>>> outputs =  new ArrayList<Tuple<List<Double>, List<Double>>>();
		
		if(isTimeSeriesData){
			
			int inputWindow = network.getNetworkConfiguration().getInputWindowSize();
			int outputWindow = NetworkConstants.NUMBER_OF_OUTPUTS;
			
			//When evaluating user supplied input we don't need outputWindow because there is no expected output value
			//(we try to predict output value)
			if(isEvaluationMode && !isExpectedOutputNeeded){
				outputWindow = 0; 
			}
			
			/**
			 * "inputData.size() - (inputWindow+outputWindow)" is needed because if the offset value will come too close to
			 * the end of List of inputs we might not have enough dataset instances to populate a list of inputWindow size 
			 * and a list of outputWindow size.
			 */
			for( int index = 0; index <= inputData.size() - (inputWindow + outputWindow); index++){//Added = - check if works
				
				List<Double> timeboxedInputData = getTimeBoxedValues(inputData, index, inputWindow, true);
				/**
				 * "index + inputWindow" so we will get expected output values from dataset entries located just after dataset
				 * entries we used as inputs. So e.g. if dataset entries 1,2,3 are used as inputs , a datset entry 4 will be
				 * used as an output
				 */
				List<Double> timeboxedOutputData = getTimeBoxedValues(inputData, index + inputWindow, outputWindow, false);
				
				List<Double> actualOutputs = train(network, timeboxedInputData, timeboxedOutputData,
						epochNumber, isEvaluationMode, activationFunction, isPercentageData);
				outputs.add(new Tuple<List<Double>,List<Double>>(timeboxedOutputData, actualOutputs));				
			}
		}
		else{
			
			for(Tuple<List<Double>,List<Double>> trainingExample : inputData){
				List<Double> expectedOutputs = trainingExample.getSecond();
				
				List<Double> actualOutputs = train(network, trainingExample.getFirst(), expectedOutputs,
						epochNumber, isEvaluationMode, activationFunction, isPercentageData);
				outputs.add(new Tuple<List<Double>,List<Double>>(expectedOutputs, actualOutputs));
			}		
			return outputs;
		}		
		return outputs;
	}

	/**
	 *  Method implemented in all subclasses.
	 */
	public List<Double> train(Network network,
			List<Double> timeboxedInputData, List<Double> timeboxedOutputData,
			int epochNumber, boolean isEvaluationMode,
			ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException, NeuralNetworkException{
		return null;
	}

	/**
	 *  Returns a List of inputs or expected outputs.
	 */
	private List<Double> getTimeBoxedValues(List<Tuple<List<Double>, List<Double>>> inputData,
			int offset, int windowSize, boolean isInputData){
		
		List<Double> timeboxedData = new ArrayList<Double>();
		
		for( int i = 0; i < windowSize ; i++){
			Tuple<List<Double>, List<Double>> datasetEntry = inputData.get(offset+i);
			if(isInputData){//For inputs we are only interested in the first element of a tuple which is a list of inputs
				timeboxedData.addAll(datasetEntry.getFirst());
			}else{//For outputs we are only interested in the second element of a tuple which is a list of outputs
				timeboxedData.addAll(datasetEntry.getSecond());
			}
		}
		
		return timeboxedData;
	}
	
	/**
	 *  This method will create a list of output values (after activation) of all output neurons
	 *  which is the end result of a neural network calculation.
	 *  
	 * @param outputNeurons - output neurons of a neural network.
	 * @return a list of output values (after activation) of all output neurons.
	 */
	protected List<Double> getOutputNeuronsOutputValues(List<Neuron> outputNeurons) {
		
		List<Double> outputNeuronsValues = new ArrayList<Double>();
		for(Neuron outputNeuron: outputNeurons){
			outputNeuronsValues.add(outputNeuron.getOutputValue());
		}
		return outputNeuronsValues;
	}
	
	/**
	 * This method updates output values of Elman and Jordan neurons in the input layer if they are present
	 * with the output values of hiddenNeurons (for Elman neurons) or output neurons (for Jordan neurons)
	 * 
	 * @param inputNeurons - input neurons of a neural network.
	 * @param hiddenNeurons - hidden neurons of a neural network.
	 * @param outputNeurons - output neurons of a neural network.
	 */
	protected void updateElmanJordanNeurons(List<Neuron> inputNeurons,
			List<Neuron> hiddenNeurons, List<Neuron> outputNeurons) {
		
		//We need FIFO so the Bias neuron value from the hidden layer won't be used.
		Queue<Neuron> hiddenNeuronsQueue = new LinkedList<Neuron>();
		hiddenNeuronsQueue.addAll(hiddenNeurons);
		
		Stack<Neuron> outputNeuronsStack = new Stack<Neuron>();
		outputNeuronsStack.addAll(outputNeurons);
		
		for(Neuron inputNeuron: inputNeurons){
			if(inputNeuron.getName().contains(NetworkConstants.ELMAN_NEURON_NAME)){
				//Update output with a hidden neuron output so it will be used in the next iteration.
				inputNeuron.setOutputValue(hiddenNeuronsQueue.poll().getOutputValue());
			}else if(inputNeuron.getName().contains(NetworkConstants.JORDAN_NEURON_NAME)){
				//Update output with an output neuron output so it will be used in the next iteration.
				inputNeuron.setOutputValue(outputNeuronsStack.pop().getOutputValue());
			}
		}
	}
	/**
	 * This method saves neural network's all synapses weights values to be used for evaluation purposes.
	 * 
	 * @param epochNumber
	 * @param layers
	 * @param synapseWeights - map of values Map<String, Map<Integer, Double>> where 
	 * String - synapse name
	 * Integer - iteration number
	 * Double - synapse weight value
	 */
	protected void saveSynapseValues(int epochNumber, Layer[] layers, 
			Map<String, Map<Integer, Double>> synapseWeights) {
		
		for(Layer layer: layers){
			for(Neuron neuron: layer.getNeurons()){
				for(Synapse synapse: neuron.getSynapses()){
					saveSingleSynapseWeight(epochNumber, synapse, synapseWeights);
				}
			}
		}
		
	}

	/**
	 * This method saves a single synapse weight value.
	 *  
	 * @param epochNumber
	 * @param synapse
	 * @param synapseWeights - map of values Map<String, Map<Integer, Double>> where 
	 * String - synapse name
	 * Integer - iteration number
	 * Double - synapse weight value
	 */
	private void saveSingleSynapseWeight(int epochNumber, Synapse synapse, 
			Map<String, Map<Integer, Double>> synapseWeights) {
		
		//If this synapse past recordings already exist - just add new weight
		if(synapseWeights.containsKey(synapse.getName())){
			synapseWeights.get(synapse.getName())
				.put(epochNumber, synapse.getWeight());
		}else{//add new synapse to synapseWeights Map
			Map<Integer, Double> synapseWeightsPerIteration = new HashMap<Integer, Double>();
			synapseWeightsPerIteration.put(epochNumber, synapse.getWeight());
			
			synapseWeights.put( synapse.getName(), synapseWeightsPerIteration);
		}
	}
	
	/**
	 *  This method calculates output neurons values given input values and a neural network
	 * @throws TrainingException 
	 */
	protected void calculateOutputNeuronsValues(List<Double> inputs, Network network,
			ActivationFunction activationFunction) throws TrainingException {
		
		Layer[] layers = network.getLayers();
		
		List<Neuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getNeurons();// Input Layer
		List<Neuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getNeurons();//Hidden Layer
		List<Neuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getNeurons();//Output Layer
		
		if(inputs.size() > inputNeurons.size()){
			throw new TrainingException("Not enough input neurons, please correct. Currently there are " +
					inputNeurons.size() + " input neurons and " +  inputs.size() + " are needed in total.");
		}
		
		//Initialize input neurons
		for( int i = 0; i < inputs.size() ; i++){
			inputNeurons.get(i).setOutputValue(inputs.get(i));
			if(Double.isInfinite(inputs.get(i)) || Double.isNaN(inputs.get(i)) ){
				System.out.println("as");//PCH debug
			}
		}
				
		/**
		 * 	 1.Calculate net values of hidden neurons
		 */
		
		//-1 is to exclude Bias neuron value which should be always 1
		for( int index = 0; index < hiddenNeurons.size()-1 ; index++){
			System.out.println("\n\nCalculating Output value of " + hiddenNeurons.get(index).getName() + "...");
			
			updateNeuronOutputValue(inputNeurons, hiddenNeurons.get(index), index);
			
			System.out.println("\n\nThe FINAL OUTPUT value of " + hiddenNeurons.get(index).getName() + " is: "
					+ hiddenNeurons.get(index).getOutputValue());
		}
		
		/**
		 * 	2.Activate hidden neurons using Sigmoid function
		 */
		activateNeurons(hiddenNeurons, activationFunction);
		
		/**
		 * 	3.Calculate net value of output neurons
		 */
		
		for( int index = 0; index < outputNeurons.size() ; index++){
			updateNeuronOutputValue(hiddenNeurons, outputNeurons.get(index), index);
		}
		
		/**
		 * 	4.Activate output neuron using Sigmoid function
		 */
		activateNeurons(outputNeurons, activationFunction);
	}

	private static void activateNeurons(List<Neuron> neurons, ActivationFunction activationFunction) {
		for(Neuron neuron : neurons){
			if(!neuron.getName().contains(NetworkConstants.BIAS_NEURON_NAME)){//We don't update Bias output which must stay 1
				
				System.out.println("\nCurrent Output value of " + neuron.getName() +  
						" before SIGMOID is: " + neuron.getOutputValue());
				
				neuron.setOutputValue(activationFunction.activateFunction((neuron.getOutputValue())));
				
				System.out.println("\nCurrent Output value of " + neuron.getName() +  
						" after SIGMOID is: " + neuron.getOutputValue());
			}
		}
	}

	private static void updateNeuronOutputValue(List<Neuron> inputNeurons, Neuron outputNeuron, int outputNeuronIndex) {
		
		for( int i = 0 ; i < inputNeurons.size() ; i++){
			
			System.out.println("\nCurrent Output value of " + outputNeuron.getName() + 
					" is: " + outputNeuron.getOutputValue());
			
			outputNeuron.setOutputValue( outputNeuron.getOutputValue() 
					+ inputNeurons.get(i).getOutputValue()
					* inputNeurons.get(i).getSynapses()[outputNeuronIndex].getWeight());
			
			if(Double.isInfinite(outputNeuron.getOutputValue()) || Double.isNaN(outputNeuron.getOutputValue()) ){
				System.out.println("as");//PCH debug
			}
			
			System.out.println("After adding the weighted sum of " + inputNeurons.get(i).getName() +
					" to Output value of " 
					+ outputNeuron.getName() +  " is now: " + outputNeuron.getOutputValue());
		}
	}
	
	public String getTrainingAlgorithmName() {
		return trainingAlgorithmName;
	}

	/**
	 * Method implemented in all subclasses.
	 */
	public void trainNetwork(Network network,
			List<Tuple<List<Double>, List<Double>>> trainingData, boolean b,
			ActivationFunction activationFunction, boolean c,
			boolean isPercentageData) throws TrainingException, NeuralNetworkException{	
	}
	
	
}
