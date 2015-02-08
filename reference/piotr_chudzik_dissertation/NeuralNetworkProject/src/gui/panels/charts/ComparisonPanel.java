package gui.panels.charts;

import java.awt.BorderLayout;
import java.awt.Color;
import java.text.DecimalFormat;
import java.util.List;
import java.util.Map;

import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

import exception.NeuralNetworkException;

public class ComparisonPanel extends ChartPanel {

	private static final long serialVersionUID = 1L;

	public ComparisonPanel(){
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null), 
				"MSE Comparison Chart", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		
		this.setLayout(new BorderLayout());
	}

	public void drawComparisonChart(List<Network> networks) throws NeuralNetworkException {
		 
		this.removeAll();//Clear Display
		
		org.jfree.chart.ChartPanel chartPanel = null;
		
		chartPanel = createScatteredChart(networks, "Training Comparison Chart", "Epochs", "Mean Square Error Value");
		
		this.add((chartPanel), BorderLayout.CENTER);		
		this.revalidate();				
	}
	
	@Override
	public XYDataset createDataset(List<Network> networks){
	
		XYSeriesCollection dataset = new XYSeriesCollection();
		
		//Round R squared to some more human readable form
		DecimalFormat twoDForm = new DecimalFormat("#.##########");
		
		for(Network network : networks){
				
			double rsquared = 0.00;
			try{
				rsquared =  Double.valueOf(twoDForm.format(network.getRSquared()));
			}catch(Exception e){
				//Do nothing - if for some reason R squared is invalid (e.g. NaN) ignore it and use default.
			}
			XYSeries meanSquareErrorSeries = new XYSeries("R squared:" + rsquared);

			for (Map.Entry<Integer, Double> entry : network.getMSEData().entrySet()) {
				meanSquareErrorSeries.add(entry.getKey(), entry.getValue());
			}
		dataset.addSeries(meanSquareErrorSeries);
		}
		
		return dataset;
	}

}
