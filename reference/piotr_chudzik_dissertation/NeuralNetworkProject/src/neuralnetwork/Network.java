package neuralnetwork;

import gui.panels.controls.GeneticParametersPanel;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import business.NetworkConstants;

import utils.DataUtils;
import utils.ListUtils;
import utils.StatisticalUtils;
import utils.Tuple;

public class Network implements Serializable {
	
	
	private static final long serialVersionUID = 1L;
	
	/**
	 * Network Morphology.
	 */
	protected Layer[] layers;	
	protected NetworkConfiguration networkConfiguration;
	
	/**
	 * Training details.
	 */
	protected String datasetName;
	protected String trainingAlgorithmUsed;
	
	protected String activationFunction;
	protected boolean isPercentageData;
	
	/**
	 * Network Backpropagation parameters.
	 */
	private double learningRate;
	private double mSEMaxValue;
	private int numberOfEpochs;
	private boolean epochsUsed;
	
	/**
	 * Network Genetic Algorithm parameters.
	 */
	private int populationSize;
	private int elitism;
	private double crossoverPercent;
	private double mutationPercent;
	private double crossoverCutLength;
	private boolean isGenerationCriteriumChosen;
	private int generations;
	private int generationsResults;
	
	/**
	 * Statistical Indicators.
	 */
	protected double finalMSEValue;
	protected double rSquared;
	protected double minimumAbsoluteError;
	protected double maximumAbsoluteError;
	
	/**
	 * Evaluation measures
	 */
	
	private List<Tuple<List<Double>,List<Double>>>  evaluationResults;
	private double evaluationMSE;
	private double evaluationRsquared;
	/**
	 * Stores all MSEs per iteration: key value is the iteration number and MSE is the value object.
	 */
	protected Map<Integer, Double> MSEData;
	
	/**
	 *  Stores all weights per iteration number(integer) 
	 *  for a specific synapse (String - synapse's name)
	 */
	protected Map<String, Map<Integer, Double>> synapseWeights; 
	
	/**
	 * Time taken to train a neural network
	 */
	private String timeTakenToTrain;
	
	public Network(){
		
		this.synapseWeights = new HashMap<String, Map<Integer,Double>>();
		this.MSEData =  new HashMap<Integer, Double>();
		this.minimumAbsoluteError = 0;
		this.maximumAbsoluteError = 0;
		this.evaluationMSE = NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE;
		this.evaluationRsquared = NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE;
		this.evaluationResults = new ArrayList<Tuple<List<Double>,List<Double>>>();
	}

	/**
	 * Update network parameters
	 */
	
	public void updateNetworkParameters(String trainingAlgorithmUsed, double learningRate,
			double mSEMaxValue, int numberOfEpochs, boolean useEpochs, int populationSize, 
			double crossoverPercent, double mutationPercent, double crossoverCutLength, int elitism,
			int generations, int generationsResults, boolean isGenerationCriteriaChosen,
			String activationFunction, boolean isPercentageData, NetworkConfiguration configuration) {
		
		this.setTrainingAlgorithmUsed(trainingAlgorithmUsed);
		this.setNetworkConfiguration(configuration);
		this.setActivationFunction(activationFunction);
		this.setPercentageData(isPercentageData);
		
		this.setEpochsUsed(useEpochs);
		this.setLearningRate(learningRate);
		this.setMSEMaxValue(mSEMaxValue);
		this.setNumberOfEpochs(numberOfEpochs);
		
		this.setPopulationSize(populationSize);
		this.setCrossoverPercent(crossoverPercent);
		this.setMutationPercent(mutationPercent);
		this.setCrossoverCutLength(crossoverCutLength);
		this.setElitism(elitism);
		this.setGenerations(generations);
		this.setGenerationsResults(generationsResults);
		this.setGenerationCriteriumChosen(isGenerationCriteriaChosen);
				
	}

	public void updateStatisticalIndicators(int i,
			List<Tuple<List<Double>, List<Double>>> outputs, boolean isPercentageDataSelected) {
		
		//Create a copy of outputs so it can be denormalized without affecting original list
		List<Tuple<List<Double>, List<Double>>> copiedOutputs = ListUtils.createListCopy(outputs);
		
		if( ! isPercentageDataSelected){
			DataUtils.denormalizeData(copiedOutputs);
		}
		
		this.finalMSEValue = StatisticalUtils.calculateMeanSquaredError(copiedOutputs);
		this.rSquared = StatisticalUtils.calculateCoefficientOfDetermination(copiedOutputs);
		this.maximumAbsoluteError = StatisticalUtils.calculateMaximumAbsoluteError(copiedOutputs, maximumAbsoluteError);
		this.minimumAbsoluteError = StatisticalUtils.calculateMinimumAbsoluteError(copiedOutputs, minimumAbsoluteError, i);
		
		this.MSEData.put(i,finalMSEValue);
	}
	
