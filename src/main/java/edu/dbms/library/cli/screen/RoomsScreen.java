/**
 *
 */
package edu.dbms.library.cli.screen;

import java.awt.Container;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import edu.dbms.library.cli.route.Route;
import edu.dbms.library.cli.route.RouteConstant;
import edu.dbms.library.db.DBUtils;
import edu.dbms.library.db.manager.RoomsManager;
import edu.dbms.library.entity.Library;
import edu.dbms.library.entity.resource.Room;
import edu.dbms.library.session.SessionUtils;

/**
 * @author ARPIT
 *
 */
public class RoomsScreen extends BaseScreen {

	/**
	 *
	 */
	public RoomsScreen() {
		super();
		options.put(2, new Route(RouteConstant.BACK));
	}

	/* (non-Javadoc)
	 * @see edu.dbms.library.cli.screen.BaseScreen#execute()
	 */
	@Override
	public void execute() {
		//displayOptions(options, "Book a Room");


		String[][] options = {{"Book Rooms"},{"Check-out/Cancel Booked Room"},{"Check-In Room"},{"Back"},{"Logout"}};
		String[] title = {"Options"};
		displayOptions(options, title);
		int choice = readOptionNumber("Enter a choice", 1, 5);
		clearConsole();
		switch(choice)
		{
		case 1:
			bookRoom();
			break;
		case 2:
			checkoutRoom();
			break;
		case 3:
			checkinRoom();
			break;
		case 4:
			getNextScreen(RouteConstant.BACK).execute();
			break;
		case 5:
			getNextScreen(RouteConstant.LOGOUT).execute();
			break;
		}
		//if(options);
		//if(option==2)
		//nextScree
		//diplayAvailableRooms();
	}


