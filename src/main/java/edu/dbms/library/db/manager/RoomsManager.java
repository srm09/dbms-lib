package edu.dbms.library.db.manager;

import java.util.Date;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import edu.dbms.library.db.DBUtils;
import edu.dbms.library.entity.Address;
import edu.dbms.library.entity.AssetCheckout;
import edu.dbms.library.entity.Library;
import edu.dbms.library.entity.Patron;
import edu.dbms.library.entity.RoomReserve;
import edu.dbms.library.entity.resource.ConferenceRoom;
import edu.dbms.library.entity.resource.Room;
import edu.dbms.library.entity.resource.StudyRoom;
import edu.dbms.library.session.SessionUtils;

public class RoomsManager extends DBManager {

	public static List<Library> getLibraryList(){
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(
				DEFAULT_PERSISTENCE_UNIT_NAME);
		EntityManager entitymanager = emfactory.createEntityManager( );

		List<Library> libraries = entitymanager.createQuery("select l from Library l").getResultList();
		return libraries;
	}

	public static List<Object[]> getAvailableRooms(int occupants, Library l, Date start, Date end) {
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(
				DEFAULT_PERSISTENCE_UNIT_NAME);
		
		EntityManager entitymanager = emfactory.createEntityManager( );
		
		Query q = entitymanager.createNativeQuery("SELECT R.*, AT.SUB_CATEGORY FROM ROOM R, ASSET A, ROOM_RESERVATION RR, ASSET_TYPE AT "
				+ "WHERE R.ROOM_ID = RR.ROOM_ASSET_ID(+) "
				+ "AND R.CAPACITY >= ? AND R.ROOM_ID = A.ASSET_ID "
				+ "AND A.LIBRARY_ID = ? "
				+ "AND A.ASSET_TYPE  = AT.ASSETTYPEID "
				+ "AND AT.CATEGORY = 'Room' "
				+ "AND (AT.SUB_CATEGORY = 'Study Room' OR AT.SUB_CATEGORY = DECODE(?, '1', 'Conference Room','XX'))"
				+ "AND ((RR.START_TIME IS NULL) OR (( ? < RR.START_TIME OR ? > RR.END_TIME) AND ( ? < RR.START_TIME OR ? > RR.END_TIME))) ORDER BY R.ROOMNO");
		q.setParameter(1, occupants);
		q.setParameter(2, l.getLibraryId());
		q.setParameter(3, SessionUtils.isStudent()?"0":"1");
		q.setParameter(4, start);
		q.setParameter(5, start);
		q.setParameter(6, end);
		q.setParameter(7, end);
		
		List rooms = q.getResultList();
		return rooms;
	}

	public static boolean reserve(Room room, Date start, Date end) {
		try{
			RoomReserve rr = new RoomReserve();
			rr.setRoom(room);
			rr.setPatron((Patron) DBUtils.findEntity(Patron.class, SessionUtils.getPatronId(), String.class));
			rr.setStartTime(start);
			rr.setEndTime(end);
			rr.setrTime(new Date());
			DBUtils.persist(rr);
		}
		catch(Exception e){
			return false;
		}
		return true;
	}
	
	public static List<Object[]> getBookedRooms() {
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(
				DEFAULT_PERSISTENCE_UNIT_NAME);
		
		EntityManager entitymanager = emfactory.createEntityManager( );
		
		Query q = entitymanager.createNativeQuery("SELECT RR.RESERVATION_ID, R.*, AT.SUB_CATEGORY ,RR.START_TIME, CASE WHEN RR.START_TIME < SYSDATE+60/(24*60) THEN 'Available' ELSE 'Not Available' END AS IS_AVAILABLE, RR.END_TIME "
					+ "FROM ROOM R, ROOM_RESERVATION RR, ASSET A, ASSET_TYPE AT "
					+ "WHERE R.ROOM_ID = RR.ROOM_ASSET_ID "
					+ "AND R.ROOM_ID = A.ASSET_ID "
					+ "AND A.ASSET_TYPE  = AT.ASSETTYPEID "
					+ "AND AT.CATEGORY = 'Room' "
					+ "AND RR.START_TIME > SYSDATE "
					+ "AND RR.PATRON_ID = ? ORDER BY R.ROOMNO");
		q.setParameter(1, SessionUtils.getPatronId());
		
		List rooms = q.getResultList();
		return rooms;
	}

	public static boolean checkOut(long reservationId) {
		try{
			RoomReserve rr = (RoomReserve) DBUtils.findEntity(RoomReserve.class, reservationId, Long.class);
			AssetCheckout ac = new AssetCheckout();
			ac.setAsset(rr.getRoom());
			ac.setIssueDate(rr.getStartTime());
			ac.setDueDate(rr.getEndTime());
			ac.setRoomReserve(rr);
			ac.setPatron((Patron) DBUtils.findEntity(Patron.class, SessionUtils.getPatronId(), String.class));
			DBUtils.persist(ac);
		}
		catch(Exception e){
			return false;
		}
		return true;
	}

	public static boolean cancel(long reservationId) {
		try{
			DBUtils.removeEntity(RoomReserve.class, reservationId, Long.class);
		}
		catch(Exception e){
			return false;
		}
		return true;
	}

	public static List<Object[]> getCheckedOutRooms() {
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(
				DEFAULT_PERSISTENCE_UNIT_NAME);
		
		EntityManager entitymanager = emfactory.createEntityManager( );
		
		Query q = entitymanager.createNativeQuery("SELECT R.*, AC.ISSUE_DATE, AC.DUE_DATE, RR.RESERVATION_ID, AC.ID FROM ROOM R, ROOM_RESERVATION RR, ASSET_CHECKOUT AC "
					+ "WHERE R.ROOM_ID = RR.ROOM_ASSET_ID "
					+ "AND RR.CHECKOUT_ID = AC.ID "
					+ "AND AC.RETURN_DATE IS NULL "
					+ "AND RR.PATRON_ID = ? ORDER BY DUE_DATE DESC");
		q.setParameter(1, SessionUtils.getPatronId());
		
		List rooms = q.getResultList();
		return rooms;
	}

	public static boolean checkIn(long checkoutId) {
		EntityManagerFactory emfactory = Persistence.createEntityManagerFactory(
				DEFAULT_PERSISTENCE_UNIT_NAME);
		
		EntityManager entitymanager = emfactory.createEntityManager( );
		entitymanager.getTransaction().begin();
		Query q = entitymanager.createNativeQuery("UPDATE ASSET_CHECKOUT AC SET AC.RETURN_DATE = SYSDATE "
					+ "WHERE AC.ID = ?");
		q.setParameter(1, checkoutId);

		int r = q.executeUpdate();
		entitymanager.getTransaction().commit();
		return r==1;
	}

}
