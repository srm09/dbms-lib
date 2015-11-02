--Run the following query and use the output of the query as drop scripts

--SELECT 'DROP '||OBJECT_TYPE||' '||OBJECT_NAME||DECODE(OBJECT_TYPE,'TABLE', ' CASCADE CONSTRAINTS;', ';') FROM USER_OBJECTS;

--ALTER TABLE ENROLL
--  DROP CONSTRAINT FK_ENROLL_STUDENT_ID;


--ALTER TABLE ENROLL ADD (
--  CONSTRAINT FK_ENROLL_STUDENT_ID 
--  FOREIGN KEY (STUDENT_ID) 
--  REFERENCES PATRON (PATRON_ID)
--  ENABLE VALIDATE);


ALTER TABLE ENROLL
  DROP CONSTRAINT FK_ENROLL_STUDENT_ID;


ALTER TABLE ENROLL ADD (
  CONSTRAINT FK_ENROLL_STUDENT_ID 
  FOREIGN KEY (STUDENT_ID) 
  REFERENCES STUDENT (STUDENT_ID)
  ENABLE VALIDATE);


--ALTER TABLE TEACH
--  DROP CONSTRAINT FK_TEACH_FACULTY_ID;


--ALTER TABLE TEACH ADD (
--  CONSTRAINT FK_TEACH_FACULTY_ID 
--  FOREIGN KEY (FACULTY_ID) 
--  REFERENCES PATRON (PATRON_ID)
--  ENABLE VALIDATE);



ALTER TABLE TEACH
  DROP CONSTRAINT FK_TEACH_FACULTY_ID;


ALTER TABLE TEACH ADD (
  CONSTRAINT FK_TEACH_FACULTY_ID 
  FOREIGN KEY (FACULTY_ID) 
  REFERENCES FACULTY (FACULTY_ID)
  ENABLE VALIDATE);


ALTER TABLE ASSET ADD 
CONSTRAINT FK_ASSET_TYPE
 FOREIGN KEY (ASSET_TYPE)
 REFERENCES ASSET_TYPE (ASSETTYPEID)
 ENABLE
 VALIDATE;


CREATE TABLE PATRON_TYPE
(
  PATRON_TYPE_ID  CHAR(1 BYTE)              NOT NULL,
  DESCRIPTION     VARCHAR2(50 BYTE)             NOT NULL
);


ALTER TABLE PATRON_TYPE ADD (
  CONSTRAINT PATRON_TYPE_PK
  PRIMARY KEY
  (PATRON_TYPE_ID)
  ENABLE VALIDATE);


ALTER TABLE ASSET_PATRON_CONSTRAINT ADD 
CONSTRAINT ASSET_PATRON_CONSTRAINT_P_TYPE
 FOREIGN KEY (PATRON_TYPE)
 REFERENCES PATRON_TYPE (PATRON_TYPE_ID)
 ENABLE
 VALIDATE;


ALTER TABLE PATRON ADD 
CONSTRAINT FK_PATRON_TYPE
 FOREIGN KEY (PATRON_TYPE)
 REFERENCES PATRON_TYPE (PATRON_TYPE_ID)
 ENABLE
 VALIDATE;


ALTER TABLE ASSET_PATRON_CONSTRAINT ADD 
CONSTRAINT FK_ASSET_P_C_ASSET_TYPE
 FOREIGN KEY (ASSET_TYPE_ID)
 REFERENCES ASSET_TYPE (ASSETTYPEID)
 ENABLE
 VALIDATE;

CREATE OR REPLACE FUNCTION MY_HASH(X IN VARCHAR2, y IN NUMBER, z IN NUMBER) RETURN NUMBER IS
  RETVAL NUMBER;
BEGIN
  SELECT ORA_HASH(X,y,z) INTO RETVAL FROM DUAL;
  RETURN RETVAL;
END;
/

CREATE OR REPLACE TRIGGER LOGIN_PASSWORD
BEFORE INSERT OR UPDATE
OF PASSWORD
ON LOGIN_DETAILS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :new.PASSWORD := MY_HASH(:new.PASSWORD, 100000, 57643);
END;
/



