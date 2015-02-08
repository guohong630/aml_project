package training;

import java.util.ArrayList;
import java.util.List;

import exception.NeuralNetworkException;
import exception.TrainingException;

import utils.Tuple;

import neuralnetwork.Layer;
import neuralnetwork.Network;
import neuralnetwork.NetworkConfiguration;
import neuralnetwork.Neuron;
import activation.ActivationFunction;
import activation.SigmoidFunction;
import business.NetworkConstants;

public class Backpropagation extends TrainingAlgorithm implements Training{
	
	private static Backpropagation instance = new Backpropagation();
	
	public static Backpropagation getInstance(){
		return instance;
	}
	
	public Backpropagation(){
		trainingAlgorithmName = "Backpropagation";
	}
	
	@Override
	public void trainNetwork(Network network, List<Tuple<List<Double>, List<Double>>> inputData, 
			boolean isTimeSeriesData, ActivationFunction activationFunction,
			boolean isEvaluationMode, boolean isPercentageData
			) throws TrainingException, NeuralNetworkException{
		
		if (network.isEpochsUsed()) {
			for (int i = 0; i < network.getNumberOfEpochs(); i++) {

				trainNetwork(network, inputData, i, isTimeSeriesData, activationFunction, isEvaluationMode, isPercentageData);
			}
		} else {// Use MSE
			int count = 0;
			do {
				trainNetwork(network, inputData, count, isTimeSeriesData, activationFunction, isEvaluationMode, isPercentageData);
				count++;
			} while (network.getFinalMSEValue() >= network.getMSEMaxValue());
		}
	}
	
	private void trainNetwork(Network network, List<Tuple<List<Double>, List<Double>>> inputData,
			int epochNumber, boolean isTimeSeriesData, ActivationFunction activationFunction,
			boolean isEvaluationMode, boolean isPercentageData)
					throws TrainingException, NeuralNetworkException {
		
		List<Tuple<List<Double>, List<Double>>> outputs = 
				calculateOutputs(network, inputData, epochNumber, isTimeSeriesData, 
						false, true, activationFunction, isPercentageData);
		
		if ( ! isEvaluationMode){//Do not update training statistical values during evaluation
			network.updateStatisticalIndicators(epochNumber, outputs, isPercentageData);
		}
	}
	
