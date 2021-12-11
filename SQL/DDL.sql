create table if not exists Region
	(postal_code	varchar(10),
	 state			varchar(50),
	 country		varchar(50),
	 primary key (postal_code)
	);
	
create table if not exists Address
	(address_id		int,
	 building_num	int,
	 street			varchar(50),
	 city 			varchar(50),
	 postal_code 	varchar(10),
	 primary key (address_id),
	 foreign key (postal_code) references Region
	);

create table if not exists Publisher
	(publisher_id	int,
	 name			varchar(50),
	 email			varchar(50),
	 phone_number 	int,
	 address_id 	int,
	 primary key (publisher_id),
	 foreign key (address_id) references Address
	);
	
create table if not exists Book
	(ISBN				varchar(15),
	 title				varchar(50),
	 author_name		varchar(50),
	 genre 				varchar(15),
	 publisher_id 		int,
	 number_of_pages 	int,
	 cost 				numeric(3,2),
	 price 				numeric(3,2),
	 publisher_percent 	numeric(2,2),
	 stock 				int,
	 threshold 			int,
	 primary key (ISBN),
	 foreign key (publisher_id) references Publisher
	);
	
create table if not exists Staff
	(staff_id			int,
	 email				varchar(50),
	 primary key (staff_id)
	);
	
create table if not exists Warehouse
	(warehouse_id		int,
	 address_id			int,
	 primary key (warehouse_id),
	 foreign key (address_id) references Address
	);
	
create table if not exists Client
	(client_id 		int,
	 name 			varchar(50),
	 email 			varchar(50),
	 phone_number 	int,
	 address_id 	int,
	 primary key (client_id),
	 foreign key (address_id) references Address
	);
	
create table if not exists BankAccount
	(account_number 	int,
	 amount 			numeric(12,2),
	 primary key (account_number)
	);
	
create table if not exists Sales
	(ISBN 				varchar(15),
	 month 				varchar(20) check (month in ('January','February','March','April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')),
	 year 				int check (year > 1900 and year < 2022),
	 total_sales_value 	Numeric(12,2),
	 primary key (ISBN, month, year),
	 foreign key (ISBN) references Book
	);

create table if not exists Orders
	(order_number 			int,
	 order_placement_date 	Date,
	 status 				varchar(15) check (status in ('PENDING', 'SHIPPED', 'ARRIVED')),
	 final_total 			Numeric(12,2),
	 address_id 			int,
	 warehouse_id 			int,
	 primary key (order_number),
	 foreign key (address_id) references Address,
	 foreign key (warehouse_id) references Warehouse
	);