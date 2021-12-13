<?php
   /**
    * The class Painting holds all the information about a single painting.
    */
    class Book {
        public $isbn;
        public $title;
        public $author_name;
        public $genre;
        public $publisher;
        public $num_pages;
        public $cost;
        public $price;
        public $publisher_percent;
        public $stock;
        public $threshold;

        function __construct($record){
            $this->isbn = $record['isbn'];
            $this->title = $record['title'];
            $this->author_name = $record['author_name'];
            $this->genre = $record['genre'];
            $this->publisher = $record['name'];
            $this->num_pages = $record['number_of_pages'];
            $this->cost = $record['cost'];
            $this->price = $record['price'];
            $this->publisher_percent = $record['publisher_percent'];
            $this->stock = $record['stock'];
            $this->threshold = $record['threshold'];
        }
    }

    /**
     * The class Genre to keep track of the genre names.
     */
    class Genre{
        public $genreName;

        function __construct($record){
            $this->genreName = $record['genre'];
        }
    }

    /**
     * The class Client keeps track of the client information.
     */
    class Client{
        public $id;
        public $client_name;
        public $email;
        public $phone;
        public $address_id;

        function __construct($record){
            $this->id = $record['client_id'];
            $this->client_name = $record['name'];
            $this->email = $record['email'];
            $this->phone = $record['phone_number'];
            $this->address_id = $record['address_id'];
        }
    }

    /**
     * The class Manager keeps track of the manager information.
     */
    class Staff{
        public $id;
        public $email;

        function __construct($record){
            $this->id = $record['staff_id'];
            $this->email = $record['email'];
        }
    }
?>