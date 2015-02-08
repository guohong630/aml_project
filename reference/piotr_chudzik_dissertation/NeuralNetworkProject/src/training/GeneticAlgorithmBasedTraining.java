package training;

import exception.NeuralNetworkException;
import exception.TrainingException;
import ga.Chromosome;
import ga.FitnessComparator;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Random;

import activation.ActivationFunction;
import business.NetworkConstants;

import neuralnetwork.CTRNeuralNetwork;
import neuralnetwork.Network;
import neuralnetwork.NetworkConfiguration;
import utils.DataUtils;
import utils.ListUtils;
import utils.StatisticalUtils;
import utils.Tuple;

public class GeneticAlgorithmBasedTraining extends TrainingAlgorithm implements Training {
	
	/**
	 *  Fitness of each chromosome is measured by MSE value: smaller MSE, higher fitness value 
	 *  hence a chromosome should get bigger part of a roulette wheel.
	 *  This introduces a challenge because a standard roulette wheel algorithm assigns bigger part of a roulette wheel
	 *  to chromosomes with a bigger(not smaller) fitness. Standard algoruthm deals with a maximum optimization problem
	 *  whereas in this particular domain we deal with a minimum optimization problem.
	 *  
	 *  In order to solve it we choose a chromosome with maximum fitness (MSE value) from a set of chromosomes chosen to
	 *  mate and from that value we subtract all other chromosomes' fitness values. As a result a chromosomes with smallest fitness
	 *  values become chromosomes with biggest fitness values and get biggest part of a roulette wheel. Of course this process is
	 *  temporary and chromosomes fitness values are not permanently overwritten.
	 *  
	 *  A special case we need to consider in this algorithm is when we subtract a highest fitness value from itself which will result
	 *  in 0. That means that the least fit chromosome in a set of all chromosomes chosen to mate will have much smaller chance to
	 *  mate than others which is undesired. In order to prevent this we add experimentally chosen small constant 
	 *  to the maximum value so we never obtain 0 as a fitness value.
	 */
	private static final double ROULETTE_WHEEL_CONSTANT = 0.001;
	
	private static GeneticAlgorithmBasedTraining instance = new GeneticAlgorithmBasedTraining();
	
	/**
	 * In order to use Gaussian operator for mutation we need to know highest and lowest weights values possible
	 */
	private static double networkWeightsHighestValue;
	private static double networkWeightsLowestValue;
	
	
	public static GeneticAlgorithmBasedTraining getInstance(){
		return instance;
	}
	
	public GeneticAlgorithmBasedTraining(){
		trainingAlgorithmName = "GA_BASED_TRAINING";
		
		//Default Values
		networkWeightsHighestValue = 1;
		networkWeightsLowestValue = 0;
	}
	
