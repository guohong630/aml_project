package utils;

import java.util.List;

public class StatisticalUtils {

	/**
	 * Calculates R squared - coefficient of determination. R squared compares accuracy of a neural network results
	 * to the accuracy of a benchmark model where a prediction is calculated as a mean of all samples.
	 * 
	 * If R squared value is close to 1 it means that neural network results fit data really well and a neural network model 
	 * is a good estimator of this data.
	 * 
	 * If R squared value is less than 0 it means that neural network results are worse than results we could predict using
	 * mean of data outputs.
	 *  
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return R squared - coefficient of determination.
	 */
	public static double calculateCoefficientOfDetermination(List<Tuple<List<Double>, List<Double>>> outputs){
		
		double sumOfSquaredErrors = calculateSumOfSquaredErrors(outputs);
		
		double sumOfSquaredMeanErrors = calculateSumOfSquaredMeanErrors(outputs);
		
		return 1-(sumOfSquaredErrors/sumOfSquaredMeanErrors);
	}
	
	/**
	 * Calculates sum of squared differences between actual output value and mean expected output value.
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return sum of squared differences between actual output value and mean expected output value.
	 */ 
	private static double calculateSumOfSquaredMeanErrors(List<Tuple<List<Double>, List<Double>>> outputs) {
		
		double runningSum = 0;
		
		double meanOfExpectedOutputs = calculateMeanOfExpectedOutputs(outputs);
		
		for ( Tuple<List<Double>, List<Double>> tuple : outputs){			
			runningSum = runningSum + Math.pow(
					calculateAverageOutput( tuple.getSecond()) - meanOfExpectedOutputs, 2);
		}
		
		return runningSum;
	}

	/**
	 * Calculates mean of all expected outputs.
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return mean of all expected outputs.
	 */
	private static double calculateMeanOfExpectedOutputs(List<Tuple<List<Double>, List<Double>>> outputs) {
		
		double runningSum = 0;
		
		for ( Tuple<List<Double>, List<Double>> tuple : outputs){			
			runningSum = runningSum + calculateAverageOutput( tuple.getFirst());
		}
		
		return runningSum/outputs.size();
	}
	/**
	 * Calculates the mean square error given a List of expected outputs and a List of actual output
	 * per each training example (hence list of Tuples).
	 * 
	 * This method is designed to work with a list of expected and actual outputs but since we are
	 * trying to predict only one value in future those lists will have only one element each.
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return mean squared error value.
	 */
	public static double calculateMeanSquaredError(List<Tuple<List<Double>, List<Double>>> outputs){
		
		double allOutputsSum = calculateSumOfSquaredErrors(outputs);
		
		return allOutputsSum/outputs.size();
	}

	/**
	 * Calculates sum of all squared differences between actual and expected outputs.
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return a sum of all squared differences between actual and expected outputs.
	 */
	private static double calculateSumOfSquaredErrors( List<Tuple<List<Double>, List<Double>>> outputs) {
		
		double allOutputsSum = 0;
		
		for ( Tuple<List<Double>, List<Double>> tuple : outputs){			
			//Calculate the squared error between averaged actual output and averaged expected output.
			allOutputsSum = allOutputsSum + Math.pow(
					calculateAverageOutput( tuple.getSecond()) - calculateAverageOutput( tuple.getFirst()), 2);
		}
		return allOutputsSum;
	}

	/**
	 * Calculates average value of output given a list of outputs.
	 * 
	 * @param outputs a list of output values.
	 * @return average output value.
	 */
	private static double calculateAverageOutput(List<Double> outputs) {
		
		double outputsSum = 0;
				
		//get sum of all outputs
		for(Double output : outputs){
			outputsSum = outputsSum + output;
		}
		
		return outputsSum/outputs.size();
	}

	/**
	 * Calculates maximum absolute error.
	 *  
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @param currentMaximumAbsoluteError current maximum absolute error.
	 * @return updated maximum absolute error.
	 */
	public static double calculateMaximumAbsoluteError(
			List<Tuple<List<Double>, List<Double>>> outputs, double currentMaximumAbsoluteError) {
		
		double sumOfDifferences = calculateSumOfDifferences(outputs);
		
		if(sumOfDifferences > currentMaximumAbsoluteError){
			return sumOfDifferences;
		}else{
			return currentMaximumAbsoluteError;
		}
	}

	/**
	 * Calculates minimum absolute error.
	 * 
	 * @param outputs a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @param currentMinimumAbsoluteError current minimum absolute error.
	 * @param iterationNumber iteration number.
	 * @return updated minimum absolute error.
	 */
	public static double calculateMinimumAbsoluteError(
			List<Tuple<List<Double>, List<Double>>> outputs, double currentMinimumAbsoluteError,
			int iterationNumber) {
		
		double sumOfDifferences = calculateSumOfDifferences(outputs);
		
		if( iterationNumber == 0){
			return sumOfDifferences;
		}else if(sumOfDifferences < currentMinimumAbsoluteError){
			return sumOfDifferences;
		}else{
			return currentMinimumAbsoluteError;
		}
	}

	/**
	 * This method calculates a total sum of all differences between averaged expected and actual 
	 * outputs needed to calculate mean square error.
	 *  
	 * @param outputs  a list of tuples. A single tuple contains a pair of lists: a list of expected
	 * outputs and a list of actual outputs.
	 * @return a total sum of all differences between averaged expected and actual outputs.
	 */
	private static double calculateSumOfDifferences(List<Tuple<List<Double>, List<Double>>> outputs) {
		
		double sumOfDifferences = 0;
		
		for (Tuple<List<Double>, List<Double>> tuple : outputs){
			
			sumOfDifferences = sumOfDifferences + Math.abs(calculateAverageOutput( tuple.getFirst())
					- calculateAverageOutput( tuple.getSecond()));//expected output - actual output
		}
		return sumOfDifferences;
	}

}
