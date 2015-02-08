package gui.frames;

import gui.panels.charts.EvaluationChartPanel;
import gui.panels.charts.MainChartPanel;

import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;

public class EvaluationFrame extends JFrame{

private static final long serialVersionUID = 1L;
	
	private EvaluationChartPanel evaluationPanel;
	
	/**
	 * Launch the application.
	 * @param mainChart 
	 */
	public EvaluationFrame(EvaluationChartPanel evaluationPanel){

		this.evaluationPanel = evaluationPanel;
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
		this.setTitle("Evaluation");
		this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		this.setBounds(845, 0, 400, 300);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		this.setLayout( new BorderLayout());
		this.add((evaluationPanel), BorderLayout.CENTER);
	}
}
