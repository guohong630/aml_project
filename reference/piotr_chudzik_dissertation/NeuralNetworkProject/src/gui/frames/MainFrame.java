package gui.frames;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

import exception.NeuralNetworkException;
import gui.panels.charts.ChartPanel;
import gui.panels.charts.ComparisonPanel;
import gui.panels.charts.ErrorChartPanel;
import gui.panels.charts.EvaluationChartPanel;
import gui.panels.charts.MainChartPanel;
import gui.panels.charts.WeightsChartPanel;
import gui.panels.controls.GeneticParametersPanel;
import gui.panels.controls.NeuronPanel;
import gui.panels.controls.StatisticsPanel;
import gui.panels.controls.StatusPanel;
import gui.panels.controls.TrainingPanel;

import javax.swing.AbstractButton;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.SwingUtilities;

import utils.FileUtils;

import neuralnetwork.Network;

public class MainFrame extends JFrame {

	private static final long serialVersionUID = 1L;
	
	private Network network;
	
	private MainChartPanel mainChart;
	private ErrorChartPanel errorChart;
	private WeightsChartPanel weightsChart;
	private EvaluationChartPanel evaluationChart;
	private ComparisonPanel trainingComparisonChart;
	private EvaluationChartPanel evaluationComparisonChart;
	
	private ErrorFrame errorFrame;
	private MainChartFrame mainChartFrame;
	private WeightsFrame weightsFrame;
	private EvaluationFrame evaluationFrame;
	private TrainingComparisonFrame trainingComparisonFrame;
	private EvaluationComparisonFrame evaluationComparisonFrame;
	
	private NeuronPanel neuronPanel;
	private StatisticsPanel statisticsPanel;
	private TrainingPanel trainingPanel;
	private GeneticParametersPanel geneticParametersPanel;
	private StatusPanel statusPanel;
	

	/**
	 * Launch the application.
	 * 
	 * @param network 
	 * @param weightsChart 
	 * @param errorChart 
	 * @param mainChart 
	 * @param evaluationChart 
	 */
	public MainFrame(Network network, MainChartPanel mainChart, 
			ErrorChartPanel errorChart, WeightsChartPanel weightsChart,
			EvaluationChartPanel evaluationChart, ComparisonPanel trainingComparisonChart,
			EvaluationChartPanel evaluationComparisonChart){

		this.network = network;
		this.mainChart = mainChart;
		this.errorChart = errorChart;
		this.weightsChart = weightsChart;
		this.evaluationChart = evaluationChart;
		this.trainingComparisonChart = trainingComparisonChart;
		this.evaluationComparisonChart = evaluationComparisonChart;
		
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
		this.setTitle("Neural Network Mentalist");
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setBounds(0, 0, 840, 730);
		this.setVisible(true);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		this.setContentPane(contentPane);
		
		errorFrame = new ErrorFrame(errorChart);
		mainChartFrame = new MainChartFrame(mainChart);
		weightsFrame= new WeightsFrame(weightsChart);
		evaluationFrame = new EvaluationFrame(evaluationChart);
		trainingComparisonFrame = new TrainingComparisonFrame(trainingComparisonChart);
		evaluationComparisonFrame = new EvaluationComparisonFrame(evaluationComparisonChart);
		
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);
		
		JMenu networkMenu = new JMenu("Network");
		menuBar.add(networkMenu);
		
		networkMenu.add(createSaveItem());
		networkMenu.add(createLoadItem());
		networkMenu.add(createCompareNetworksItem());
		networkMenu.add(createCompareEvaluationsItem());
		
		JMenu chartsMenu = new JMenu("Charts");
		menuBar.add(chartsMenu);
		
