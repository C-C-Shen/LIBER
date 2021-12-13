delete from Orders;
delete from Checkout;

select checkout_book('668-54-24160-15-0', 100001, (select place_order(1, 100005, 1000001)), 1);