package neuralnetwork;

import java.io.Serializable;

import business.NetworkConstants;

public class Neuron implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	protected static final String SYNAPSE_NAME_DELIMITER = "->";
	private static final String LAYER = "Layer";
	private static final String NEURON = "Neuron";
	private static final String DELIMITER = "|";

	protected double outputValue;
	protected Synapse synapses[];
	protected double delta;
	protected String name;

	public Neuron(int numberOfOutgoingWeights, int layerNumber, int neuronNumber, String specialNeuronName) {
		
		delta = 0;
		name = this.buildNeuronName(layerNumber, neuronNumber, specialNeuronName);
		setOutputValue(outputValue);
		synapses = new Synapse[numberOfOutgoingWeights];
	}
	
	public Neuron(int numberOfOutgoingWeights, int outputValue,
			int layerNumber, int neuronNumber, String specialNeuronName,
			double weightsScaleFactor, double weightsShiftFactor) {
		
		delta = 0;
		name = this.buildNeuronName(layerNumber, neuronNumber, specialNeuronName);
		setOutputValue(outputValue);
		synapses = new Synapse[numberOfOutgoingWeights];
		
		for( int i = 0 ; i < numberOfOutgoingWeights ; i++){
			synapses[i] = new Synapse();
			synapses[i].setWeight((Math.random() * weightsScaleFactor) 
					+ weightsShiftFactor);
			synapses[i].setFrom(name);
			String targetNeuronName = this.buildNeuronName(layerNumber+1, i, "");
			synapses[i].setTo(targetNeuronName);
			synapses[i].setName(name + SYNAPSE_NAME_DELIMITER + targetNeuronName);
		}	
	}

	public void updateWeight(int weightGoalNeuronIndex, double increment) {
		
		System.out.println( "\n" + this.getName() + ": Added " + increment +
				" to the current weight " + this.synapses[weightGoalNeuronIndex].getWeight()
				+ " for weight " + weightGoalNeuronIndex);
		
		this.synapses[weightGoalNeuronIndex].setWeight(this.synapses[weightGoalNeuronIndex].getWeight() + increment);
		
		System.out.println( this.getName() + ": Current weight value is "
				+ this.synapses[weightGoalNeuronIndex].getWeight());
		
	}
	
	public String buildNeuronName(int layerNumber, int neuronNumber, String specialNeuronName){
		
		return LAYER + layerNumber + DELIMITER + NEURON + neuronNumber + specialNeuronName;
	}
	
	public void setOutputValue(double outputValue) {
		this.outputValue = outputValue;
	}

	public double getOutputValue() {
		return outputValue;
	}
	
	public double getDelta() {
		return delta;
	}

	public void setDelta(double delta) {
		this.delta = delta;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Synapse[] getSynapses() {
		return synapses;
	}

	public void setSynapses(Synapse[] synapses) {
		this.synapses = synapses;
	}
}