	@Override
	public void trainNetwork(Network network, List<Tuple<List<Double>, List<Double>>> inputData, 
			boolean isTimeSeriesData, ActivationFunction activationFunction,
			boolean isEvaluationMode, boolean isPercentageData) throws TrainingException, NeuralNetworkException{
		
		updateWeightsPeripheralsValues(network.getNetworkConfiguration());
		
		/**
		 * Termination Criteria
		 */
		int maxGenerations = network.getGenerations();
		 // If the best result will not change for a number of predefined iterations, training will be stopped
		int generationsWithoutChange = network.getGenerationsResults();
		//If true use maxGenerations as termination criteria, otherwise use generationsWithoutChange
		boolean useGenerationCriteria = network.isGenerationCriteriumChosen();
		
		int generationsCount = 0;
		/**
		 * Stores MSE for all best Chromosomes across all generations
		 * Key - generation number
		 * Value - MSE value of the best Chromosome
		 */
		Map<Integer,Double> MSEOfAllBestChromosomesAcrossGenerations = new HashMap<Integer,Double>();
		Chromosome fittestChromosomeOfAllGenerations = null;
		/**
		 *  1. Create initial population
		 */
		PriorityQueue<Chromosome> population = createPopulation(network, inputData, isTimeSeriesData, activationFunction, isPercentageData);
		//Add initially best chromosome fitness value
		MSEOfAllBestChromosomesAcrossGenerations.put(generationsCount, population.peek().getFitness());
		generationsCount++;
		
		/**
		 * 2. Perform genetic training until the best solution will not change for a number of iterations
		 */
		for(int count=1; count < generationsWithoutChange+1 ; count++){
			
			if(useGenerationCriteria){
				count = 1;//Restart count so generationsWithoutChange criterium will not be considered.
			}
			
			PriorityQueue<Chromosome> nextGenPopulation = crossoverBestChromosomes(population, network, inputData,
					isTimeSeriesData, activationFunction, isPercentageData);
			Chromosome fittestChromosome = nextGenPopulation.peek();
			if(fittestChromosomeOfAllGenerations == null || fittestChromosome.getFitness() < fittestChromosomeOfAllGenerations.getFitness()){
				fittestChromosomeOfAllGenerations = fittestChromosome; //Update the best solution
				count = 1;//Restart count
			}
			population = nextGenPopulation;//update current population
			MSEOfAllBestChromosomesAcrossGenerations.put(generationsCount, fittestChromosomeOfAllGenerations.getFitness());
			generationsCount++;
			//Check if generations criterium was used and fullfilled.
			if(useGenerationCriteria && generationsCount >= maxGenerations)
			{
				break;
			}
		}
		
		System.out.println("Generations used to get to the best result: " + generationsCount + " MSE value: " + fittestChromosomeOfAllGenerations.getFitness());
		
		network.updateWeight(fittestChromosomeOfAllGenerations.getWeightGenes());
		network.setFinalMSEValue(fittestChromosomeOfAllGenerations.getFitness());
		network.setMSEData(MSEOfAllBestChromosomesAcrossGenerations);
		network.setRSquared(calculateRSquared(inputData, isTimeSeriesData, network, activationFunction,isPercentageData));
	}

	private void updateWeightsPeripheralsValues(NetworkConfiguration networkConfiguration) {
		
		double scalingFactor = networkConfiguration.getWeightsScalingFactor();
		double shiftingFactor = networkConfiguration.getWeightsShiftingFactor();
		
		networkWeightsHighestValue = networkWeightsHighestValue * scalingFactor + shiftingFactor;
		networkWeightsLowestValue = networkWeightsLowestValue * scalingFactor + shiftingFactor;		
	}

	private PriorityQueue<Chromosome> crossoverBestChromosomes(
			PriorityQueue<Chromosome> population, Network network, 
			List<Tuple<List<Double>, List<Double>>> inputData, boolean isTimeSeriesData,
			ActivationFunction activationFunction, boolean isPercentageData) {
		
		int populationSize = population.size();
		int elitism = network.getElitism();
		/**
		 * 1. Create a list consisting of the top percent of all chromosomes
		 */
		
		// A list of chromosomes with best fitness value
		List<Chromosome> alphaChromosomes = new ArrayList<Chromosome>();
		
		int numberOfTopChromosomes = (int) (populationSize*network.getCrossoverPercent());
		for( int i=0 ; i < numberOfTopChromosomes ; i++){
			alphaChromosomes.add(population.poll());
		}
		
		/**
		 * 1. Create roulette wheel used for selection. 	
		 */
		double[] fitnessWheelRanges = createRouletteWheel(alphaChromosomes);
		
		/**
		 * 2. Crossover best chromosomes until a new population with a size equal to the original population is created.
		 */
		
		List<Chromosome> offspringChromosomes = new ArrayList<Chromosome>();
				
		do{
			try{
				Chromosome father = alphaChromosomes.get(performRouletteWheelSelection(fitnessWheelRanges));
				Chromosome mother = alphaChromosomes.get(performRouletteWheelSelection(fitnessWheelRanges));
			
				doSingleCrossover(father, mother, offspringChromosomes, network, 
						inputData, isTimeSeriesData, activationFunction, isPercentageData);
			}catch(Exception e){
				//StatusPanel System.out.println("asd");
			}
		}while(offspringChromosomes.size() < populationSize - elitism);
		
		/**
		 * Create next generation Population
		 */
		PriorityQueue<Chromosome> nextGenPopulation = createNextGeneration(populationSize, elitism, 
				alphaChromosomes, offspringChromosomes);
		
		return nextGenPopulation;
	}

