package gui.panels.charts;

import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

import neuralnetwork.Network;
import neuralnetwork.NetworkConfiguration;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.DateAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.LegendTitle;
import org.jfree.chart.title.TextTitle;
import org.jfree.chart.title.Title;
import org.jfree.data.xy.XYDataset;
import org.jfree.ui.RectangleEdge;
import org.jfree.ui.RectangleInsets;

import exception.NeuralNetworkException;

import utils.Tuple;

import business.NetworkConstants;
import business.TrainingAlgorithmName;

public class ChartPanel extends JPanel{
	

	private static final long serialVersionUID = 1L;

	public ChartPanel(){
		super();
	}
	
	protected org.jfree.chart.ChartPanel createTimeSeriesChart(List<Network> networks,String chartTitle, String xAxisLabel, String yAxisLabel) 
			throws NeuralNetworkException{
		
		
		Network firstNetwork = networks.get(0); //There is always at least one network to evaluate
	
		XYDataset dataset = createDataset(networks);
		
		JFreeChart chart = ChartFactory.createTimeSeriesChart(
			chartTitle + " for " + firstNetwork.getDatasetName(), // chart title
			xAxisLabel, // x axis label
			yAxisLabel, // y axis label
			dataset, // data
			true, // include legend
			true, // tooltips
			false // urls
			);
		
		customizeChart(chart, null, firstNetwork.getDatasetName());
		
		if(networks.size() == 1 && firstNetwork.getEvaluationMSE() > NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE 
				&& firstNetwork.getEvaluationRsquared() > NetworkConstants.DEFAULT_EVALUATION_STAT_VALUE){
			chart.addSubtitle( new TextTitle(" Evaluation MSE: " + firstNetwork.getEvaluationMSE() + " , Evaluation R squared: " + firstNetwork.getEvaluationRsquared()));
		}
		
		XYPlot plot = (XYPlot) chart.getPlot();
		XYItemRenderer r = plot.getRenderer();
		if (r instanceof XYLineAndShapeRenderer) {
			XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) r;
			renderer.setBaseShapesVisible(true);
			renderer.setBaseShapesFilled(true);
		}
		
		DateAxis axis = (DateAxis) plot.getDomainAxis();
		axis.setDateFormatOverride(new SimpleDateFormat("mm-HH-dd-MMM-yyyy"));
		
		org.jfree.chart.ChartPanel chartPanel = new org.jfree.chart.ChartPanel(chart);
		chartPanel.setMouseZoomable(true, false);
		
