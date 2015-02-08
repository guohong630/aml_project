package neuralnetwork;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import utils.NumberUtils;

import exception.NeuralNetworkException;

import activation.SigmoidFunction;
import business.NetworkConstants;

public class CTRNeuralNetwork extends Network{

	private static final long serialVersionUID = 1L;

	private BigDecimal deltaT;
	  
	  private double  low_bound_inputWts      = -8;
	  private double  upper_bound_inputWts    = 8;
	  private double low_bound_inputBias     = -5;
	  private double  upper_bound_inputBias   = 5;
	  
	  private double  low_bound_hiddenWts     = -8;
	  private double upper_bound_hiddenWts   = 8;
	  
	  private double low_bound_hiddenTau     = 1;
	  private double  upper_bound_hiddenTau   = 1;
	  
	  private double low_bound_hiddenBias    = -5;
	  private double  upper_bound_hiddenBias  = 5;
	  
	  private double low_bound_outputBias    = -5;
	  private double upper_bound_outputBias  = 5;
	  
	  private double low_bound_sensorsGain   = 0;
	  private double upper_bound_sensorsGain = 1;
	  
	  private BigDecimal[] sensorsGain;
	  
	  private MathContext mathContext;
	
	  /**
	 * Network Morphology.
	 */
	protected CTRLayer[] layers;	
	
	@Override
	public void initializeNetwork(NetworkConfiguration configuration, String datasetName){
		
		deltaT = new BigDecimal(1);
		synapseWeights = new HashMap<String, Map<Integer,Double>>();
		MSEData =  new HashMap<Integer, Double>();
		minimumAbsoluteError = 0;
		maximumAbsoluteError = 0;
		this.datasetName = datasetName;
		this.networkConfiguration = configuration;
		
		mathContext = new MathContext(50, RoundingMode.HALF_UP);
		
		int numberOfLayers = configuration.getNumberOfLayers();
		layers = new CTRLayer[numberOfLayers];
		
		sensorsGain = new BigDecimal[configuration.getNumberOfInputNeurons()];
		for( int i=0 ; i < sensorsGain.length ; i++){
			sensorsGain[i] = new BigDecimal(1);
		}
		
		double weightsScalingFactor = configuration.getWeightsScalingFactor();
		double weightsShiftingFactor = configuration.getWeightsShiftingFactor();
				
		for( int i = 0 ; i < numberOfLayers ; i++ ){
			
			if( i+1 == numberOfLayers ){//Output Layer
				layers[i] = new CTRLayer(configuration.getNumberOfOutputNeurons(), 0, i, weightsScalingFactor, weightsShiftingFactor);
			}else if (i == 0){//Number of outgoing connections is equal to number of neurons in the next layer
				layers[i] = new CTRLayer(configuration.getNumberOfInputNeurons(),
						configuration.getNumberOfHiddenNeurons(), i,  weightsScalingFactor, weightsShiftingFactor);
			}else{//Hidden Layer
				layers[i] = new CTRLayer(configuration.getNumberOfHiddenNeurons(),
						configuration.getNumberOfOutputNeurons(), i,  weightsScalingFactor, weightsShiftingFactor); 
			}
		}
	}

	public int calculateGenotypeLength(NetworkConfiguration configuration) {
		
		int genotypeLength = 0;
		int numberOfInputNeurons = configuration.getNumberOfInputNeurons();
		int numberOfHiddenNeurons = configuration.getNumberOfHiddenNeurons();
		int numberOfOutputNeurons = configuration.getNumberOfOutputNeurons();
		
		// weights input-hidden
		for (int i = 0; i < numberOfInputNeurons; i++)
			for (int h = 0; h < numberOfHiddenNeurons; h++)
				genotypeLength++;

		// weights hidden-hidden
		for (int h = 0; h < numberOfHiddenNeurons; h++)
			for (int hh = 0; hh < numberOfHiddenNeurons; hh++)
				genotypeLength++;

		// weights hidden-output
		for (int h = 0; h < numberOfHiddenNeurons; h++)
			for (int o = 0; o < numberOfOutputNeurons; o++)
				genotypeLength++;

		// tau - it only applies to hidden nodes
		for (int h = 0; h < numberOfHiddenNeurons; h++)
			genotypeLength++;

		// bias - it applies to hidden nodes plus a single bias for all input
		// nodes, and a single bias for all output nodes
		for (int h = 0; h < numberOfHiddenNeurons + 2; h++)
			genotypeLength++;

		// sensor gain - there is only one single gain for all input nodes
		genotypeLength++;
		
		return genotypeLength;
	}
	
