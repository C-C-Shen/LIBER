DROP FUNCTION checkout_func;

create or replace function sales_by_month_per_book (ISBN_to_check varchar(30), month_to_check char(20), year_to_check int)
	returns int
	language plpgsql
as
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
	language plpgsql
as
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
	language plpgsql
as
$$
begin
return 
	query
	select
	   get_month_name(cast(date_part('month', date_trunc('month', current_timestamp) - interval '1 month') as integer)),
	   cast(date_part('year', date_trunc('month', current_timestamp) - interval '1 month') as integer);
end;		
$$;

create or replace function order_books() returns trigger as
'
	declare 
		order_month varchar(20);
		order_year int;
		new_stock int;
	begin
		if NEW.stock < NEW.threshold then
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
'
language plpgsql;

create or replace function checkout_func(target_ISBN varchar(30), target_client int, client_bank int, target_order int, new_quantity int) returns boolean as
'
	declare
		p_id			int				:= (select publisher_id FROM Book WHERE ISBN = target_ISBN);
		pre_tax			numeric(12,2)	:= (select price from Book where Book.ISBN = target_ISBN) * new_quantity;
		with_tax		numeric(12,2)	:= pre_tax * 1.13;
		p_cut			numeric(12,2)	:= pre_tax * (select publisher_percent FROM Book WHERE ISBN = target_ISBN) * 0.01;
		revenue_final	numeric(12,2)	:= with_tax - p_cut;
		curr_month		varchar(20) := (select get_month_name(cast(date_part(''month'', date_trunc(''month'', current_timestamp)) as integer)));
		curr_year		int := (select date_part(''year'', CURRENT_DATE));
		error_val		boolean := FALSE;
	begin		
		IF ((select stock FROM Book WHERE Book.ISBN = target_ISBN) >= new_quantity) and
			((select amount FROM BankAccount Where BankAccount.account_number = client_bank) >= with_tax) THEN
			
			UPDATE Book
			SET stock = stock - new_quantity
			WHERE Book.ISBN = target_ISBN;
			
			UPDATE Orders
			SET final_total = final_total + with_tax
			WHERE Orders.order_number = target_order;
			
			UPDATE BankAccount
			SET amount = amount - with_tax
			WHERE BankAccount.account_number = client_bank;
			
			UPDATE BankAccount 
			SET amount = amount + p_cut
			WHERE BankAccount.account_number = (select account_number FROM publisher_account WHERE publisher_account.publisher_id = p_id);

			IF target_ISBN not in (SELECT ISBN FROM Sales WHERE Sales.month = curr_month and Sales.year = curr_year) THEN
				INSERT INTO Sales VALUES(target_ISBN, curr_month, curr_year, new_quantity);
			ELSE
				UPDATE Sales
				SET quantity = quantity + new_quantity
				WHERE Sales.month = curr_month and Sales.year = curr_year;
			END IF;

			INSERT INTO checkout VALUES(target_ISBN, target_order, new_quantity); 
		ELSE
			error_val := TRUE;
		END IF;
		
		IF error_val THEN
			return FALSE;
		END IF;
		return TRUE;
	end;        
'
language plpgsql;