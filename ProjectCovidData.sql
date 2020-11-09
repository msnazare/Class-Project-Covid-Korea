
----------------------------------- View Tables --------------------------------

---Master Table---
SELECT * FROM PatientInfo 
WHERE deceased_date is not null AND city is not null

---Parent Table subset of Master Table---
SELECT * FROM PatientDemographics
order by patient_id asc

SELECT * FROM PatientChild;

SELECT * FROM PatientYouth;

SELECT * FROM PatientMiddleAged;

SELECT * FROM PatientOld;

---Child Table that shows resolved cases final outcomes ---
SELECT * FROM PatientStateTimeline
ORDER BY state asc;

SELECT * FROM PatientDeceased;

SELECT * FROM PatientReleased;

---Child Table that shows infection data ---
SELECT * FROM InfectionInfo;

----------------------------------------- CREATE TABLES ---------------------------------

DROP TABLE PatientDemographics
DROP TABLE InfectionInfo
DROP TABLE PatientStateTimeline
DROP TABLE PatientDeceased

---Parent Table---
SELECT patient_id,sex,age,country,province,city 
INTO PatientDemographics FROM PatientInfo
WHERE NOT (sex is null
		OR age is null
		OR country is null
		OR province is null
		OR city is null
		OR infection_case is null
		OR infected_by is null
		OR confirmed_date is null
		OR state is null);

SELECT patient_id,age,sex,city
INTO PatientChild
FROM PatientDemographics
WHERE age = '0s' OR age = '10s'; 

SELECT patient_id,age,sex,city
INTO PatientYouth
FROM PatientDemographics
WHERE age = '20s' OR age = '30s'; 

SELECT patient_id,age,sex,city
INTO PatientMiddleAged
FROM PatientDemographics
WHERE age = '40s' OR age = '50s'; 

SELECT patient_id,age,sex,city
INTO PatientOld
FROM PatientDemographics
WHERE age = '60s' OR age = '70s' 
	OR age = '80s' OR age = '90s'; 

--- Child Infected Info Table ---
SELECT infected_by,infection_case,patient_id
INTO InfectionInfo FROM PatientInfo
WHERE NOT (sex is null
		OR age is null
		OR country is null
		OR province is null
		OR city is null
		OR infection_case is null
		OR infected_by is null
		OR confirmed_date is null
		OR state is null)
			AND
		(released_date is not null 
		OR deceased_date is not null);

--- Child Status Table Info ---
SELECT patient_id,confirmed_date,released_date,deceased_date,state
INTO PatientStateTimeline FROM PatientInfo
WHERE NOT (sex is null
		OR age is null
		OR country is null
		OR province is null
		OR city is null
		OR infection_case is null
		OR infected_by is null
		OR confirmed_date is null
		OR state is null)	
		AND
		(released_date is not null 
		OR deceased_date is not null); 

SELECT patient_id,released_date,state
INTO PatientReleased FROM PatientStateTimeline
WHERE released_date is not null;

SELECT patient_id,deceased_date,state
INTO PatientDeceased FROM PatientStateTimeline
WHERE deceased_date is not null;

--------------------------- Adding Constraints - Primary/Foreign Key ----------------

ALTER TABLE PatientInfo
ADD patient_number int not null IDENTITY (1,1);

ALTER TABLE PatientInfo
DROP CONSTRAINT PK_PatientInfo;

ALTER TABLE PatientInfo
ADD CONSTRAINT PK_PatientInfo PRIMARY KEY (patient_number);

ALTER TABLE PatientDemographics
ADD CONSTRAINT PK_PatientDemographics PRIMARY KEY (patient_id);

ALTER TABLE PatientChild
ADD child_number int not null IDENTITY (10001,1);

ALTER TABLE PatientChild
ADD CONSTRAINT PK_PatientChild PRIMARY KEY (child_number);

ALTER TABLE PatientChild
ADD CONSTRAINT FK_PatientChild FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientYouth
ADD youth_number int not null IDENTITY (100001,1);

ALTER TABLE PatientYouth
ADD CONSTRAINT PK_PatientYouth PRIMARY KEY (youth_number);

ALTER TABLE PatientYouth
ADD CONSTRAINT FK_PatientYouth FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientMiddleAged
ADD middle_aged_number int not null IDENTITY (1000001,1);

ALTER TABLE PatientMiddleAged
ADD CONSTRAINT PK_PatientMiddleAged PRIMARY KEY (middle_aged_number);

ALTER TABLE PatientMiddleAged
ADD CONSTRAINT FK_PatientMiddleAged FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientOld
ADD old_number int not null IDENTITY (6001,1);