	/**
	 * Create a next generation population.
	 *  
	 * Next generation will consist of all offsprings and specified number of best chromosomes
	 * of a previous generation.
	 *  
	 * @param populationSize size of the population.
	 * @param elitism a number of best chromosomes from previous population that will be added to a new population.
	 * @param alphaChromosomes set of best chromosomes.
	 * @param offspringChromosomes set of offsprings.
	 * @return new population consisting of all offsprings of a previous population and elite- best chromosomes.
	 * of previous generation.
	 */
	private PriorityQueue<Chromosome> createNextGeneration(int populationSize,
			int elitism, List<Chromosome> alphaChromosomes,
			List<Chromosome> offspringChromosomes) {
		PriorityQueue<Chromosome> nextGenPopulation = createPriorityQueue(populationSize);
		
		//Add Offsprings
		for(Chromosome nextGenChromosome: offspringChromosomes){
			nextGenPopulation.add(nextGenChromosome);
		}
		
		//Add elite from previous generation
		for(int i=0 ; i< elitism ; i++){
			nextGenPopulation.add(alphaChromosomes.get(i));
		}
		return nextGenPopulation;
	}
	
	/**
	 * Perform Roulette Wheel Selection. This method will "create" roulette wheel by calculating fitness ranges for each chromosome.
	 *
	 * Fitness ranges correspond to parts of a roulette wheel. The bigger the fitness range, the bigger part of a roulette wheel.
	 * Fitness ranges are proportional to chromosomes' fitness values - better fitness value, larger fitness range.
	 * 
	 * A chromosome with the best fitness value will get the biggest part of a roulette wheel hence its chances to be chosen for a 
	 * crossover are highest across all chromosomes.
	 * 
	 * @param alphaChromosomes list of chromosomes with highest fitness values chosen to mate.
	 * @return fitnessWheelRanges a list of fitness ranges for each chromosome.
	 */
	private double[] createRouletteWheel(List<Chromosome> alphaChromosomes){
		
		//This list with hold chromosomes with inverted fitness values used for calculations of a roulette wheel parts.
		List<Chromosome> alphaChromosomesWithInvertedFitnessValues = createChromosomesListCopy(alphaChromosomes);
				
		double highestFitnessValue = getHighestFitnessValue(alphaChromosomesWithInvertedFitnessValues);
				
		//Invert chromosomes fitness values
		invertFitnessValues(alphaChromosomesWithInvertedFitnessValues, highestFitnessValue);
				
		//Calculate Cumulative Fitness used to calculate part of a roulette wheel for each chromosome	
		double cumulativeFitness = calculateCumulativeFitness(alphaChromosomesWithInvertedFitnessValues);
		
		//Calculate a part of the roulette wheel for each chosen chromosome.
		double[] fitnessWheelRanges = calculateFitnessRanges(alphaChromosomesWithInvertedFitnessValues, cumulativeFitness);
		
		return fitnessWheelRanges;
	}
	

	/**
	 * This method executes "starting" a roulette wheel.
	 * We choose a random number and based on previously calculated fitness ranges we determine
	 * a chosen chromosome index value.
	 * 
	 * @param fitnessWheelRanges array with fitness ranges peripheral values.
	 * @return index of a chosen chromosome.
	 */
	private int performRouletteWheelSelection(double[] fitnessWheelRanges) {
		
		int chosenChromosomeIndex = 0;
		double random = Math.random();
		
		for(int index = 0 ; index < fitnessWheelRanges.length ; index++){
			if(random > fitnessWheelRanges[index]){
				chosenChromosomeIndex = index-1;
				break;
			}else if(index+1 == fitnessWheelRanges.length){//Last case
				chosenChromosomeIndex = index;
				break;
			}
		}
		return chosenChromosomeIndex;
	}