CREATE OR REPLACE TRIGGER UPD_ASSET_CK_CSTRN
AFTER INSERT OR UPDATE
OF RETURN_DATE
ON ASSET_CHECKOUT
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
BEGIN
      IF UPDATING THEN
        IF :new.RETURN_DATE IS NOT NULL THEN
            DELETE FROM ASSET_CHECKOUT_CONSTRAINT ACC WHERE ACC.ASSETCHECKOUT_ID = :new.ID;
        END IF;
      ELSIF INSERTING THEN
        IF :new.RETURN_DATE IS NULL AND :new.ASSET_SECONDARY_ID IS NOT NULL THEN
            INSERT INTO ASSET_CHECKOUT_CONSTRAINT(ASSETCHECKOUT_ID, PATRON_ID, ASSET_SECONDARY_ID) VALUES (:new.ID, :new.PATRON_ID, :new.ASSET_SECONDARY_ID);
        END IF;
      END IF;
END;
/

show errors TRIGGER UPD_ASSET_CK_CSTRN;


CREATE OR REPLACE TRIGGER NO_CONF_ROOM_HILL
BEFORE INSERT OR UPDATE
ON ASSET
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
BEGIN
        SELECT COUNT(*) INTO cnt FROM LIBRARY LIB, ASSET_TYPE AST WHERE AST.ASSETTYPEID = :new.ASSET_TYPE AND AST.SUB_CATEGORY = 'Conference Room' AND UPPER(LIB.LIBRARY_NAME) LIKE '%D%H%HILL%' AND LIB.LIBRARY_ID = :new.LIBRARY_ID;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20013, 'NO_CNF_ROOM_IN_HILL');
        END IF;
END;
/

show errors TRIGGER NO_CONF_ROOM_HILL;


CREATE OR REPLACE TRIGGER NO_CONF_ROOM_STUDENT
BEFORE INSERT OR UPDATE
ON ROOM_RESERVATION
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
BEGIN
        SELECT COUNT(*) INTO cnt FROM PATRON PT, ASSET_TYPE AST, ASSET ASS, PATRON_TYPE PTT WHERE ASS.ASSET_ID = :new.ROOM_ASSET_ID AND AST.ASSETTYPEID = ASS.ASSET_TYPE AND AST.SUB_CATEGORY = 'Conference Room' AND PT.PATRON_ID = :new.PATRON_ID AND PT.PATRON_TYPE = PTT.PATRON_TYPE_ID AND PTT.DESCRIPTION = 'Student' ;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20013, 'NO_CONF_ROOM_STUDENT');
        END IF;
END;
/


show errors TRIGGER NO_CONF_ROOM_STUDENT;


CREATE OR REPLACE TRIGGER NO_RES_BOOK_FACULTY
BEFORE INSERT OR UPDATE
ON ASSET_CHECKOUT
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
BEGIN
        SELECT COUNT(*) INTO cnt FROM PATRON PT, ASSET_TYPE AST, ASSET ASS, PATRON_TYPE PTT WHERE ASS.ASSET_ID = :new.ASSET_ASSET_ID AND AST.ASSETTYPEID = ASS.ASSET_TYPE AND AST.SUB_CATEGORY = 'Reserve Book' AND PT.PATRON_ID = :new.PATRON_ID AND PT.PATRON_TYPE = PTT.PATRON_TYPE_ID AND PTT.DESCRIPTION = 'Faculty' ;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20013, 'NO_RESERVE_BOOK_FACULTY');
        END IF;
END;
/


show errors TRIGGER NO_RES_BOOK_FACULTY;