		return chartPanel;
	
	}
	
	protected org.jfree.chart.ChartPanel createScatteredChart(Network network, String chartTitle, String xAxisLabel,
			String yAxisLabel) throws NeuralNetworkException{
		
		List<Network> networks = new ArrayList<Network>();
		networks.add(network);
		
		return createScatteredChart(networks, chartTitle, xAxisLabel, yAxisLabel);
	}
	
	
	protected org.jfree.chart.ChartPanel createScatteredChart(List<Network> networks, String chartTitle, String xAxisLabel,
			String yAxisLabel) throws NeuralNetworkException{
		
		XYDataset dataset = createDataset(networks);
		
		Network firstNetwork = networks.get(0); //There is always at least one network to evaluate
		
		JFreeChart chart = ChartFactory.createScatterPlot(
				chartTitle, // chart title
				xAxisLabel, // x axis label
				yAxisLabel, // y axis label
				dataset, // data
				PlotOrientation.VERTICAL,
				true, // include legend
				true, // tooltips
				false // urls
				);
		
		if(networks != null && networks.size() == 1){
			customizeChart(chart, networks.get(0), chartTitle);
		}else{
			customizeChart(chart, null, chartTitle + " for " + firstNetwork.getDatasetName());
		}
		
		XYPlot plot = (XYPlot) chart.getPlot();
		XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) plot.getRenderer();
		renderer.setShapesVisible(true);
		renderer.setShapesFilled(true);
		
		org.jfree.chart.ChartPanel chartPanel = new org.jfree.chart.ChartPanel(chart);
		chartPanel.setMouseZoomable(true, false);
		
		return chartPanel;
	}

	/**
	 * Creates a dataset based on network details. This method is overwritten in all subclasses that 
	 * use this method.
	 * 
	 * @param network a neural network.
	 * @return dataset.
	 * @throws NeuralNetworkException 
	 */
	protected XYDataset createDataset(List<Network> networks) throws NeuralNetworkException {
		
		return null;
	}

	private void customizeChart(JFreeChart chart, Network network, String chartTitle) {
		
		chart.removeLegend();//Remove previous legend
		LegendTitle legend = new LegendTitle(chart.getPlot()); 
		Font font = new Font("Arial",0,16); 
		legend.setItemFont(font); 
		legend.setPosition(RectangleEdge.BOTTOM); 
		legend.setBackgroundPaint(Color.WHITE);
		chart.addLegend(legend); 
		
		chart.addSubtitle(createSubtitle(network, chartTitle));
		
		if(chartTitle.equalsIgnoreCase("Weights change in relation to MSE")){
			chart.removeLegend();//Too many weights in a chart legend make it unreadable so a legend has to be removed.
		}
		chart.setBackgroundPaint(new GradientPaint(0, 0, Color.white, 0, 2000, Color.blue));
		
		XYPlot plot = (XYPlot) chart.getPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setAxisOffset(new RectangleInsets(5.0, 5.0, 5.0, 5.0));
		plot.setDomainGridlinePaint(Color.black);
		plot.setRangeGridlinePaint(Color.black);	
	}

	private Title createSubtitle(Network network, String chartTitle) {
		
		StringBuilder chartSubtitle = new StringBuilder();
		String datasetName = chartTitle;
		StringBuilder recurrence = new StringBuilder(" ,Recurrence:");
		if(network != null){
			datasetName = network.getDatasetName();
			NetworkConfiguration configuration = network.getNetworkConfiguration();
			recurrence.append(addRecurrenceInfo(configuration));
			
			if(network.isPercentageData()){
				chartSubtitle.append( " ,Percentage Data");
			}else{
				chartSubtitle.append( " ,Real Data");
			}
			
			chartSubtitle.append(" ,Activation Function:" + network.getActivationFunction());
			
			if(network.getTrainingAlgorithmUsed().equalsIgnoreCase(TrainingAlgorithmName.BACKPROPAGATION.toString())){
				
				chartSubtitle.append(" ,Training Algorithm: ").append(network.getTrainingAlgorithmUsed())
					.append(" ,Learning Rate:  ").append(network.getLearningRate());
				
				if(network.isEpochsUsed()){
					chartSubtitle.append(" ,Epochs: ").append(network.getNumberOfEpochs());
				}else{//Use MSE
					chartSubtitle.append(" ,MSE < ").append(network.getMSEMaxValue());
				}
			}else if(network.getTrainingAlgorithmUsed().equalsIgnoreCase(TrainingAlgorithmName.GA_BASED.toString())){
				
				chartSubtitle.append(" ,Training Algorithm: ").append(network.getTrainingAlgorithmUsed())
					.append(" ,Population Size: ").append(network.getPopulationSize())
					.append(" ,Crossover Percent: ").append(network.getCrossoverPercent())
					.append(" ,Crossover Cut Length: ").append(network.getCrossoverCutLength())
					.append(" ,Mutation Percent: ").append(network.getMutationPercent())
					.append(" ,Elitism: ").append(network.getElitism()).append(" ,Termination Criteria: ");
				
				if(network.isGenerationCriteriumChosen()){
					chartSubtitle.append(" Max Generations: " + network.getGenerations());
				}else{
					chartSubtitle.append(" Best Result did not change since: " + network.getGenerationsResults());
				}
			}
			
			chartSubtitle.append(recurrence.toString())
				.append(" , Mean Squared Error: ").append(network.getFinalMSEValue())
				.append(" ,R squared: ").append(network.getRSquared())
				.append(" ,Time used for training: ").append(network.getTimeTakenToTrain());
		}
		
		return new TextTitle("Dataset: " + datasetName + chartSubtitle.toString());
	}

	/**
	 * Add information concerning recurrence : is network is Elman recurrent, Jordan recurrent, CTRNN or none?
	 *  
	 * @param configuration ANN configuration.
	 * @return text message about any recurrence present.
	 */
	private String addRecurrenceInfo(NetworkConfiguration configuration) {
		
		StringBuilder recurrence = new StringBuilder();
		
		boolean isElman = configuration.isElmanRecurrent();
		boolean isJordan = configuration.isJordanRecurrent();
		boolean isCTRNN = configuration.isCtrnnNetwork();
		
		if(isElman){
			recurrence.append(" Elman");
		}
		if(isJordan){
			recurrence.append( " Jordan");
		}
		if(isCTRNN){
			recurrence.append( " CTRNN");
		}
		if(! isElman && ! isJordan && !isCTRNN){
			recurrence.append(" none");
		}
		
		return recurrence.toString();
	}
}
