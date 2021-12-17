SELECT * FROM Book NATURAL JOIN Publisher WHERE isbn = '668-54-24160-15-0'
AND upper(title) LIKE 'The Sun Also Rises' AND upper(author_name) LIKE 'Jules Verne' AND  genre = 'Crime' AND stock > 0 ORDER BY cost LIMIT 20;

SELECT * FROM Book NATURAL JOIN Publisher WHERE ISBN = '668-54-24160-15-0';

SELECT genre FROM Book GROUP BY (genre);

SELECT * FROM Client WHERE client_id = 1 AND email = 'christophershen@cmali.carleton.ca';

SELECT * FROM Staff WHERE staff_id = 10001 AND email = 'bookstore@gmail.com';

INSERT INTO Client(name, email, phone_number, address_id) VALUES('Christopher Shen', 'christopehrshen@cmail.carleton.ca', 7371111, 100005);

SELECT currval(pg_get_serial_sequence('Client', 'client_id')) AS client_id;

INSERT INTO client_account VALUES(1, 100001);

SELECT status FROM tracks NATURAL JOIN Orders WHERE client_id = 1 AND order_number = 1;

SELECT amount FROM BankAccount WHERE account_number = 100001;

SELECT count(address_id) AS num_address FROM Address WHERE address_id = 100005;

INSERT INTO Region VALUES('K1V 8R9', 'Ottawa', 'Ontario');

INSERT INTO Address VALUES(100005, 2515, 'Bank St', 'Ottawa', 'K1V 8R9');

SELECT place_order(1, 100005 1) AS order_number;

SELECT checkout_book(100000001, 100001, 1, 2);

SELECT count(client_id) AS num_client FROM client_account WHERE client_id = 1 AND account_number = 100001;

CALL update_orders();

UPDATE Book SET cost = 20, price = 40, publisher_percent = 15, stock = 30, threshold = 10 WHERE isbn = '668-54-24160-15-0';

SELECT * FROM Publisher WHERE publisher_id = 100000001;

INSERT INTO Book VALUES('668-54-24160-15-0', 'The Sun Also Rises', 'Jules Verne', 'Crime', 100000001, 100, 12.99, 25.99, 15, 30, 10);

DELETE FROM Book WHERE isbn = '668-54-24160-15-0';

SELECT warehouse_id FROM Warehouse;

SELECT * FROM ". $viewToUse ." NATURAL JOIN Book WHERE ((to_date(month, 'Month') >= to_date('January', 'Month') AND year >= 2020) OR (year > 2020))
AND ((to_date(month, 'Month') <= to_date('April', 'Month') AND year <= 2021) OR (year < 2021)) AND upper(Book.author_name) LIKE 'Jules Verne'
AND Book.genre = 'Crime' AND Book.publisher_id = 100000001;

