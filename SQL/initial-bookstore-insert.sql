INSERT INTO Region VALUES('K4B 1P6', 'Ontario', 'Canada');
INSERT INTO Region VALUES('K1S 5B6', 'Ontario', 'Canada');
INSERT INTO Region VALUES('H3A 0B8', 'Quebec', 'Canada');
INSERT INTO Region VALUES('06511', 'Connecticut', 'United States');
INSERT INTO Region VALUES('K1V 8R9', 'Ontario', 'Canada');

INSERT INTO Address VALUES(100001, 5525, 'Boundary Rd', 'Navan', 'K4B 1P6');
INSERT INTO Address VALUES(100002, 1125, 'Colonel By Dr', 'Ottawa', 'K1S 5B6');
INSERT INTO Address VALUES(100003, 680, 'Sherbrooke St W', 'Montreal', 'H3A 0B8');
INSERT INTO Address VALUES(100004, 77, 'Broadway', 'New Haven', '06511');
INSERT INTO Address VALUES(100005, 2515, 'Bank St', 'Ottawa', 'K1V 8R9');

INSERT INTO Warehouse VALUES(1000001, 100001);

INSERT INTO Publisher VALUES(100000001, 'Good Books Publishing', 'goodbookspublishing@gmail.com', 1, 100002);
INSERT INTO Publisher VALUES(100000002, 'Joe and Smiths', 'joe_smiths@gmail.com', 2, 100003);
INSERT INTO Publisher VALUES(100000003, 'New Haven Publishing', 'newhavenpublishing@gmail.com', 3, 100004);

