package utils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class NumberUtils {

	public static double capDoubleValue(Double number){
		
		if(number == Double.POSITIVE_INFINITY){
			number = Double.MAX_VALUE/1000;
		}else if(number == Double.NEGATIVE_INFINITY){
			number = Double.MIN_VALUE*1000;
		}
		return number;
	}
	public static double convertBigDecimalToDouble(BigDecimal number){
		
		return capDoubleValue(number.doubleValue());
	}
	
	public static List<BigDecimal> convertListOfDoublesToBigDecimals(List<Double> listOfDoubles){
		
		List<BigDecimal> convertedValues = new ArrayList<BigDecimal>();
		
		for(Double number : listOfDoubles){
			convertedValues.add(new BigDecimal(number));
		}
		
		return convertedValues;
	}
	
	public static List<Double> convertListOfBigDecimalsToDoubles(List<BigDecimal> listOfBigDecimals){
		
		List<Double> convertedValues = new ArrayList<Double>();
		
		for(BigDecimal number : listOfBigDecimals){
			convertedValues.add(convertBigDecimalToDouble(number));
		}		
		return convertedValues;
	}
}