	/**
	 *  Perform actual backpropagation training
	 * @throws TrainingException 
	 */
	@Override
	public List<Double> train(Network network, List<Double> inputs, List<Double> outputs,
			int epochNumber, boolean isEvaluationMode, ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException{
		
		calculateOutputNeuronsValues(inputs, network, activationFunction);
		
		Layer[] layers = network.getLayers();		
		List<Neuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getNeurons();//Output Layer
		
		//In evaluation mode we do not want to update deltas and weights since we are interested in 
		// the output of the neural network only not training it.
		if(isEvaluationMode){
			return getOutputNeuronsOutputValues(outputNeurons);
		}
		
		double learningRate = network.getLearningRate();
		List<Neuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getNeurons();// Input Layer
		List<Neuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getNeurons();//Hidden Layer
		
		
		
		/**
		 * 1.Calculate deltas
		 */
		
		//For output layer
		updateDeltasForOutputNeurons(outputNeurons, outputs, activationFunction);
		
		//For hidden layer
		updateDeltasForHiddenNeurons(hiddenNeurons, outputNeurons.get(0).getDelta(), activationFunction);
		
		/**
		 *  2.Update Weights
		 */
		
		List<Double> outputValues = new ArrayList<Double>(inputs);
		outputValues.add(1.0);//For Bias
		//double[] outputValues = {firstInput, secondInput,1};
		
		
		//Weights between Input Layer and Hidden Layer
		for(int inputIndex = 0 ; inputIndex < inputNeurons.size(); inputIndex++){
			for(int hiddenIndex=0 ; hiddenIndex < hiddenNeurons.size()-1; hiddenIndex++){// -1 is to remove bias
				inputNeurons.get(inputIndex).updateWeight(hiddenIndex, learningRate
						*hiddenNeurons.get(hiddenIndex).getDelta()
						*inputNeurons.get(inputIndex).getOutputValue());
			}
		}
		
		//Weights between Hidden Layer and Output Layer
		for(int hiddenIndex = 0 ; hiddenIndex < hiddenNeurons.size(); hiddenIndex++){
			for(int outputIndex=0 ; outputIndex < outputNeurons.size(); outputIndex++){
				hiddenNeurons.get(hiddenIndex).updateWeight(outputIndex, learningRate
						*outputNeurons.get(outputIndex).getDelta()
						* hiddenNeurons.get(hiddenIndex).getOutputValue());
			}
		}
		
		saveSynapseValues(epochNumber, layers , network.getSynapseWeights());
		
		/**
		 *  3. Update Elman and Jordan neurons if needed.
		 */
		
		updateElmanJordanNeurons(inputNeurons, hiddenNeurons, outputNeurons);
//		/**
//		 *  6.Update Weights
//		 */
//		
//		List<Double> outputValues = new ArrayList<Double>(inputs);
//		outputValues.add(1.0);//For Bias
//		//double[] outputValues = {firstInput, secondInput,1};
//		
//		for( int i=0; i < 3; i++){
//			
//			if(i == 2){// Update data for the output neuron
//				outputValues.set(0, hiddenNeurons[0].getOutputValue());
//				outputValues.set(1, hiddenNeurons[1].getOutputValue());
////				outputValues[0] = hiddenNeurons[0].getOutputValue();
////				outputValues[1] = hiddenNeurons[1].getOutputValue();
//			}
//			
//			switch(i){
//				case INPUT_LAYER_INDEX: //Weights between Input Layer and First Hidden Neuron
//					for(int j=0 ; j < inputNeurons.length; j++){
//						inputNeurons[j].updateWeight(0, learningRate*hiddenNeurons[0].getDelta()*outputValues.get(j));
//					}
//					break;
//				case HIDDEN_LAYER_INDEX: //Weights between Input Layer and Second Hidden Neuron
//					for(int j=0 ; j < inputNeurons.length; j++){
//						inputNeurons[j].updateWeight(1, learningRate*hiddenNeurons[1].getDelta()*outputValues.get(j));
//					}
//					break;
//				case OUTPUT_LAYER_INDEX: //Weights between Hidden Layer and Output Neuron
//					for(int j=0 ; j < inputNeurons.length; j++){
//						hiddenNeurons[j].updateWeight(0, learningRate*outputNeurons[0].getDelta()*outputValues.get(j));
//					}
//					break;
//			}	
//		}
//		saveSynapseValues(epochNumber);
//		
//		List<Double> outputNeuronsValues = new ArrayList<Double>();
//		for(Neuron outputNeuron: outputNeurons){
//			outputNeuronsValues.add(outputNeuron.getOutputValue());
//		}

		return getOutputNeuronsOutputValues(outputNeurons);		
	}

	private static void updateDeltasForOutputNeurons(List<Neuron> outputNeurons, List<Double> expectedOutputs,
			ActivationFunction activationFunction) {
		
		for( int i=0 ; i < outputNeurons.size() ; i++){
			Neuron currentOutputNeuron = outputNeurons.get(i);
			double actualOutputValue = currentOutputNeuron.getOutputValue();
			
			System.out.println( "\nOutput neuron output value before calculating delta is: " + actualOutputValue 
					+ " ,desired output is " + expectedOutputs.get(i) + 
					" and delta: " + currentOutputNeuron.getDelta());
			
			//That's for sigmoid function only
			//currentOutputNeuron.setDelta(actualOutputValue * (1 - actualOutputValue ) * (expectedOutputs.get(i) - actualOutputValue));
			currentOutputNeuron.setDelta(activationFunction.activateFunctionDerivative(actualOutputValue) *
					(expectedOutputs.get(i) - actualOutputValue));
			//neuron.setDelta(outputValue * (output - outputValue));
			
			System.out.println( "\nOutput neuron delta is: " + currentOutputNeuron.getDelta());
		}
	}
	
	private static void updateDeltasForHiddenNeurons(List<Neuron> hiddenNeurons, double outputNeuronDelta,
			ActivationFunction activationFunction) {
		
		for(int i=0; i < hiddenNeurons.size() - 1; i++){//Don't update bias
			Neuron currentHiddenNeuron = hiddenNeurons.get(i);
			double actualOutputValue = currentHiddenNeuron.getOutputValue();
			
			System.out.println( currentHiddenNeuron.getName() + " output value before calculating delta is: " 
					+ actualOutputValue 
					//+ " ,desired output: " + outputs.get(i) 
					+ " ,Output Neuron Delta: " + outputNeuronDelta
					+ " ,weight to output Neuron:" + currentHiddenNeuron.getSynapses()[0].getWeight()
					+ " , current delta: " + currentHiddenNeuron.getDelta());
			
//			currentHiddenNeuron.setDelta(actualOutputValue 
//					* (1- actualOutputValue )
//					* currentHiddenNeuron.getSynapses()[0].getWeight() * outputNeuronDelta);
			
			currentHiddenNeuron.setDelta(activationFunction.activateFunctionDerivative(actualOutputValue)
					* currentHiddenNeuron.getSynapses()[0].getWeight() * outputNeuronDelta);
			
			System.out.println( currentHiddenNeuron.getName() + " updated delta is: " + currentHiddenNeuron.getDelta());
		}
	}
}
