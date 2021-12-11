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

create or replace function order_books() returns trigger AS 
'
	declare 
		order_month varchar(20);
		order_year int;

	begin
		IF NEW.stock < NEW.threshold then
			select month into order_month from get_prev_month();
			select year into order_year from get_prev_month();

			update Book
			set stock = stock + sales_by_month_per_book(ISBN, order_month, order_year)
			where Book.ISBN = NEW.ISBN;
		end if;
		return NEW;
	end;
'
language plpgsql;