	/**
	 * Calculate fitness ranges for each chromosomes. Chromosomes with best fitness (smallest MSE) get biggest fitness ranges.
	 * 
	 * Ranges start from 1 meaning that the first range is between first and second element and is reserved
	 * for a chromosome with best (smallest MSE) fitness.
	 * 
	 * @param alphaChromosomesWithInvertedFitnessValues a list of chromosomes.
	 * @param cumulativeFitness a total of all chromosomes fitness values.
	 * @return array with fitness ranges peripheral values.
	 */
	private double[] calculateFitnessRanges(List<Chromosome> alphaChromosomesWithInvertedFitnessValues, double cumulativeFitness) {
		
		int alphaChromosomesSize = alphaChromosomesWithInvertedFitnessValues.size();
		double[] fitnessWheelRanges = new double[alphaChromosomesSize];
		
		for(int i = 0 ; i < alphaChromosomesSize ; i++){
			double runningFitnessSum = 0;
			for( int k =  alphaChromosomesSize - 1; k >= i ; k--){//Iterate starting from last element
				runningFitnessSum += alphaChromosomesWithInvertedFitnessValues.get(k).getFitness();			
			}
			fitnessWheelRanges[i] = runningFitnessSum/cumulativeFitness;
		}
		return fitnessWheelRanges;
	}

	/**
	 * Create a copy of alpha chromosomes list that can be modified without affecting original list
	 *  
	 * @param alphaChromosomes list of chromosomes sorted based on a fitness value 
	 * in descending order.
	 * @return copy of alphaChromosomes list that can be modified without affecting original list.
	 */
	private List<Chromosome> createChromosomesListCopy( List<Chromosome> alphaChromosomes) {
		
		List<Chromosome> alphaChromosomesWithInvertedFitnessValues = new ArrayList<Chromosome>();
		
		for(Chromosome chromosomeToBeCopied : alphaChromosomes){
			alphaChromosomesWithInvertedFitnessValues.add(new Chromosome(chromosomeToBeCopied));
		}
		return alphaChromosomesWithInvertedFitnessValues;
	}

	/**
	 * Inverts fitness values of all chromosomes so that chromosomes with smallest MSE (fitness measure) have highest
	 * fitness values. As a result they will get a bigger roulette wheel part.
	 * 
	 * @param alphaChromosomesWithInvertedFitnessValues a list of chromosomes sorted based on a fitness value 
	 * in ascending order.
	 * @param highestFitnessValue highest fitness value of all chromosomes used to invert other fitness values.
	 */
	private void invertFitnessValues(List<Chromosome> alphaChromosomesWithInvertedFitnessValues, double highestFitnessValue) {
		
		for(Chromosome chromosome : alphaChromosomesWithInvertedFitnessValues){
			chromosome.setFitness(highestFitnessValue - chromosome.getFitness());
		}
	}

	/**
	 * Calculate cumulative fitness value of all chromosomes.
	 *  
	 * @param alphaChromosomesWithInvertedFitnessValues a list of chromosomes sorted based on a fitness value 
	 * in ascending order.
	 * @return cumulative fitness value of all chromosomes.
	 */
	private double calculateCumulativeFitness(List<Chromosome> alphaChromosomesWithInvertedFitnessValues) {
		
		double cumulativeFitness = 0;
		
		for(Chromosome chromosome : alphaChromosomesWithInvertedFitnessValues){
			cumulativeFitness += chromosome.getFitness();
		}
		return cumulativeFitness;
	}

	/**
	 * Returns highest fitness value of all chromosomes increased by a roulette wheel constant.
	 * 
	 * All chromosomes are sorted based on fitness in ascending order hence last chromosome will have
	 * higest fitness value.
	 * 
	 * @param alphaChromosomesWithInvertedFitnessValues a list of chromosomes sorted based on a fitness value 
	 * in ascending order.
	 * @return highest fitness value of all chromosomes.
	 */
	private double getHighestFitnessValue( List<Chromosome> alphaChromosomesWithInvertedFitnessValues) {
			
		return alphaChromosomesWithInvertedFitnessValues.
				get(alphaChromosomesWithInvertedFitnessValues.size() - 1).getFitness() + ROULETTE_WHEEL_CONSTANT;
	}

