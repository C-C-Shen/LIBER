create or replace function sales_by_month_per_book (ISBN_to_check varchar(30), month_to_check char(20), year_to_check int)
	returns int
	language plpgsql as
$$
	declare 
		total_sales int;
	begin
		select quantity
		into total_sales
		from Sales
		where ISBN = ISBN_to_check and
			month = month_to_check and
			year = year_to_check;

		return total_sales;
	end;		
$$;

create or replace function get_month_name(month_val int)
	returns varchar(20)
	language plpgsql as
$$
	declare 
		months varchar(20)[];
	begin
		months := array ['January','February','March','April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
		return months[month_val];
	end;		
$$;


create or replace function get_prev_month ()
	returns table(month varchar(20), year int)
	language plpgsql as
$$
	begin
	return 
		query
		select
		   get_month_name(cast(date_part('month', date_trunc('month', current_timestamp) - interval '1 month') as integer)),
		   cast(date_part('year', date_trunc('month', current_timestamp) - interval '1 month') as integer);
	end;		
$$;

create or replace function get_curr_month ()
	returns table(month varchar(20), year int)
	language plpgsql as
$$
	begin
	return 
		query
		select
		   get_month_name(cast(date_part('month', date_trunc('month', current_timestamp)) as integer)),
		   cast(date_part('year', date_trunc('month', current_timestamp)) as integer);
	end;		
$$;

create or replace function order_books() 
	returns trigger
	language plpgsql as
$$
	declare 
		order_month varchar(20);
		order_year int;
		new_stock int;
	begin
		if NEW.stock < NEW.threshold then
			insert into  emails select 10001, NEW.publisher_id
			where not exists (select publisher_id from emails where publisher_id = NEW.publisher_id);
	
			select month into order_month from get_prev_month();
			select year into order_year from get_prev_month();
			select sales_by_month_per_book(NEW.ISBN, order_month, order_year) into new_stock;
			if new_stock is NULL then
				select 2 * NEW.threshold into new_stock;
			end if;
			update Book
			set stock = stock + new_stock
			where Book.ISBN = NEW.ISBN;
		end if;
		return NEW;
	end;
$$;

create or replace function checkout_book(target_ISBN varchar(30), client_bank int, target_order int, new_quantity int) 
	returns boolean
	language plpgsql as
$$
	declare
		p_id			int		:= (select publisher_id from Book where ISBN = target_ISBN);
		pre_tax			numeric(12,2)	:= (select price from Book where Book.ISBN = target_ISBN) * new_quantity;
		with_tax		numeric(12,2)	:= pre_tax * 1.13;
		p_cut			numeric(12,2)	:= pre_tax * (select publisher_percent from Book where ISBN = target_ISBN) * 0.01;
		revenue_final		numeric(12,2)	:= with_tax - p_cut;
		curr_month		varchar(20) 	:= (select month from get_curr_month());
		curr_year		int 		:= (select year from get_curr_month());
		error_val		boolean 	:= FALSE;
	begin		
		if ((select stock FROM Book WHERE Book.ISBN = target_ISBN) >= new_quantity) and
			((select amount FROM BankAccount Where BankAccount.account_number = client_bank) >= with_tax) THEN
			
			update Book
			set stock = stock - new_quantity
			where Book.ISBN = target_ISBN;
			
			UPDATE Orders
			SET final_total = final_total + with_tax
			WHERE Orders.order_number = target_order;
			
			update BankAccount
			set amount = amount - with_tax
			where BankAccount.account_number = client_bank;
			
			update BankAccount 
			set amount = amount + p_cut
			where BankAccount.account_number = (select account_number from publisher_account where publisher_account.publisher_id = p_id);

			if target_ISBN not in (select ISBN from Sales where Sales.month = curr_month and Sales.year = curr_year) then
				insert into Sales values(target_ISBN, curr_month, curr_year, new_quantity);
			else
				update Sales
				set quantity = quantity + new_quantity
				where Sales.isbn = target_isbn and Sales.month = curr_month and Sales.year = curr_year;
			end if;

			insert into update_sales values(target_order, target_ISBN, curr_month, curr_year);
			
			insert into checkout values(target_ISBN, target_order, new_quantity); 
		else
			error_val := TRUE;
		end if;
		
		if error_val then
			return FALSE;
		end if;

		return TRUE;
	end;        
$$;


create or replace function place_order(target_client int, target_address bigint, target_warehouse int)
	returns int
	language plpgsql as
$$
	declare 
			target_order	int;
	begin
			insert into Orders (order_placement_date, status, final_total, address_id, warehouse_id) values(current_timestamp, 'PENDING', 0, target_address, target_warehouse);

			select currval(pg_get_serial_sequence('Orders', 'order_number')) into target_order; 

			insert into tracks values (target_order, target_client);

			return target_order;
	end;
$$;