	private void checkinRoom() {
		System.out.println("=============CheckIn Room==========");
		int choice = -1;
		List<Object[]> rooms = RoomsManager.getCheckedOutRooms();
		String[][] _rooms = new String[rooms.size()][3];
		int i=0;
		for (Iterator iterator = rooms.iterator(); iterator.hasNext();) {
			Object[] room = (Object[]) iterator.next();
			_rooms[i][0] = ""+room[3];
			_rooms[i][1] = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new Date(((Timestamp)room[4]).getTime()));
			_rooms[i][2] = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new Date(((Timestamp)room[5]).getTime()));
			i++;
		}

		String[] RoomsTitles = {"Room No.","Start Time" ,"Due By"};
		displayOptions(_rooms,RoomsTitles);
		if(rooms.size()==0){
			choice = readOptionNumber("No rooms available to check in\nEnter 0 to go back", 0, 0);
			BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
			nextScreen.execute();
			return;
		}
		else{
			int roomNo = readOptionNumber("Enter a choice (0 to go back)", 0, rooms.size());
			if(roomNo==0){
				BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
				nextScreen.execute();
				return;
			}
			long checkoutId = Long.parseLong(rooms.get(roomNo-1)[7].toString());
			boolean result = RoomsManager.checkIn(checkoutId);
			if(result){
				System.out.println("Checked In Successfully...");
				BaseScreen nextScreen = getNextScreen(RouteConstant.BACK);
				nextScreen.execute();
				return;
			}

		}


	}



	private void checkoutRoom() {
		System.out.println("=============Checkout Room==========");
		int choice = -1;
		List<Object[]> rooms = RoomsManager.getBookedRooms();
		String[][] _rooms = new String[rooms.size()][6];
		int i=0;
		for (Iterator iterator = rooms.iterator(); iterator.hasNext();) {
			Object[] room = (Object[]) iterator.next();
			_rooms[i][0] = ""+room[4];
			_rooms[i][1] = ""+room[3];
			_rooms[i][2] = ""+room[2];
			_rooms[i][3] = ""+room[5];
			_rooms[i][4] = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new Date(((Timestamp)room[6]).getTime()));
			_rooms[i][5] = ""+room[7];
			i++;
		}

		String[] RoomsTitles = {"Room No.","Floor","Capacity","Type","Start Time" ,"Available to Check-In"};
		displayOptions(_rooms,RoomsTitles);
		if(rooms.size()==0){
			choice = readOptionNumber("No rooms available for given criteria\nEnter 0 to go back", 0, 0);
			BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
			nextScreen.execute();
			return;
		}
		else{
			int roomNo = readOptionNumber("Enter a choice (0 to go back)", 0, rooms.size());
			if(roomNo==0){
				BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
				nextScreen.execute();
				return;
			}
			long reservationId = Long.parseLong(rooms.get(roomNo-1)[0].toString());
			if("Available".equalsIgnoreCase(rooms.get(roomNo-1)[7].toString())){
				choice = readOptionNumber("Press 1 to Checkout, 2 to Cancel or 0 to Go Back", 0, 2);
				if(choice==0){
					BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
					nextScreen.execute();
					return;
				}
				else if(choice==1){
					boolean result = RoomsManager.checkOut(reservationId);
					if(result){
						System.out.println("Room checked out Successfully\nYou need to vacate room by : "+new SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new Date(((Timestamp)rooms.get(roomNo-1)[8]).getTime())));
						BaseScreen nextScreen = getNextScreen(RouteConstant.BACK);
						nextScreen.execute();
						return;
					}

				}
				else if(choice==2){
					boolean result = RoomsManager.cancel(reservationId);
					if(result){
						System.out.println("Cancelled Successfully...");
						BaseScreen nextScreen = getNextScreen(RouteConstant.BACK);
						nextScreen.execute();
						return;
					}
				}

			}
			else
			{
				choice = readOptionNumber("Press 1 to Cancel or 0 to Go Back", 0, 1);
				if(choice==0){
					BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
					nextScreen.execute();
					return;
				}
				else if(choice==1){
					boolean result = RoomsManager.cancel(reservationId);
					if(result){
						System.out.println("Cancelled Successfully...");
						BaseScreen nextScreen = getNextScreen(RouteConstant.BACK);
						nextScreen.execute();
						return;
					}
				}
			}
		}


	}

	private void bookRoom() {

		List<Library> libs = RoomsManager.getLibraryList();
		String[][] lib_names = new String[libs.size()][5];
		int i=0;
		for (Iterator iterator = libs.iterator(); iterator.hasNext();) {
			Library library = (Library) iterator.next();
			lib_names[i][0] = library.getLibraryName();
			lib_names[i][1] = library.getLibraryAddress().getAddressLineOne();
			lib_names[i][2] = library.getLibraryAddress().getAddressLineTwo();
			lib_names[i][3] = library.getLibraryAddress().getCityName();
			lib_names[i][4] = ""+library.getLibraryAddress().getPinCode();
			i++;
		}

		String[] libTitles = {"Library","Address 1","Address 2","City","Post Code"};
		displayOptions(lib_names,libTitles);
		int choice = readOptionNumber("Enter a choice (0 to go back)", 0, libs.size());
		//int choice = 1;
		if(choice==0){
			BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
			nextScreen.execute();
			return;
		}
		Library library = libs.get(choice-1);
		int occupents = readOptionNumber("Enter number of occupents", 1, 20);
		//int occupents = 9;
		while(true){
			int startTime = 0;
			int endTime = 0;
			String date = readInput("Enter Date in MM/DD/YYYY Format");
			String _startTime = readInput("Enter start time HH:MM(24 hours format, MM can be 00 or 30)");
			String _endTime = readInput("Enter end time HH:MM(24 hours format,MM can be 00 or 30, Use 24:00 for mid-night)");
			if(_startTime.length()==5 && _startTime.indexOf(':')==2){
				try{
					int hh = Integer.parseInt(_startTime.substring(0,2));
					int mm = Integer.parseInt(_startTime.substring(3));
					if(hh<0||hh>23||mm%30!=0){
						System.out.println("Invalid Time Entered...\nPlease enter a valid time");
						continue;
					}
					startTime = hh*100+mm;
				}
				catch(NumberFormatException e){
					System.out.println("Invalid Time Entered...\nPlease enter a valid time");
					continue;
				}
			}
			else{
				System.out.println("Invalid Time Entered...\nPlease enter a valid time");
				continue;
			}
			if(_endTime.length()==5 && _endTime.indexOf(':')==2){
				try{
					int hh = Integer.parseInt(_endTime.substring(0,2));
					int mm = Integer.parseInt(_endTime.substring(3));
					if(hh<0||hh>24||(hh==24&&mm>0)||mm%30!=0){
						System.out.println("Invalid Time Entered...\nPlease enter a valid time");
						continue;
					}
					endTime = hh*100+mm;
					if(endTime-startTime<30){
						System.out.println("Rooms can be booked for minimum 30 minutes\nInvalid Time Entered...\nPlease enter a valid time");
						continue;
					}
					if(endTime-startTime>300){
						System.out.println("Rooms can be booked for maximum 3 hours\nInvalid Time Entered...\nPlease enter a valid time");
						continue;
					}
				}
				catch(NumberFormatException e){
					System.out.println("Invalid Time Entered...\nPlease enter a valid time");
					continue;
				}
			}
			else{
				System.out.println("Invalid Time Entered...\nPlease enter a valid time");
				continue;
			}
//			String date = "10/31/2015";
//			int startTime = 12;
//			int endTime = 14;
			Date startDate = DBUtils.validateDate(date+" "+_startTime, "MM/dd/yyyy HH:mm", true);
			if(startDate==null){
				System.out.println("Enter a valid start date(future date/time)");
				continue;
			}
			boolean adjust = false;
			if(endTime==2400)
			{
				_endTime="00:00";
				adjust = true;
			}
			Date endDate = DBUtils.validateDate(date+" "+_endTime, "MM/dd/yyyy HH:mm", true&&!adjust);
			if(endDate==null){
				System.out.println("Enter a valid future date/time for end time");
				continue;
			}
			if(adjust){
				Calendar c = Calendar.getInstance();
				c.setTime(endDate);
				c.add(Calendar.DATE, 1);  // number of days to add
				endDate = c.getTime();
			}
			List<Object[]> rooms = RoomsManager.getAvailableRooms(occupents, library, startDate, endDate);
			String[][] _rooms = new String[rooms.size()][4];
			i=0;
			for (Iterator iterator = rooms.iterator(); iterator.hasNext();) {
				Object[] room = (Object[]) iterator.next();
				_rooms[i][0] = ""+room[3];
				_rooms[i][1] = ""+room[2];
				_rooms[i][2] = ""+room[1];
				_rooms[i][3] = ""+room[4];
				i++;
			}

			String[] RoomsTitles = {"Room No.","Floor","Capacity","Type"};
			displayOptions(_rooms,RoomsTitles);
			if(rooms.size()==0){
				choice = readOptionNumber("No rooms available for given criteria\nEnter 0 to go back or 1 to try other options", 0, 1);
				if(choice==1){
					continue;
				}
			}
			else
				choice = readOptionNumber("Enter a choice (0 to go back)", 0, rooms.size());
			if(choice==0){
				BaseScreen nextScreen = getNextScreen(SessionUtils.getCurrentRoute());
				nextScreen.execute();
				return;
			}
			Room room = (Room) DBUtils.findEntity(Room.class, rooms.get(choice-1)[0], String.class);
			boolean status = RoomsManager.reserve(room, startDate, endDate);
			if(status){
				choice = readOptionNumber("Successfully booked Room # "+room.getRoomNo()+" on "+date+" from "+startTime+" Hrs to "+endTime+" Hrs\nDo not forget to check in within 1 Hour of start time\nEnter 0 to go back", 0, 0);
				BaseScreen nextScreen = getNextScreen(RouteConstant.BACK);
				nextScreen.execute();
				return;
			}
			break;
		}
	}

	@Override
	public void displayOptions() {
		// TODO Auto-generated method stub

	}

}
