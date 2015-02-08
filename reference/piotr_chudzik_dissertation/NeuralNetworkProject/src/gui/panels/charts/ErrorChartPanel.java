package gui.panels.charts;

import java.awt.BorderLayout;
import java.awt.Color;
import java.util.List;
import java.util.Map;

import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

import exception.NeuralNetworkException;

public class ErrorChartPanel extends ChartPanel {

	private static final long serialVersionUID = 1L;

	public ErrorChartPanel(){
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null), 
				"Error Chart", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		
		this.setLayout(new BorderLayout());
	}

	public void drawMeanSquareErrorChart(Network network) throws NeuralNetworkException {
		 
		this.removeAll();//Clear Display
		
		org.jfree.chart.ChartPanel chartPanel = createScatteredChart(network,
				"Mean Square Error Chart", "Epochs", "Mean Square Error Value");
		
		this.add((chartPanel), BorderLayout.CENTER);		
		this.revalidate();				
	}
	
	@Override
	public XYDataset createDataset(List<Network> networks){
	
		XYSeries meanSquareErrorSeries = new XYSeries("Mean Square Error");
		XYSeriesCollection dataset = new XYSeriesCollection();

		for(Network network : networks){
			for (Map.Entry<Integer, Double> entry : network.getMSEData().entrySet()) {
				meanSquareErrorSeries.add(entry.getKey(), entry.getValue());
			}
			dataset.addSeries(meanSquareErrorSeries);
		}	
		return dataset;
	}

}