		chartsMenu.add(createChartItem(mainChartFrame, "Time Series Chart", true));
		chartsMenu.add(createChartItem(errorFrame, "MSE Chart", false));
		chartsMenu.add(createChartItem(weightsFrame, "Weights Chart", false));
		chartsMenu.add(createChartItem(evaluationFrame, "Evaluation Chart", false));
		chartsMenu.add(createChartItem(trainingComparisonFrame, "Training Comparison Chart", false));
		chartsMenu.add(createChartItem(evaluationComparisonFrame, "Evaluation Comparison Chart", false));
		
		neuronPanel = new NeuronPanel();
		statusPanel = new StatusPanel();
		geneticParametersPanel = new GeneticParametersPanel();
		statisticsPanel = new StatisticsPanel();
		trainingPanel = new TrainingPanel(network, neuronPanel, 
				statisticsPanel, errorChart, weightsChart, mainChart, evaluationChart, geneticParametersPanel,
				statusPanel);	
			
		GroupLayout gl_contentPane = new GroupLayout(contentPane);
		
		gl_contentPane.setHorizontalGroup(
				gl_contentPane.createParallelGroup(Alignment.LEADING)
					.addGroup(gl_contentPane.createSequentialGroup()
						.addContainerGap()
						.addGroup(gl_contentPane.createParallelGroup(Alignment.TRAILING, false)
							.addComponent(statusPanel, Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
							.addGroup(Alignment.LEADING, gl_contentPane.createSequentialGroup()
								.addGroup(gl_contentPane.createParallelGroup(Alignment.TRAILING, false)
									.addComponent(statisticsPanel, Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
									.addComponent(trainingPanel, Alignment.LEADING, GroupLayout.DEFAULT_SIZE,  GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
								.addGap(18)
								.addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING, false)
									.addComponent(neuronPanel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
									.addComponent(geneticParametersPanel, GroupLayout.DEFAULT_SIZE,  GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
						.addContainerGap(88, Short.MAX_VALUE))
			);
			gl_contentPane.setVerticalGroup(
				gl_contentPane.createParallelGroup(Alignment.LEADING)
					.addGroup(gl_contentPane.createSequentialGroup()
						.addGroup(gl_contentPane.createParallelGroup(Alignment.TRAILING)
							.addComponent(neuronPanel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
							.addComponent(trainingPanel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
						.addGap(18)
						.addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING)
							.addComponent(geneticParametersPanel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
							.addComponent(statisticsPanel, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
						.addGap(14)
						.addComponent(statusPanel, GroupLayout.PREFERRED_SIZE, 125, GroupLayout.PREFERRED_SIZE))
			);
		contentPane.setLayout(gl_contentPane);
	}
	
	/**
     * Creates the "Save" item in "Network" menu and sets its action listener
     */
	private JMenuItem createSaveItem() {

		JMenuItem item = new JMenuItem("Save");
		// Create inner class to handle action
		class MenuItemListener implements ActionListener {
			public void actionPerformed(ActionEvent arg0) {	
				FileUtils.saveNetwork(network);
			}
		}

		ActionListener listener = new MenuItemListener();
		item.addActionListener(listener);

		return item;
	}
	
	/**
     * Creates the "Load" item in "Network" menu and sets its action listener
     */
	private JMenuItem createLoadItem() {

		JMenuItem item = new JMenuItem("Load");
		// Create inner class to handle action
		class MenuItemListener implements ActionListener {
			public void actionPerformed(ActionEvent arg0) {	
				List<Network> networks = FileUtils.loadNetworks(false);
				
				Network network = networks.get(0);
				if(network != null){
					try{
						trainingPanel.loadNetwork(network);
						neuronPanel.loadParameters(network.getNetworkConfiguration());
						statisticsPanel.updateValues(network);
						errorChart.drawMeanSquareErrorChart(network);
						weightsChart.drawWeightsChart(network);
						geneticParametersPanel.loadParameters(network);
					}catch(Exception exception){
						statusPanel.updateStatusLabel("Failed to load data due to error: " 
								+ exception.getMessage(), true);
					}
				}
			}
		}

		ActionListener listener = new MenuItemListener();
		item.addActionListener(listener);

		return item;
	}
	
	/**
     * Creates the "Compare Networks" item in the "Network" menu and sets its Action Listener.
     */
	private JMenuItem createCompareNetworksItem() {

		JMenuItem item = new JMenuItem("Compare Training Results");
		// Create inner class to handle action
		class MenuItemListener implements ActionListener {
			public void actionPerformed(ActionEvent arg0) {	
				List<Network> networks = FileUtils.loadNetworks(true);
				if(networks != null && networks.size() > 0){
					try{
						String datasetName = null;
						for(Network network : networks){
							//Check that all networks are referring to the same dataset
							if(datasetName == null){
								datasetName = network.getDatasetName();
							}else if(! datasetName.equalsIgnoreCase(network.getDatasetName())){
								throw new NeuralNetworkException("Attempt to load networks " +
										"for different datasets : " + datasetName + " and " 
										+  network.getDatasetName() + " .Please correct");
							}
						}
						
						trainingComparisonChart.drawComparisonChart(networks);
						trainingComparisonFrame.setVisible(true);
					}catch(Exception exception){
						statusPanel.updateStatusLabel("Failed to compare networks due to error: " 
								+ exception.getMessage(), true);
					}
				}
			}
		}

		ActionListener listener = new MenuItemListener();
		item.addActionListener(listener);

		return item;
	}
	
	/**
     * Creates the "Compare Evaluations" item in the "Network" menu and sets its Action Listener.
     */
	private JMenuItem createCompareEvaluationsItem() {

		JMenuItem item = new JMenuItem("Compare Evaluation Results");
		// Create inner class to handle action
		class MenuItemListener implements ActionListener {
			public void actionPerformed(ActionEvent arg0) {	
				List<Network> networks = FileUtils.loadNetworks(true);
				if(networks != null && networks.size() > 0){
					try{
						//Check that all networks are referring to the same dataset
						String datasetName = null;
						int evaluationResultsSize = 0;
						for(Network network : networks){
							if(datasetName == null){
								datasetName = network.getDatasetName();
							}else if(! datasetName.equalsIgnoreCase(network.getDatasetName())){
								throw new NeuralNetworkException("Attempt to load networks " +
										"for different datasets : " + datasetName + " and " 
										+  network.getDatasetName() + " .Please correct");
							}
							//Only networks with the same evaluation size can be compared
							if(evaluationResultsSize == 0){
								evaluationResultsSize = network.getEvaluationResults().size();
							}else if( evaluationResultsSize != network.getEvaluationResults().size()){
								throw new NeuralNetworkException("Can't compare networks of different types. Network" +
										"evaluation sizes are inconsistent. Please correct.");
							}
						}
						evaluationComparisonChart.drawMainChart(networks);
						evaluationComparisonFrame.setVisible(true);
					}catch(Exception exception){
						statusPanel.updateStatusLabel("Failed to compare networks due to error: " 
								+ exception.getMessage(), true);
					}
				}
			}
		}

		ActionListener listener = new MenuItemListener();
		item.addActionListener(listener);

		return item;
	}
	
	/**
     * Create chart items in the "Charts" menu and set their listeners.
     */
	private JMenuItem createChartItem(final JFrame frame, String chartName, boolean isSelected) {

		JCheckBoxMenuItem  item = new JCheckBoxMenuItem (chartName);
		item.setSelected(isSelected);
		// Create inner class to handle action
		class MenuItemListener implements ActionListener {
			public void actionPerformed(ActionEvent event) {
				 AbstractButton button = (AbstractButton) event.getSource();
			     boolean isSelected = button.getModel().isSelected();
			     
			     if (isSelected) {
			    	 frame.setVisible(true);
			     }else {
			    	 frame.setVisible(false);
			     }		      
			}
		}
		ActionListener listener = new MenuItemListener();
		item.addActionListener(listener);

		return item;
	}	
}
