delete from Orders;
delete from Checkout;

select checkout_book('668-54-24160-15-0', 1001, 100001, (select place_order(1000001, 100005, 1000001)), 1);