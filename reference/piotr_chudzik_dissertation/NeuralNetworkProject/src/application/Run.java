package application;

import gui.frames.ErrorFrame;
import gui.frames.EvaluationFrame;
import gui.frames.MainChartFrame;
import gui.frames.MainFrame;
import gui.frames.WeightsFrame;
import gui.panels.charts.ComparisonPanel;
import gui.panels.charts.ErrorChartPanel;
import gui.panels.charts.EvaluationChartPanel;
import gui.panels.charts.MainChartPanel;
import gui.panels.charts.WeightsChartPanel;
import neuralnetwork.Network;

public class Run {
	
	public static void main(String... aArgs){
		
		Network network= new Network();
		
		MainChartPanel mainChart = new MainChartPanel();
		ErrorChartPanel errorChart = new ErrorChartPanel();
		WeightsChartPanel weightsChart = new WeightsChartPanel();
		EvaluationChartPanel evaluationChart = new EvaluationChartPanel();
		ComparisonPanel trainingComparisonChart = new ComparisonPanel();
		EvaluationChartPanel evaluationComparisonChart = new EvaluationChartPanel();
		
		MainFrame mainFrame = new MainFrame(network, mainChart, errorChart, 
				weightsChart, evaluationChart, trainingComparisonChart, evaluationComparisonChart);
	}
}
