package ga;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import utils.NumberUtils;

import business.NetworkConstants;

import neuralnetwork.CTRLayer;
import neuralnetwork.CTRNeuralNetwork;
import neuralnetwork.CTRNeuron;
import neuralnetwork.Layer;
import neuralnetwork.Network;
import neuralnetwork.Neuron;
import neuralnetwork.Synapse;

public class Chromosome {

	private double fitness;
	private List<Double> weightGenes;
	
	/**
	 * Creates a copy of a chromosoem
	 * @param chromosome is a chromosome to be copied
	 */
	public Chromosome(Chromosome chromosome){
		
		this.fitness = chromosome.getFitness();
		this.weightGenes = chromosome.getWeightGenes();
	}
	
	/**
	 * Create a chromosome based on ANN.
	 * 
	 * Chromosome's genes are weights values between all neurons.
	 * 
	 * @param network ANN.
	 */
	public Chromosome(Network network){
		
		this.weightGenes = new ArrayList<Double>();
		this.fitness = 0;
		
		if(network instanceof CTRNeuralNetwork){
			convertCTRNNToChromosome((CTRNeuralNetwork)network);
		}else{
			for(Layer layer: network.getLayers()){
				for(Neuron neuron: layer.getNeurons()){
					for(Synapse synapse : neuron.getSynapses()){
					weightGenes.add(synapse.getWeight());
					}
				}
			}
		}
	}
	
	/**
	 * Create a chromosome based on a CTRNN.
	 * 
	 * Chromosome's genes are structured as follows:
	 * 
	 * INPUT BIAS, INPUT GAIN, INPUT TO HIDDEN WEIGHTS, 
     * FOR EACH HIDDEN NEURON: 
     * HIDDEN TO OUTPUT WEIGHTS, TAU, BIAS, HIDDEN TO HIDDEN WEIGHTS
     * OUTPUT BIAS 
	 * 
	 * @param network CTRNN.
	 */
	public void convertCTRNNToChromosome(CTRNeuralNetwork network){
		
		CTRLayer[] layers = network.getLayers();	
		List<CTRNeuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getCTRNeurons();// Input Layer
		List<CTRNeuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getCTRNeurons();//Hidden Layer
		List<CTRNeuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getCTRNeurons();//Output Layer
		
		//Input Bias - it is the same for all input neurons hence 0.
		weightGenes.add(NumberUtils.convertBigDecimalToDouble(inputNeurons.get(0).getBias()));
		
		//Input Gain - it is the same for all input neurons hence 0.
		weightGenes.add(NumberUtils.convertBigDecimalToDouble(network.getSensorsGain()[0]));
		
		//Input to Hidden weights
		for(CTRNeuron inputNeuron : inputNeurons){
				for(Synapse synapse : inputNeuron.getSynapses()){
					weightGenes.add(synapse.getWeight());
				}
			}
	
		//Hidden Layer
		for(CTRNeuron hiddenNeuron : hiddenNeurons){
			//Weights between hidden neuron and output layer
			for(Synapse synapse : hiddenNeuron.getSynapses()){
				weightGenes.add(synapse.getWeight());
			}
			//TAU
			weightGenes.add(NumberUtils.convertBigDecimalToDouble(hiddenNeuron.getTau()));
			weightGenes.add(NumberUtils.convertBigDecimalToDouble(hiddenNeuron.getBias()));
			//Weights between hidden neuron and other hidden neurons (including itself)
			for(Synapse synapse : hiddenNeuron.getIngoingSynapses()){
				weightGenes.add(synapse.getWeight());
			}
		}
		
		//Output Bias - there is always one output neuron hence 0.
		weightGenes.add(NumberUtils.convertBigDecimalToDouble(outputNeurons.get(0).getBias()));	
	}
	
	public static Chromosome convertToChromosome(List<Double> weights,Network network) {
		
		Chromosome offspring = new Chromosome(network);
		offspring.setWeightGenes(weights);
		
		return offspring;
	}

	public double getFitness() {
		return fitness;
	}

	public void setFitness(double fitness) {
		this.fitness = fitness;
	}

	public List<Double> getWeightGenes() {
		return weightGenes;
	}

	public void setWeightGenes(List<Double> weightGenes) {
		this.weightGenes = weightGenes;
	}
}
