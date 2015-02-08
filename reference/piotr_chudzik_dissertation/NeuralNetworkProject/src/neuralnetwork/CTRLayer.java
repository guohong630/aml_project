package neuralnetwork;

import java.util.ArrayList;
import java.util.List;

public class CTRLayer extends Layer{

	private static final long serialVersionUID = 1L;
	
	private List<CTRNeuron> ctrNeurons;

	public CTRLayer(int numberOfNeurons, int numberOfOutgoingWeights,
			int layerNumber, double weightsScaleFactor, double weightsShiftFactor) {
		
		this.ctrNeurons = new ArrayList<CTRNeuron>();
		
		for( int i = 0 ; i < numberOfNeurons ; i++ ){
			ctrNeurons.add(new CTRNeuron(numberOfOutgoingWeights, 0, layerNumber, i, "", numberOfNeurons, weightsScaleFactor, weightsShiftFactor));
		}
	}

	public List<CTRNeuron> getCTRNeurons() {
		return this.ctrNeurons;
	}

	public void setCTRNeurons(List<CTRNeuron> ctrNeurons) {
		this.ctrNeurons = ctrNeurons;
	}

}
