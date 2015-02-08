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

import exception.NeuralNetworkException;

import utils.DateUtils;
import utils.Tuple;

public class EvaluationChartPanel extends ChartPanel {

private static final long serialVersionUID = 1L;
	
	/**
	 * A currency rate chart should have only two inputs (Date and Time) which together are treated
	 * as X coordinate in Cartesian Space and two outputs (expected and actual close Value) which
	 * are treated as Y coordinate in Cartesian Space (for two time series diagrams).
	 */
	private static final int NUMBER_OF_CHART_INPUTS = 2;
	private static final int NUMBER_OF_CHART_OUTPUTS = 2;

	public EvaluationChartPanel(){
		
		super();
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null), "Evaluation Chart",
				TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		
		this.setLayout(new BorderLayout(0, 0));
		
	}

	public void drawMainChart(List<Network> networks) 
			throws NeuralNetworkException {
		
		this.removeAll();//Clear Display
		
		org.jfree.chart.ChartPanel chartPanel = createTimeSeriesChart(networks,"Evaluation Comparison Chart", "Date and Time", "Close Value");
						
		this.add((chartPanel), BorderLayout.CENTER);
		this.revalidate();
	}
	
	@Override
	public XYDataset createDataset(List<Network> networks)
			throws NeuralNetworkException{
		
		TimeSeriesCollection dataset = new TimeSeriesCollection();
		TimeSeries expectedCurrencyRateChart = new TimeSeries("Expected CR");
		boolean expectedCurrencyChartIsFull = false;
		dataset.addSeries(expectedCurrencyRateChart);
		
		for(Network network : networks){
			TimeSeries actualCurrencyRateChart = new TimeSeries("Predicted CR with R squared: " + network.getEvaluationRsquared());
		
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
	//				throw new Exception("Expected are 2 output values (expected and actual close Value) but actual is "
	//						+ closeValues.size());
					break;//For now since not all evaluation elements are updating - check
				}
				try{
					if(isMinuteChart){
						if(!expectedCurrencyChartIsFull){
							expectedCurrencyRateChart.add(new Minute(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
									(int)Math.round(datesAndTimes.get(1)))), closeValues.get(0));
						}
						
						actualCurrencyRateChart.add(new Minute(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
								(int)Math.round(datesAndTimes.get(1)))), closeValues.get(1));
					}else{//Hours
						if(!expectedCurrencyChartIsFull){
							expectedCurrencyRateChart.add(new Hour(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
									(int)Math.round(datesAndTimes.get(1)))), closeValues.get(0));
						}
						
						actualCurrencyRateChart.add(new Hour(DateUtils.convertDate((int) Math.round(datesAndTimes.get(0)),
								(int)Math.round(datesAndTimes.get(1)))), closeValues.get(1));
					}
				}catch(ParseException exception){
					throw new NeuralNetworkException("Failed to parse input data in order to draw evaluation chart due to error: " 
							+ exception.getMessage());
				}
			}
			dataset.addSeries(actualCurrencyRateChart);
			expectedCurrencyChartIsFull = true;
		}
		return dataset;
	}
}