INSERT INTO Book VALUES('668-54-24160-15-0','The Sun Also Rises','Jules Verne','Crime',100000001,104,12.91,55.09,50,33,18);
INSERT INTO Book VALUES('343-68-52881-00-5','Game of Thrones','Jane Austen','Romance',100000001,497,9.20,61.74,63,29,10);
INSERT INTO Book VALUES('887-22-81808-10-8','The Sound and the Fury','Herman Melville','Crime',100000001,411,11.62,74.43,59,24,18);
INSERT INTO Book VALUES('863-84-01487-68-6','Oedipus at Colonus','Dr. Seuss','Adventure',100000001,484,10.90,65.87,18,14,4);
INSERT INTO Book VALUES('716-52-50048-25-4','Lord of the Flies','J. K. Rowling','Adventure',100000001,428,31.11,43.06,18,19,14);
INSERT INTO Book VALUES('458-28-70542-13-3','The Handmaid''s Tale','Paulo Coelo','Family',100000001,435,30.43,70.73,2,29,15);
INSERT INTO Book VALUES('587-11-10570-06-6','Lolita','John Steinbeck','Thriller',100000001,464,29.07,49.11,7,35,5);
INSERT INTO Book VALUES('472-37-48401-50-8','Gulliver''s Travels','Emily Dickinson','History',100000001,159,23.57,51.56,36,27,4);
INSERT INTO Book VALUES('567-08-25425-52-7','The Flowers of Evil','C.S. Lewis','Family',100000001,121,23.63,62.06,5,41,19);
INSERT INTO Book VALUES('160-54-35031-61-5','Invisible Man','Leo Tolstoy','Drama',100000001,323,10.81,52.35,16,28,8);
INSERT INTO Book VALUES('622-07-80488-72-1','The Grapes of Wrath','Danielle Steel','Musical', 100000001,484,24.88,68.04,47,32,3);
INSERT INTO Book VALUES('880-82-45816-81-1','The Metamorphosis','Oscar Wilde','Sci-Fi',100000002,137,11.23,69.11,22,28,11);
INSERT INTO Book VALUES('083-73-73061-08-8','The Old Man and the Sea','T. S. Eliot','Sci-Fi',100000002,209,35.10,59.12,57,36,8);
INSERT INTO Book VALUES('345-73-78534-72-0','To Kill a Mockingbird','Tennessee Williams','History',100000002,246,35.48,40.53,13,28,19);
INSERT INTO Book VALUES('774-21-03220-38-1','One Thousand and One Nights','Edith Wharton','Horror',100000002,156,20.57,57.26,2,19,10);
INSERT INTO Book VALUES('261-23-67185-85-3','The Flowers of Evil','Cormac McCarthy','History',100000002,117,25.00,43.40,51,12,18);
INSERT INTO Book VALUES('257-05-06740-84-7','The Canterbury Tales','Horatio Alger','Action',100000002,183,13.97,60.47,69,27,8);
INSERT INTO Book VALUES('813-60-20452-86-7','Oedipus','Edith Wharton','Musical',100000002,467,10.09,53.77,69,28,17);
INSERT INTO Book VALUES('537-16-53204-03-6','Hamlet','Stephenie Meyer','Biography',100000002,484,22.85,63.18,16,38,10);
INSERT INTO Book VALUES('515-37-15864-05-3','Tess of the d''Urbervilles','Bella Forrest','Fantasy',100000002,428,30.60,53.63,14,12,18);
INSERT INTO Book VALUES('273-21-86363-55-0','Game of Thrones','Ray Bradbury','Fantasy',100000002,450,9.73,45.94,20,46,3);
INSERT INTO Book VALUES('687-45-37386-00-7','Les Misérables','Stephenie Meyer','Thriller',100000002,434,29.89,77.30,9,46,15);
INSERT INTO Book VALUES('254-44-08082-51-1','Lord of the Flies','Alexandre Dumas','Family',100000002,312,11.64,52.03,24,12,11);
INSERT INTO Book VALUES('282-23-87500-18-8','Wuthering Heights','Horatio Alger','Fantasy',100000002,403,7.15,58.77,45,33,13);
INSERT INTO Book VALUES('853-14-56848-24-6','David Copperfield','Dr. Seuss','Fantasy',100000002,309,38.19,42.05,57,19,5);
INSERT INTO Book VALUES('164-81-67536-36-4','War and Peace','Jin Yong','Sci-Fi',100000002,245,12.45,41.05,32,14,2);
INSERT INTO Book VALUES('318-74-55022-86-0','Oedipus','Alexandre Dumas','Musical',100000002,150,29.13,41.36,62,24,17);
INSERT INTO Book VALUES('776-73-21644-58-6','The Brothers Karamazov ','Oscar Wilde','Thriller',100000002,146,14.40,50.73,26,21,13);
INSERT INTO Book VALUES('358-32-16470-05-8','Oedipus','G.R.R. Martin','Adventure',100000002,138,11.25,61.16,56,8,4);
INSERT INTO Book VALUES('438-14-11430-36-3','Gargantua and Pantagruel','Cormac McCarthy','Biography',100000002,422,6.19,65.97,34,43,9);
INSERT INTO Book VALUES('431-50-74546-78-2','The Good Soldier','William Shakespeare','Animation',100000002,472,24.22,73.29,69,36,7);
INSERT INTO Book VALUES('686-15-31044-51-8','The Good Soldier','Mark Twain','Animation',100000002,321,33.16,63.95,36,9,6);
INSERT INTO Book VALUES('856-32-00467-71-0','Wuthering Heights','Alexander Pushkin','Crime',100000002,325,32.39,67.99,66,34,8);
INSERT INTO Book VALUES('152-47-03174-10-6','Gargantua and Pantagruel','C.S. Lewis','Comedy',100000002,272,7.44,44.71,12,29,5);
INSERT INTO Book VALUES('700-10-32083-15-6','The Metamorphosis','G.R.R. Martin','Action',100000002,299,28.33,61.16,69,22,16);
INSERT INTO Book VALUES('882-84-45000-66-0','Anna Karenina','Jack London','Sci-Fi',100000002,209,12.09,54.58,11,40,16);
INSERT INTO Book VALUES('375-07-00762-11-1','Nineteen Eighty Four','Emily Dickinson','History',100000002,382,11.57,64.91,66,28,7);
INSERT INTO Book VALUES('582-87-01704-55-8','The Handmaid''s Tale','Herman Melville','Adventure',100000002,121,36.07,70.98,61,19,19);
INSERT INTO Book VALUES('665-35-18332-48-6','The Great Gatsby','Barbara Cartland','Animation',100000002,119,19.10,65.73,60,25,3);
INSERT INTO Book VALUES('845-07-63652-21-3','Gargantua and Pantagruel','Agatha Christie','Fantasy',100000003,322,12.29,64.10,22,19,19);
INSERT INTO Book VALUES('836-56-62724-40-5','The Divine Comedy','Flannery O''Connor','Action',100000003,484,33.35,56.76,51,19,6);
INSERT INTO Book VALUES('110-45-70515-04-8','Lolita','Barbara Cartland','Horror',100000003,128,21.90,70.27,14,21,13);
INSERT INTO Book VALUES('566-28-82204-45-5','David Copperfield','Edgar Allan Poe','Sci-Fi',100000003,318,36.84,78.88,6,32,5);
INSERT INTO Book VALUES('843-27-40873-87-1','Oedipus','Henry James','Biography',100000003,240,31.34,60.28,20,19,8);
INSERT INTO Book VALUES('142-33-37504-34-5','Gulliver''s Travels','Cormac McCarthy','Action',100000003,288,23.82,45.78,30,17,16);
INSERT INTO Book VALUES('255-16-08518-03-2','War and Peace','Harper Lee','Sci-Fi',100000003,364,17.73,67.35,13,37,9);
INSERT INTO Book VALUES('270-64-15613-17-6','Paradise Lost','Guillaume Musso','Adventure',100000003,302,31.34,63.83,7,18,17);
INSERT INTO Book VALUES('834-36-54072-78-0','Anna Karenina','Margaret Atwood','Fantasy',100000003,243,17.13,73.49,55,36,2);
INSERT INTO Book VALUES('461-57-15241-70-6','Anna Karenina','Jack London','Animation',100000003,478,9.93,59.84,61,49,7);
INSERT INTO Book VALUES('532-48-33164-88-3','Tess of the d''Urbervilles','Herman Melville','Drama',100000003,353,25.46,72.39,8,14,5);
						
INSERT INTO Staff VALUES(10001, 'bookstore@gmail.com');
INSERT INTO Staff VALUES(10002, 'bookstore@gmail.com');

INSERT INTO Client Values(1001, 'Christopher Shen', 'christophershen@cmail.carleton.ca', 737111, 100005);

INSERT INTO BankAccount Values(100001, 5000);
INSERT INTO BankAccount Values(100002, 13000);
INSERT INTO BankAccount Values(100003, 50000);
INSERT INTO BankAccount Values(100004, 44000);
INSERT INTO BankAccount Values(100005, 200);
INSERT INTO BankAccount Values(100006, 10000);
INSERT INTO BankAccount Values(100007, 9000);
INSERT INTO BankAccount Values(100008, 5600);
INSERT INTO BankAccount Values(100009, 23000);
INSERT INTO BankAccount Values(100010, 500);

INSERT INTO client_account Values(1001, 100001);

INSERT INTO publisher_account Values(100000001, 100002);
INSERT INTO publisher_account Values(100000002, 100003);
INSERT INTO publisher_account Values(100000003, 100004);
