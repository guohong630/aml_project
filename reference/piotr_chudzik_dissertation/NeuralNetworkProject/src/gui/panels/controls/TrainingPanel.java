package gui.panels.controls;


import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileNotFoundException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.swing.ButtonGroup;
import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import exception.NeuralNetworkException;
import exception.TrainingException;
import gui.panels.charts.ErrorChartPanel;
import gui.panels.charts.EvaluationChartPanel;
import gui.panels.charts.MainChartPanel;
import gui.panels.charts.WeightsChartPanel;

import training.Backpropagation;
import training.GeneticAlgorithmBasedTraining;
import training.TrainingAlgorithm;
import utils.DataUtils;
import utils.DateUtils;
import utils.FileUtils;
import utils.ListUtils;
import utils.NumberUtils;
import utils.StatisticalUtils;
import utils.Tuple;

import activation.ActivationFunction;
import activation.HyperbolicFunction;
import activation.SigmoidFunction;
import business.TrainingAlgorithmName;
import business.TrainingSet;

import neuralnetwork.CTRNeuralNetwork;
import neuralnetwork.Network;
import neuralnetwork.NetworkConfiguration;

public class TrainingPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	
	private NeuronPanel neuronPanel;
	private StatisticsPanel statisticsPanel;
	
	private ErrorChartPanel errorChartPanel;
	private WeightsChartPanel weightsChart;
	private MainChartPanel mainChart;
	private EvaluationChartPanel evaluationChart;
	private GeneticParametersPanel geneticParametersPanel;
	private StatusPanel statusPanel;
	
	private Network network;
	
	private JComboBox trainingSetList;
	private JComboBox trainingAlgorithmList;
	
	private JTextField epochsField;
	private JTextField learningRateField;
	private JTextField mseField;
	
	private JRadioButton epochsRadioButton;
	private JRadioButton mseRadioButton;
	private JRadioButton sigmoidRadioButton;
	private JRadioButton hyperbolicRadioButton;
	
	
	private JCheckBox isPercentageData;
	
	/**
	 *  Data structure used for storing all training examples of a single training set.
	 */
	private List<Tuple<List<Double>,List<Double>>>  trainingData;
	
	/**
	 *  Data structure used storing all dataset entries used for evaluation purposes.
	 */
	private List<Tuple<List<Double>,List<Double>>>  evaluationData;
	private JTextField evaluationRatioField;

	private JTextArea userInputsArea;

	private JTextField outputField;
	

	public TrainingPanel(Network networkInput, NeuronPanel neuronPanelInput,
			StatisticsPanel statisticsPanelInput, ErrorChartPanel errorChartPanelInput,
			WeightsChartPanel weightsChartInput, MainChartPanel mainChartInput,
			EvaluationChartPanel evaluationChartInput, GeneticParametersPanel geneticParametersPanelInput, 
			StatusPanel statusPanelInput){
		
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null), 
				"Training Constants", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		this.setToolTipText("Training Constants");
		
		this.neuronPanel = neuronPanelInput;
		this.network = networkInput;
		this.statisticsPanel = statisticsPanelInput;
		this.errorChartPanel = errorChartPanelInput;
		this.weightsChart = weightsChartInput;
		this.mainChart = mainChartInput;
		this.evaluationChart = evaluationChartInput;
		this.geneticParametersPanel = geneticParametersPanelInput;
		this.statusPanel = statusPanelInput;
		
		JLabel trainingSetLabel = new JLabel("Training Set");
		JLabel trainingAlgorithmLabel = new JLabel("Training Algorithm");	
		JLabel learningRateLabel = new JLabel("Learning Rate");		
		JLabel evaluationRatioLabel = new JLabel("Evaluation Ratio:");
		JLabel terminationCriteriaLabel = new JLabel("Termination Criteria:");
		JLabel userInputsLabel = new JLabel("Enter Inputs:");
		
		ButtonGroup firstButtons = new ButtonGroup();
		epochsRadioButton = new JRadioButton("Epochs");
		epochsRadioButton.setSelected(true);
		mseRadioButton = new JRadioButton("MSE <");
		firstButtons.add(epochsRadioButton);
		firstButtons.add(mseRadioButton);
		
		ButtonGroup secondButtons = new ButtonGroup();
		sigmoidRadioButton = new JRadioButton("Sigmoid");
		sigmoidRadioButton.setSelected(true);
		hyperbolicRadioButton = new JRadioButton("Hiperbolic");
		secondButtons.add(sigmoidRadioButton);
		secondButtons.add(hyperbolicRadioButton);
		
		//TrainingSet.values();
		trainingSetList = new JComboBox(TrainingSet.values());
		trainingSetList.setSelectedIndex(0);
		
		 //Create inner class to handle action
        class TrainingSetListener implements ActionListener {
        	
			public void actionPerformed(ActionEvent arg0){
				String datasetName = trainingSetList.getSelectedItem().toString();
            	getInputData(datasetName, isTimeseriesData(datasetName), isTimeseriesData(datasetName), false);         	
            }
        }
        
        ActionListener listener = new TrainingSetListener();
        trainingSetList.addActionListener(listener);
		
		trainingAlgorithmList = new JComboBox(TrainingAlgorithmName.values());
		trainingAlgorithmList.setSelectedIndex(0);
		
		learningRateField = new JTextField();
		learningRateField.setText("0.10");//Initial Value
		learningRateField.setColumns(10);
		
		epochsField = new JTextField();
		epochsField.setColumns(10);
		epochsField.setText("100");//Initial Value
		
		mseField = new JTextField();
		mseField.setColumns(10);
		mseField.setText("0.10");//Initial Value
		
		outputField = new JTextField();
		outputField.setEditable(false);
		
		evaluationRatioField = new JTextField();
		evaluationRatioField.setColumns(6);
		evaluationRatioField.setText("0.30");//Initial Value
		
		
		userInputsArea = new JTextArea();
		userInputsArea.setLineWrap(true);
		
		isPercentageData = new JCheckBox("Percentage Data");
		isPercentageData.setSelected(false);
		
		JButton trainingStartButton = new JButton("Train!");
		
		 //Create inner class to handle action
        class TrainingListener implements ActionListener
        {
            public void actionPerformed(ActionEvent arg0) 
            {	
            	statusPanel.updateStatusLabel("Started Training...", false);
            	
            	String datasetName = trainingSetList.getSelectedItem().toString();
            	String learningRate = learningRateField.getText();
            	String trainingAlgorithmName = trainingAlgorithmList.getSelectedItem().toString();
            	ActivationFunction activationFunction = getActivationFunction();
            	
            	int epochs = 0;
            	double MSEMaxValue = 0;
            	boolean useEpochs = false;
            	boolean isPercentageData = isPercentageDataSelected();
            	isTimeseriesData(datasetName);
            	
            	getInputData(datasetName, false, isTimeseriesData(datasetName), isPercentageDataSelected());
            	
            	if(epochsRadioButton.isSelected()){//Use Epochs number
            		epochs = Integer.parseInt(epochsField.getText());
            		useEpochs = true;
            	}else{//Use MSE criteria
            		MSEMaxValue = Double.parseDouble(mseField.getText());
            	}
            	
            	NetworkConfiguration networkConfiguration = neuronPanel.getConfiguration();
            	
            	if(networkConfiguration.isCtrnnNetwork()){
            		network = new CTRNeuralNetwork();
            	}
            	network.initializeNetwork(networkConfiguration, datasetName, trainingAlgorithmName,
            			Double.parseDouble(learningRate), MSEMaxValue, epochs, useEpochs,
            			activationFunction.getName(), isPercentageDataSelected(), geneticParametersPanel);
            	
            	try{
            		TrainingAlgorithm trainingAlgorithm = getTrainingAlgorithm(trainingAlgorithmList.getSelectedItem().toString());
            		
            		long startTime = System.currentTimeMillis();
            		if(!isTimeseriesData(datasetName)){//Special case since XOR and AND is not timeseries data
            			trainingAlgorithm.trainNetwork(network, trainingData, false, activationFunction, false, isPercentageData);
    	            }else{
    	            	trainingAlgorithm.trainNetwork(network, trainingData, true, activationFunction, false, isPercentageData);
    	            }
            		
            		long endTime = System.currentTimeMillis();
            		network.setTimeTakenToTrain(DateUtils.convertMilisToHours(endTime-startTime));
            		
	            	FileUtils.saveNetwork(network);
	            	
	            	/**
	            	 * Update Statistical Panel
	            	 */
	            	statisticsPanel.updateValues(network);
	            	
	            	/**
	            	 * Update Charts
	            	 */
	            	errorChartPanel.drawMeanSquareErrorChart(network);
	            	
	            	weightsChart.drawWeightsChart(network);
	            	
	            	statusPanel.updateStatusLabel("Network was trained successfully!", false);
            	}catch(Exception trainingException){
            		statusPanel.updateStatusLabel( trainingException.getMessage(), true);
            	}
            }
        }
        
        ActionListener trainingListener = new TrainingListener();
        trainingStartButton.addActionListener(trainingListener);
        
        JButton evaluationButton = new JButton("Evaluate!");
        
        //Create inner class to handle action
        class EvaluationListener implements ActionListener
        {
            public void actionPerformed(ActionEvent arg0) 
            {	
            	statusPanel.updateStatusLabel("Started Evaluation...", false);
            	
            	boolean isPecentageDataSelected  = isPercentageDataSelected();
				try {
					
					if(network == null || network.getSynapseWeights() == null){
	            		throw new NeuralNetworkException("Network chosen for evaluation is non existing or not initialized!");
	            	}
					
					String datasetName = trainingSetList.getSelectedItem().toString();
					TrainingAlgorithm trainingAlgorithm = getTrainingAlgorithm(trainingAlgorithmList.getSelectedItem().toString());
					ActivationFunction activationFunction = getActivationFunction();
					
					List<Tuple<List<Double>, List<Double>>> outputs = null;
					if (datasetName.equalsIgnoreCase("XOR_TRAINING_SET")) {// Special case since XOR is not timeseries data
						throw new NeuralNetworkException("Evaluation is not possible for not time series data.");
					}else{
						getInputData(datasetName, false, true, isPercentageDataSelected());
						outputs = trainingAlgorithm.evaluateNetwork(network, evaluationData,
								true, true, activationFunction, isPecentageDataSelected);
						
						if( ! isPercentageDataSelected()){
							DataUtils.denormalizeData(outputs);
						}
						
						network.setEvaluationMSE(StatisticalUtils.calculateMeanSquaredError(outputs));
						network.setEvaluationRsquared(StatisticalUtils.calculateCoefficientOfDetermination(outputs));
					}

					if (outputs != null) {

						getInputData(datasetName, true, true, isPercentageDataSelected());

						// Add actual output to data.
						for (int entryIndex = 0; entryIndex < evaluationData.size(); entryIndex++) {
							for (int outputIndex = 0; outputIndex < outputs.size(); outputIndex++) {
								if (entryIndex == outputIndex) {

									double expectedOutput = outputs.get(outputIndex).getFirst().get(0);
									double actualOutput = outputs.get(outputIndex).getSecond().get(0);

									List<Double> expectedAndActualOutputs = new ArrayList<Double>();
									expectedAndActualOutputs.add(expectedOutput);
									expectedAndActualOutputs.add(actualOutput);

									evaluationData.get(entryIndex).setSecond(expectedAndActualOutputs);
									break;
								}
							}
						}
						network.setEvaluationResults(evaluationData);
						//Overwrite already saved network
						FileUtils.saveNetwork(network);
						/**
		            	 * Update Statistical Panel
		            	 */
		            	statisticsPanel.updateValues(network);
						
						List<Network> networks = new ArrayList<Network>();
						networks.add(network);
						evaluationChart.drawMainChart(networks);
					}
				} catch (Exception e) {
					statusPanel.updateStatusLabel(e.getMessage(), true);
				}
            }
        }
        
        ActionListener evaluationListener = new EvaluationListener();
        evaluationButton.addActionListener(evaluationListener);
        
        JButton calculateOutputButton = new JButton("Calculate Output");
        
        class OutputCalculationListener implements ActionListener
        {
            public void actionPerformed(ActionEvent arg0) 
            {	
            	
            	if(network == null || network.getSynapseWeights().isEmpty()){
            		statusPanel.updateStatusLabel("Network chosen for calculating output is non existing or not initialized!", true);
            	}
            	
            	boolean isPercentageData = isPercentageDataSelected();
            	
            	String datasetName = trainingSetList.getSelectedItem().toString();
            	String inputData = userInputsArea.getText();
            	List<Tuple<List<Double>,List<Double>>> userEvaluationData = new ArrayList<Tuple<List<Double>,List<Double>>>();
            	ActivationFunction activationFunction = getActivationFunction();
            	
            	try{
            		TrainingAlgorithm trainingAlgorithm = getTrainingAlgorithm(trainingAlgorithmList.getSelectedItem().toString());
            		String[] inputBars = inputData.split("\n");
            		for(String inputBar: inputBars){
            			List<Double> inputValues = new ArrayList<Double>();
            			String[] inputs = inputBar.split(String.valueOf("\\" + FileUtils.FILE_DELIMITER));//"\\" escape sequence
                		for(String input : inputs){
                			inputValues.add(Double.parseDouble(input));
                		}
                		if(inputValues.size() > 0){
                    		userEvaluationData.add(new Tuple<List<Double>, List<Double>>( inputValues, new ArrayList<Double>()));
                		}
            		}
            		if(userEvaluationData.size() > 0){
            		
	            	List<Tuple<List<Double>, List<Double>>> outputs = null;
	            	
	            	if(datasetName.equalsIgnoreCase("XOR_TRAINING_SET")){//Special case since XOR is not timeseries data
	            		
	            		trainingAlgorithm.evaluateNetwork(network, userEvaluationData,
	            				false, false, activationFunction, isPercentageData);
	            	}else{
	            		DataUtils.normalizeData(userEvaluationData);
	            		outputs = trainingAlgorithm.evaluateNetwork(network, userEvaluationData,
	            				true, false, activationFunction, isPercentageData);
	            		
	            		if( isPercentageData){
							DataUtils.denormalizeData(outputs);
						}
	            	}
	            	
	            	outputField.setText(String.valueOf(outputs.get(0).getSecond().get(0)));
	            	userInputsArea.setText("");//clear JTextArea
            		}
            	}catch(Exception exception){
            	statusPanel.updateStatusLabel(exception.getMessage(), true);
            	}
            }
        }
        
        ActionListener outputListener = new OutputCalculationListener();
        calculateOutputButton.addActionListener(outputListener);
        	
		GroupLayout trainingPanel = new GroupLayout(this);
		
		trainingPanel.setHorizontalGroup(
			trainingPanel.createParallelGroup(Alignment.LEADING)
				.addGroup(trainingPanel.createSequentialGroup()
					.addContainerGap()
					.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING)
						.addGroup(trainingPanel.createSequentialGroup()
							.addComponent(trainingStartButton)
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(evaluationButton)
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(evaluationRatioLabel)
							.addPreferredGap(ComponentPlacement.RELATED, 33, Short.MAX_VALUE)
							.addComponent(evaluationRatioField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
						.addComponent(terminationCriteriaLabel)
						.addGroup(trainingPanel.createSequentialGroup()
							.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING, false)
								.addGroup(trainingPanel.createSequentialGroup()
									.addComponent(learningRateLabel)
									.addPreferredGap(ComponentPlacement.RELATED, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
									.addComponent(learningRateField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
								.addGroup(trainingPanel.createSequentialGroup()
									.addComponent(trainingAlgorithmLabel)
									.addPreferredGap(ComponentPlacement.RELATED, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
									.addComponent(trainingAlgorithmList, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
								.addGroup(trainingPanel.createSequentialGroup()
									.addComponent(trainingSetLabel)
									.addPreferredGap(ComponentPlacement.RELATED, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
									.addComponent(trainingSetList, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
								.addGroup(trainingPanel.createSequentialGroup()
									.addComponent(epochsRadioButton)
									.addPreferredGap(ComponentPlacement.RELATED)
									.addComponent(epochsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
									.addPreferredGap(ComponentPlacement.RELATED)
									.addComponent(mseRadioButton)))
							.addPreferredGap(ComponentPlacement.RELATED)
							.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING)
								.addComponent(mseField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addComponent(isPercentageData)
								.addComponent(sigmoidRadioButton)
								.addComponent(hyperbolicRadioButton)))
						.addGroup(trainingPanel.createSequentialGroup()
							.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING)
								.addComponent(userInputsLabel)
								.addComponent(userInputsArea, GroupLayout.PREFERRED_SIZE, 133, GroupLayout.PREFERRED_SIZE))
							.addGap(18)
							.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING)
								.addGroup(trainingPanel.createSequentialGroup()
									.addComponent(calculateOutputButton)
									.addGap(22))
								.addComponent(outputField, GroupLayout.DEFAULT_SIZE, 168, Short.MAX_VALUE))))
					.addContainerGap())
		);
		trainingPanel.setVerticalGroup(
			trainingPanel.createParallelGroup(Alignment.TRAILING)
				.addGroup(trainingPanel.createSequentialGroup()
					.addContainerGap()
					.addGroup(trainingPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(trainingSetLabel)
						.addComponent(trainingSetList, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(isPercentageData))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(trainingPanel.createParallelGroup(Alignment.TRAILING)
						.addComponent(trainingAlgorithmLabel)
						.addGroup(trainingPanel.createParallelGroup(Alignment.BASELINE)
							.addComponent(trainingAlgorithmList, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
							.addComponent(sigmoidRadioButton)))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(trainingPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(learningRateLabel)
						.addComponent(learningRateField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(hyperbolicRadioButton))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(terminationCriteriaLabel)
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(trainingPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(epochsRadioButton)
						.addComponent(mseRadioButton)
						.addComponent(epochsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(mseField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(trainingPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(trainingStartButton)
						.addComponent(evaluationButton)
						.addComponent(evaluationRatioField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(evaluationRatioLabel))
					.addGroup(trainingPanel.createParallelGroup(Alignment.LEADING)
						.addGroup(trainingPanel.createSequentialGroup()
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(userInputsLabel)
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(userInputsArea, GroupLayout.DEFAULT_SIZE, 40, Short.MAX_VALUE))
						.addGroup(trainingPanel.createSequentialGroup()
							.addGap(17)
							.addComponent(calculateOutputButton)
							.addPreferredGap(ComponentPlacement.RELATED, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
							.addComponent(outputField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)))
					.addContainerGap())
		);
		this.setLayout(trainingPanel);
	}


	public void loadNetwork(Network loadedNetwork) {
		
		this.network = loadedNetwork;
		this.evaluationData = null;
		this.trainingData = null;
		
		/**
		 *  Backpropagation factors
		 */
		this.epochsField.setText(String.valueOf(loadedNetwork.getNumberOfEpochs()));
		this.mseField.setText(String.valueOf(loadedNetwork.getMSEMaxValue()));
		
		if(loadedNetwork.isEpochsUsed()){
			this.epochsRadioButton.setSelected(true);
		}else{
			this.mseRadioButton.setSelected(true);
		}
		this.learningRateField.setText(String.valueOf(loadedNetwork.getLearningRate()));
		
		/**
		 *  General Data Set and Training details
		 */
		for(int i= 0 ; i< TrainingSet.values().length ; i++){
			if(TrainingSet.values()[i].name().equalsIgnoreCase(loadedNetwork.getDatasetName())){
				this.trainingSetList.setSelectedIndex(i);
			}
		}
		
		for(int i= 0 ; i< TrainingAlgorithmName.values().length ; i++){
			if(TrainingAlgorithmName.values()[i].name().equalsIgnoreCase(loadedNetwork.getTrainingAlgorithmUsed())){
				this.trainingAlgorithmList.setSelectedIndex(i);
			}
		}
		
		this.isPercentageData.setSelected(loadedNetwork.isPercentageData());
		
		if(loadedNetwork.getActivationFunction().equalsIgnoreCase(SigmoidFunction.NAME)){
			this.sigmoidRadioButton.setSelected(true);
		}else{
			this.hyperbolicRadioButton.setSelected(true);
		}
	}
	
	private void getInputData(String datasetName, boolean isChartData , boolean isTimeseriesData, boolean isPercentageData) {
		
		try {
			trainingData = FileUtils.retrieveInputData(datasetName, isChartData);
			if(isPercentageData && isTimeseriesData && ! isChartData){// Percentage changes are calculated for Time Series data only
				DataUtils.convertToPercentageData(trainingData);
			}
    	} catch (FileNotFoundException e) {
    		statusPanel.updateStatusLabel("Could not retrieve file " + datasetName + " due to error: "
    				+ e.getMessage(), true);
		}
    	
    	if(isChartData && trainingData != null){ //No need to normalize chart input
        	try {
        		Network mainChartNetwork = new Network();
        		mainChartNetwork.setEvaluationResults(trainingData);
        		mainChartNetwork.setDatasetName(datasetName);
				mainChart.drawMainChart(mainChartNetwork);
			} catch (Exception e) {
				statusPanel.updateStatusLabel("Could not draw a diagram for " + datasetName + " due to error: "
	    				+ e.getMessage(), true);
			}
    	}else if( ! isPercentageData){//We do not normalize percentage data
    		DataUtils.normalizeData(trainingData);
    	}
    	
    	if(isTimeseriesData){
    		evaluationData = ListUtils.getEvaluationDataList(trainingData, Double.parseDouble(evaluationRatioField.getText()));
    	}
	}
	
	private boolean isTimeseriesData(String datasetName) {
		return (!datasetName.equalsIgnoreCase("XOR_TRAINING_SET") && !datasetName.equalsIgnoreCase("AND_TRAINING_SET"));
	}
	
	private TrainingAlgorithm getTrainingAlgorithm(String trainingAlgorithmName) throws TrainingException {
		
		if(trainingAlgorithmName.equalsIgnoreCase(TrainingAlgorithmName.BACKPROPAGATION.toString())){
			return Backpropagation.getInstance();
		}else if(trainingAlgorithmName.equalsIgnoreCase(TrainingAlgorithmName.GA_BASED.toString())){
			return GeneticAlgorithmBasedTraining.getInstance();
		}else{
			throw new TrainingException("Unrecognized Training Algorithm used. Please Investigate.");
		}	
	}
	
	private ActivationFunction getActivationFunction() {
		if(sigmoidRadioButton.isSelected()){
			return SigmoidFunction.getInstance();
		}else{//Hyperbolic must be selected
			return HyperbolicFunction.getInstance();
		}
	}


	public boolean isPercentageDataSelected() {
		return isPercentageData.isSelected();
	}


	public void setPercentageData(boolean isSelected) {
		this.isPercentageData.setSelected(isSelected);
	}
	
}
