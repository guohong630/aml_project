package gui.frames;

import java.awt.BorderLayout;

import gui.panels.charts.WeightsChartPanel;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

public class WeightsFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	
	private WeightsChartPanel weightsChart;
	/**
	 * Launch the application.
	 * @param weightsChart 
	 */
	public WeightsFrame(WeightsChartPanel weightsChart){

		this.weightsChart = weightsChart;
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
		this.setTitle("Weights and Error Correlation");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(845, 600, 400, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add((weightsChart), BorderLayout.CENTER);
	}
}
