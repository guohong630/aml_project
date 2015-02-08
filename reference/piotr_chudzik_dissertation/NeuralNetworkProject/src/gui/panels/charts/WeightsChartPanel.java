package gui.panels.charts;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GradientPaint;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.swing.JPanel;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.xy.DefaultXYZDataset;
import org.jfree.data.xy.MatrixSeriesCollection;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.data.xy.XYZDataset;
import org.jfree.ui.RectangleInsets;

import exception.NeuralNetworkException;

public class WeightsChartPanel extends ChartPanel {

	private static final long serialVersionUID = 1L;

	public WeightsChartPanel(){
		super();

		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED,
				null, null), "Weights and Error Correlation", TitledBorder.LEADING,
				TitledBorder.TOP, null, Color.BLUE));

		this.setLayout(new BorderLayout());
}

	public void drawWeightsChart(Network network) throws NeuralNetworkException {
		
		this.removeAll();//Clear Display
			
		org.jfree.chart.ChartPanel chartPanel = createScatteredChart(network, "Weights change in relation to MSE", 
				"Weights", "Mean Square Error Value");
		
		this.add((chartPanel), BorderLayout.CENTER);	
		this.revalidate();		
	}
	
	@Override
	public XYDataset createDataset(List<Network> networks){
		
		XYSeriesCollection datasetOfAllSynapses = new XYSeriesCollection();
		
		for(Network network : networks){
			Map<String, Map<Integer, Double>> synapseWeights = network.getSynapseWeights();
			
			//Create dataset for each synapse
			for(Map.Entry<String, Map<Integer, Double>> synapseEntry : synapseWeights.entrySet()){
				
				XYSeries synapseSeries = new XYSeries(synapseEntry.getKey());
				
				//Key - iteration number , Value - weight value
				Map<Integer, Double> allSynapseWeights = synapseEntry.getValue();
				
				for (Map.Entry<Integer, Double> synapseWeightEntry : allSynapseWeights.entrySet()){
					Map<Integer, Double> MSEData = network.getMSEData();
					for (Map.Entry<Integer, Double> MSEentry : MSEData.entrySet()){
						if(synapseWeightEntry.getKey() == MSEentry.getKey()){
							synapseSeries.add(synapseWeightEntry.getValue(), MSEentry.getValue());
							break;
						}
					}
				}
						
				datasetOfAllSynapses.addSeries(synapseSeries);
			}
		}
	return datasetOfAllSynapses;
	}
}