	public void init(List<Double> genotypeInput) throws NeuralNetworkException {

		int counter = 0;
		BigDecimal singleTau = new BigDecimal(0);
		BigDecimal singleGain = new BigDecimal(0);
		BigDecimal singleBias = new BigDecimal(0);

		NetworkConfiguration networkConfiguration = this.getNetworkConfiguration();

		int genotypeLength = calculateGenotypeLength(networkConfiguration);

		int numberOfInputNeurons = networkConfiguration.getNumberOfInputNeurons();
		int numberOfHiddenNeurons = networkConfiguration.getNumberOfHiddenNeurons();
		int numberOfOutputNeurons = networkConfiguration.getNumberOfOutputNeurons();

		CTRLayer[] layers = this.getLayers();	
		List<CTRNeuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getCTRNeurons();// Input Layer
		List<CTRNeuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getCTRNeurons();//Hidden Layer
		List<CTRNeuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getCTRNeurons();//Output Layer
		
		List<BigDecimal> genotype = NumberUtils.convertListOfDoublesToBigDecimals(genotypeInput);
		
		System.out.println("Initializing Input Layer of CTRNN...");
		
		/**
		 * INPUT LAYER
		 */
		// SINGLE TAU EQUAL TO deltaT
		singleTau = deltaT;
		// SINGLE BIAS FOR ALL INPUT
		singleBias = genotype.get(counter++).multiply(new BigDecimal((upper_bound_inputBias - low_bound_inputBias) + low_bound_inputBias), mathContext);
		// SINGLE GAIN FOR ALL INPUT
		singleGain = genotype.get(counter++).multiply(new BigDecimal((upper_bound_sensorsGain - low_bound_sensorsGain) + low_bound_sensorsGain), mathContext);
		for (int i = 0; i < numberOfInputNeurons; i++) {
			for (int j = 0; j < numberOfHiddenNeurons; j++) {
				inputNeurons.get(i).getSynapses()[j].setWeight(NumberUtils.convertBigDecimalToDouble(genotype.get(counter++)
						.multiply(new BigDecimal((upper_bound_inputWts - low_bound_inputWts)+ low_bound_inputWts), mathContext)));//Weights between input and hidden layer
				inputNeurons.get(i).setTau(singleTau);
				inputNeurons.get(i).setBias(singleBias);
				sensorsGain[i] = singleGain;
			}
		}
		
//		//SINGLE TAU EQUAL TO DELTA_T
//		  single_tau = delta_t;
//		  // SINGLE BIAS FOR ALL INPUT
//		  single_bias = genotype.get()[counter++]*(upper_bound_inputBias - low_bound_inputBias) + low_bound_inputBias;
//		  //SINGLE GAIN FOR ALL INPUT
//		  single_gain = genes[counter++] * (upper_bound_sensorsGain - low_bound_sensorsGain) + low_bound_sensorsGain;
//		  for( int i=0; i<num_input; i++){
//		    for(int j=0; j< num_hidden ; j++)
//		      inputLayer[i].weightsOut[j] = genes[counter++]*(upper_bound_inputWts - low_bound_inputWts) + low_bound_inputWts;
//		    inputLayer[i].tau          = single_tau;
//		    inputLayer[i].bias         = single_bias;
//		    sensorsGain[i]             = single_gain;
//		  }

		System.out.println("Initializing Hidden Layer of CTRNN...");
		/**
		 * HIDDEN LAYER
		 */

		for (int i = 0; i < numberOfHiddenNeurons; i++) {
			for (int j = 0; j < numberOfOutputNeurons; j++) {
				System.out.println("Initializing hidden weight" + i);
				hiddenNeurons.get(i).getSynapses()[j].setWeight(NumberUtils.convertBigDecimalToDouble(genotype.get(counter).multiply(new BigDecimal((upper_bound_hiddenWts - low_bound_hiddenWts)
						+ low_bound_hiddenWts), mathContext)));//Weights between hidden and output layer
				counter++;
			}
			BigDecimal factor = new BigDecimal(upper_bound_hiddenTau).multiply(genotype.get(counter++), mathContext);
			double result = NumberUtils.convertBigDecimalToDouble(( new BigDecimal(low_bound_hiddenTau)).add(factor));
			double power = NumberUtils.capDoubleValue(Math.pow(10,result));
			System.out.println("Initializing hidden tau, factor:" + factor.doubleValue() + " result" + result + " power:" + power);
			
			hiddenNeurons.get(i).setTau(new BigDecimal(NumberUtils.capDoubleValue(Math.pow(10, 
					NumberUtils.convertBigDecimalToDouble(( new BigDecimal(low_bound_hiddenTau)).add(factor))))));
			//  hiddenLayer[i].tau         = pow(10, (low_bound_hiddenTau + (upper_bound_hiddenTau * genes[counter++]) ));
			System.out.println("Initializing hidden bias");
			hiddenNeurons.get(i).setBias(genotype.get(counter++).multiply(new BigDecimal((upper_bound_hiddenBias - low_bound_hiddenBias)
							+ low_bound_hiddenBias), mathContext));

			for (int j = 0; j < numberOfHiddenNeurons; j++) {
				System.out.println("Initializing hidden ingoing weight" + j);
				hiddenNeurons.get(i).getIngoingSynapses()[j].setWeight(NumberUtils.convertBigDecimalToDouble(genotype.get(counter++)
						.multiply(new BigDecimal((upper_bound_hiddenWts - low_bound_hiddenWts)
								+ low_bound_hiddenWts), mathContext)));
			}
		}
		
//		for( int i=0; i<num_hidden; i++){
//		    for(int j=0; j<num_output; j++){
//		      hiddenLayer[i].weightsOut[j] = genes[counter]*(upper_bound_hiddenWts - low_bound_hiddenWts) + low_bound_hiddenWts;
//		      counter++;
//		    }
//		    hiddenLayer[i].tau         = pow(10, (low_bound_hiddenTau + (upper_bound_hiddenTau * genes[counter++]) ));
//		    hiddenLayer[i].bias        = genes[counter++]*(upper_bound_hiddenBias - low_bound_hiddenBias) + low_bound_hiddenBias;
//		    for( int j=0; j<num_hidden; j++)
//		      hiddenLayer[i].weightsSelf[j] = genes[counter++]*(upper_bound_hiddenWts - low_bound_hiddenWts) + low_bound_hiddenWts;
//		  }

		System.out.println("Initializing Output Layer of CTRNN...");
		/**
		 * OUTPUT LAYER
		 */

		// SINGLE TAU EQUAL TO deltaT
		singleTau = deltaT;
		// SINGLE BIAS FOR ALL OUTPUT
		singleBias = genotype.get(counter++).multiply(new BigDecimal((upper_bound_outputBias - low_bound_outputBias)
				+ low_bound_outputBias), mathContext);
		for (int i = 0; i < numberOfOutputNeurons; i++) {
			outputNeurons.get(i).setTau(singleTau);
			outputNeurons.get(i).setBias(singleBias);
		}
		
//		 //SINGLE TAU EQUAL TO DELTA_T
//		  single_tau           = delta_t;
//		  // SINGLE BIAS FOR ALL OUTPUT
//		  single_bias = genes[counter++]*(upper_bound_outputBias - low_bound_outputBias) + low_bound_outputBias;
//		  for(int i=0; i<num_output; i++){
//		    outputLayer[i].tau  =  single_tau;
//		    outputLayer[i].bias =  single_bias;
//		  }
		  

		if (counter != genotypeLength) {
			throw new NeuralNetworkException(" The number of genes is incorrect. Expected: " + genotypeLength + " ,Actual: counter");
		}
	}
	
