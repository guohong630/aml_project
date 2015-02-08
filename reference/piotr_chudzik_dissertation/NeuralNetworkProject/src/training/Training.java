package training;

import java.util.List;

import neuralnetwork.Network;
import utils.Tuple;
import activation.ActivationFunction;
import exception.NeuralNetworkException;
import exception.TrainingException;

public interface Training {

	/**
	 * This is a point of entry method to the training process. It is implemented in all subclasses of this class.
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	public void trainNetwork(Network network, List<Tuple<List<Double>, List<Double>>> inputData, 
			boolean isTimeSeriesData, ActivationFunction activationFunction, 
			boolean isEvaluationMode, boolean isPercentageData) throws TrainingException, NeuralNetworkException;
	
	/**
	 *  Method containing the training algorithm main logic.
	 *  
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	public List<Double> train(Network network,
			List<Double> timeboxedInputData, List<Double> timeboxedOutputData,
			int epochNumber, boolean isEvaluationMode,
			ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException, NeuralNetworkException;
}
