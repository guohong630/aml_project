package gui.frames;

import java.awt.BorderLayout;

import gui.panels.charts.MainChartPanel;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

import neuralnetwork.Network;

public class MainChartFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	
	private MainChartPanel mainChart;
	
	/**
	 * Launch the application.
	 * @param mainChart 
	 */
	public MainChartFrame(MainChartPanel mainChart){

		this.mainChart = mainChart;
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
		this.setTitle("Time Series");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(950, 10, 850, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add((mainChart), BorderLayout.CENTER);
	}
}