	public List <Double> step (List<Double> inputs , int numIn){
		
		CTRLayer[] layers = this.getLayers();
		NetworkConfiguration configuration = this.getNetworkConfiguration();
		List<Double> actualOutputs = new ArrayList<Double>();
		
		List<CTRNeuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getCTRNeurons();// Input Layer
		List<CTRNeuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getCTRNeurons();//Hidden Layer
		List<CTRNeuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getCTRNeurons();//Output Layer
		
		List<BigDecimal> convertedInputs = NumberUtils.convertListOfDoublesToBigDecimals(inputs); 
		
		  for( int i=0; i < configuration.getNumberOfInputNeurons(); i++) {
		   	BigDecimal previousS = inputNeurons.get(i).getState().negate();
		    inputNeurons.get(i).setS(previousS.add(sensorsGain[i].multiply(convertedInputs.get(i), mathContext)));

		    inputNeurons.get(i).setState(inputNeurons.get(i).getState().add(inputNeurons.get(i).getS()));
		  } 
		  
		  updateHiddenLayer(inputNeurons, hiddenNeurons);
		  updateOutputLayerFromHidden(hiddenNeurons, outputNeurons);
//		  update_hidden_layer();
//		  update_output_layer_from_hidden( );
		  /* here we set the actuators state */
		  //for( int i = 0; i < numOut; i++ ){
		    //outputs[i] = 1.0/( 1.0 + exp( -(outputLayer[i].state + outputLayer[i].bias ) ) );
		 // }
		  
		//There is always one output value because there is always one output neuron
		 for(CTRNeuron outputNeuron : outputNeurons){
			// double number = 1.0/( 1.0 + Math.exp( -(outputNeuron.getState().add(outputNeuron.getBias()) ) ));
			
			 actualOutputs.add(SigmoidFunction.getInstance().activateFunction(
					 NumberUtils.convertBigDecimalToDouble(outputNeuron.getState().add(outputNeuron.getBias()))));
		 }
		
		return actualOutputs;		  
		}

