package gui.frames;

import gui.panels.charts.ComparisonPanel;
import gui.panels.charts.ErrorChartPanel;

import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

public class TrainingComparisonFrame extends JFrame{

	private static final long serialVersionUID = 1L;
	
	private  ComparisonPanel comparisonChart;
	
	/**
	 * Launch the application.
	 */
	public TrainingComparisonFrame(ComparisonPanel comparisonChart){

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
		this.setTitle("MSE Results Comparison");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(600, 400, 400, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add(comparisonChart, BorderLayout.CENTER);
	}
}
