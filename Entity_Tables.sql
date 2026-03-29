CREATE TABLE HotelChain (
    Chain_id SERIAL PRIMARY KEY,
	ChainName varchar(200) not null,
    Address varchar (200) not null,
    NumberOfHotels INT check (NumberOfHotels >= 0)
);

Create table ChainEmail(
	Chain_id int not null,
	Email varchar not null,
	Primary key (Chain_id,Email),
	foreign key (Chain_id) references HotelChain(Chain_id)ON DELETE CASCADE
);

Create table ChainPhone(
	Chain_id int not null,
	PhoneNumber varchar not null,
	primary key (Chain_id, PhoneNumber),
	foreign key (Chain_id) references HotelChain(Chain_id)ON DELETE CASCADE
);

create table Hotel (
	Hotel_id serial primary key,
	Chain_id int not null,
	HotelName varchar(200) not null,
	Address varchar (200) not null,
	Area varchar (50) not null,
	Email varchar (100) not null,
	Stars int check (Stars between 1 and 5),
	Manager_id int unique, -- manager not null cus hotel is created before employees
	foreign key (Chain_id) references HotelChain(Chain_id) ON DELETE CASCADE 
);

create table HotelPhone(
	Hotel_id int not null,
	PhoneNumber varchar not null,
	primary key (Hotel_id, PhoneNumber),
	foreign key (Hotel_id) references Hotel(Hotel_id) ON DELETE CASCADE
);

Create table Person(
	Person_id serial primary key,
	FirstName varchar(50) not null,
	MiddleName varchar(50),
	LastName varchar(50) not null,
	Address varchar (100) not null,
	Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL;
);

create table Employee(
	Person_id int Primary key not null,
	Hotel_id int not null,
	SSN_SIN varchar(50) not null unique,
	role varchar(50) not null,
	foreign key (Person_id) references Person(Person_id) ON DELETE CASCADE,
	foreign key (Hotel_id) references Hotel(Hotel_id) ON DELETE CASCADE
);

create table Customer(
	Person_id int Primary Key not null,
	IdType varchar(50) not null check ( IdType in ('SSN_SIN','Passport','Drivers License')),
	IdValue varchar not null,
	unique (IdType, IdValue),
	Registration date not null check (Registration <= CURRENT_DATE),
	foreign key (Person_id) references Person(Person_id) ON DELETE CASCADE
);


Create Table Room(
	Room_id serial primary key,
	Hotel_id int not null,
	RoomNumber int not null,
	PricePerNight decimal Check (PricePerNight > 0),
	Capacity int not null check (Capacity > 0),
	RoomView varchar (30) not null Check (RoomView in ('Sea','Mountain')),
	Extendable boolean,
	unique (Hotel_id,RoomNumber),
	foreign key (Hotel_id) references Hotel(Hotel_id) ON DELETE CASCADE
);

Create Table Amenity(
	Amenity_id serial primary,
	AmenityType varchar (100) not null check (AmenityType in ('Air Conditioning','TV','Fridge'))
);

create table RoomAmenity(
	Room_id int not null,
	Amenity_id int not null,
	unique (Room_id,Amenity_id),
	foreign key (Room_id) references Room(Room_id) ON DELETE CASCADE,
	Foreign key (Amenity_id) references Amenity(Amenity_id) ON DELETE CASCADE
);

create table Damages(
	Damage_id int not null,
	Room_id int not null,
	Description text not null,
	Status varchar(100) not null,
	DateReported date,
	unique (Room_id,Damage_id),
	FOREIGN KEY (Room_id) REFERENCES Room(Room_id) ON DELETE CASCADE
);

create table Booking(
	Booking_id serial Primary key,
	Customer_id int not null,
	Room_id int not null,
	StartDate date not null check(StartDate >= current_date),
	EndDate date not null check (EndDate > StartDate),
	BookingDate date DEFAULT CURRENT_DATE,
	foreign key (Customer_id) references Customer(Person_id)ON DELETE RESTRICT,
	foreign key (Room_id) references Room(Room_id) ON DELETE RESTRICT,
);

create table Renting(
	Renting_id serial primary key,
	Room_id int not null,
	Customer_id int not null,
	Employee_id int not null,
	Booking_id int,
	unique (Booking_id),
	StartDate date not null check(StartDate >= current_date),
	EndDate date not null check ( EndDate > StartDate),
	RentingDate date DEFAULT CURRENT_DATE,
	
    foreign key (Room_id) references Room(Room_id)  ON DELETE RESTRICT,
    foreign key (Customer_id) references Customer(Person_id) ON DELETE RESTRICT  ,
    foreign key (Employee_id) references Employee(Person_id)  ON DELETE RESTRICT
);

create table BookingArchive (
    ArchiveBooking_id serial primary key,
    OriginalBooking_id int,
	
    ArchivedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	
    CustomerFullName varchar(100) not null,
	CustomerIDType varchar (100) not null,
	CustomerIDValue varchar (100) not null,
    CustomerAddress varchar(255),
    
    RoomNumber varchar(20),
    Capacity varchar(20),
    RoomView varchar(20),
	Extendable boolean,
    PricePerNight decimal(10,2),
	
    HotelChainName varchar (200),
    HotelName varchar(100),
    HotelAddress varchar(255),
    
    StartDate date not null,
    EndDate date not null,
    BookingDate date
    
);

create table RentingArchive (
    ArchiveRentingID serial primary key, 
    OriginalRentingID int,

	ArchivedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CustomerFullName varchar(100) not null,
	CustomerIDType varchar (100) not null,
	CustomerIDValue varchar (100) not null,
    CustomerAddress varchar(255),
    
    EmployeeID int,
    EmployeeFullName VARCHAR(100),
    
    RoomNumber varchar(20),
    Capacity varchar(20),
    RoomView varchar(20),
	Extendable boolean,
    PricePerNight decimal(10,2),
    
    HotelChainName varchar (200),
    HotelName varchar(100),
    HotelAddress varchar(255),
    
    StartDate date not null,
    EndDate date not null,
    RentingDate date
);
