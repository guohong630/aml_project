package utils;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 * 
 * Class responsible for all non standard operations on lists which are not provided by 
 * standard java API. 
 *
 */
public class ListUtils {

	/**
	 * Create a data set used for evaluation.
	 * 
	 * @param mainList list containing all training examples.
	 * @param evaluationListRatio percentage of all training examples that will be used as evaluation data
	 * @return list containing all examples used for evaluation.
	 */
	public static List<Tuple<List<Double>,List<Double>>> getEvaluationDataList(
			List<Tuple<List<Double>,List<Double>>> mainList, double evaluationListRatio){
		
		int evaluationListSize = (int) Math.round(mainList.size() * evaluationListRatio);
		
		List<Tuple<List<Double>,List<Double>>> evaluationListView = mainList.subList(
				mainList.size() - evaluationListSize, mainList.size() - 1);
		
		List<Tuple<List<Double>,List<Double>>>  evaluationList = new ArrayList<Tuple<List<Double>,List<Double>>>(
				evaluationListView);
		// evaluationListView is backed by mainList hence this removes all sub-list items from mainList
		evaluationListView.clear();
		
		return evaluationList;
	}
	
	/**
	 * Create a deep copy of a list
	 * 
	 * @param originalList list to be copied
	 * @return copied List
	 */
	public static List<Tuple<List<Double>, List<Double>>> createListCopy(List<Tuple<List<Double>, List<Double>>> originalList){
		
		List<Tuple<List<Double>, List<Double>>> copiedList = new ArrayList<Tuple<List<Double>, List<Double>>>();
				
		for(Tuple<List<Double>, List<Double>> dataEntry : originalList){
			copiedList.add(dataEntry.copy(dataEntry.getFirst(), dataEntry.getSecond()));
		}
		return copiedList;
	}
}