	/**
	 *  Perform single crossover using two parent chromosomes. This method will calculate two crossover cut points which will result in 3 pieces 
	 *  of genetic material that will be used to create two offspring chromosomes:
	 *  
	 *  Father:      fffff|fffff|fffff
	 *  Mother:      mmmmm|mmmmm|mmmmm
	 *  
	 *  Offspring1:  fffff|mmmmm|fffff
	 *  Offspring2:  mmmmm|fffff|mmmmm 
	 *  
	 * 
	 * @param father parent chromosome chosen to mate.
	 * @param mother parent chromosome chosen to mate.
	 * @param offspringChromosomes a list of all offspring chromosomes.
	 * @param network neural network with the same structure as all neural networks represented by chromosomes.
	 * @param inputData
	 * @param isTimeSeriesData
	 * @throws TrainingException
	 * @throws NeuralNetworkException 
	 */
	private void doSingleCrossover(Chromosome father, Chromosome mother,
			List<Chromosome> offspringChromosomes, Network network,
			List<Tuple<List<Double>, List<Double>>> inputData, boolean isTimeSeriesData,
			ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException, NeuralNetworkException {
		
		List<Double> fatherGenes = father.getWeightGenes();
		List<Double> motherGenes = mother.getWeightGenes();
		int numberOfGenesInChromosome = fatherGenes.size();
		double crossoverCutLength = network.getCrossoverCutLength();
		int distanceBetweenCuts = (int) (numberOfGenesInChromosome*crossoverCutLength);
		
		if(distanceBetweenCuts < 1){
			distanceBetweenCuts = 1; //When crossoverCutLength is too small
		}
		
		int firstCutPoint = (int) (Math.random() * (numberOfGenesInChromosome - distanceBetweenCuts));
		
		int secondCutPoint = firstCutPoint + distanceBetweenCuts;
		
		/**
		 * First offspring is build as follows:
		 * Father (between list's start and firstCutPoint) + Mother (between firstCutPoint and secondCutPoint) + Father(between secondCutPoint and list's end).
		 */
		List<Double> firstOffspring = new ArrayList<Double>();
		firstOffspring.addAll(fatherGenes.subList(0, firstCutPoint));
		firstOffspring.addAll(motherGenes.subList(firstCutPoint, secondCutPoint));
		firstOffspring.addAll(fatherGenes.subList(secondCutPoint, numberOfGenesInChromosome));
		
		/**
		 * Second offspring is build as follows:
		 * Mother (between list's start and firstCutPoint) + Father (between firstCutPoint and secondCutPoint) + Mother(between secondCutPoint and list's end).
		 */
		List<Double> secondOffspring = new ArrayList<Double>();
		secondOffspring.addAll(motherGenes.subList(0, firstCutPoint));
		secondOffspring.addAll(fatherGenes.subList(firstCutPoint, secondCutPoint));
		secondOffspring.addAll(motherGenes.subList(secondCutPoint, numberOfGenesInChromosome));
		
		/**
		 * Mutate offsprings if needed
		 */
		
		double mutationPercent = network.getMutationPercent();
		
		Random random = new Random();
	
		mutateOffspring(firstOffspring, mutationPercent, random);
		mutateOffspring(secondOffspring, mutationPercent, random);
		
		
		/**
		 * Convert offsprings to chromosomes
		 */
		
		offspringChromosomes.add(convertToChromosome(firstOffspring, network, inputData, isTimeSeriesData, activationFunction, isPercentageData));
		offspringChromosomes.add(convertToChromosome(secondOffspring, network,  inputData, isTimeSeriesData, activationFunction, isPercentageData));
				
	}

	/**
	 * Mutate a percentage of all chromosomes chosen to mate.
	 * 
	 * @param offspring list of neural network weights to be mutated.
	 * @param mutationPercent percentage of all chromosomes chosen to mate that will be mutated.
	 * @param random random numbers generator.
	 */
	private void mutateOffspring(List<Double> offspring, double mutationPercent, Random random) {
		
		if (Math.random() < mutationPercent) {
			mutateUsingGaussianOperator(offspring, random);
		}
	}

	/**
	 * Mutates each gene using Gaussian operator.
	 * 
	 * @param offspring list of neural network weights to be mutated.
	 * @param random random numbers generator.
	 */
	private void mutateUsingGaussianOperator(List<Double> offspring, Random random) {
		
		for(int i=0 ; i < offspring.size() ; i++){
			
			//Java generates normally (gaussian) distributed values with mean 0 and standard deviation 1.
			//Through a number of tests we concluded that this standard deviation is too big and
			//standard deviation 0.1 yields better results. Hence we scale this number by 0.1
			double randomGaussianNumber = random.nextGaussian()*0.1;
			
			double mutatedGeneValue = randomGaussianNumber + offspring.get(i);
			
			//Clip gene's new value if it falls outside predefined ranges
			if(mutatedGeneValue > networkWeightsHighestValue){
				mutatedGeneValue = networkWeightsHighestValue;
			}else if(mutatedGeneValue < networkWeightsLowestValue){
				mutatedGeneValue = networkWeightsLowestValue;
			}			
			offspring.set(i, mutatedGeneValue);
			}
	}

	/**
	 * This method converts a list of weights to a neural network with the same structure
	 * as ancestor neural network.
	 * 
	 * @param offspring list of neural network weights.
	 * @param ancestorNetwork ancestor neural network (from previous generation). 
	 * @param inputData training dataset.
	 * @param isTimeSeriesData flag denoting type of input data. Due to the structure of data, time series data must
	 * be processed differently than other data.
	 * @return chromosome representing a single neural network.
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	private Chromosome convertToChromosome(List<Double> offspring, Network ancestorNetwork,
			List<Tuple<List<Double>, List<Double>>> inputData, boolean isTimeSeriesData, 
			ActivationFunction activationFunction,boolean isPercentageData) throws TrainingException, NeuralNetworkException {
		
		/**
		 * Create a neural network with offspring's weights values 
		 */
		Network network = createNetworkCopy(ancestorNetwork);
		network.updateWeight(offspring);
		
		Chromosome offspringChromosome = Chromosome.convertToChromosome(offspring, network);
		offspringChromosome.setFitness(calculateFitness(inputData, isTimeSeriesData, network, activationFunction, isPercentageData));
		
		return offspringChromosome;
	}

