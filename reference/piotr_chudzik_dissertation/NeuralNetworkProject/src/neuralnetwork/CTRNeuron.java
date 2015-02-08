package neuralnetwork;

import java.math.BigDecimal;

public class CTRNeuron extends Neuron{
	
	private static final long serialVersionUID = 1L;
	private BigDecimal tau;
	private BigDecimal bias;
	private BigDecimal state;
	private BigDecimal s;
//	private double gain;
	/**
	 * Synapses between neurons within the same layer.
	 */
	private Synapse ingoingSynapses[];

	public CTRNeuron(int numberOfOutgoingWeights, int outputValue,
			int layerNumber, int neuronNumber, String specialNeuronName, int numberOfNeuronsInCurrentLayer,
			 double weightsScaleFactor, double weightsShiftFactor) {
		super(numberOfOutgoingWeights, outputValue, layerNumber, neuronNumber, specialNeuronName, 
				weightsScaleFactor, weightsShiftFactor);
		
		this.tau = new BigDecimal(1);
		this.bias = new BigDecimal(1);
		this.state = new BigDecimal(1);
		this.s = new BigDecimal(1);
		
		if(layerNumber == 1){//Only hidden layer has in going synapses
			this.ingoingSynapses = new Synapse[numberOfNeuronsInCurrentLayer];
			for( int i = 0 ; i < numberOfNeuronsInCurrentLayer ; i++){
				this.ingoingSynapses[i] = new Synapse();
				this.ingoingSynapses[i].setWeight((Math.random() * weightsScaleFactor)+ weightsShiftFactor);
				this.ingoingSynapses[i].setFrom(name);
				String targetNeuronName = this.buildNeuronName(layerNumber, i, "");
				this.ingoingSynapses[i].setTo(targetNeuronName);
				this.ingoingSynapses[i].setName(name + SYNAPSE_NAME_DELIMITER + targetNeuronName);				
			}
		}else{
			this.ingoingSynapses = null;
		}
	}

	public BigDecimal getTau() {
		return tau;
	}

	public void setTau(BigDecimal tau) {
		this.tau = tau;
	}

	public BigDecimal getBias() {
		return bias;
	}

	public void setBias(BigDecimal bias) {
		this.bias = bias;
	}

	public Synapse[] getIngoingSynapses() {
		return ingoingSynapses;
	}

	public void setIngoingSynapses(Synapse[] ingoingSynapses) {
		this.ingoingSynapses = ingoingSynapses;
	}

	public BigDecimal getState() {
		return state;
	}

	public void setState(BigDecimal state) {
		this.state = state;
	}

	public BigDecimal getS() {
		return s;
	}

	public void setS(BigDecimal s) {
		this.s = s;
	}

//	public double getGain() {
//		return gain;
//	}
//
//	public void setGain(double gain) {
//		this.gain = gain;
//	}
	
//	public Neuron(int numberOfOutgoingWeights, int outputValue,
//			int layerNumber, int neuronNumber, String specialNeuronName,
//			double weightsScaleFactor, double weightsShiftFactor) {
//		
//		delta = 0;
//		name = NeuronUtils.buildNeuronName(layerNumber, neuronNumber, specialNeuronName);
//		setOutputValue(outputValue);
//		synapses = new Synapse[numberOfOutgoingWeights];
//		
//		for( int i = 0 ; i < numberOfOutgoingWeights ; i++){
//			synapses[i] = new Synapse();
//			synapses[i].setWeight((Math.random() * weightsScaleFactor) 
//					+ weightsShiftFactor);
//			//synapses[i].setWeight((Math.random()));
//			//synapses[i].setWeight(0.9);//Test
//			synapses[i].setFrom(name);
//			String targetNeuronName = NeuronUtils.buildNeuronName(layerNumber+1, i, "");
//			synapses[i].setTo(targetNeuronName);
//			synapses[i].setName(name + SYNAPSE_NAME_DELIMITER + targetNeuronName);
//		}	
//	}

}
