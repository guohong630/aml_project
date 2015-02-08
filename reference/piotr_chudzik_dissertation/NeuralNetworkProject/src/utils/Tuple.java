package utils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Tuple<F,S> implements Serializable{

	private static final long serialVersionUID = 1L;
	
	private F first;
	private S second;

	public Tuple(F first, S second) {
		this.first = first;
		this.second = second;
	}
	
	/**
	 *  Create a copy of a Tuple which consists of lists of doubles.
	 *  
	 *  We need to go through all elements because we want to copy values not references
	 *  and create a completely new object.
	 *  
	 * @param inputs list of inputs.
	 * @param outputs list of outputs.
	 * @return copy of an existing Tuple.
	 */
	public Tuple<List<Double>,List<Double>> copy(List<Double> inputs, List<Double> outputs){
		
		List<Double> copiedInputs = new ArrayList<Double>();
		List<Double> copiedOutputs = new ArrayList<Double>();
		
		for(Double input: inputs){
			copiedInputs.add(input);
		}
		
		for(Double output: outputs){
			copiedOutputs.add(output);
		}
				
		Tuple<List<Double>,List<Double>> copy = new Tuple<List<Double>,List<Double>>(copiedInputs, copiedOutputs);
		
		return copy;
	}

	public F getFirst() {
		return first;
	}

	public S getSecond() {
		return second;
	}
	
	public void setFirst(F first) {
		this.first = first;
	}

	public void setSecond(S second) {
		this.second = second;
	}
}
