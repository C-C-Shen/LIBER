<?php
// Collection of functions to deal with the SQL database
/**
 * Sets a connection with the database.
 * @param values: the connection parameters.
 * @return pdo object.
 */
function setConnectionInfo($values=array()) {
      // your code goes here
      try {
        if (count($values) == 3){
            $pdo = new PDO($values[0], $values[1], $values[2]);
        } else {
            $pdo = new PDO(DBCONNECTION, DBUSER, DBPASS);
        }

        return $pdo;

      }  catch (PDOException $e){
        die ($e->getMessage());
      }
}

/**
 * Runs a query with optional parameters.
 * @param pdo the pdo object of the database.
 * @param sql the sql query to run.
 * @param parameters: the optional parameters for the param.
 * @return result the result of the query.
 */
function runQuery($pdo, $sql, $parameters=array())     {
    // your code goes here
    try {
        $statement = $pdo->prepare($sql);
        $i = 1;

        foreach ($parameters as $param){
            $statement->bindValue($i, $param);
            $i++;
        }


        $statement->execute();
  
        return $statement;
    }  catch (PDOException $e){
        die ($e->getMessage());
    }
}

/**
 * Gets all the books based on their isbn, title, author, and genre
 * @param isbn the isbn of the book
 * @param title the title of the book
 * @param author the author of the book
 * @return genre the genre of the book
 */
function fetchBooks($isbn = "", $title = "", $author = "", $genre = ""){
    $sql = "SELECT * FROM Book NATURAL JOIN Publisher WHERE";

    $filters = "";

    if ($isbn == "" || $isbn == "null"){
      $isbn = 'true';
      $sql = $sql." ? AND";
    } else {
      $filters = $filters." ISBN = '".$isbn."'";
      $sql = $sql." ISBN = ? AND";
    }

    if ($title == "" || $title == "null"){
      $title = 'true';
      $sql = $sql." ? AND";
    } else {
      $filters = $filters." title = '".$title."'";
      $title = '%'.strtoupper($title).'%';
      $sql = $sql." upper(title) LIKE ? AND";
    }

    if ($author == "" || $author == "null"){
      $author = 'true';
      $sql = $sql." ? AND";
    } else {
      $filters = $filters." author = '".$author."'";
      $author = '%'.strtoupper($author).'%';
      $sql = $sql." upper(author_name) LIKE ? AND";
    }

    if ($genre == "" || $genre == "null"){
      $genre = 'true';
      $sql = $sql." ?";
    } else {
      $filters = $filters." genre = '".$genre."'";
      $sql = $sql." genre = ?";
    }

    if ($filters == ""){
      echo '<h4> ALL PAINTINGS [TOP 20] </h4>';
    } else {
      echo '<h4> PAINTINGS FILTERED BY'.$filters.'<br/> [TOP 20] </h4>';
    }

    $sql = $sql." ORDER BY cost LIMIT 20;";
    $pdo = setConnectionInfo();

    $result = runQuery($pdo, $sql, Array($isbn, $title, $author, $genre));
    $pdo = null;

    $rows = $result->fetchAll();
    $books = Array();
    foreach($rows as $row){
        $books[] = new Book($row);
    }

    return $books;
  }  

  /**
   * Gets the book based on the ISBN.
   * @param isbn the isbn of the book
   */
  function getBookByISBN($isbn = ""){
    $sql = "SELECT * FROM Book  NATURAL JOIN Publisher WHERE ISBN = ?";
    $pdo = setConnectionInfo();

    $result = runQuery($pdo, $sql, Array($isbn));
    $pdo = null;

    return new Book($result->fetch());
  } 

  /**
   * Gets the genres of the books
   */
  function getGenres(){
    $sql = "SELECT genre FROM Book GROUP BY (genre)";

    $pdo = setConnectionInfo();
    $result = runQuery($pdo, $sql);
    $pdo = null;

    $rows = $result->fetchAll();
    $genres = Array();
    foreach($rows as $row){
        $genres[] = new Genre($row);
    }

    return $genres;
  }
?>
