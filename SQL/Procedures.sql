create or replace procedure update_orders()
	language plpgsql as
$$
	begin
		update Orders set status = 'ARRIVED' 
		where status = 'SHIPPED' and (current_timestamp - interval '10 minutes') > order_placement_date;
		
		update Orders set status = 'SHIPPED' 
		where status = 'PENDING' and (current_timestamp - interval '5 minutes') > order_placement_date;
	end;
$$;