	 /**
	  * Compute the activation of each hidden neurons.
	 * @param hiddenNeurons 
	  */
	public void updateHiddenLayer(List<CTRNeuron> inputNeurons, List<CTRNeuron> hiddenNeurons){
	  
		int numberOfHiddenNeurons = hiddenNeurons.size();
		
		for(int i=0; i < numberOfHiddenNeurons; i++) {
			
			BigDecimal hiddenNeuronS = hiddenNeurons.get(i).getState().negate();
			hiddenNeuronS = hiddenNeuronS.add(updateStimesW( i, inputNeurons ));
			hiddenNeuronS = hiddenNeuronS.add(updateStimesWself( i, hiddenNeurons ));
					
//			hiddenLayer[i].s = -hiddenLayer[i].state; 
//	        hiddenLayer[i].s += update_StimesW  ( i, inputLayer );
//	        hiddenLayer[i].s += update_StimesWself  ( i, hiddenLayer );
	    
			hiddenNeurons.get(i).setS(hiddenNeuronS);
	  }
	  for(int i=0; i < numberOfHiddenNeurons; i++){
		hiddenNeurons.get(i).setState( hiddenNeurons.get(i).getState().add(( hiddenNeurons.get(i).getS().multiply(
				(deltaT.divide(hiddenNeurons.get(i).getTau(), mathContext)), mathContext))));
	    //hiddenLayer[i].state += (hiddenLayer[i].s * (delta_t/hiddenLayer[i].tau));
	  }
	}
	
	/**
	 * This function is used to multiply the firing rate 
	 * of the neurons (layer) with a connection to neuron j
	 * 
	 * @param j
	 * @param neurons
	 * @return
	 */
	public BigDecimal updateStimesW ( int j, List<CTRNeuron> neurons ){
	  
	  BigDecimal runningSum = new BigDecimal(0);
	  
	  for(  int i = 0; i < neurons.size(); i++ ) {
		  BigDecimal factor = new BigDecimal(SigmoidFunction.getInstance()
				  .activateFunction(NumberUtils.convertBigDecimalToDouble(neurons.get(i).getState().add(neurons.get(i).getBias()))));
		  //BigDecimal factor = 1.0/( 1.0 + Math.exp( -( neurons.get(i).getState() + neurons.get(i).getBias() ) ));
		  
		  runningSum = runningSum.add(new BigDecimal(neurons.get(i).getSynapses()[j].getWeight()).multiply(factor, mathContext));
		  
	   // double z = 1.0/( 1.0 + exp( -( layer[i].state + layer[i].bias ) ));
	   // sum  +=  layer[i].weightsOut[j] * z;
	  }
	  return runningSum;
	}
	
	/* This function is used to multiply the firig rate 
	   of the neurons (layer) with the self-connections to neuron j */
	
	/**
	 * This function is used to multiply the firing rate 
	 * of the neurons (layer) with the self-connections to neuron j
	 *  
	 * @param j
	 * @param neurons
	 * @return
	 */
	public BigDecimal updateStimesWself ( int j, List<CTRNeuron> neurons ){
	  
		BigDecimal runningSum = new BigDecimal(0);
	  
	  for( int i = 0; i < neurons.size(); i++ ) {
		BigDecimal factor = new BigDecimal(SigmoidFunction.getInstance().activateFunction(NumberUtils.convertBigDecimalToDouble(
				neurons.get(i).getState().add(neurons.get(i).getBias()))));
		//BigDecimal factor = 1.0/( 1.0 + Math.exp( -( -1.0 * (neurons.get(i).getState().add(neurons.get(i).getBias())) ) ));
		runningSum = runningSum.add(new BigDecimal(neurons.get(i).getIngoingSynapses()[j].getWeight()).multiply(factor, mathContext));  
//	    double z = 1.0/( 1.0 + exp( -1.0 * ( layer[i].state + layer[i].bias ) ));
//	    sum  +=  layer[i].weightsSelf[j] * z;
	  }
	  return runningSum;
	}
	
