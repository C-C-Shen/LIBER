drop table checkout;
drop table emails;
drop table tracks;
drop table publisher_account;
drop table client_account;
drop table handle_account;
drop table update_sales;
drop table manage;
drop table Orders;
drop table Sales;
drop table BankAccount;
drop table Client;
drop table Warehouse;
drop table Staff;
drop table Book;
drop table Publisher;
drop table Address;
drop table Region;

create table if not exists Region
	(postal_code		varchar(10),
	 state			varchar(50) not null,
	 country		varchar(50) not null,
	 primary key (postal_code)
	);
	
create table if not exists Address
	(address_id		serial,
	 building_num		int,
	 street			varchar(50),
	 city 			varchar(50),
	 postal_code 		varchar(10) not null,
	 primary key (address_id),
	 foreign key (postal_code) references Region
	 	on delete cascade
	);

create table if not exists Publisher
	(publisher_id		int,
	 name			varchar(50) not null,
	 email			varchar(50),
	 phone_number 		int not null,
	 address_id 		serial,
	 primary key (publisher_id),
	 foreign key (address_id) references Address
	 	 	on delete set null
	);
	
create table if not exists Book
	(ISBN			varchar(30),
	 title			varchar(50) not null,
	 author_name		varchar(50) not null,
	 genre 			varchar(30) not null,
	 publisher_id 		int not null,
	 number_of_pages 	int not null,
	 cost 			numeric(4,2) not null,
	 price 			numeric(4,2) not null,
	 publisher_percent 	numeric(4,2) not null,
	 stock 			int not null,
	 threshold 		int not null,
	 primary key (ISBN),
	 foreign key (publisher_id) references Publisher
	 	 	on delete cascade
	);
	
create table if not exists Staff
	(staff_id		int,
	 email			varchar(50) not null,
	 primary key (staff_id)
	);
	
create table if not exists Warehouse
	(warehouse_id		int,
	 address_id		serial,
	 primary key (warehouse_id),
	 foreign key (address_id) references Address
	 	on delete set null
	);
	
create table if not exists Client
	(client_id 		serial,
	 name 			varchar(50) not null,
	 email 			varchar(50) not null,
	 phone_number 		int,
	 address_id 		serial,
	 primary key (client_id),
	 foreign key (address_id) references Address
	 	on delete set null
	);
	
create table if not exists BankAccount
	(account_number 	int,
	 amount 		numeric(12,2) not null,
	 primary key (account_number)
	);
	
create table if not exists Sales
	(ISBN 			varchar(30),
	 month 			varchar(20) check (month in ('January','February','March','April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')),
	 year 			int check (year > 1900 and year < 2022),
	 quantity		int not null,
	 primary key (ISBN, month, year),
	 foreign key (ISBN) references Book
	 	on delete cascade
	);

create table if not exists Orders
	(order_number 		serial,
	 order_placement_date 	timestamp not null,
	 status 		varchar(15) check (status in ('PENDING', 'SHIPPED', 'ARRIVED')),
	 final_total 		Numeric(12,2) not null,
	 address_id 		serial not null,
	 warehouse_id 		int not null,
	 primary key (order_number),
	 foreign key (address_id) references Address
	 	on delete cascade,
	 foreign key (warehouse_id) references Warehouse
	 	on delete cascade
	);

create table if not exists manage
	(ISBN			varchar(30),
	 staff_id		int,
	 primary key (ISBN, staff_id),
	 foreign key (ISBN) references Book
	 	on delete cascade,
	 foreign key (staff_id) references Staff
	 	on delete cascade
	);

create table if not exists update_sales
	(order_number		serial,
	 ISBN 			varchar(30),
	 month 			varchar(20) check (month in ('January','February','March','April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')),
	 year 			int check (year > 1900 and year < 2022),
	 primary key (order_number, ISBN, month, year),
	 foreign key (order_number) references Orders
	 	on delete cascade,
	 foreign key (ISBN, month, year) references Sales
	 	on delete cascade
	);

create table if not exists handle_account
	(order_number		serial,
	 account_number		int,
	 primary key (order_number, account_number),
	 foreign key (order_number) references Orders
	 	on delete cascade,
	 foreign key (account_number) references BankAccount
	 	on delete cascade
	);

create table if not exists client_account
	(client_id		serial,
	 account_number 	int,
	 primary key (client_id, account_number),
	 foreign key (client_id) references Client
	 	on delete cascade,
	 foreign key (account_number) references BankAccount
	 	on delete cascade
	);

create table if not exists publisher_account
	(publisher_id		int,
	 account_number 	int,
	 primary key (publisher_id),
	 foreign key (publisher_id) references Publisher
	 	on delete cascade,
	 foreign key (account_number) references BankAccount
	 	on delete cascade
	);

create table if not exists tracks
	(order_number		serial,
	 client_id 		serial,
	 primary key (order_number),
	 foreign key (order_number) references Orders
	 	on delete cascade,
	 foreign key (client_id) references Client
	 	on delete cascade
	);

create table if not exists emails
	(staff_id		int,
	 publisher_id 		int,
	 primary key (staff_id, publisher_id),
	 foreign key (staff_id) references Staff
	 	on delete cascade,
	 foreign key (publisher_id) references Publisher
	 	on delete cascade
	);

create table if not exists checkout
	(ISBN			varchar(30),
	 order_number		serial,
	 quantity		int,
	 primary key (ISBN, order_number),
	 foreign key (ISBN) references Book
	 	on delete cascade,
	 foreign key (order_number) references Orders
	 	on delete cascade
	);