package gui.panels.controls;

import java.awt.Color;

import javax.swing.GroupLayout;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.NetworkConfiguration;

public class NeuronPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	
	private JTextField inputNeuronsField;
	private JTextField hiddenNeuronsField;
	private JTextField outputNeuronsField;
	private JTextField inputWindowField;
	
	private JTextField scalingFactorField;
	private JTextField shiftingFactorField;
	
	private JCheckBox elmanCheckbox;
	private JCheckBox jordanCheckbox;
	private JCheckBox ctrnnCheckbox;

	public NeuronPanel(){
		super();
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null),
				"Network Morphology", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		this.setToolTipText("Network Morphology");
		
		JLabel inputNeuronsLabel = new JLabel("Number of Input Neurons");		
		JLabel hiddenNeuronsLabel = new JLabel("Number of Hidden Neurons");		
		JLabel outputNeuronsLabel = new JLabel("Number of Output Neurons");
		JLabel inputWindowSizeLabel = new JLabel("Input Window");
		JLabel recurrenceLabel = new JLabel("Recurrence:");
		JLabel weightsScalingFactorLabel = new JLabel("Weights Scaling Factor");	
		JLabel weightsShiftingFactor = new JLabel("Weights Shifting Factor");
		
		inputNeuronsField = new JTextField();
		inputNeuronsField.setText("9");//Default
		inputNeuronsField.setColumns(10);
		
		hiddenNeuronsField = new JTextField();
		hiddenNeuronsField.setText("7");//Default
		hiddenNeuronsField.setColumns(10);
		
		outputNeuronsField = new JTextField();
		outputNeuronsField.setText("1");//Default
		outputNeuronsField.setColumns(10);
		
		elmanCheckbox = new JCheckBox("Elman");	
		jordanCheckbox = new JCheckBox("Jordan");
		ctrnnCheckbox = new JCheckBox("CTRNN");
			
		scalingFactorField = new JTextField();
		scalingFactorField.setText("0.5");
		scalingFactorField.setColumns(10);
		
		shiftingFactorField = new JTextField();
		shiftingFactorField.setText("-0.25");
		shiftingFactorField.setColumns(10);
		
		GroupLayout neuronsPanel = new GroupLayout(this);
		
		inputWindowField = new JTextField();
		inputWindowField.setText("3");
		inputWindowField.setColumns(10);
		
		GroupLayout gl_neuronPanel = new GroupLayout(this);
		
		gl_neuronPanel.setHorizontalGroup(
			gl_neuronPanel.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_neuronPanel.createSequentialGroup()
					.addContainerGap()
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.LEADING)
						.addGroup(gl_neuronPanel.createSequentialGroup()
							.addComponent(elmanCheckbox)
							.addGap(18)
							.addComponent(jordanCheckbox)
							.addPreferredGap(ComponentPlacement.UNRELATED)
							.addComponent(ctrnnCheckbox))
						.addComponent(recurrenceLabel)
						.addGroup(gl_neuronPanel.createSequentialGroup()
							.addComponent(weightsScalingFactorLabel)
							.addGap(18)
							.addComponent(scalingFactorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
						.addGroup(gl_neuronPanel.createSequentialGroup()
							.addComponent(weightsShiftingFactor)
							.addGap(18)
							.addComponent(shiftingFactorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
						.addGroup(gl_neuronPanel.createParallelGroup(Alignment.TRAILING, false)
							.addGroup(gl_neuronPanel.createSequentialGroup()
								.addComponent(hiddenNeuronsLabel)
								.addPreferredGap(ComponentPlacement.UNRELATED)
								.addComponent(hiddenNeuronsField, 0, 0, Short.MAX_VALUE))
							.addGroup(Alignment.LEADING, gl_neuronPanel.createSequentialGroup()
								.addComponent(inputNeuronsLabel)
								.addGap(18)
								.addComponent(inputNeuronsField, GroupLayout.PREFERRED_SIZE, 59, GroupLayout.PREFERRED_SIZE))
							.addGroup(Alignment.LEADING, gl_neuronPanel.createSequentialGroup()
								.addGroup(gl_neuronPanel.createParallelGroup(Alignment.LEADING)
									.addComponent(outputNeuronsLabel)
									.addComponent(inputWindowSizeLabel, GroupLayout.PREFERRED_SIZE, 101, GroupLayout.PREFERRED_SIZE))
								.addPreferredGap(ComponentPlacement.UNRELATED)
								.addGroup(gl_neuronPanel.createParallelGroup(Alignment.LEADING)
									.addComponent(inputWindowField, GroupLayout.PREFERRED_SIZE, 59, GroupLayout.PREFERRED_SIZE)
									.addComponent(outputNeuronsField, 0, 0, Short.MAX_VALUE)))))
					.addContainerGap(48, Short.MAX_VALUE))
		);
		gl_neuronPanel.setVerticalGroup(
			gl_neuronPanel.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_neuronPanel.createSequentialGroup()
					.addContainerGap()
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(inputNeuronsLabel)
						.addComponent(inputNeuronsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(hiddenNeuronsLabel)
						.addComponent(hiddenNeuronsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.LEADING)
						.addGroup(gl_neuronPanel.createSequentialGroup()
							.addComponent(outputNeuronsLabel)
							.addGap(14)
							.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
								.addComponent(inputWindowSizeLabel)
								.addComponent(inputWindowField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
							.addPreferredGap(ComponentPlacement.UNRELATED)
							.addComponent(recurrenceLabel))
						.addComponent(outputNeuronsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(elmanCheckbox)
						.addComponent(jordanCheckbox)
						.addComponent(ctrnnCheckbox))
					.addGap(18)
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(weightsScalingFactorLabel)
						.addComponent(scalingFactorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(gl_neuronPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(weightsShiftingFactor)
						.addComponent(shiftingFactorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addContainerGap(58, Short.MAX_VALUE))
		);
		this.setLayout(gl_neuronPanel);
	}

	/**
	 *  Returns morphology chosen by the user.
	 */
	public NetworkConfiguration getConfiguration() {
		
		return new NetworkConfiguration(Integer.parseInt(inputNeuronsField.getText()),
				Integer.parseInt(hiddenNeuronsField.getText()), Integer.parseInt(outputNeuronsField.getText()), Integer.parseInt(inputWindowField.getText()),
				elmanCheckbox.isSelected(), jordanCheckbox.isSelected(), ctrnnCheckbox.isSelected(), Double.parseDouble(scalingFactorField.getText()),
				Double.parseDouble(shiftingFactorField.getText()));
	}

	/**
	 *  Loads number of neurons in each layer (assumes only 3 layers since only such models are used)
	 */
	public void loadParameters(NetworkConfiguration configuration) {
		
		//Input Layer
		inputNeuronsField.setText(String.valueOf(configuration.getNumberOfInputNeurons()));
		
		//Hidden Layer
		hiddenNeuronsField.setText(String.valueOf(configuration.getNumberOfHiddenNeurons())); 
		
		//Output Layer
		outputNeuronsField.setText(String.valueOf(configuration.getNumberOfOutputNeurons()));
		
		//Input Window Size
		inputWindowField.setText(String.valueOf(configuration.getInputWindowSize()));
		
		//Weights Scale
		scalingFactorField.setText(String.valueOf(configuration.getWeightsScalingFactor()));
		
		//Weights Shift
		shiftingFactorField.setText(String.valueOf(configuration.getWeightsShiftingFactor()));
		
		//Recurrence
		
		if(configuration.isElmanRecurrent()){
			elmanCheckbox.setSelected(true);
		}
		
		if(configuration.isJordanRecurrent()){
			jordanCheckbox.setSelected(true);
		}
		
		if(configuration.isCtrnnNetwork()){
			ctrnnCheckbox.setSelected(true);
		}	
	}
	
}
