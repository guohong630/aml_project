package gui.panels.controls;

import java.awt.Color;

import javax.swing.ButtonGroup;
import javax.swing.GroupLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextField;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

public class GeneticParametersPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	private JTextField populationSizeField;
	private JTextField crossoverPercentField;
	private JTextField mutationPercentField;
	private JTextField cutLengthField;
	private JTextField elitismField;
	private JTextField generationsField;
	private JTextField resultsField;
	
	private JRadioButton generationsRadioButton;
	private JRadioButton resultsRadioButton;
	
	private boolean isGenerationsCriteriumChosen;

	public GeneticParametersPanel(){
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null),
				"GA Parameters", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		this.setToolTipText("GA Parameters");
		
		JLabel populationSizeLabel = new JLabel("Population Size");
		JLabel matePercentLabel = new JLabel("Crossover Percent");
		JLabel mutationPercentLabel = new JLabel("Mutation Percent");
		JLabel crossoverCutLengthLabel = new JLabel("Crossover Cut Length");
		JLabel elitismLabel = new JLabel("Elitism");
		JLabel terminationLabel = new JLabel("Termination Criteria:");
		
		populationSizeField = new JTextField();
		populationSizeField.setText("100");
		populationSizeField.setColumns(10);
		
		crossoverPercentField = new JTextField();
		crossoverPercentField.setText("0.70");
		crossoverPercentField.setColumns(10);
		
		mutationPercentField = new JTextField();
		mutationPercentField.setText("0.10");
		mutationPercentField.setColumns(10);
		
		cutLengthField = new JTextField();
		cutLengthField.setText("0.10");
		cutLengthField.setColumns(10);
		
		elitismField = new JTextField();
		elitismField.setText("4");
		elitismField.setColumns(10);
		
		generationsField = new JTextField();
		generationsField.setText("10");
		generationsField.setColumns(10);
		
		resultsField = new JTextField();
		resultsField.setColumns(10);
		resultsField.setText("2");
		
		isGenerationsCriteriumChosen = true; //Default
		
		ButtonGroup buttons = new ButtonGroup();
		generationsRadioButton = new JRadioButton("Generations");
		generationsRadioButton.setSelected(isGenerationsCriteriumChosen);
		resultsRadioButton = new JRadioButton("Results");
		buttons.add(generationsRadioButton);
		buttons.add(resultsRadioButton);

		GroupLayout geneticParametersPanelLayout = new GroupLayout(this);

		geneticParametersPanelLayout.setHorizontalGroup(
			geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
				.addGroup(geneticParametersPanelLayout.createSequentialGroup()
					.addGap(21)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
						.addGroup(geneticParametersPanelLayout.createSequentialGroup()
							.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
								.addComponent(populationSizeLabel)
								.addComponent(matePercentLabel))
							.addGap(18)
							.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
								.addComponent(crossoverPercentField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addComponent(populationSizeField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)))
						.addGroup(geneticParametersPanelLayout.createSequentialGroup()
							.addPreferredGap(ComponentPlacement.RELATED)
							.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.TRAILING)
								.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING, false)
									.addGroup(geneticParametersPanelLayout.createSequentialGroup()
										.addComponent(elitismLabel)
										.addPreferredGap(ComponentPlacement.RELATED, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
										.addComponent(elitismField, GroupLayout.PREFERRED_SIZE, 78, GroupLayout.PREFERRED_SIZE))
									.addGroup(geneticParametersPanelLayout.createSequentialGroup()
										.addComponent(mutationPercentLabel)
										.addGap(18)
										.addComponent(mutationPercentField, 0, 0, Short.MAX_VALUE))
									.addGroup(geneticParametersPanelLayout.createSequentialGroup()
										.addComponent(crossoverCutLengthLabel)
										.addGap(18)
										.addComponent(cutLengthField, GroupLayout.PREFERRED_SIZE, 67, GroupLayout.PREFERRED_SIZE))
									.addComponent(terminationLabel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
								.addGroup(geneticParametersPanelLayout.createSequentialGroup()
									.addComponent(generationsRadioButton)
									.addPreferredGap(ComponentPlacement.RELATED)
									.addComponent(generationsField, GroupLayout.PREFERRED_SIZE, 38, GroupLayout.PREFERRED_SIZE)
									.addPreferredGap(ComponentPlacement.UNRELATED)
									.addComponent(resultsRadioButton)))
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(resultsField, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE)))
					.addGap(76))
		);
		geneticParametersPanelLayout.setVerticalGroup(
			geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
				.addGroup(geneticParametersPanelLayout.createSequentialGroup()
					.addContainerGap()
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.BASELINE)
						.addComponent(populationSizeLabel)
						.addComponent(populationSizeField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
						.addComponent(crossoverPercentField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(matePercentLabel))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.BASELINE)
						.addComponent(mutationPercentField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(mutationPercentLabel))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.BASELINE)
						.addComponent(cutLengthField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(crossoverCutLengthLabel))
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.LEADING)
						.addComponent(elitismLabel)
						.addComponent(elitismField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addComponent(terminationLabel)
					.addPreferredGap(ComponentPlacement.RELATED, 7, Short.MAX_VALUE)
					.addGroup(geneticParametersPanelLayout.createParallelGroup(Alignment.BASELINE)
						.addComponent(generationsRadioButton)
						.addComponent(generationsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(resultsRadioButton)
						.addComponent(resultsField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)))
		);
		this.setLayout(geneticParametersPanelLayout);
	}
	
	public int getPopulationSize(){
		return Integer.parseInt(populationSizeField.getText().toString());
	}
	
	public double getCrossoverPercent(){
		return Double.parseDouble(crossoverPercentField.getText().toString());
	}
	
	public double getMutationPercent(){
		return Double.parseDouble(mutationPercentField.getText().toString());
	}
	
	public double getCrossoverCutLength(){
		return Double.parseDouble(cutLengthField.getText().toString());
	}
	
	public int getElitism(){
		return Integer.parseInt(elitismField.getText().toString());	
	}
	
	public int getGenerations(){
		return Integer.parseInt(generationsField.getText().toString());	
	}
	
	public int getGenerationsResults(){
		return Integer.parseInt(resultsField.getText().toString());	
	}
	
	public boolean isGenerationCriteriaChosen(){
		return this.isGenerationsCriteriumChosen;	
	}

	/**
	 * Load parameters of a loaded neural network
	 * 
	 * @param network loaded neural network
	 */
	public void loadParameters(Network network) {
		
		populationSizeField.setText(String.valueOf(network.getPopulationSize()));
		crossoverPercentField.setText(String.valueOf(network.getCrossoverPercent()));
		cutLengthField.setText(String.valueOf(network.getCrossoverCutLength()));
		mutationPercentField.setText(String.valueOf(network.getMutationPercent()));
		elitismField.setText(String.valueOf(network.getElitism()));
		
		generationsField.setText(String.valueOf(network.getGenerations()));
		resultsField.setText(String.valueOf(network.getGenerationsResults()));
		
		this.isGenerationsCriteriumChosen = network.isGenerationCriteriumChosen(); 
		
		if(this.isGenerationsCriteriumChosen){
			generationsRadioButton.setSelected(true);
		}else{
			resultsRadioButton.setSelected(true);
		}
	}
}
