package gui.panels.charts;

import java.awt.BorderLayout;
import java.awt.Color;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

import neuralnetwork.Network;

import org.jfree.data.time.Hour;
import org.jfree.data.time.Minute;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.xy.XYDataset;

import business.NetworkConstants;

import exception.NeuralNetworkException;

import utils.DateUtils;
import utils.Tuple;

public class MainChartPanel extends ChartPanel {

	private static final long serialVersionUID = 1L;
	
	/**
	 * A currency rate chart should have only two inputs (Date and Time) which together are treated
	 * as X coordinate in Cartesian Space and one output (Close Value) which is treated as Y coordinate
	 * in Cartesian Space.
	 */
	private static final int NUMBER_OF_CHART_INPUTS = 2;
	private static final int NUMBER_OF_CHART_OUTPUTS = 1;

	public MainChartPanel(){		
		super();
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null), "Main Chart",
				TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		
		this.setLayout(new BorderLayout(0, 0));
		
	}

	public void drawMainChart(Network network) throws Exception {
		
		this.removeAll();//Clear Display
		
		List<Network> networks = new ArrayList<Network>();
		networks.add(network);
		
		org.jfree.chart.ChartPanel chartPanel = createTimeSeriesChart(networks, "Currency Exchange Rate Chart",
				"Date and Time", "Close Value");
		
		this.add((chartPanel), BorderLayout.CENTER);	
		this.revalidate();
	}
	
	@Override
	public XYDataset createDataset(List<Network> networks) throws NeuralNetworkException{
		
		TimeSeriesCollection dataset = new TimeSeriesCollection();
		
		for(Network network: networks){
			TimeSeries currencyRateChart = new TimeSeries("Currency Rate Chart");
			
			boolean isMinuteChart = false;
			
			if(network.getDatasetName().contains("MIN")){
				isMinuteChart = true;
			}
			
			for (Tuple<List<Double>, List<Double>> entry : network.getEvaluationResults())
			{
				List<Double> datesAndTimes = entry.getFirst();
				if(datesAndTimes.size() != NUMBER_OF_CHART_INPUTS){
					throw new NeuralNetworkException("Expected number of inputs for currency rate chart is 2 (Date and Time) " +
							" but actual is " + datesAndTimes.size());
				}
				
				List<Double> closeValues = entry.getSecond();
				if(closeValues.size() != NUMBER_OF_CHART_OUTPUTS){
					throw new NeuralNetworkException(" More than 1 output value found for currency rate chart. " +
							"Expected is 1 (Close Value) but actual is " + closeValues.size());
				}
				try{
					if(isMinuteChart){
						currencyRateChart.add(new Minute(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
								(int)Math.round(datesAndTimes.get(1)))), closeValues.get(0));
					}else{//Hour chart
						currencyRateChart.add(new Hour(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
								(int)Math.round(datesAndTimes.get(1)))), closeValues.get(0));
					}
				}catch(ParseException exception){
					throw new NeuralNetworkException(exception.getMessage());
				}
			}
			dataset.addSeries(currencyRateChart);
		}
		return dataset;
	}

}