ALTER TABLE PatientOld
ADD CONSTRAINT PK_PatientOld PRIMARY KEY (old_number);

ALTER TABLE PatientOld
ADD CONSTRAINT FK_PatientOld FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE InfectionInfo
ADD infection_number int not null IDENTITY (1001,1);

ALTER TABLE InfectionInfo
ADD CONSTRAINT PK_InfectionInfo PRIMARY KEY (infection_number);

ALTER TABLE InfectionInfo
ADD CONSTRAINT FK_InfectionInfo FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientStateTimeline
ADD timeline_number int not null IDENTITY (101,1);

ALTER TABLE PatientStateTimeline
ADD CONSTRAINT PK_PatientStateTimeline PRIMARY KEY (timeline_number);

ALTER TABLE PatientStateTimeline 
ADD CONSTRAINT FK_PatientStateTimeline FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientReleased
ADD released_number int not null IDENTITY (401,1);

ALTER TABLE PatientReleased
ADD CONSTRAINT PK_PatientReleased PRIMARY KEY (released_number);

ALTER TABLE PatientReleased
ADD CONSTRAINT FK_Released FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);

ALTER TABLE PatientDeceased
ADD deceased_number int not null IDENTITY (801,1);

ALTER TABLE PatientDeceased
ADD CONSTRAINT PK_PatientDeceased PRIMARY KEY (deceased_number);

ALTER TABLE PatientDeceased 
ADD CONSTRAINT FK_PatientDeceased FOREIGN KEY (patient_id) REFERENCES PatientDemographics(patient_id);


------------------------------- Stored Procedure ---------------------------

---Unsuccessful in attempting to store an execution of transaction conditional on updating table 


--------------------------------- JOINS -------------------------------------------

--- LEFT JOIN ---

SELECT PatientDemographics.sex,PatientDemographics.age,PatientStateTimeline.state
FROM PatientDemographics
LEFT JOIN PatientStateTimeline
ON PatientDemographics.patient_id = PatientStateTimeline.patient_id 
WHERE state is not null;
---Was not sure why there is null in state when restricted. 
---Then realized it is because I removed isolated from child tables so null in parent

--- RIGHT JOIN ---

SELECT PatientDemographics.city,InfectionInfo.infected_by
FROM PatientDemographics
RIGHT JOIN InfectionInfo
ON PatientDemographics.patient_id = InfectionInfo.patient_id
ORDER BY infected_by;
---Did not need WHERE condition to take away null values like LEFT JOIN

--- INNER JOIN ---

SELECT PatientDeceased.deceased_date,PatientStateTimeline.released_date,PatientStateTimeline.state
FROM PatientDeceased
INNER JOIN PatientStateTimeline
ON PatientDeceased.patient_id = PatientStateTimeline.patient_id;

--- FULL JOIN ---

SELECT PatientDeceased.deceased_date,PatientStateTimeline.released_date,PatientStateTimeline.state
FROM PatientDeceased
FULL OUTER JOIN PatientStateTimeline
ON PatientDeceased.patient_id = PatientStateTimeline.patient_id
ORDER BY state;

------------------------------- Unions/Intersect/Except --------------------------------------

--- Union ---
SELECT released_date,state
FROM PatientReleased
UNION
SELECT deceased_date,state
FROM PatientDeceased
ORDER BY state asc
---- Not sure I can change coloumn name to say resolved_date other than creating a table

--- Intersect ---

SELECT city,sex
FROM PatientChild
INTERSECT
SELECT city,sex
FROM PatientYouth
WHERE age = '10s' OR age = '20s' AND sex = 'male';

--- Except ---

SELECT city, sex, age
FROM PatientDemographics
EXCEPT
SELECT city,sex,age
FROM PatientChild;
----------------------- UPDATE/INSERT --------------------

---UPDATE---
BEGIN TRANSACTION

UPDATE PatientDemographics
SET sex = 'm'
WHERE sex = 'male';

UPDATE PatientDemographics
SET sex = 'f'
WHERE sex = 'female';

ROLLBACK;---Changing parent table does not automatically change subset table

BEGIN TRANSACTION

DROP TABLE PatientStateTimeline

ROLLBACK;


---INSERT---

INSERT INTO PatientDemographics
VALUES ('6015000006','female','70s','Korea','Gyeonsangbuk-do','Yeongcheon-si'),
	('6015000035','male','70s','Korea','Gyeonsangbuk-do','Yeongcheon-si');

INSERT INTO PatientDeceased
VALUES ('6015000006','2020-04-09','deceased'),
		('6015000035','2020-03-07','deceased');