	/* This function compute the activation of each output neurons taking
	   into account the hidden layer */
	/**
	 *  This function compute the activation of each output neurons taking
	   into account the hidden layer
	 * @param outputNeurons 
	 */
	public void updateOutputLayerFromHidden (List<CTRNeuron> hiddenNeurons, List<CTRNeuron> outputNeurons ){
	  
	  double numberOfOutputNeurons = outputNeurons.size();
	  
	  for(int i=0; i < numberOfOutputNeurons; i++) {
		
		BigDecimal outputNeuronS = outputNeurons.get(i).getState().negate();
		
		outputNeuronS = outputNeuronS.add(updateStimesW(i, hiddenNeurons));
		
		outputNeurons.get(i).setS(outputNeuronS);
		  
//	    outputLayer[i].s = -outputLayer[i].state;
//	    outputLayer[i].s += update_StimesW  ( i, hiddenLayer );
	  }
	  for(int i=0; i < numberOfOutputNeurons; i++){
		 outputNeurons.get(i).setState(  outputNeurons.get(i).getS().multiply(deltaT.divide(outputNeurons.get(i).getTau(), mathContext)));
	  }
	    //outputLayer[i].state += (outputLayer[i].s * (delta_t/outputLayer[i].tau));
	}
	
	/**
	 * Update ANN weights and parameters based on genotype provided.
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
	@Override
	public void updateWeight(List<Double> offspring) {
		
		//Convert Arraylist to LinkedList which is FIFO - first in first out
		LinkedList<Double> offspringLinkedList = new LinkedList<Double>(offspring);
		
		CTRLayer[] layers = this.getLayers();	
		List<CTRNeuron> inputNeurons = layers[NetworkConstants.INPUT_LAYER_INDEX].getCTRNeurons();// Input Layer
		List<CTRNeuron> hiddenNeurons = layers[NetworkConstants.HIDDEN_LAYER_INDEX].getCTRNeurons();//Hidden Layer
		List<CTRNeuron> outputNeurons = layers[NetworkConstants.OUTPUT_LAYER_INDEX].getCTRNeurons();//Output Layer
		
		
		//Input Bias - it is the same for all input neurons.
		BigDecimal inputBias = new BigDecimal(offspringLinkedList.poll());
		
		//Input Gain - it is the same for all input neurons.
		BigDecimal sensorGain = new BigDecimal(offspringLinkedList.poll());
		
		for( int i=0 ; i < this.sensorsGain.length ; i++){
			this.sensorsGain[i] = sensorGain;
		}
		
		
		//Input to Hidden weights
		for(CTRNeuron inputNeuron : inputNeurons){
			inputNeuron.setBias(inputBias);
				for(Synapse synapse : inputNeuron.getSynapses()){
					synapse.setWeight(offspringLinkedList.poll());
				}
			}
	
		//Hidden Layer
		for(CTRNeuron hiddenNeuron : hiddenNeurons){
			//Weights between hidden neuron and output layer
			for(Synapse synapse : hiddenNeuron.getSynapses()){
				synapse.setWeight(offspringLinkedList.poll());
			}
			//TAU
			hiddenNeuron.setTau(new BigDecimal(offspringLinkedList.poll()));
			hiddenNeuron.setBias(new BigDecimal(offspringLinkedList.poll()));
			//Weights between hidden neuron and other hidden neurons (including itself)
			for(Synapse synapse : hiddenNeuron.getIngoingSynapses()){
				synapse.setWeight(offspringLinkedList.poll());
			}
		}
		
		//Output Bias - there is always one output neuron hence 0.
		outputNeurons.get(0).setBias(new BigDecimal(offspringLinkedList.poll()));	
	}

	
	public CTRLayer[] getLayers() {
		return layers;
	}

	public void setLayers(CTRLayer[] layers) {
		this.layers = layers;
	}

	public BigDecimal[] getSensorsGain() {
		return sensorsGain;
	}

	public void setSensorsGain(BigDecimal[] sensorsGain) {
		this.sensorsGain = sensorsGain;
	}
}
