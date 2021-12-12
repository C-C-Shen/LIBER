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
?>