-- COMP9311 16s2 Assignment 1
-- Schema for KensingtonCars
--
-- Written by <<Xinjie Lu>>
-- Student ID: <<5101488>>
--

-- Some useful domains; you can define more if needed.

create domain URLType as
	varchar(100) check (value like 'http://%');

create domain EmailType as
	varchar(100) check (value like '%@%.%');

create domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');

create domain CarLicenseType as
        char(6) check (value ~ '[0-9A-Za-z]{6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17) check (value ~ '[0-9A-HJ-NPR-Z]{17}');

create domain  YearType as integer check (value >= 1970 and value <= 2099);

create domain MoneyType as numeric(6,2) check (value > 0);


-- EMPLOYEE
create table Employee (
	EID          serial,
  TFN			     char(9) unique not null check (TFN ~ '[[:digit:]]{9}'), 
  --unique: because one person can have one tfn number
  Salary       integer not null check (Salary > 0),
	firstname	   varchar(50) not null,
	lastname	   varchar(50) not null,
	primary key (EID)
);

create table Admin(
	EID			    integer references Employee(EID),
	primary key (EID)
);

create table Mechanic(
	EID			     integer references Employee(EID),
	license      char(8) not null unique, 
  --unique: because one mechanic have one license number
	primary key (EID)
);

create table salesman(
	EID			   integer references Employee(EID),
	commRate	 integer not null check(commRate >= 5 and commRate <= 20),
	primary key (EID)
);

-- CLIENT

create table Client (
	CID          serial,
	name 		     varchar(100) not null,
	address 	   varchar(200) not null,
	phone 	 	   PhoneType not null,
	email 	  	 EmailType,
	primary key (CID)
);

create table Company(
	CID  		   integer references Client(CID),
	ABN   		 char(11) check(ABN ~ '[[:digit:]]{11}')not null unique, 
  --unique: because one company have one ABN
	url  		   URLType,
	primary key (CID)
);
	

-- CAR

create table Car(
	VIN 		      VINType,
	manufacturer  varchar(40) not null,
	model		      varchar(40) not null,
	"year"        YearType not null,
	primary key (VIN)
);

create table Options(
	VIN 		      VINType references Car(VIN),
	OptionType    OptionType,
	primary key (VIN,OptionType)
);

create table UsedCar(
	VIN 		      VINType references Car(VIN),
	plateNumber   CarLicenseType not null unique,  
	primary key (VIN)
);

create table NewCar(
	VIN 		    VINType references Car(VIN),
	cost		    MoneyType not null,
	charge		  MoneyType not null,
	primary key (VIN)
);

--Relationship

create table RepairJob(
	"number"     integer check("number" >= 1 and "number" <= 999), 
	"date"  	 	 date,
	parts			   MoneyType,
	"work"			 MoneyType,
  description  varchar(250),
	VIN   		   VINType references UsedCar(VIN),
	CID				   integer references Client(CID),
	primary key("number",VIN)
);


create table Does(
	VIN   			VINType not null,
	EID				  integer not null references Mechanic(EID), 
	"number"    integer check("number" >= 1 and "number" <= 999),
  primary key (EID,"number",VIN),
  foreign key ("number",VIN)references RepairJob("number",VIN)
);
  --Each repair job can be carried out by more than one mechanic.

   
create table Buys(
	price		    MoneyType not null,
	"date"			date,
	VIN   			VINType references UsedCar(VIN),
	EID				  integer references Salesman(EID),
	CID 			  integer references Client(CID),
	commission	MoneyType not null,
	primary key ("date",VIN,CID,EID)		
);
  --The actual buying price must be lower than the market value of the car.
  --The car can be owned by joint owners.
  --The commission is calculated by the commission rate times the profit.
  --commission = commission rate x (market value - buying price).
  --There will only be one salesman involved.

create table Sells(
	VIN   		VINType references UsedCar(VIN),
	EID				integer references salesman(EID),
	CID 			integer references Client(CID),
	"date"		date,
	price			MoneyType not null,
	commission      MoneyType not null,
	primary key ("date",VIN,CID,EID)
);
  --There will only be one salesman involved.
  --The car can be owned by joint owners.
  --The market value of a used car is determined by the number of years following the    
  --acquisition date of the car, with every year depreciating 10% from the previous      
  --year's market value, with the minimum capped at $1000.
  --The actual selling price must be higher than the market value of the used car.
  --The commission is calculated by the commission rate times the profit.
  --commission = commission rate x (selling price - market value).
  

create table SellsNew(
	VIN   		VINType references NewCar(VIN),
	EID				integer references salesman(EID),
	CID 			integer references Client(CID),
	plateNumber     CarLicenseType not null unique,
	commission      MoneyType  not null,
	"date"          date,
	price           MoneyType not null,
	primary key(EID,VIN,CID,"date")
);
  --There will only be one salesman involved.
  --The car can be owned by joint owners.
  --The actual selling price must be higher than the manufacturer cost plus delivery     
  --charges of the new car.
  --The commission is calculated by the commission rate times the profit.
  --commission = commission rate x (selling price - (cost + delivery charges)).




