package gui.frames;

import gui.panels.charts.ErrorChartPanel;

import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

public class ErrorFrame extends JFrame{

	private static final long serialVersionUID = 1L;
	
	private  ErrorChartPanel errorChart;
	
	/**
	 * Launch the application.
	 */
	public ErrorFrame(ErrorChartPanel errorChart){

		this.errorChart = errorChart;
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
		this.setTitle("Mean Squared Error");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(845, 300, 400, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add((errorChart), BorderLayout.CENTER);
	}
}
