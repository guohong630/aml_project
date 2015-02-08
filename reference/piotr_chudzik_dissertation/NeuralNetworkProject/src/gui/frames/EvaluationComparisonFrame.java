package gui.frames;

import gui.panels.charts.EvaluationChartPanel;

import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

public class EvaluationComparisonFrame extends JFrame{

	private static final long serialVersionUID = 1L;
	
	private  EvaluationChartPanel comparisonChart;
	
	/**
	 * Launch the application.
	 */
	public EvaluationComparisonFrame(EvaluationChartPanel comparisonChart){

		this.comparisonChart = comparisonChart;
		try{
	          SwingUtilities.invokeLater(new Runnable()
	            {public void run() {
	                create();
	            }});
	        }
	        catch (Exception e) {
	            System.out.println("invokeLater exception"+e);
	        }
	}	
	/**
	 * Create the frame.
	 */
	public void create() {
		this.setTitle("Evaluation Results Comparison");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(300, 450, 400, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add(comparisonChart, BorderLayout.CENTER);
	}
}
