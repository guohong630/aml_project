package gui.panels.controls;

import java.awt.Color;
import java.awt.Font;

import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.ScrollPaneConstants;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;


public class StatusPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	private JTextArea statusArea;

	public StatusPanel(){
		super();
		
		this.setBorder(new TitledBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null),
				"Status", TitledBorder.LEADING, TitledBorder.TOP, null, Color.BLUE));
		this.setToolTipText("Status Details");
		
		statusArea = new JTextArea(3,38);
		statusArea.setLineWrap(true);
		statusArea.setWrapStyleWord(true);
		statusArea.setEditable(false);
		statusArea.setFont(new Font("Serif", Font.PLAIN, 26));
		updateStatusLabel("Welcome! Are you ready to get rich?", false);
		
		this.add(statusArea);
	}
	
	public void updateStatusLabel(String message, boolean isError){
		statusArea.setText(message);
		if(isError){
			statusArea.setForeground(Color.RED);
		}else{
			statusArea.setForeground(Color.BLACK);
		}
		this.revalidate();
		//this.repaint();
	}
}
