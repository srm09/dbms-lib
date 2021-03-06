package edu.dbms.library.cli.screen;

import dnl.utils.text.table.TextTable;
import edu.dbms.library.cli.Constant;
import edu.dbms.library.cli.route.Route;
import edu.dbms.library.cli.route.RouteConstant;

public class PatronScreen extends BaseScreen {

	public PatronScreen() {
		super();
		options.put(1, new Route(RouteConstant.PATRON_PROFILE));
		options.put(2, new Route(RouteConstant.PATRON_RESOURCES));
		options.put(3, new Route(RouteConstant.PATRON_CHECKED_OUT));
		options.put(4, new Route(RouteConstant.PATRON_RES_REQUEST));
		options.put(5, new Route(RouteConstant.PATRON_NOTIFICATIONS));
		options.put(6, new Route(RouteConstant.PATRON_BALANCE));
		options.put(7, new Route(RouteConstant.LOGOUT));
	}
	
	@Override
	public void execute() {
		displayOptions();
		readInputLabel();
		Object o = readInput();
		while(!(o instanceof Integer)) {
			System.out.println("Incorrect input.");
			readInputLabel();
			o = readInput();
		}
		
		BaseScreen nextScreen = getNextScreen(options.get((Integer)o).getRouteKey());
		nextScreen.execute();
	}

	public void readInputLabel() {
		System.out.print("Enter your choice: ");
	}
	
	public Object readInput() {
		/*
		 * Buggy!! Returns incorrect input without any input
		 * 
		 * String option = inputScanner.nextLine();
		try {
			int correct = Integer.parseInt(option);
			return correct;
		} catch (Exception e) {
			return option;
		}*/
		int option = inputScanner.nextInt();
		return option;
	}
	
	@Override
	public void displayOptions() {
		
		String[] title = {""};
		String[][] options = { 
							{Constant.OPTION_PROFILE},
							{Constant.OPTION_RESOURCES},
							{Constant.OPTION_CHKDOUT_RES},
							{Constant.OPTION_RES_REQUEST},
							{Constant.OPTION_NOTIFICATIONS},
							{Constant.OPTION_BALANCE},
							{Constant.OPTION_LOGOUT}
							};
		TextTable tt = new TextTable(title, options);
		tt.setAddRowNumbering(true);
		tt.printTable();
	}
	
	/*public static void main(String []args) {
		SessionUtils.init("patron_id", true);
		SessionUtils.updateCurrentRoute("/patron");
		new PatronScreen().execute();
	}*/
}