	/**
	 * Create initial population of chromosomes with size defined by a user.
	 * 
	 * @param ancestorNetwork
	 * @param inputData training dataset.
	 * @param isTimeSeriesData
	 * @return initial population of chromosomes.
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	private PriorityQueue<Chromosome> createPopulation(Network ancestorNetwork, List<Tuple<List<Double>, List<Double>>> inputData,
			boolean isTimeSeriesData, ActivationFunction activationFunction, boolean isPercentageData) throws TrainingException, NeuralNetworkException {
		
		PriorityQueue<Chromosome> population = createPriorityQueue(ancestorNetwork.getPopulationSize());
		
		for( int i=0 ; i < ancestorNetwork.getPopulationSize() ; i++){
			
			Network network = createNetworkCopy(ancestorNetwork);
						
			Chromosome chromosome = new Chromosome(network);
			chromosome.setFitness(calculateFitness(inputData, isTimeSeriesData, network, activationFunction, isPercentageData));
			population.add(chromosome);
		}
		
		return population;
	}

	/**
	 * Creates a priority queue for storing chromosomes based on their fitness value in a descending order.
	 * 
	 * @param populationSize number of chromosomes in a population.
	 * @return Priority queue with comparator based on fitness value.
	 */
	private PriorityQueue<Chromosome> createPriorityQueue(int populationSize) {
		
		Comparator<Chromosome> comparator = new FitnessComparator();
		
		PriorityQueue<Chromosome> population = new PriorityQueue<Chromosome>(populationSize, comparator);
		return population;
	}

