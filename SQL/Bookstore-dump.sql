--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: checkout_book(character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkout_book(target_isbn character varying, client_bank integer, target_order integer, new_quantity integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.checkout_book(target_isbn character varying, client_bank integer, target_order integer, new_quantity integer) OWNER TO postgres;

--
-- Name: get_curr_month(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_curr_month() RETURNS TABLE(month character varying, year integer)
    LANGUAGE plpgsql
    AS $$
	begin
	return 
		query
		select
		   get_month_name(cast(date_part('month', date_trunc('month', current_timestamp)) as integer)),
		   cast(date_part('year', date_trunc('month', current_timestamp)) as integer);
	end;		
$$;


ALTER FUNCTION public.get_curr_month() OWNER TO postgres;

--
-- Name: get_month_name(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_month_name(month_val integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	declare 
		months varchar(20)[];
	begin
		months := array ['January','February','March','April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
		return months[month_val];
	end;		
$$;


ALTER FUNCTION public.get_month_name(month_val integer) OWNER TO postgres;

--
-- Name: get_prev_month(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_prev_month() RETURNS TABLE(month character varying, year integer)
    LANGUAGE plpgsql
    AS $$
	begin
	return 
		query
		select
		   get_month_name(cast(date_part('month', date_trunc('month', current_timestamp) - interval '1 month') as integer)),
		   cast(date_part('year', date_trunc('month', current_timestamp) - interval '1 month') as integer);
	end;		
$$;


ALTER FUNCTION public.get_prev_month() OWNER TO postgres;

--
-- Name: order_books(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.order_books() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.order_books() OWNER TO postgres;

--
-- Name: place_order(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.place_order(target_client integer, target_address integer, target_warehouse integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare 
			target_order	int;
	begin
			insert into Orders (order_placement_date, status, final_total, address_id, warehouse_id) values(current_timestamp, 'PENDING', 0, target_address, target_warehouse);

			select currval(pg_get_serial_sequence('Orders', 'order_number')) into target_order; 

			insert into tracks values (target_order, target_client);

			return target_order;
	end;
$$;


ALTER FUNCTION public.place_order(target_client integer, target_address integer, target_warehouse integer) OWNER TO postgres;

--
-- Name: place_order(integer, bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.place_order(target_client integer, target_address bigint, target_warehouse integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare 
			target_order	int;
	begin
			insert into Orders (order_placement_date, status, final_total, address_id, warehouse_id) values(current_timestamp, 'PENDING', 0, target_address, target_warehouse);

			select currval(pg_get_serial_sequence('Orders', 'order_number')) into target_order; 

			insert into tracks values (target_order, target_client);

			return target_order;
	end;
$$;


ALTER FUNCTION public.place_order(target_client integer, target_address bigint, target_warehouse integer) OWNER TO postgres;

--
-- Name: sales_by_month_per_book(character varying, character, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sales_by_month_per_book(isbn_to_check character varying, month_to_check character, year_to_check integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.sales_by_month_per_book(isbn_to_check character varying, month_to_check character, year_to_check integer) OWNER TO postgres;

--
-- Name: update_orders(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_orders()
    LANGUAGE plpgsql
    AS $$
	begin
		update Orders set status = 'ARRIVED' 
		where status = 'SHIPPED' and (current_timestamp - interval '10 minutes') > order_placement_date;
		
		update Orders set status = 'SHIPPED' 
		where status = 'PENDING' and (current_timestamp - interval '5 minutes') > order_placement_date;
	end;
$$;


ALTER PROCEDURE public.update_orders() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    address_id bigint NOT NULL,
    building_num integer,
    street character varying(50),
    city character varying(50),
    postal_code character varying(10) NOT NULL
);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    isbn character varying(30) NOT NULL,
    month character varying(20) NOT NULL,
    year integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT sales_month_check CHECK (((month)::text = ANY ((ARRAY['January'::character varying, 'February'::character varying, 'March'::character varying, 'April'::character varying, 'May'::character varying, 'June'::character varying, 'July'::character varying, 'August'::character varying, 'September'::character varying, 'October'::character varying, 'November'::character varying, 'December'::character varying])::text[]))),
    CONSTRAINT sales_year_check CHECK (((year > 1900) AND (year < 2022)))
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- Name: allcurrmonthsales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.allcurrmonthsales AS
 SELECT sales.isbn,
    sales.month,
    sales.year,
    sales.quantity
   FROM public.sales
  WHERE (((sales.year)::double precision = date_part('year'::text, CURRENT_DATE)) AND (to_date((sales.month)::text, 'Month'::text) = to_date(to_char((CURRENT_DATE)::timestamp with time zone, 'MONTH'::text), 'Month'::text)))
  ORDER BY sales.year, sales.month;


ALTER TABLE public.allcurrmonthsales OWNER TO postgres;

--
-- Name: allcurryearsales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.allcurryearsales AS
 SELECT sales.isbn,
    sales.month,
    sales.year,
    sales.quantity
   FROM public.sales
  WHERE ((sales.year)::double precision = date_part('year'::text, CURRENT_DATE))
  ORDER BY sales.year, sales.month;


ALTER TABLE public.allcurryearsales OWNER TO postgres;

--
-- Name: allsales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.allsales AS
 SELECT sales.isbn,
    sales.month,
    sales.year,
    sales.quantity
   FROM public.sales
  ORDER BY sales.year, (to_date((sales.month)::text, 'Month'::text));


ALTER TABLE public.allsales OWNER TO postgres;

--
-- Name: bankaccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bankaccount (
    account_number integer NOT NULL,
    amount numeric(12,2) NOT NULL
);


ALTER TABLE public.bankaccount OWNER TO postgres;

--
-- Name: book; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.book (
    isbn character varying(30) NOT NULL,
    title character varying(50) NOT NULL,
    author_name character varying(50) NOT NULL,
    genre character varying(30) NOT NULL,
    publisher_id integer NOT NULL,
    number_of_pages integer NOT NULL,
    cost numeric(4,2) NOT NULL,
    price numeric(4,2) NOT NULL,
    publisher_percent numeric(4,2) NOT NULL,
    stock integer NOT NULL,
    threshold integer NOT NULL
);


ALTER TABLE public.book OWNER TO postgres;

--
-- Name: checkout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkout (
    isbn character varying(30) NOT NULL,
    order_number integer NOT NULL,
    quantity integer
);


ALTER TABLE public.checkout OWNER TO postgres;

--
-- Name: checkout_order_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checkout_order_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checkout_order_number_seq OWNER TO postgres;

--
-- Name: checkout_order_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checkout_order_number_seq OWNED BY public.checkout.order_number;


--
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    client_id integer NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    phone_number bigint,
    address_id bigint
);


ALTER TABLE public.client OWNER TO postgres;

--
-- Name: client_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_account (
    client_id integer NOT NULL,
    account_number integer NOT NULL
);


ALTER TABLE public.client_account OWNER TO postgres;

--
-- Name: client_account_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_account_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_account_client_id_seq OWNER TO postgres;

--
-- Name: client_account_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_account_client_id_seq OWNED BY public.client_account.client_id;


--
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_client_id_seq OWNER TO postgres;

--
-- Name: client_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.client_client_id_seq OWNED BY public.client.client_id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emails (
    staff_id integer NOT NULL,
    publisher_id integer NOT NULL
);


ALTER TABLE public.emails OWNER TO postgres;

--
-- Name: handle_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.handle_account (
    order_number integer NOT NULL,
    account_number integer NOT NULL
);


ALTER TABLE public.handle_account OWNER TO postgres;

--
-- Name: handle_account_order_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.handle_account_order_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.handle_account_order_number_seq OWNER TO postgres;

--
-- Name: handle_account_order_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.handle_account_order_number_seq OWNED BY public.handle_account.order_number;


--
-- Name: manage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manage (
    isbn character varying(30) NOT NULL,
    staff_id integer NOT NULL
);


ALTER TABLE public.manage OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_number integer NOT NULL,
    order_placement_date timestamp without time zone NOT NULL,
    status character varying(15),
    final_total numeric(12,2) NOT NULL,
    address_id bigint NOT NULL,
    warehouse_id integer NOT NULL,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SHIPPED'::character varying, 'ARRIVED'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_order_number_seq OWNER TO postgres;

--
-- Name: orders_order_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_number_seq OWNED BY public.orders.order_number;


--
-- Name: publisher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publisher (
    publisher_id integer NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(50),
    phone_number bigint NOT NULL,
    address_id bigint
);


ALTER TABLE public.publisher OWNER TO postgres;

--
-- Name: publisher_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publisher_account (
    publisher_id integer NOT NULL,
    account_number integer
);


ALTER TABLE public.publisher_account OWNER TO postgres;

--
-- Name: region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region (
    postal_code character varying(10) NOT NULL,
    state character varying(50) NOT NULL,
    country character varying(50) NOT NULL
);


ALTER TABLE public.region OWNER TO postgres;

--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    staff_id integer NOT NULL,
    email character varying(50) NOT NULL
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Name: tracks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tracks (
    order_number integer NOT NULL,
    client_id integer NOT NULL
);


ALTER TABLE public.tracks OWNER TO postgres;

--
-- Name: tracks_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tracks_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tracks_client_id_seq OWNER TO postgres;

--
-- Name: tracks_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tracks_client_id_seq OWNED BY public.tracks.client_id;


--
-- Name: tracks_order_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tracks_order_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tracks_order_number_seq OWNER TO postgres;

--
-- Name: tracks_order_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tracks_order_number_seq OWNED BY public.tracks.order_number;


--
-- Name: update_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.update_sales (
    order_number integer NOT NULL,
    isbn character varying(30) NOT NULL,
    month character varying(20) NOT NULL,
    year integer NOT NULL,
    CONSTRAINT update_sales_month_check CHECK (((month)::text = ANY ((ARRAY['January'::character varying, 'February'::character varying, 'March'::character varying, 'April'::character varying, 'May'::character varying, 'June'::character varying, 'July'::character varying, 'August'::character varying, 'September'::character varying, 'October'::character varying, 'November'::character varying, 'December'::character varying])::text[]))),
    CONSTRAINT update_sales_year_check CHECK (((year > 1900) AND (year < 2022)))
);


ALTER TABLE public.update_sales OWNER TO postgres;

--
-- Name: update_sales_order_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.update_sales_order_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.update_sales_order_number_seq OWNER TO postgres;

--
-- Name: update_sales_order_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.update_sales_order_number_seq OWNED BY public.update_sales.order_number;


--
-- Name: warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse (
    warehouse_id integer NOT NULL,
    address_id bigint
);


ALTER TABLE public.warehouse OWNER TO postgres;

--
-- Name: checkout order_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout ALTER COLUMN order_number SET DEFAULT nextval('public.checkout_order_number_seq'::regclass);


--
-- Name: client client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client ALTER COLUMN client_id SET DEFAULT nextval('public.client_client_id_seq'::regclass);


--
-- Name: client_account client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_account ALTER COLUMN client_id SET DEFAULT nextval('public.client_account_client_id_seq'::regclass);


--
-- Name: handle_account order_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handle_account ALTER COLUMN order_number SET DEFAULT nextval('public.handle_account_order_number_seq'::regclass);


--
-- Name: orders order_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_number SET DEFAULT nextval('public.orders_order_number_seq'::regclass);


--
-- Name: tracks order_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks ALTER COLUMN order_number SET DEFAULT nextval('public.tracks_order_number_seq'::regclass);


--
-- Name: tracks client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks ALTER COLUMN client_id SET DEFAULT nextval('public.tracks_client_id_seq'::regclass);


--
-- Name: update_sales order_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.update_sales ALTER COLUMN order_number SET DEFAULT nextval('public.update_sales_order_number_seq'::regclass);


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.address VALUES (100001, 5525, 'Boundary Rd', 'Navan', 'K4B 1P6');
INSERT INTO public.address VALUES (100002, 1125, 'Colonel By Dr', 'Ottawa', 'K1S 5B6');
INSERT INTO public.address VALUES (100003, 680, 'Sherbrooke St W', 'Montreal', 'H3A 0B8');
INSERT INTO public.address VALUES (100004, 77, 'Broadway', 'New Haven', '06511');
INSERT INTO public.address VALUES (100005, 2515, 'Bank St', 'Ottawa', 'K1V 8R9');


--
-- Data for Name: bankaccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.bankaccount VALUES (100001, 5000.00);
INSERT INTO public.bankaccount VALUES (100002, 13000.00);
INSERT INTO public.bankaccount VALUES (100003, 50000.00);
INSERT INTO public.bankaccount VALUES (100004, 44000.00);
INSERT INTO public.bankaccount VALUES (100005, 200.00);
INSERT INTO public.bankaccount VALUES (100006, 10000.00);
INSERT INTO public.bankaccount VALUES (100007, 9000.00);
INSERT INTO public.bankaccount VALUES (100008, 5600.00);
INSERT INTO public.bankaccount VALUES (100009, 23000.00);
INSERT INTO public.bankaccount VALUES (100010, 500.00);


--
-- Data for Name: book; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.book VALUES ('668-54-24160-15-0', 'The Sun Also Rises', 'Jules Verne', 'Crime', 100000001, 104, 12.91, 55.09, 50.00, 33, 18);
INSERT INTO public.book VALUES ('343-68-52881-00-5', 'Game of Thrones', 'Jane Austen', 'Romance', 100000001, 497, 9.20, 61.74, 63.00, 29, 10);
INSERT INTO public.book VALUES ('887-22-81808-10-8', 'The Sound and the Fury', 'Herman Melville', 'Crime', 100000001, 411, 11.62, 74.43, 59.00, 24, 18);
INSERT INTO public.book VALUES ('863-84-01487-68-6', 'Oedipus at Colonus', 'Dr. Seuss', 'Adventure', 100000001, 484, 10.90, 65.87, 18.00, 14, 4);
INSERT INTO public.book VALUES ('716-52-50048-25-4', 'Lord of the Flies', 'J. K. Rowling', 'Adventure', 100000001, 428, 31.11, 43.06, 18.00, 19, 14);
INSERT INTO public.book VALUES ('458-28-70542-13-3', 'The Handmaid''s Tale', 'Paulo Coelo', 'Family', 100000001, 435, 30.43, 70.73, 2.00, 29, 15);
INSERT INTO public.book VALUES ('587-11-10570-06-6', 'Lolita', 'John Steinbeck', 'Thriller', 100000001, 464, 29.07, 49.11, 7.00, 35, 5);
INSERT INTO public.book VALUES ('472-37-48401-50-8', 'Gulliver''s Travels', 'Emily Dickinson', 'History', 100000001, 159, 23.57, 51.56, 36.00, 27, 4);
INSERT INTO public.book VALUES ('567-08-25425-52-7', 'The Flowers of Evil', 'C.S. Lewis', 'Family', 100000001, 121, 23.63, 62.06, 5.00, 41, 19);
INSERT INTO public.book VALUES ('160-54-35031-61-5', 'Invisible Man', 'Leo Tolstoy', 'Drama', 100000001, 323, 10.81, 52.35, 16.00, 28, 8);
INSERT INTO public.book VALUES ('622-07-80488-72-1', 'The Grapes of Wrath', 'Danielle Steel', 'Musical', 100000001, 484, 24.88, 68.04, 47.00, 32, 3);
INSERT INTO public.book VALUES ('880-82-45816-81-1', 'The Metamorphosis', 'Oscar Wilde', 'Sci-Fi', 100000002, 137, 11.23, 69.11, 22.00, 28, 11);
INSERT INTO public.book VALUES ('083-73-73061-08-8', 'The Old Man and the Sea', 'T. S. Eliot', 'Sci-Fi', 100000002, 209, 35.10, 59.12, 57.00, 36, 8);
INSERT INTO public.book VALUES ('345-73-78534-72-0', 'To Kill a Mockingbird', 'Tennessee Williams', 'History', 100000002, 246, 35.48, 40.53, 13.00, 28, 19);
INSERT INTO public.book VALUES ('774-21-03220-38-1', 'One Thousand and One Nights', 'Edith Wharton', 'Horror', 100000002, 156, 20.57, 57.26, 2.00, 19, 10);
INSERT INTO public.book VALUES ('261-23-67185-85-3', 'The Flowers of Evil', 'Cormac McCarthy', 'History', 100000002, 117, 25.00, 43.40, 51.00, 12, 18);
INSERT INTO public.book VALUES ('257-05-06740-84-7', 'The Canterbury Tales', 'Horatio Alger', 'Action', 100000002, 183, 13.97, 60.47, 69.00, 27, 8);
INSERT INTO public.book VALUES ('813-60-20452-86-7', 'Oedipus', 'Edith Wharton', 'Musical', 100000002, 467, 10.09, 53.77, 69.00, 28, 17);
INSERT INTO public.book VALUES ('537-16-53204-03-6', 'Hamlet', 'Stephenie Meyer', 'Biography', 100000002, 484, 22.85, 63.18, 16.00, 38, 10);
INSERT INTO public.book VALUES ('515-37-15864-05-3', 'Tess of the d''Urbervilles', 'Bella Forrest', 'Fantasy', 100000002, 428, 30.60, 53.63, 14.00, 12, 18);
INSERT INTO public.book VALUES ('273-21-86363-55-0', 'Game of Thrones', 'Ray Bradbury', 'Fantasy', 100000002, 450, 9.73, 45.94, 20.00, 46, 3);
INSERT INTO public.book VALUES ('687-45-37386-00-7', 'Les Mis├®rables', 'Stephenie Meyer', 'Thriller', 100000002, 434, 29.89, 77.30, 9.00, 46, 15);
INSERT INTO public.book VALUES ('254-44-08082-51-1', 'Lord of the Flies', 'Alexandre Dumas', 'Family', 100000002, 312, 11.64, 52.03, 24.00, 12, 11);
INSERT INTO public.book VALUES ('282-23-87500-18-8', 'Wuthering Heights', 'Horatio Alger', 'Fantasy', 100000002, 403, 7.15, 58.77, 45.00, 33, 13);
INSERT INTO public.book VALUES ('853-14-56848-24-6', 'David Copperfield', 'Dr. Seuss', 'Fantasy', 100000002, 309, 38.19, 42.05, 57.00, 19, 5);
INSERT INTO public.book VALUES ('164-81-67536-36-4', 'War and Peace', 'Jin Yong', 'Sci-Fi', 100000002, 245, 12.45, 41.05, 32.00, 14, 2);
INSERT INTO public.book VALUES ('318-74-55022-86-0', 'Oedipus', 'Alexandre Dumas', 'Musical', 100000002, 150, 29.13, 41.36, 62.00, 24, 17);
INSERT INTO public.book VALUES ('776-73-21644-58-6', 'The Brothers Karamazov ', 'Oscar Wilde', 'Thriller', 100000002, 146, 14.40, 50.73, 26.00, 21, 13);
INSERT INTO public.book VALUES ('358-32-16470-05-8', 'Oedipus', 'G.R.R. Martin', 'Adventure', 100000002, 138, 11.25, 61.16, 56.00, 8, 4);
INSERT INTO public.book VALUES ('438-14-11430-36-3', 'Gargantua and Pantagruel', 'Cormac McCarthy', 'Biography', 100000002, 422, 6.19, 65.97, 34.00, 43, 9);
INSERT INTO public.book VALUES ('431-50-74546-78-2', 'The Good Soldier', 'William Shakespeare', 'Animation', 100000002, 472, 24.22, 73.29, 69.00, 36, 7);
INSERT INTO public.book VALUES ('686-15-31044-51-8', 'The Good Soldier', 'Mark Twain', 'Animation', 100000002, 321, 33.16, 63.95, 36.00, 9, 6);
INSERT INTO public.book VALUES ('856-32-00467-71-0', 'Wuthering Heights', 'Alexander Pushkin', 'Crime', 100000002, 325, 32.39, 67.99, 66.00, 34, 8);
INSERT INTO public.book VALUES ('152-47-03174-10-6', 'Gargantua and Pantagruel', 'C.S. Lewis', 'Comedy', 100000002, 272, 7.44, 44.71, 12.00, 29, 5);
INSERT INTO public.book VALUES ('700-10-32083-15-6', 'The Metamorphosis', 'G.R.R. Martin', 'Action', 100000002, 299, 28.33, 61.16, 69.00, 22, 16);
INSERT INTO public.book VALUES ('882-84-45000-66-0', 'Anna Karenina', 'Jack London', 'Sci-Fi', 100000002, 209, 12.09, 54.58, 11.00, 40, 16);
INSERT INTO public.book VALUES ('375-07-00762-11-1', 'Nineteen Eighty Four', 'Emily Dickinson', 'History', 100000002, 382, 11.57, 64.91, 66.00, 28, 7);
INSERT INTO public.book VALUES ('582-87-01704-55-8', 'The Handmaid''s Tale', 'Herman Melville', 'Adventure', 100000002, 121, 36.07, 70.98, 61.00, 19, 19);
INSERT INTO public.book VALUES ('665-35-18332-48-6', 'The Great Gatsby', 'Barbara Cartland', 'Animation', 100000002, 119, 19.10, 65.73, 60.00, 25, 3);
INSERT INTO public.book VALUES ('845-07-63652-21-3', 'Gargantua and Pantagruel', 'Agatha Christie', 'Fantasy', 100000003, 322, 12.29, 64.10, 22.00, 19, 19);
INSERT INTO public.book VALUES ('836-56-62724-40-5', 'The Divine Comedy', 'Flannery O''Connor', 'Action', 100000003, 484, 33.35, 56.76, 51.00, 19, 6);
INSERT INTO public.book VALUES ('110-45-70515-04-8', 'Lolita', 'Barbara Cartland', 'Horror', 100000003, 128, 21.90, 70.27, 14.00, 21, 13);
INSERT INTO public.book VALUES ('566-28-82204-45-5', 'David Copperfield', 'Edgar Allan Poe', 'Sci-Fi', 100000003, 318, 36.84, 78.88, 6.00, 32, 5);
INSERT INTO public.book VALUES ('843-27-40873-87-1', 'Oedipus', 'Henry James', 'Biography', 100000003, 240, 31.34, 60.28, 20.00, 19, 8);
INSERT INTO public.book VALUES ('142-33-37504-34-5', 'Gulliver''s Travels', 'Cormac McCarthy', 'Action', 100000003, 288, 23.82, 45.78, 30.00, 17, 16);
INSERT INTO public.book VALUES ('255-16-08518-03-2', 'War and Peace', 'Harper Lee', 'Sci-Fi', 100000003, 364, 17.73, 67.35, 13.00, 37, 9);
INSERT INTO public.book VALUES ('270-64-15613-17-6', 'Paradise Lost', 'Guillaume Musso', 'Adventure', 100000003, 302, 31.34, 63.83, 7.00, 18, 17);
INSERT INTO public.book VALUES ('834-36-54072-78-0', 'Anna Karenina', 'Margaret Atwood', 'Fantasy', 100000003, 243, 17.13, 73.49, 55.00, 36, 2);
INSERT INTO public.book VALUES ('461-57-15241-70-6', 'Anna Karenina', 'Jack London', 'Animation', 100000003, 478, 9.93, 59.84, 61.00, 49, 7);
INSERT INTO public.book VALUES ('532-48-33164-88-3', 'Tess of the d''Urbervilles', 'Herman Melville', 'Drama', 100000003, 353, 25.46, 72.39, 8.00, 14, 5);


--
-- Data for Name: checkout; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.client VALUES (1, 'Christopher Shen', 'christophershen@cmail.carleton.ca', 737111, 100005);


--
-- Data for Name: client_account; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: emails; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: handle_account; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: manage; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: publisher; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.publisher VALUES (100000001, 'Good Books Publishing', 'goodbookspublishing@gmail.com', 1, 100002);
INSERT INTO public.publisher VALUES (100000002, 'Joe and Smiths', 'joe_smiths@gmail.com', 2, 100003);
INSERT INTO public.publisher VALUES (100000003, 'New Haven Publishing', 'newhavenpublishing@gmail.com', 3, 100004);


--
-- Data for Name: publisher_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.publisher_account VALUES (100000001, 100002);
INSERT INTO public.publisher_account VALUES (100000002, 100003);
INSERT INTO public.publisher_account VALUES (100000003, 100004);


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.region VALUES ('K4B 1P6', 'Ontario', 'Canada');
INSERT INTO public.region VALUES ('K1S 5B6', 'Ontario', 'Canada');
INSERT INTO public.region VALUES ('H3A 0B8', 'Quebec', 'Canada');
INSERT INTO public.region VALUES ('06511', 'Connecticut', 'United States');
INSERT INTO public.region VALUES ('K1V 8R9', 'Ontario', 'Canada');


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.staff VALUES (10001, 'bookstore@gmail.com');
INSERT INTO public.staff VALUES (10002, 'bookstore@gmail.com');


--
-- Data for Name: tracks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: update_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.warehouse VALUES (1, 100001);
INSERT INTO public.warehouse VALUES (2, 100001);


--
-- Name: checkout_order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checkout_order_number_seq', 1, false);


--
-- Name: client_account_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.client_account_client_id_seq', 1, false);


--
-- Name: client_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.client_client_id_seq', 1, true);


--
-- Name: handle_account_order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.handle_account_order_number_seq', 1, false);


--
-- Name: orders_order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_number_seq', 1, false);


--
-- Name: tracks_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tracks_client_id_seq', 1, false);


--
-- Name: tracks_order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tracks_order_number_seq', 1, false);


--
-- Name: update_sales_order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.update_sales_order_number_seq', 1, false);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: bankaccount bankaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bankaccount
    ADD CONSTRAINT bankaccount_pkey PRIMARY KEY (account_number);


--
-- Name: book book_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book
    ADD CONSTRAINT book_pkey PRIMARY KEY (isbn);


--
-- Name: checkout checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_pkey PRIMARY KEY (isbn, order_number);


--
-- Name: client_account client_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_account
    ADD CONSTRAINT client_account_pkey PRIMARY KEY (client_id, account_number);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (staff_id, publisher_id);


--
-- Name: handle_account handle_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handle_account
    ADD CONSTRAINT handle_account_pkey PRIMARY KEY (order_number, account_number);


--
-- Name: manage manage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manage
    ADD CONSTRAINT manage_pkey PRIMARY KEY (isbn, staff_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_number);


--
-- Name: publisher_account publisher_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_account
    ADD CONSTRAINT publisher_account_pkey PRIMARY KEY (publisher_id);


--
-- Name: publisher publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (postal_code);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (isbn, month, year);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: tracks tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (order_number);


--
-- Name: update_sales update_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.update_sales
    ADD CONSTRAINT update_sales_pkey PRIMARY KEY (order_number, isbn, month, year);


--
-- Name: warehouse warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (warehouse_id);


--
-- Name: book order_books; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER order_books AFTER UPDATE ON public.book FOR EACH ROW EXECUTE FUNCTION public.order_books();


--
-- Name: address address_postal_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_postal_code_fkey FOREIGN KEY (postal_code) REFERENCES public.region(postal_code) ON DELETE CASCADE;


--
-- Name: book book_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book
    ADD CONSTRAINT book_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publisher(publisher_id) ON DELETE CASCADE;


--
-- Name: checkout checkout_isbn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_isbn_fkey FOREIGN KEY (isbn) REFERENCES public.book(isbn) ON DELETE CASCADE;


--
-- Name: checkout checkout_order_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkout
    ADD CONSTRAINT checkout_order_number_fkey FOREIGN KEY (order_number) REFERENCES public.orders(order_number) ON DELETE CASCADE;


--
-- Name: client_account client_account_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_account
    ADD CONSTRAINT client_account_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.bankaccount(account_number) ON DELETE CASCADE;


--
-- Name: client_account client_account_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_account
    ADD CONSTRAINT client_account_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id) ON DELETE CASCADE;


--
-- Name: client client_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE SET NULL;


--
-- Name: emails emails_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publisher(publisher_id) ON DELETE CASCADE;


--
-- Name: emails emails_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id) ON DELETE CASCADE;


--
-- Name: handle_account handle_account_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handle_account
    ADD CONSTRAINT handle_account_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.bankaccount(account_number) ON DELETE CASCADE;


--
-- Name: handle_account handle_account_order_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.handle_account
    ADD CONSTRAINT handle_account_order_number_fkey FOREIGN KEY (order_number) REFERENCES public.orders(order_number) ON DELETE CASCADE;


--
-- Name: manage manage_isbn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manage
    ADD CONSTRAINT manage_isbn_fkey FOREIGN KEY (isbn) REFERENCES public.book(isbn) ON DELETE CASCADE;


--
-- Name: manage manage_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manage
    ADD CONSTRAINT manage_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id) ON DELETE CASCADE;


--
-- Name: orders orders_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE CASCADE;


--
-- Name: orders orders_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(warehouse_id) ON DELETE CASCADE;


--
-- Name: publisher_account publisher_account_account_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_account
    ADD CONSTRAINT publisher_account_account_number_fkey FOREIGN KEY (account_number) REFERENCES public.bankaccount(account_number) ON DELETE CASCADE;


--
-- Name: publisher_account publisher_account_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher_account
    ADD CONSTRAINT publisher_account_publisher_id_fkey FOREIGN KEY (publisher_id) REFERENCES public.publisher(publisher_id) ON DELETE CASCADE;


--
-- Name: publisher publisher_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE SET NULL;


--
-- Name: sales sales_isbn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_isbn_fkey FOREIGN KEY (isbn) REFERENCES public.book(isbn) ON DELETE CASCADE;


--
-- Name: tracks tracks_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id) ON DELETE CASCADE;


--
-- Name: tracks tracks_order_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_order_number_fkey FOREIGN KEY (order_number) REFERENCES public.orders(order_number) ON DELETE CASCADE;


--
-- Name: update_sales update_sales_isbn_month_year_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.update_sales
    ADD CONSTRAINT update_sales_isbn_month_year_fkey FOREIGN KEY (isbn, month, year) REFERENCES public.sales(isbn, month, year) ON DELETE CASCADE;


--
-- Name: update_sales update_sales_order_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.update_sales
    ADD CONSTRAINT update_sales_order_number_fkey FOREIGN KEY (order_number) REFERENCES public.orders(order_number) ON DELETE CASCADE;


--
-- Name: warehouse warehouse_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

