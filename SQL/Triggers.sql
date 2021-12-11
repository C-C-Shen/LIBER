create trigger order_books
after update on Book
    for each row execute procedure order_books();