	/**
	 * Create a neural network with the same configuration as the ancestor neural network.
	 * 
	 * @param ancestorNetwork
	 * @return neural network with the same morphology as neural network used as a parameter.
	 */
	private Network createNetworkCopy(Network ancestorNetwork) {
		
		Network network = null;
		
		if(ancestorNetwork instanceof CTRNeuralNetwork){
			network = new CTRNeuralNetwork();
		}else{
			network = new Network();
		}
		
		network.initializeNetwork(ancestorNetwork.getNetworkConfiguration(), ancestorNetwork.getDatasetName());
		return network;
	}

	/**
	 * Calculate MSE of a single neural network which will be used as a fitness measure.
	 * 
	 * @param inputData training dataset.
	 * @param isTimeSeriesData flag denoting type of input data. Due to the structure of data, time series data must
	 * be processed differently than other data.
	 * @param network neural network .
	 * @return Mean Squared Error value of a particular neural network.
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	private double calculateFitness( List<Tuple<List<Double>, List<Double>>> inputData, 
			boolean isTimeSeriesData, Network network, ActivationFunction activationFunction, boolean isPercentageData)
			throws TrainingException, NeuralNetworkException {
		
		List<Tuple<List<Double>, List<Double>>> outputs = calculateOutputs(network, inputData, 1, 
				isTimeSeriesData, true, true, activationFunction, isPercentageData);
		return StatisticalUtils.calculateMeanSquaredError(outputs);
	}
	
	/**
	 * Calculates R squared value for a single neural network.
	 * 
	 * @param inputData training dataset.
	 * @param isTimeSeriesData flag denoting type of input data. Due to the structure of data, time series data must
	 * be processed differently than other data.
	 * @param network neural network .
	 * @return R squared value of a particular neural network.
	 * @throws TrainingException 
	 * @throws NeuralNetworkException 
	 */
	private double calculateRSquared( List<Tuple<List<Double>, List<Double>>> inputData,
			boolean isTimeSeriesData, Network network, ActivationFunction activationFunction, boolean isPercentageData)
				throws TrainingException, NeuralNetworkException {
		
		List<Tuple<List<Double>, List<Double>>> outputs = calculateOutputs(network, inputData, 1, 
				isTimeSeriesData, true, true, activationFunction, isPercentageData);
		
		if( ! isPercentageData){
			//Create a copy of outputs so it can be denormalized without affecting original list
			List<Tuple<List<Double>, List<Double>>> copiedOutputs = ListUtils.createListCopy(outputs);
			DataUtils.denormalizeData(copiedOutputs);
			
			return StatisticalUtils.calculateCoefficientOfDetermination(copiedOutputs);
		}else{
			return StatisticalUtils.calculateCoefficientOfDetermination(outputs);
		}
	}
	
	@Override
	public List<Double> train(Network network,List<Double> timeboxedInputData, List<Double> timeboxedOutputData,
			int epochNumber, boolean isEvaluationMode, ActivationFunction activationFunction,
			boolean isPercentageData) throws TrainingException, NeuralNetworkException {
		
		if(network instanceof CTRNeuralNetwork){
			CTRNeuralNetwork cTRNNetwork = (CTRNeuralNetwork) network;
			Chromosome chromosome = new Chromosome(network);
			try{
				cTRNNetwork.init(chromosome.getWeightGenes());
			}catch(Exception exception){
				throw new NeuralNetworkException("Failed to initialize CTRNN due to error:" + exception.getMessage());
			}
			
			List<Double> outputs = null;
			try{
				outputs = cTRNNetwork.step(timeboxedInputData, timeboxedInputData.size());
			}catch(Exception e){
				throw new NeuralNetworkException("Failed to evaluate CTRNN due to error:" + e.getMessage());
			}
			
			return outputs;
		}else{
			calculateOutputNeuronsValues(timeboxedInputData, network, activationFunction);
			return getOutputNeuronsOutputValues(network.getLayers()[NetworkConstants.OUTPUT_LAYER_INDEX].getNeurons());
		}
	}
}
