CREATE TABLE HotelChain (
    Chain_id SERIAL PRIMARY KEY,
    Address VARCHAR(200) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PhoneNumber BIGINT NOT NULL CHECK (PhoneNumber > 0),
    NumberOfHotels INT CHECK (NumberOfHotels >= 0)
);

Create table ChainEmail(
	Chain_id INT NOT NULL,
	Email VARCHAR NOT NULL CHECK (Email > 0),
	PRIMARY KEY (Chain_id,Email),
	FOREIGN KEY (Chain_id) REFERENCES HotelChain(Chain_id)
);

Create table ChainPhone(
	Chain_id INT NOT NULL,
	PhoneNumber VARCHAR NOT NULL CHECK ( PhoneNumber > 0),
	PRIMARY KEY (Chain_id, PhoneNumber),
	FOREIGN KEY (Chain_id) REFERENCES ChainHotel(Chain_id)
);

CREATE TABLE Hotel (
	Hotel_id SERIAL PRIMARY KEY,
	Chain_id INT NOT NULL,
	Address VARCHAR (200) NOT NULL,
	Email VARCHAR (100) NOT NULL,
	Stars INT CHECK (Stars BETWEEN 1 AND 5),
	Manager_id INT not null UNIQUE,
	FOREIGN KEY (Chain_id) REFERENCES HotelChain(Chain_id),
	FOREIGN KEY (Manager_id) REFERENCES Employee(Person_id)
);

CREATE TABLE HotelPhone(
	Hotel_id INT NOT NULL,
	PhoneNumber VARCHAR NOT NULL CHECK ( PhoneNumber > 0),
	PRIMARY KEY (Hotel_id, PhoneNumber),
	FOREIGN KEY (Hotel_id) REFERENCES Hotel(Hotel_id)
);

Create Table Room(
	Room_id SERIAL PRIMARY KEY,
	Hotel_id INT NOT NULL,
	RoomNumber INT NOT NULL,
	PricePerNight DECIMAL Check (PricePerNight > 0),
	Capacity VARCHAR (50) NOT NULL,
	RoomView VARCHAR (30) NOT NULL Check (RoomView IN 'Sea','Mountain')),
	Extendable BOOLEAN,
	UNIQUE (Hotel_id,RoomNumber),
	FOREIGN KEY (Hotel_id) REFERENCES Hotel(Hotel_id)
);

Create Table Amenity(
	Amenity_id serial PRIMARY KEY,
	AmenityType VARCHAR (100) not null check (type in 'Air Conditioning','TV', 'Fridge'),
);

create table RoomAmenity(
	Room_id int not null,
	Amenity_id int not null,
	unique (Room_id,Amenity_id),
	FOREIGN KEY (Room_id) REFERENCES Room(Room_id),
	Foreign key (Amenity_id) references Amenity(Amenity_id)
);

create table Damages(
	Damage_id int not null,
	Room_id int not null,
	Description text not null,
	Status VARCHAR(100) not null,
	DateReported date,
	unique (Room_id,Damage_id),
	FOREIGN KEY (Room_id) REFERENCES Room(Room_id),
);

Create table Person(
	Person_id serial primary key,
	FirstName varchar(50) not null
	MiddleName varchar(50),
	LastName varchar(50) not null,
	Address varchar (100) not null
);

create table Employee(
	Person_id int Primary key not null,
	Hotel_id int not null,
	SSN_SIN varchar(50) not null unique,
	role varchar(50) not null,
	foreign key (Person_id) references Person(Person_id),
	foreign key (Hotel_id) references Hotel(Hotel_id)
);

create table Customer(
	Person_id int Primary Key not null,
	IdType varchar(50) not null unique check ( IdType is in 'SSN_SIN','Passport','Drivers License')),
	Registration date not null check (Registration <= CURRENT_DATE)
);

create table Booking(
	Booking_id serial Primary key,
	Customer_id int not null,
	Room_id int not null,
	StartDate date not null check(StartDate <= current_date),
	EndDate date not null check (EndDate < StartDate),
	foreign key (Customer_id) references Customer(Person_id),
	foreign key (Room_id) references Room(Room_id)
	 EXCLUDE USING gist (
        RoomID WITH =,
        daterange(StartDate, EndDate, '[)') WITH &&
    )
);

create table Renting(
	Renting_id serial primary key,
	Room_id int not null,
	Customer_id int not null,
	Employee_id int not null,
	Booking_id int,
	unique (Booking_id),
	StartDate date not null check(StartDate >= current_date)
	EndDate date not null check ( StartDate < EndDate),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(PersonID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(PersonID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)	
);
