module lang::ql::gen::Generic


public str header() = 
"/*
 * DO NOT EDIT THIS FILE
 * THIS FILE IS AUTOMATICALLY GENERATED
 */
 
package form;
";


public str imports() = "
import com.trolltech.qt.core.*;
import com.trolltech.qt.gui.*;
import org.json.simple.*;
import java.util.*;
import java.io.*;
";

public str declarations() = "
public class FormGUI extends QWidget {

	List\<QLabel\> labels = new ArrayList\<QLabel\>();
 	Map\<QLabel, Boolean\> visibilityMap = new HashMap\<QLabel, Boolean\>();
";

public str main() = "
	public static void main(String args[]) {
		QApplication.initialize(args);
	    FormGUI formGUI = new FormGUI();
	    formGUI.move(200, 200);
	    formGUI.show();
	    //formGUI.setFixedWidth(formGUI.width());
	    QApplication.exec();
	}	
";

public str constructor() = "
	public FormGUI() {
	 	QGridLayout layout = new QGridLayout();
	 	setLayout(layout);
	 	QPushButton submitButton = new QPushButton(\"Submit\");
	 	submitButton.clicked.connect(this, \"onClicked()\");
";

public str addTitle(str name) = "
		setWindowTitle(\"<name>\");";

public str gridLayout() = "	 
		int labelMinWidth = 0, widgetMinWidth = 0;	
	 	for (int i = 0; i \< labels.size(); i++) {
	 		labels.get(i).setVisible(true);
			labels.get(i).buddy().setVisible(true);
	 		layout.addWidget(labels.get(i), i, 0,  Qt.AlignmentFlag.AlignRight);
	 		layout.addWidget(labels.get(i).buddy(), i, 1);
			if (labels.get(i).width() \> labelMinWidth) 
	 			labelMinWidth = labels.get(i).width();
	 		if (labels.get(i).buddy().width() \> widgetMinWidth)
	 			widgetMinWidth = labels.get(i).buddy().width();
	 	}
		layout.setColumnMinimumWidth(0, labelMinWidth);
		layout.setColumnMinimumWidth(1, widgetMinWidth);
";
	 	
public str visibility() = "
	 	updateVisibility();
	 	layout.addWidget(submitButton, labels.size(), 0, 1, 2, Qt.AlignmentFlag.AlignCenter);
	}
	
	private void updateVisibility() {
		for (int i = 0; i \< labels.size(); i++) {
			labels.get(i).setVisible(visibilityMap.get(labels.get(i)));
			labels.get(i).buddy().setVisible(visibilityMap.get(labels.get(i)));
		}
	}
	
	private void onChanged() {
";

public str slots() = "
		updateVisibility();
	}
	 	
	private void onChanged(boolean value) {
		onChanged();
	}
	private void onChanged(int value) {
		onChanged();
	}
	private void onChanged(String value) {
		onChanged();
	}
	private void onChanged(double value) {
		onChanged();
	}
	private void onChanged(QDate value) {
		onChanged();
	}

	private void onClicked() {
		JSONObject obj=new JSONObject();
";
	
	
public str submit() = "	
		System.out.println(obj);
		PrintWriter out = null;
		try{
			out = new PrintWriter(new FileWriter(\"form.answers\")); 
  			out.println(obj);
  		} catch (Exception e) {
  			System.err.println(\"Error: \" + e.getMessage());
  		} finally {
			out.close();
		}
		QApplication.quit();
	}
}
";