	public void initializeNetwork(NetworkConfiguration configuration, String datasetName, String trainingAlgorithmName,
			double learningRate, double mSEMaxValue,int epochs, boolean useEpochs,  
			String activationFunction, boolean isPercentageData, GeneticParametersPanel geneticParametersPanel){
		
		this.updateNetworkParameters(trainingAlgorithmName, learningRate, mSEMaxValue, epochs, useEpochs,
				geneticParametersPanel.getPopulationSize(), geneticParametersPanel.getCrossoverPercent(),
				geneticParametersPanel.getMutationPercent(), geneticParametersPanel.getCrossoverCutLength(),
				geneticParametersPanel.getElitism(),geneticParametersPanel.getGenerations(), 
				geneticParametersPanel.getGenerationsResults(), geneticParametersPanel.isGenerationCriteriaChosen(),
				activationFunction, isPercentageData, configuration);
		
		this.initializeNetwork(configuration, datasetName);
		
	}
	
	public void initializeNetwork(NetworkConfiguration configuration, String datasetName){
		
		this.synapseWeights = new HashMap<String, Map<Integer,Double>>();
		this.MSEData =  new HashMap<Integer, Double>();
		this.minimumAbsoluteError = 0;
		this.maximumAbsoluteError = 0;
		this.datasetName = datasetName;
		this.networkConfiguration = configuration;
		this.evaluationMSE = NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE;
		this.evaluationRsquared = NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE;
		this.evaluationResults = new ArrayList<Tuple<List<Double>,List<Double>>>();

		
		int numberOfLayers = configuration.getNumberOfLayers();
		this.layers = new Layer[numberOfLayers];
		int numberOfElmanNeurons = 0;
		int numberOfJordanNeurons = 0;
		
		if(configuration.isElmanRecurrent()){
			numberOfElmanNeurons = configuration.getNumberOfHiddenNeurons();
		}
		
		if(configuration.isJordanRecurrent()){
			numberOfJordanNeurons = configuration.getNumberOfOutputNeurons();
		}
		
		double weightsScalingFactor = configuration.getWeightsScalingFactor();
		double weightsShiftingFactor = configuration.getWeightsShiftingFactor();
		
		for( int i = 0 ; i < numberOfLayers ; i++ ){
			
			if( i+1 == numberOfLayers ){//Output Layer
				this.layers[i] = new Layer(configuration.getNumberOfOutputNeurons(), 0, i, 0, 0,
						weightsScalingFactor, weightsShiftingFactor);
			}else if (i == 0){//Number of outgoing connections is equal to number of neurons in the next layer
				this.layers[i] = new Layer(configuration.getNumberOfInputNeurons(),//Elman and Jordan neurons are added only to input layer 
						configuration.getNumberOfHiddenNeurons(), i, numberOfElmanNeurons, numberOfJordanNeurons,
						weightsScalingFactor, weightsShiftingFactor);
			}else{//Hidden Layer
				this.layers[i] = new Layer(configuration.getNumberOfHiddenNeurons(),
						configuration.getNumberOfOutputNeurons(), i, 0, 0,
						weightsScalingFactor, weightsShiftingFactor); 
			}
		}
	}
	
	public void updateWeight(List<Double> offspring) {
		
		//Convert Arraylist to LinkedList which is FIFO - first in first out
		
		LinkedList<Double> offspringLinkedList = new LinkedList<Double>(offspring);

		for(Layer layer: this.getLayers()){
			for(Neuron neuron: layer.getNeurons()){
				for(Synapse synapse : neuron.getSynapses()){
					synapse.setWeight(offspringLinkedList.poll());
				}
			}
		}	
		
	}

	public Map<Integer, Double> getMSEData() {
		return MSEData;
	}

	public double getFinalMSEValue() {
		return finalMSEValue;
	}

	public double getMinimumAbsoluteError() {
		return minimumAbsoluteError;
	}

	public double getMaximumAbsoluteError() {
		return maximumAbsoluteError;
	}

	public Map<String, Map<Integer, Double>> getSynapseWeights() {
		return synapseWeights;
	}

	public String getDatasetName() {
		return datasetName;
	}

