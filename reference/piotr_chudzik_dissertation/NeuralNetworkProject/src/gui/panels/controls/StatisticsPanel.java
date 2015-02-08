package gui.panels.controls;

import java.awt.Color;

import javax.swing.GroupLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

public class StatisticsPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	private JTextField meanSquaredErrorTrainingField;
	private JTextField minAbsoluteErrorField;
	private JTextField maxAbsoluteErrorField;
	private JTextField rSquaredTrainingField;
	
	private JTextField rSquaredEvaluationField;
	private JTextField meanSquaredErrorEvaluationField;

	public StatisticsPanel(){
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null),
				"Evaluation", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		this.setToolTipText("Statistical Constants");
		
		JLabel meanSquaredErrorTrainingLabel = new JLabel("Mean Squared Error");
		JLabel rSquaredTrainingLabel = new JLabel("R squared");
		JLabel minAbsoluteErrorLabel = new JLabel("Min Absolute Error");
		JLabel maxAbsoluteErrorLabel = new JLabel("Max Absolute Error");
		JLabel meanSquaredErrorEvaluationLabel = new JLabel("Mean Squared Error");
		JLabel rSquaredEvaluationLabel = new JLabel("R squared");
		JLabel trainingLabel = new JLabel("Training:");
		JLabel evaluationLabel = new JLabel("Evaluation:");
		
		meanSquaredErrorTrainingField = new JTextField();
		meanSquaredErrorTrainingField.setText("0");
		meanSquaredErrorTrainingField.setEditable(false);
		meanSquaredErrorTrainingField.setColumns(10);
		
		meanSquaredErrorEvaluationField = new JTextField();
		meanSquaredErrorEvaluationField.setText("0");
		meanSquaredErrorEvaluationField.setEditable(false);
		meanSquaredErrorEvaluationField.setColumns(10);
		
		rSquaredEvaluationField = new JTextField();
		rSquaredEvaluationField.setText("0");
		rSquaredEvaluationField.setEditable(false);
		rSquaredEvaluationField.setColumns(10);
		
		minAbsoluteErrorField = new JTextField();
		minAbsoluteErrorField.setText("0");
		minAbsoluteErrorField.setEditable(false);
		minAbsoluteErrorField.setColumns(10);
		
		maxAbsoluteErrorField = new JTextField();
		maxAbsoluteErrorField.setText("0");
		maxAbsoluteErrorField.setEditable(false);
		maxAbsoluteErrorField.setColumns(10);
		
		rSquaredTrainingField = new JTextField();
		rSquaredTrainingField.setText("0");
		rSquaredTrainingField.setEditable(false);
		rSquaredTrainingField.setColumns(10);
		
		GroupLayout gl_statisticsPanel = new GroupLayout(this);
		gl_statisticsPanel.setHorizontalGroup(
			gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_statisticsPanel.createSequentialGroup()
					.addContainerGap()
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
						.addComponent(trainingLabel)
						.addComponent(evaluationLabel)
						.addGroup(Alignment.TRAILING, gl_statisticsPanel.createSequentialGroup()
							.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.TRAILING)
								.addGroup(Alignment.LEADING, gl_statisticsPanel.createSequentialGroup()
									.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
										.addComponent(rSquaredEvaluationLabel)
										.addComponent(meanSquaredErrorEvaluationLabel))
									.addGap(15)
									.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING, false)
										.addComponent(meanSquaredErrorEvaluationField)
										.addComponent(rSquaredEvaluationField, GroupLayout.DEFAULT_SIZE, 187, Short.MAX_VALUE)))
								.addGroup(Alignment.LEADING, gl_statisticsPanel.createParallelGroup(Alignment.TRAILING)
									.addGroup(Alignment.LEADING, gl_statisticsPanel.createSequentialGroup()
										.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
											.addComponent(minAbsoluteErrorLabel, GroupLayout.PREFERRED_SIZE, 90, GroupLayout.PREFERRED_SIZE)
											.addComponent(maxAbsoluteErrorLabel, GroupLayout.PREFERRED_SIZE, 101, GroupLayout.PREFERRED_SIZE))
										.addGap(7)
										.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
											.addComponent(maxAbsoluteErrorField, GroupLayout.DEFAULT_SIZE, 190, Short.MAX_VALUE)
											.addComponent(minAbsoluteErrorField, GroupLayout.DEFAULT_SIZE, 190, Short.MAX_VALUE)))
									.addGroup(Alignment.LEADING, gl_statisticsPanel.createSequentialGroup()
										.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING)
											.addComponent(rSquaredTrainingLabel, GroupLayout.PREFERRED_SIZE, 90, GroupLayout.PREFERRED_SIZE)
											.addComponent(meanSquaredErrorTrainingLabel))
										.addGap(12)
										.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.LEADING, false)
											.addComponent(rSquaredTrainingField)
											.addComponent(meanSquaredErrorTrainingField, GroupLayout.DEFAULT_SIZE, 187, Short.MAX_VALUE)))))
							.addGap(39)))
					.addContainerGap())
		);
		gl_statisticsPanel.setVerticalGroup(
			gl_statisticsPanel.createParallelGroup(Alignment.TRAILING)
				.addGroup(gl_statisticsPanel.createSequentialGroup()
					.addComponent(trainingLabel)
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(meanSquaredErrorTrainingLabel)
						.addComponent(meanSquaredErrorTrainingField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addGap(5)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(rSquaredTrainingLabel)
						.addComponent(rSquaredTrainingField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(minAbsoluteErrorLabel)
						.addComponent(minAbsoluteErrorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(maxAbsoluteErrorLabel)
						.addComponent(maxAbsoluteErrorField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
					.addGap(4)
					.addComponent(evaluationLabel)
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(meanSquaredErrorEvaluationField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(meanSquaredErrorEvaluationLabel))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addGroup(gl_statisticsPanel.createParallelGroup(Alignment.BASELINE)
						.addComponent(rSquaredEvaluationField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addComponent(rSquaredEvaluationLabel)))
		);
		this.setLayout(gl_statisticsPanel);
	}

	public void updateValues(Network network) {
		
		meanSquaredErrorTrainingField.setText(String.valueOf(network.getFinalMSEValue()));
		minAbsoluteErrorField.setText(String.valueOf(network.getMinimumAbsoluteError()));
		maxAbsoluteErrorField.setText(String.valueOf(network.getMaximumAbsoluteError()));
		rSquaredTrainingField.setText(String.valueOf(network.getRSquared()));
		
		meanSquaredErrorEvaluationField.setText(String.valueOf(network.getEvaluationMSE()));
		rSquaredEvaluationField.setText(String.valueOf(network.getEvaluationRsquared()));
		
		this.repaint();
	}
}