ALTER TABLE AUTHOR ADD 
CONSTRAINT AUTHOR_U01
 UNIQUE (NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE AUTHOR ADD 
CONSTRAINT AUTHOR_C01
 CHECK (NAME IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE CLASSIFICATION ADD 
CONSTRAINT CLASSIFICATION_U01
 UNIQUE (NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE CLASSIFICATION ADD 
CONSTRAINT CLASSIFICATION_C01
 CHECK (NAME IS NOT NULL AND LOWER(NAME) IN ('undergraduate','postgraduate','graduate'))
 ENABLE
 VALIDATE;


ALTER TABLE COURSE ADD 
CONSTRAINT COURSE_U01
 UNIQUE (COURSE_NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE COURSE ADD 
CONSTRAINT COURSE_C01
 CHECK (COURSE_NAME IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE DEGREE_PROGRAM ADD 
CONSTRAINT DEGREE_PROGRAM_U01
 UNIQUE (NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE DEGREE_PROGRAM ADD 
CONSTRAINT DEGREE_PROGRAM_C01
 CHECK (NAME IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE FACULTY_CATEGORY ADD 
CONSTRAINT FACULTY_CATEGORY_U01
 UNIQUE (NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE FACULTY_CATEGORY ADD 
CONSTRAINT FACULTY_CATEGORY_C01
 CHECK (NAME IS NOT NULL)
 ENABLE
 VALIDATE;


ALTER TABLE LIBRARY ADD 
CONSTRAINT LIBRARY_U01
 UNIQUE (LIBRARY_NAME)
 ENABLE
 VALIDATE;
 
ALTER TABLE LIBRARY ADD 
CONSTRAINT LIBRARY_C01
 CHECK (LIBRARY_NAME IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE LOGIN_DETAILS ADD 
CONSTRAINT LOGIN_DETAILS_U01
 UNIQUE (PATRON_ID)
 ENABLE
 VALIDATE;
 
ALTER TABLE LOGIN_DETAILS ADD 
CONSTRAINT LOGIN_DETAILS_C01
 CHECK (PATRON_ID IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE LOGIN_DETAILS ADD 
CONSTRAINT LOGIN_DETAILS_C02
 CHECK (PASSWORD IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C01
 CHECK (PATRON_TYPE IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C02
 CHECK (EMAIL_ADDRESS IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_U01
 UNIQUE (EMAIL_ADDRESS)
 ENABLE
 VALIDATE;


ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C03
 CHECK (FIRST_NAME IS NOT NULL)
 ENABLE
 VALIDATE;


ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C04
 CHECK (NATIONALITY IS NOT NULL)
 ENABLE
 VALIDATE;


ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C05
 CHECK (DEPARTMENT_ID IS NOT NULL)
 ENABLE
 VALIDATE;

ALTER TABLE PATRON ADD 
CONSTRAINT PATRON_C06
 CHECK (HOLD IN ('Y','N'))
 ENABLE
 VALIDATE;

ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_C01
 CHECK (FLOORLEVEL IS NOT NULL)
 ENABLE
 VALIDATE;
 
ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_C02
 CHECK (FLOORLEVEL BETWEEN 0 AND 100)
 ENABLE
 VALIDATE;


ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_C03
 CHECK (ROOMNO IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_U01
 UNIQUE(ROOMNO)
 ENABLE
 VALIDATE;

 
ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_C04
 CHECK (CAPACITY IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE ROOM ADD 
CONSTRAINT ROOM_C05
 CHECK (CAPACITY BETWEEN 1 AND 25)
 ENABLE
 VALIDATE;


ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C01
 CHECK (DOB IS NOT NULL)
 ENABLE
 VALIDATE;
 
--ALTER TABLE STUDENT ADD 
--CONSTRAINT STUDENT_-01
-- CHECK (TO_DATE(DOB) < SYSDATE)
-- ENABLE
-- VALIDATE; 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C_PHNO
 CHECK (PHONE_NO IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C_SEX
 CHECK (SEX IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C03
 CHECK (SEX IN ('M','F'))
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C04
 CHECK (ADDRESSLINEONE IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C05
 CHECK (CITYNAME IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C06
 CHECK (PINCODE IS NOT NULL)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C07
 CHECK (PINCODE BETWEEN 1000 AND 999999)
 ENABLE
 VALIDATE;
 

ALTER TABLE STUDENT ADD 
CONSTRAINT STUDENT_C08
 CHECK (DEGREEYEAR_DEGREE_YEAR_ID IS NOT NULL)
 ENABLE
 VALIDATE;


ALTER TABLE YEAR ADD 
CONSTRAINT YEAR_C01
 CHECK (NAME IS NOT NULL)
 ENABLE
 VALIDATE;


ALTER TABLE YEAR ADD 
CONSTRAINT YEAR_U01
 UNIQUE (NAME)
 ENABLE
 VALIDATE;


ALTER TABLE YEAR ADD 
CONSTRAINT YEAR_C02
 CHECK (LOWER(NAME) IN ('first year','second year','third year','fourth year','fifth year','sixth year'))
 ENABLE
 VALIDATE;

ALTER TABLE PUBLICATION ADD
CONSTRAINT PUBLICATION_C01
  CHECK (PUBLICATIONFORMAT IN ('Physical copy','Electronic copy'))
 ENABLE
 VALIDATE;
 
CREATE OR REPLACE VIEW min_reservation_view (camera_id, issue_date, min_reserve_date) AS 
  SELECT c.camera_Id as id, c.issue_Date, MIN(c.reserve_Date) as res_date
				FROM Camera_Reservation c
				WHERE c.reservation_status='ACTIVE'
        GROUP BY c.camera_Id, c.issue_date;




CREATE OR REPLACE FUNCTION TS_DIFF_IN_HRS(END_TIME IN TIMESTAMP, START_TIME IN TIMESTAMP, DO_ROUND IN INTEGER) RETURN NUMBER IS
  RETVAL NUMBER;
BEGIN
  IF DO_ROUND < 0 THEN
  SELECT FLOOR(EXTRACT (DAY    FROM (END_TIME-START_TIME))*24) DELTA INTO RETVAL FROM DUAL;
  ELSIF DO_ROUND > 0 THEN
  SELECT FLOOR(EXTRACT (DAY    FROM (END_TIME-START_TIME))*24) DELTA INTO RETVAL FROM DUAL;
  ELSE
  SELECT EXTRACT (DAY    FROM (END_TIME-START_TIME))*24 DELTA INTO RETVAL FROM DUAL;
  END IF;
  RETURN RETVAL;
END;
/


CREATE OR REPLACE VIEW FINE_SNAPSHOT AS 
SELECT ISSUE_DATE, 
       DUE_DATE, 
       P.PATRON_ID, 
       P.PATRON_TYPE, 
       DURATION MAX_ALLOWED_DURATION, 
       SYSDATE TODAY, 
       TS_DIFF_IN_HRS(SYSDATE, DUE_DATE, 1) OVER_DUE_HRS, 
       CEIL(TS_DIFF_IN_HRS(SYSDATE, DUE_DATE, 1)/FINE_DURATION) OVER_DUE_TIME_Q, 
       APC.FINE*CEIL(TS_DIFF_IN_HRS(SYSDATE, DUE_DATE, 1)/FINE_DURATION) FINE_AMOUNT, 
       APC.FINE FINE_PER_TIME_Q, 
       FINE_DURATION TIME_Q_HRS, 
       AC.ID CHECKOUT_ID, 
       P.EMAIL_ADDRESS, 
       P.FIRST_NAME, 
       P.LAST_NAME
FROM 
    ASSET A, 
    ASSET_PATRON_CONSTRAINT APC, 
    ASSET_CHECKOUT AC,
    PATRON P
WHERE
    A.ASSET_TYPE = APC.ASSET_TYPE_ID
    AND A.ASSET_ID = AC.ASSET_ASSET_ID
    AND P.PATRON_ID = AC.PATRON_ID
    AND P.PATRON_TYPE = APC.PATRON_TYPE
    AND APC.FINE <> 0
    AND AC.RETURN_DATE IS NULL
    AND DUE_DATE < SYSDATE;


CREATE OR REPLACE VIEW DUE_IN_NEXT_24_HRS AS 
SELECT P.FIRST_NAME, 
       P.LAST_NAME,
       P.EMAIL_ADDRESS,
       ISSUE_DATE,
       DUE_DATE,
       SYSDATE TODAY, 
       P.PATRON_ID, 
       P.PATRON_TYPE, 
       AC.ID CHECKOUT_ID,
       A.ASSET_ID,
       (SELECT 'Camera: "' || MAKER || ' ' || MODEL || '"'  FROM
            CAMERA C, 
            CAMERA_DETAIL CD 
        WHERE (C.CAMERA_ID = A.ASSET_ID AND C.CAMERA_DETAIL_ID = CD.CAMERA_DETAIL_ID)
        UNION
        SELECT 'Journal: "' || TITLE || '"'  FROM
            JOURNAL J, 
            JOURNAL_DETAIL JD 
        WHERE (J.ISSN_NUMBER = JD.ISSN_NUMBER AND J.JOURNAL_ID = A.ASSET_ID)
        UNION
        SELECT 'Conference Proceeding: "' || TITLE || '"'  FROM
            CONF_PROCEEDING CP, 
            CONFERENCE_PROCEEDING_DETAIL CPD 
        WHERE (CP.CONF_NUM = CPD.CONF_NUM AND CP.CONF_PROC_ID = A.ASSET_ID)
        UNION
        SELECT 'Book: "' || TITLE || '"' FROM
            BOOK B, 
            BOOK_DETAIL BD 
        WHERE (B.ISBN_NUMBER = BD.ISBN_NUMBER AND B.BOOK_ID = A.ASSET_ID)) ASSET_NAME
FROM 
    ASSET A, 
    ASSET_CHECKOUT AC,
    PATRON P
WHERE
    A.ASSET_ID = AC.ASSET_ASSET_ID
    AND P.PATRON_ID = AC.PATRON_ID
    AND AC.RETURN_DATE IS NULL
    AND A.ASSET_TYPE NOT IN (SELECT ASSETTYPEID FROM ASSET_TYPE AT WHERE AT.CATEGORY = 'Room')
    AND DUE_DATE < SYSDATE+1
    AND DUE_DATE > SYSDATE;


CREATE OR REPLACE VIEW DUE_IN_NEXT_3_DAYS AS 
SELECT P.FIRST_NAME, 
       P.LAST_NAME,
       P.EMAIL_ADDRESS,
       ISSUE_DATE,
       DUE_DATE,
       SYSDATE TODAY, 
       P.PATRON_ID, 
       P.PATRON_TYPE, 
       AC.ID CHECKOUT_ID,
       A.ASSET_ID,
       (SELECT 'Camera: "' || MAKER || ' ' || MODEL || '"'  FROM
            CAMERA C, 
            CAMERA_DETAIL CD 
        WHERE (C.CAMERA_ID = A.ASSET_ID AND C.CAMERA_DETAIL_ID = CD.CAMERA_DETAIL_ID)
        UNION
        SELECT 'Journal: "' || TITLE || '"'  FROM
            JOURNAL J, 
            JOURNAL_DETAIL JD 
        WHERE (J.ISSN_NUMBER = JD.ISSN_NUMBER AND J.JOURNAL_ID = A.ASSET_ID)
        UNION
        SELECT 'Conference Proceeding: "' || TITLE || '"'  FROM
            CONF_PROCEEDING CP, 
            CONFERENCE_PROCEEDING_DETAIL CPD 
        WHERE (CP.CONF_NUM = CPD.CONF_NUM AND CP.CONF_PROC_ID = A.ASSET_ID)
        UNION
        SELECT 'Book: "' || TITLE || '"' FROM
            BOOK B, 
            BOOK_DETAIL BD 
        WHERE (B.ISBN_NUMBER = BD.ISBN_NUMBER AND B.BOOK_ID = A.ASSET_ID)) ASSET_NAME
FROM 
    ASSET A, 
    ASSET_CHECKOUT AC,
    PATRON P
WHERE
    A.ASSET_ID = AC.ASSET_ASSET_ID
    AND P.PATRON_ID = AC.PATRON_ID
    AND AC.RETURN_DATE IS NULL
    AND A.ASSET_TYPE NOT IN (SELECT ASSETTYPEID FROM ASSET_TYPE AT WHERE AT.CATEGORY = 'Room')
    AND DUE_DATE < SYSDATE+3
    AND DUE_DATE > SYSDATE+2;


CREATE OR REPLACE FUNCTION FINE_FOR_PATRON(P_ID IN VARCHAR2) RETURN NUMBER IS
  RETVAL NUMBER;
BEGIN
  SELECT NVL(SUM(FINE_AMOUNT),0) INTO RETVAL FROM FINE_SNAPSHOT WHERE PATRON_ID = P_ID;
  RETURN RETVAL;
END;
/

SHOW ERRORS;
  
ALTER TABLE PUBLICATION_WAITLIST ADD (
  CONSTRAINT FK_PW_PATRON_ID 
  FOREIGN KEY (PATRONID) 
  REFERENCES PATRON (PATRON_ID)
  ENABLE VALIDATE);

CREATE OR REPLACE TRIGGER NO_STUDENT_FACULTY
BEFORE INSERT OR UPDATE
ON STUDENT
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
BEGIN
        SELECT COUNT(*) INTO cnt FROM FACULTY WHERE FACULTY_ID = :new.STUDENT_ID;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20014, 'STUDENT_AND_FACULTY_ARE_DISJOINT');
        END IF;
END;
/


CREATE OR REPLACE TRIGGER NO_FACULTY_STUDENT
BEFORE INSERT OR UPDATE
ON FACULTY
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
BEGIN
        SELECT COUNT(*) INTO cnt FROM STUDENT WHERE STUDENT_ID = :new.FACULTY_ID;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'STUDENT_AND_FACULTY_ARE_DISJOINT');
        END IF;
END;
/

CREATE OR REPLACE TRIGGER ASSET_DUE_DATE
BEFORE INSERT OR UPDATE
ON ASSET_CHECKOUT
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
cnt INTEGER;
dueDate TIMESTAMP;
atype INTEGER;
BEGIN
    SELECT DURATION,ASSET_TYPE_ID INTO cnt,atype FROM ASSET A, ASSET_PATRON_CONSTRAINT APC, PATRON P 
    WHERE A.ASSET_TYPE = APC.ASSET_TYPE_ID AND APC.PATRON_TYPE = P.PATRON_TYPE AND P.PATRON_ID = :new.PATRON_ID
    AND A.ASSET_ID = :new.ASSET_ASSET_ID;
    IF atype = 1 OR atype = 2 OR atype = 3 OR atype = 4 THEN
        dueDate := :new.ISSUE_DATE + (cnt/24);
    ELSIF atype = 5 OR atype = 6 THEN
        IF EXTRACT(HOUR FROM :new.ISSUE_DATE) >= 21 THEN
            dueDate := TO_DATE(TO_CHAR(:new.ISSUE_DATE,'MM/DD/YYYY'),'MM/DD/YYYY')+1;
        ELSE
            SELECT MAX(END_TIME) into dueDate FROM ROOM_RESERVATION WHERE ROOM_ASSET_ID = :new.ASSET_ASSET_ID AND PATRON_ID = :new.PATRON_ID AND START_TIME = :new.ISSUE_DATE;
        END IF;
    ELSIF atype = 7 THEN
           dueDate := NEXT_DAY (TO_DATE(TO_CHAR(:new.ISSUE_DATE,'MM/DD/YYYY'),'MM/DD/YYYY'), 'THU')+(18/24);
    END IF;
    :new.DUE_DATE := dueDate;
END;
/


CREATE OR REPLACE TRIGGER DISJOINT_ASSET_01
BEFORE INSERT OR UPDATE
ON BOOK
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        books:=0;
        SELECT COUNT(*) INTO cameras FROM CAMERA WHERE CAMERA_ID = :new.BOOK_ID;
        SELECT COUNT(*) INTO journals FROM JOURNAL WHERE JOURNAL_ID = :new.BOOK_ID;
        SELECT COUNT(*) INTO cps FROM CONF_PROCEEDING WHERE CONF_PROC_ID = :new.BOOK_ID;
        SELECT COUNT(*) INTO study FROM STUDY_ROOM WHERE STUDY_ROOM_ID = :new.BOOK_ID;
        SELECT COUNT(*) INTO confR FROM CONFERENCE_ROOM WHERE CONF_ROOM_ID = :new.BOOK_ID;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'BOOK';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.BOOK_ID;
        END IF;
END;
/

CREATE OR REPLACE TRIGGER DISJOINT_ASSET_02
BEFORE INSERT OR UPDATE
ON CAMERA
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        SELECT COUNT(*) INTO books FROM BOOK WHERE BOOK_ID = :new.CAMERA_ID;
        cameras :=0;
        SELECT COUNT(*) INTO journals FROM JOURNAL WHERE JOURNAL_ID = :new.CAMERA_ID;
        SELECT COUNT(*) INTO cps FROM CONF_PROCEEDING WHERE CONF_PROC_ID = :new.CAMERA_ID;
        SELECT COUNT(*) INTO study FROM STUDY_ROOM WHERE STUDY_ROOM_ID = :new.CAMERA_ID;
        SELECT COUNT(*) INTO confR FROM CONFERENCE_ROOM WHERE CONF_ROOM_ID = :new.CAMERA_ID;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'CAMERA';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.CAMERA_ID;
        END IF;
END;
/


CREATE OR REPLACE TRIGGER DISJOINT_ASSET_03
BEFORE INSERT OR UPDATE
ON JOURNAL
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        SELECT COUNT(*) INTO books FROM BOOK WHERE BOOK_ID = :new.JOURNAL_ID;
        SELECT COUNT(*) INTO cameras FROM CAMERA WHERE CAMERA_ID = :new.JOURNAL_ID;
        journals:=0;
        SELECT COUNT(*) INTO cps FROM CONF_PROCEEDING WHERE CONF_PROC_ID = :new.JOURNAL_ID;
        SELECT COUNT(*) INTO study FROM STUDY_ROOM WHERE STUDY_ROOM_ID = :new.JOURNAL_ID;
        SELECT COUNT(*) INTO confR FROM CONFERENCE_ROOM WHERE CONF_ROOM_ID = :new.JOURNAL_ID;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'JOURNAL';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.JOURNAL_ID;
        END IF;
END;
/


CREATE OR REPLACE TRIGGER DISJOINT_ASSET_04
BEFORE INSERT OR UPDATE
ON CONF_PROCEEDING
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        SELECT COUNT(*) INTO books FROM BOOK WHERE BOOK_ID = :new.CONF_PROC_ID;
        SELECT COUNT(*) INTO cameras FROM CAMERA WHERE CAMERA_ID = :new.CONF_PROC_ID;
        SELECT COUNT(*) INTO journals FROM JOURNAL WHERE JOURNAL_ID = :new.CONF_PROC_ID;
        cps:=0;
        SELECT COUNT(*) INTO study FROM STUDY_ROOM WHERE STUDY_ROOM_ID = :new.CONF_PROC_ID;
        SELECT COUNT(*) INTO confR FROM CONFERENCE_ROOM WHERE CONF_ROOM_ID = :new.CONF_PROC_ID;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'CONFERENCEPROCEEDING';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.CONF_PROC_ID;
        END IF;
END;
/

CREATE OR REPLACE TRIGGER DISJOINT_ASSET_05
BEFORE INSERT OR UPDATE
ON STUDY_ROOM
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        SELECT COUNT(*) INTO books FROM BOOK WHERE BOOK_ID = :new.STUDY_ROOM_ID;
        SELECT COUNT(*) INTO cameras FROM CAMERA WHERE CAMERA_ID = :new.STUDY_ROOM_ID;
        SELECT COUNT(*) INTO journals FROM JOURNAL WHERE JOURNAL_ID = :new.STUDY_ROOM_ID;
        SELECT COUNT(*) INTO cps FROM CONF_PROCEEDING WHERE CONF_PROC_ID = :new.STUDY_ROOM_ID;
        study:=0;
        SELECT COUNT(*) INTO confR FROM CONFERENCE_ROOM WHERE CONF_ROOM_ID = :new.STUDY_ROOM_ID;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'STUDY ROOM';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.STUDY_ROOM_ID;
        END IF;
END;
/
	
CREATE OR REPLACE TRIGGER DISJOINT_ASSET_06
BEFORE INSERT OR UPDATE
ON CONFERENCE_ROOM
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
study INTEGER;
confR INTEGER;
books INTEGER;
journals INTEGER;
cps INTEGER;
cameras INTEGER;
cnt INTEGER;
atid INTEGER;
BEGIN
        SELECT COUNT(*) INTO books FROM BOOK WHERE BOOK_ID = :new.CONF_ROOM_ID;
        SELECT COUNT(*) INTO cameras FROM CAMERA WHERE CAMERA_ID = :new.CONF_ROOM_ID;
        SELECT COUNT(*) INTO journals FROM JOURNAL WHERE JOURNAL_ID = :new.CONF_ROOM_ID;
        SELECT COUNT(*) INTO cps FROM CONF_PROCEEDING WHERE CONF_PROC_ID = :new.CONF_ROOM_ID;
        SELECT COUNT(*) INTO study FROM STUDY_ROOM WHERE STUDY_ROOM_ID = :new.CONF_ROOM_ID;
        confR:=0;
        cnt := study + confR + books + journals + cps + cameras;
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'ASSET CAN NOT FALL IN MULTIPLE CATEGORY');
        ELSE
            SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'CONFERENCE ROOM';
            UPDATE ASSET SET ASSET_TYPE = atid WHERE ASSET_ID = :new.CONF_ROOM_ID;
        END IF;
END;
/



CREATE OR REPLACE TRIGGER T_RESERVER_BOOK
AFTER INSERT 
ON  RESERVE_BOOK
REFERENCING NEW AS new OLD AS old
FOR EACH ROW
DECLARE
atid INTEGER;
BEGIN
    SELECT ASSETTYPEID INTO atid FROM ASSET_TYPE WHERE UPPER(SUB_CATEGORY) = 'RESERVED BOOK';
    UPDATE ASSET set ASSET_TYPE = atid WHERE ASSET_ID IN (SELECT BOOK_ID FROM BOOK WHERE ISBN_NUMBER = :new.BOOK_ISBN);
END;
/



ALTER TABLE CAMERA_DETAIL ADD 
CONSTRAINT CAMERA_DETAIL_U01
 UNIQUE (MODEL, MEMORYAVAILABLE, MAKER, LENSDETAIL)
 ENABLE
 VALIDATE