package neuralnetwork;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * This class models a connection between two neurons
 * @author Piotr Chudzik (pcc9@aber.ac.uk)
 *
 */
public class Synapse implements Serializable{

	private static final long serialVersionUID = 1L;
	
	private String from;
	private String to;
	private String name;
	private double weight;
	
	public String getFrom() {
		return from;
	}
	public void setFrom(String from) {
		this.from = from;
	}
	public String getTo() {
		return to;
	}
	public void setTo(String to) {
		this.to = to;
	}
	public double getWeight() {
		return weight;
	}
	public void setWeight(double weight) {
		this.weight = weight;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
}
