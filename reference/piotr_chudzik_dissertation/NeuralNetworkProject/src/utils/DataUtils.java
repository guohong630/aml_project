package utils;

import java.util.ArrayList;
import java.util.List;

import business.NetworkConstants;

import neuralnetwork.NetworkConfiguration;

public class DataUtils {
	
	/**
	 * Data will be normalized to the range {0,1}
	 */
	private static final int NORMALIZED_OUTPUT_MIN = 0;
	private static final int NORMALIZED_OUTPUT_MAX = 1;
	
	private static List<Double> inputMins;
	private static List<Double> inputMaxs;
	private static List<Double> outputMins;
	private static List<Double> outputMaxs;
	

	public static void normalizeData(List<Tuple<List<Double>, List<Double>>> inputData){
		
		inputMins = new ArrayList<Double>();
		inputMaxs = new ArrayList<Double>();
		outputMins = new ArrayList<Double>();
		outputMaxs = new ArrayList<Double>();
		getMarginalPoints(inputData);
		
		for(Tuple<List<Double>, List<Double>> datasetEntry : inputData){
			normalizeSingleEntry(datasetEntry.getFirst());//For inputs
			normalizeSingleEntry(datasetEntry.getSecond());//For outputs
		}
		
		
	}
	
	public static void denormalizeData(List<Tuple<List<Double>, List<Double>>> inputData){
		
		for(Tuple<List<Double>, List<Double>> datasetEntry : inputData){
			denormalizeSingleEntry(datasetEntry.getFirst());//For inputs
			denormalizeSingleEntry(datasetEntry.getSecond());//For outputs
		}
		
		
	}

	private static void denormalizeSingleEntry(List<Double> data) {
		
		for( int i=0 ; i < data.size() ; i++){
			
			double inputMin = inputMins.get(i);
			double inputMax = inputMaxs.get(i);			
			
			double denormalizedValue = ((inputMin - inputMax) * data.get(i) 
					- NORMALIZED_OUTPUT_MAX * inputMin
					+ inputMax * NORMALIZED_OUTPUT_MIN)
					/(NORMALIZED_OUTPUT_MIN - NORMALIZED_OUTPUT_MAX);
			
			data.set(i, denormalizedValue);
		}
		
	}

	private static void normalizeSingleEntry(List<Double> data) {
		
		for( int i=0 ; i < data.size() ; i++){
			
			double inputMin = inputMins.get(i);
			double inputMax = inputMaxs.get(i);			
			
			double normalizedValue = ((data.get(i) - inputMin)/(inputMax - inputMin)) 
					* (NORMALIZED_OUTPUT_MAX - NORMALIZED_OUTPUT_MIN) + NORMALIZED_OUTPUT_MIN;
			
			data.set(i, normalizedValue);
		}
		
	}

	/**
	 * Finds input and output minimum and maximum values of provided dataset needed for normalization process
	 * @param inputData
	 */
	private static void getMarginalPoints(List<Tuple<List<Double>, List<Double>>> inputData) {
		
		for( int count = 0; count < inputData.size() ; count++){
			List<Double> inputs = inputData.get(count).getFirst();
			List<Double> outputs = inputData.get(count).getSecond();
			
			calculateMinMax(inputs, inputMins, inputMaxs, count);//For inputs
			calculateMinMax(outputs, outputMins, outputMaxs, count);//For outputs			
		}	
	}

	/**
	 *  Calculate minimum and maximum values for a single training example(dataset entry).
	 * @param count 
	 */
	private static void calculateMinMax(List<Double> data, List<Double> minValues, List<Double> maxValues, int count) {
		
		for( int i=0 ; i < data.size() ; i++){
			if(count == 0){//First iteration hence all list are empty
				minValues.add(data.get(i));//Add first value
				maxValues.add(data.get(i));//Add first value
			}
			else if(minValues.get(i) > data.get(i)){  // If current value is smaller than current dataset minimum - update min
				// with this value
				minValues.set(i, data.get(i));
			}
			else if(maxValues.get(i) < data.get(i)){ // If current value is bigger than current dataset maximum - update max
				maxValues.set(i, data.get(i));
			}
		}
	}
	
public static void convertToPercentageData(List<Tuple<List<Double>, List<Double>>> trainingData) {
		
		boolean isFirstTrainingExample = true;
		Tuple<List<Double>, List<Double>> previousTrainingExample = null;
		
		for(Tuple<List<Double>, List<Double>> trainingExample : trainingData){
			List<Double> inputs = trainingExample.getFirst();
			List<Double> outputs = trainingExample.getSecond();
			
			//Create a copy to be used by next training example
			Tuple<List<Double>, List<Double>> copyTrainingExample = trainingExample.copy(inputs, outputs);
			
			if( ! isFirstTrainingExample){
				
				List<Double> previousInputs = previousTrainingExample.getFirst();
				List<Double> previousOutputs = previousTrainingExample.getSecond();
				
				//Convert Inputs
				calculatePercentageChange(previousInputs, inputs);
				
				//Convert Outputs
				calculatePercentageChange(previousOutputs, outputs);
				
			}else{//First Training Example
				
				//Since this is initial training example there is no percentage change hence all values are 0s.
				//zeroAllData(inputs);
				//zeroAllData(outputs);
				
				isFirstTrainingExample = false;
			}
			
			previousTrainingExample = copyTrainingExample;
		}		
	}

	private static void calculatePercentageChange(List<Double> previous, List<Double> current) {
		
		for(int index = 0 ; index < current.size() ; index++){
			current.set(index, calculateSinglePercentageChange(previous.get(index), current.get(index)));
			if(Double.isInfinite(current.get(index)) || Double.isNaN(current.get(index)) ){
				System.out.println("as");//PCH debug
			}
		}
		
	}

	private static Double calculateSinglePercentageChange(Double previousValue, Double currentValue) {
		
//		if(previousValue == 0.0){
//			previousValue = 0.0000001;//Smallest positive non zero.
//		}
		double change = currentValue - previousValue;
		double percentChange = change/previousValue;
		
		//Clip peripherial values
		if(percentChange > NetworkConstants.MAX_PERCENTAGE_INCREASE){
			percentChange = NetworkConstants.MAX_PERCENTAGE_INCREASE;
		}else if (percentChange < NetworkConstants.MIN_PERCENTAGE_INCREASE){
			percentChange = NetworkConstants.MIN_PERCENTAGE_INCREASE;
		}
		
		if(Double.isInfinite(percentChange) || Double.isNaN(percentChange) ){
			System.out.println("as");//PCH debug
			//Clip peripherial values
			if(percentChange > NetworkConstants.MAX_PERCENTAGE_INCREASE){
				percentChange = NetworkConstants.MAX_PERCENTAGE_INCREASE;
			}else if (percentChange < NetworkConstants.MIN_PERCENTAGE_INCREASE){
				percentChange = NetworkConstants.MIN_PERCENTAGE_INCREASE;
			}
		}
		
		return percentChange;
	}
}
