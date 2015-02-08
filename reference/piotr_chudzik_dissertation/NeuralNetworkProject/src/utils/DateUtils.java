package utils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class DateUtils {

	public static final String DATE_FORMAT = "yyyyMMddHHmm";
	
	/**
	 *  Converts day and hour integer into java.util.Date object
	 */
	public static Date convertDate(int day, int hour) throws ParseException{
		
		String hourString = String.valueOf(hour);
		while(hourString.length() != 4){//means that leading "0"s were truncated due to conversion to Double.class			
			hourString = "0"+hourString;
		}
		DateFormat formatter = new SimpleDateFormat(DATE_FORMAT);
		try {
			return formatter.parse(String.valueOf(day) + hourString);
		} catch (ParseException e) {
			throw new ParseException(" Failed to convert day " + day + " and hour " + hour 
					+ " data into java.util.Date object due to " + e.getMessage(), 0);
		}
	}
	
	public static String convertMilisToHours(long miliseconds){
		
		long hours = TimeUnit.MILLISECONDS.toHours(miliseconds);
		long minutes = TimeUnit.MILLISECONDS.toMinutes(miliseconds) - (hours* 60);
		long seconds = TimeUnit.MILLISECONDS.toSeconds(miliseconds) - (TimeUnit.MILLISECONDS.toMinutes(miliseconds) *60);
		
		StringBuilder time = new StringBuilder();
		time.append(convertToTimeFormat(hours)).append(":").append(convertToTimeFormat(minutes)).append(":")
			.append(convertToTimeFormat(seconds));	
		
		return time.toString();
	}

	private static String convertToTimeFormat(long time) {
		
		String timeUnit = String.valueOf(time);
		if(timeUnit.length() == 1){
			return "0" + timeUnit;
		}else{
			return timeUnit;
		}
	}
}