	public void setDatasetName(String datasetName) {
		this.datasetName = datasetName;
	}

	public String getActivationFunction() {
		return activationFunction;
	}

	public void setActivationFunction(String activationFunction) {
		this.activationFunction = activationFunction;
	}

	public boolean isPercentageData() {
		return isPercentageData;
	}

	public void setPercentageData(boolean isPercentageData) {
		this.isPercentageData = isPercentageData;
	}

	public Layer[] getLayers() {
		return layers;
	}

	public void setLayers(Layer[] layers) {
		this.layers = layers;
	}

	public double getLearningRate() {
		return learningRate;
	}

	public void setLearningRate(double learningRate) {
		this.learningRate = learningRate;
	}

	public double getMSEMaxValue() {
		return mSEMaxValue;
	}

	public void setMSEMaxValue(double mSEMaxValue) {
		this.mSEMaxValue = mSEMaxValue;
	}

	public double getRSquared() {
		return rSquared;
	}

	public void setRSquared(double rSquared) {
		this.rSquared = rSquared;
	}

	public int getNumberOfEpochs() {
		return numberOfEpochs;
	}

	public void setNumberOfEpochs(int numberOfEpochs) {
		this.numberOfEpochs = numberOfEpochs;
	}

	public boolean isEpochsUsed() {
		return epochsUsed;
	}

	public void setEpochsUsed(boolean epochsUsed) {
		this.epochsUsed = epochsUsed;
	}

	public String getTrainingAlgorithmUsed() {
		return trainingAlgorithmUsed;
	}

	public void setTrainingAlgorithmUsed(String trainingAlgorithmUsed) {
		this.trainingAlgorithmUsed = trainingAlgorithmUsed;
	}

	public NetworkConfiguration getNetworkConfiguration() {
		return networkConfiguration;
	}

	public void setNetworkConfiguration(NetworkConfiguration networkConfiguration) {
		this.networkConfiguration = networkConfiguration;
	}

	public int getPopulationSize() {
		return populationSize;
	}

	public void setPopulationSize(int populationSize) {
		this.populationSize = populationSize;
	}

	public double getCrossoverPercent() {
		return crossoverPercent;
	}

	public void setCrossoverPercent(double crossoverPercent) {
		this.crossoverPercent = crossoverPercent;
	}

	public double getMutationPercent() {
		return mutationPercent;
	}

	public void setMutationPercent(double mutationPercent) {
		this.mutationPercent = mutationPercent;
	}

	public double getCrossoverCutLength() {
		return crossoverCutLength;
	}

	public void setCrossoverCutLength(double crossoverCutLength) {
		this.crossoverCutLength = crossoverCutLength;
	}

	public int getElitism() {
		return elitism;
	}

	public void setElitism(int elitism) {
		this.elitism = elitism;
	}

	public void setFinalMSEValue(double finalMSEValue) {
		this.finalMSEValue = finalMSEValue;
	}

	public void setMSEData(Map<Integer, Double> mSEData) {
		MSEData = mSEData;
	}

	public String getTimeTakenToTrain() {
		return timeTakenToTrain;
	}

	public void setTimeTakenToTrain(String timeTakenToTrain) {
		this.timeTakenToTrain = timeTakenToTrain;
	}

	public boolean isGenerationCriteriumChosen() {
		return isGenerationCriteriumChosen;
	}

	public void setGenerationCriteriumChosen(boolean isGenerationCriteriumChosen) {
		this.isGenerationCriteriumChosen = isGenerationCriteriumChosen;
	}

	public int getGenerations() {
		return generations;
	}

	public void setGenerations(int generations) {
		this.generations = generations;
	}

	public int getGenerationsResults() {
		return generationsResults;
	}

	public void setGenerationsResults(int generationsResults) {
		this.generationsResults = generationsResults;
	}

	public List<Tuple<List<Double>, List<Double>>> getEvaluationResults() {
		return evaluationResults;
	}

	public void setEvaluationResults(
			List<Tuple<List<Double>, List<Double>>> evaluationResults) {
		this.evaluationResults = evaluationResults;
	}

	public double getEvaluationMSE() {
		return evaluationMSE;
	}

	public void setEvaluationMSE(double evaluationMSE) {
		this.evaluationMSE = evaluationMSE;
	}

	public double getEvaluationRsquared() {
		return evaluationRsquared;
	}

	public void setEvaluationRsquared(double evaluationRsquared) {
		this.evaluationRsquared = evaluationRsquared;
	}
}
