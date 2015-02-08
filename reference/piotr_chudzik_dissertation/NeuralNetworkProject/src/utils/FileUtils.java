package utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.swing.JFileChooser;

import neuralnetwork.Network;

import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVStrategy;
import org.apache.commons.io.IOUtils;


public class FileUtils {

	/**
	 * Folder names were input and results .csv files are stored.
	 */
	private static final String INPUT_FOLDER_NAME = "InputData/";
	private static final String RESULTS_FOLDER_NAME = "Results/";
	private static final String NETWORKS_FOLDER_NAME = "Networks/";
	private static final String INPUT_FILE_FORMAT = ".csv";
	private static final String SAVED_FILE_FORMAT = ".ser";
	
	/**
	 *  Each .csv data file is delimited by "|" and everything inside " " will be treated as a single string.
	 *  So e.g. "first|sentence" is treated as a single string/entry not two.
	 */
	public static final char FILE_DELIMITER = '|';
	private static final char FILE_ENCAPSULATOR = '"';
	private static final String FILE_NAME_DELIMITER = "__";
	
	/**
	 *  Each .csv data will have a list of headers at the beginning of file.
	 *  Some headers will include "Input" or "Output" words meaning that they should
	 *  be treated as inputs or outputs.
	 */
	private static final String INPUT_HEADER = "INPUT";
	private static final String OUTPUT_HEADER = "OUTPUT";
	
	/**
	 *  Those phrases are included into .csv file headers identifying columns
	 *  that are used for drawing a specific currency rate change chart.
	 */
	private static final String X_VALUE_HEADER = "XVALUE";
	private static final String Y_VALUE_HEADER = "YVALUE";

	public static List<Tuple<List<Double>,List<Double>>> retrieveInputData(String inputFileName, boolean isChartData) 
			throws FileNotFoundException {
		
		/**
		* Data will be stored as a list of tuples where
		* A Single Tuple represents a single training instance
		* Tuple = List of Input Values, List of Output Values
		*/
		List<Tuple<List<Double>,List<Double>>> data = new ArrayList<Tuple<List<Double>,List<Double>>>();
		
		List<Integer> inputIndexes = new ArrayList<Integer>();
		List<Integer> outputIndexes = new ArrayList<Integer>();
		
		String filePath = INPUT_FOLDER_NAME + inputFileName;
		
		BufferedReader br = null;		
		FileInputStream fstream = getFileInputStream(filePath);
		
		/**
		 * Those phrases determine if a column should be treated as input or output.
		 */
		String inputHeaderPhrase = null;
		String outputHeaderPhrase = null;
		
		//Get Date,Time(x) as Inputs and Close value as output(y) - used as coordinates for currency rate chart.
		if(isChartData){
			inputHeaderPhrase = X_VALUE_HEADER;
			outputHeaderPhrase = Y_VALUE_HEADER;
		}else{//Data is used as inputs and outputs for a neural network.
			inputHeaderPhrase = INPUT_HEADER;
			outputHeaderPhrase = OUTPUT_HEADER;
		}
		
        try{
            br = new BufferedReader(new InputStreamReader(fstream));

            CSVParser csvParser = new CSVParser(br, new CSVStrategy(FILE_DELIMITER,
            		FILE_ENCAPSULATOR, CSVStrategy.COMMENTS_DISABLED));
            String[] fields = csvParser.getLine(); // Headers
            
            if(fields == null){
                throw new Exception("Failed to find any content in " + filePath);
            }
            for( int i=0 ; i < fields.length ; i ++){
            	String headerName = fields[i];
            	if(headerName.contains(inputHeaderPhrase)){
            		inputIndexes.add(i);
            	}
            	if(headerName.contains(outputHeaderPhrase)){//A field can be used as both input and output
            		outputIndexes.add(i);
            	}
            }
 
            
            // load each .csv file line...
            while((fields = csvParser.getLine()) != null){
            	
            	List<Double> inputs = new ArrayList<Double>();
            	List<Double> outputs = new ArrayList<Double>();
            	
            	for( int i=0 ; i < fields.length ; i ++){
            		double value = Double.parseDouble(fields[i]);
            		if(inputIndexes.contains(i)){
            			inputs.add(value);
            		}
            		if(outputIndexes.contains(i)){
            			outputs.add(value);
            		}
            	}
            	if(inputs.size() > 0 && outputs.size() > 0){
            		data.add(new Tuple<List<Double>, List<Double>>(inputs, outputs));	
            	}
            }

        }catch (Exception e) {
                if(br != null){
                    try{
                    br.close();
                    }catch(Exception e1){
                        //do nothing
                    }
                }
        }finally {
        	IOUtils.closeQuietly(br);
        } 
		return data;
	}

	private static FileInputStream getFileInputStream(String filePath)
			throws FileNotFoundException {

		try {
			return new FileInputStream(filePath + INPUT_FILE_FORMAT);
		} catch (FileNotFoundException e) {
			throw new FileNotFoundException("Failed to retrieve file "
					+ filePath + " due to error:" + e.getMessage());
		}
	}
	
	/**
	 * Saves a network as a serialized object.
	 * 
	 * The saved file name is of a format "TrainingSet__TrainingAlgorithm__MSE";
	 * @param network an object to be saved.
	 */
	public static void saveNetwork(Network network){
		
		ObjectOutputStream oos = null;
		try {

			FileOutputStream fout = new FileOutputStream(NETWORKS_FOLDER_NAME
					+ FILE_NAME_DELIMITER + network.getDatasetName()
					+ FILE_NAME_DELIMITER + network.getTrainingAlgorithmUsed()
					+ FILE_NAME_DELIMITER + network.getRSquared()
					+ FILE_NAME_DELIMITER + String.valueOf(network.getFinalMSEValue()).replaceAll("\\.", FILE_NAME_DELIMITER)
					+ SAVED_FILE_FORMAT);
			oos = new ObjectOutputStream(fout);
			oos.writeObject(network);

		} catch (Exception ex) {
			ex.printStackTrace();
		}finally {
        	IOUtils.closeQuietly(oos);
        } 
	}

	public static List<Network> loadNetworks(boolean multipleSelection) {
		
		List<Network> networks = new ArrayList<Network>();
		
		File[] loadedFiles = getSavedFiles(multipleSelection);
		
		for(File loadedFile: loadedFiles){
			networks.add( getNetwork(loadedFile));
		}
		
		return networks;
	}
	
	private static Network getNetwork(File loadedFile) {

		if(loadedFile == null){
			return null;
		}
		ObjectInputStream ois = null;
		try {

			FileInputStream fin = new FileInputStream(loadedFile);
			ois = new ObjectInputStream(fin);
			return (Network) ois.readObject();			
		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}
		finally {
        	IOUtils.closeQuietly(ois);
        } 
	}

	/**
	 * Retrieve files chosen by a user.
	 */
	private static File[] getSavedFiles(boolean multipleSelection)
	{
		JFileChooser fileChooser = new JFileChooser(NETWORKS_FOLDER_NAME);
		fileChooser.setMultiSelectionEnabled(true);
        int returnValue = fileChooser.showOpenDialog(null);
        if (returnValue == JFileChooser.APPROVE_OPTION)
        {
          return fileChooser.getSelectedFiles();      
        }
        return null;
	}
}
