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
      echo '<h4> ALL BOOKS [TOP 20] </h4>';
    } else {
      echo '<h4> BOOKS FILTERED BY'.$filters.'<br/> [TOP 20] </h4>';
    }

    $sql = $sql." AND stock > 0 ORDER BY cost LIMIT 20;";
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
	
	// Check if got some result from query
	if ($row = $result->fetch()) {
		return new Book($row);
	}
    return null;
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

  /**
   * Verifies the client based on id and email.
   * @param id id of the client.
   * @param email email of the client.
   * @return client the Client object.
   */
  function verifyClient($id, $email){
    $sql = "SELECT * FROM Client WHERE client_id = ? AND email = ?";

    $pdo = setConnectionInfo();
    $result = runQuery($pdo, $sql, Array($id, $email));
    $pdo = null;

    if ($row = $result->fetch()){
      return new Client($row);
    } else {
      return null;
    }
  }

  /**
   * Verifies the staff based on id and email.
   * @param id id of the staff.
   * @param email email of the staff.
   * @return staff the Staff object.
   */
  function verifyStaff($id, $email){
    $sql = "SELECT * FROM Staff WHERE staff_id = ? AND email = ?";

    $pdo = setConnectionInfo();
    $result = runQuery($pdo, $sql, Array($id, $email));
    $pdo = null;

    if ($row = $result->fetch()){
      return new Staff($row);
    } else {
      return null;
    }
  }

  /**
   * Registers a new client into the system.
   * @param name the name of the client.
   * @param email email address of the client.
   * @param phone phone number of the client.
   * @param account account number of the client.
   * @param building_num street address of the client address.
   * @param street street name of the client address.
   * @param city city name of the client address.
   * @param state state name of the client address.
   * @param country country name of the client address.
   * @param postal postal code.
   * @return client the new client.
   */
  function registerClient($name, $email, $phone, $account, $building_num, $street, $city, $state, $country, $postal){
    $address_id = createAddress($building_num, $street, $city, $state, $country, $postal);

    $pdo = setConnectionInfo();

    $sql = "INSERT INTO Client(name, email, phone_number, address_id) VALUES(?, ?, ?, ?)";
    runQuery($pdo, $sql, Array($name, $email, $phone, $address_id));

    $sql = "SELECT currval(pg_get_serial_sequence('Client', 'client_id'))  AS client_id";
    $res = runQuery($pdo, $sql);

    $client_id = $res->fetch(PDO::FETCH_ASSOC)['client_id'];

    $sql = "INSERT INTO client_account VALUES(?, ?)";
    runQuery($pdo, $sql, Array($client_id, $account));

    $pdo = null;

    return verifyClient($client_id, $email);
  }

  /**
   * This function is in charge of getting the current order status.
   * @param client_id the id of the client.
   * @param order_id the order number.
   */
  function getOrderStatus($client_id, $order_id){
    $sql = "SELECT status FROM tracks NATURAL JOIN Orders WHERE client_id = ? AND order_number = ?";

    $pdo = setConnectionInfo();
    $res = runQuery($pdo, $sql, Array($client_id, $order_id));
    $pdo = null;

    $status = $res->fetch(PDO::FETCH_ASSOC);

    if (isset($status['status'])){
      return $status['status'];
    } else {
      return null;
    }
  }

  /**
   * Checks to see if the user can afford the order.
   * @param account the account number of the client.
   * @param total the cart total.
   * @return true if the client can afford the total.
   */
  function canAffordOrder($account,$total){
    $sql = "SELECT amount FROM BankAccount WHERE account_number = ?";

    $pdo = setConnectionInfo();
    $res = runQuery($pdo, $sql, Array($account));
    $pdo = null;

    $amount = $res->fetch(PDO::FETCH_ASSOC)['amount'];

    if ($amount >= $total){
      return true;
    } else {
      return false;
    }
  }

  /**
   * Creates an address element from the given parameters. 
   * @param building_num street address of the client address.
   * @param street street name of the client address.
   * @param city city name of the client address.
   * @param state state name of the client address.
   * @param country country name of the client address.
   * @param postal postal code.
   * @return address_id the address_id of the new address.
   */
  function createAddress($building_num, $street, $city, $state, $country, $postal){
    $pdo = setConnectionInfo();

    $address_id = (int)crc32($postal);

    $sql = "SELECT count(address_id) AS num_address FROM Address WHERE address_id = ?";
    $res = runQuery($pdo, $sql, Array($address_id));

    if ($res->fetch(PDO::FETCH_ASSOC)['num_address'] == 0){
      $sql = "INSERT INTO Region VALUES(?, ?, ?)";
      runQuery($pdo, $sql, Array($postal, $state, $country));


      $sql = "INSERT INTO Address VALUES(?, ?, ?, ?, ?)";
      runQuery($pdo, $sql, Array($address_id, $building_num, $street, $city, $postal));
    }

    $pdo = null;
    
    return $address_id;
  }

  /**
   * Places an order for the client and the address.
   * @param client_id the id of the client.
   * @param address_id the address_id of the order.
   * @return order_number the order_number of the new order.
   */
  function place_order($client_id, $address_id){
    $sql = "SELECT place_order(?, ?, 1) AS order_number";

    $pdo = setConnectionInfo();
    $res = runQuery($pdo, $sql, Array($client_id, $address_id));
    $pdo = null;

    return $res->fetch(PDO::FETCH_ASSOC)['order_number'];
  }

  /**
   * Handles checking out a single book item.
   * @param isbn the isbn of the book.
   * @param account the account number of the client.
   * @param order_number the current order_number.
   * @param quantity the number of books to checkout.
   */
  function checkout($isbn, $account, $order_number, $quantity){
    $sql = "SELECT checkout_book(?, ?, ?, ?)";

    $pdo = setConnectionInfo();
    $res = runQuery($pdo, $sql, Array($isbn, $account, $order_number, $quantity));
    $pdo = null;
  }

  /**
   * Adds the client bankaccount to the client_account table.
   * @param client_id the id of the client.
   * @param account the account number of tghe client.
   */
  function updateClientAccount($client_id, $account){
    $pdo = setConnectionInfo();

    $sql = "SELECT count(client_id) AS num_client FROM client_account WHERE client_id = ? AND account_number = ?";
    $res = runQuery($pdo, $sql, Array($client_id, $account));

    if ($res->fetch(PDO::FETCH_ASSOC)['num_client'] == 0){
      $sql = "INSERT INTO client_account VALUES(?, ?)";
      runQuery($pdo, $sql, Array($client_id, $account));
    }

    $pdo = null;
  }


  /**
   * Changes the status of the orders.
   */
  function updateOrders(){
    $pdo = setConnectionInfo();

    $sql = "CALL update_orders()";
    $res = runQuery($pdo, $sql);

    $pdo = null;
  }
  
  /**
   * Changes an existing book's attributes in the Book table.
   * @param isbn the target book.
   * @param cost the new cost to assign.
   * @param price the new price to assign.
   * @param publisher_percent the new publisher percentage to assign.
   * @param stock the new number of books in stock.
   * @param threshold the new book threshold value.
   */
  function manage_existing_book($isbn, $cost, $price, $publisher_percent, $stock, $threshold) {
	  $sql = "SELECT * FROM Book  NATURAL JOIN Publisher WHERE ISBN = ?";
	  $pdo = setConnectionInfo();

      $result = runQuery($pdo, $sql, Array($isbn));
	  
	  $t_book = new Book($result->fetch());
	  
	  // If none of the attributes are different, then an update is not needed.
	  if ($t_book->cost == $cost && $t_book->price == $price && $t_book->publisher_percent == $publisher_percent
		  && $t_book->stock == $stock && $t_book->threshold == $threshold) {
		$pdo = null;
		
		return "No Changes To Save";
	  }
	  
	  // Check if the changes are valid values.
	  if ($cost >= 0 && $price >= 0 && $publisher_percent >= 0 && $stock >= 0 && $threshold >= 0) {
		  $sql = "UPDATE Book SET cost = ?, price = ?, publisher_percent = ?, stock = ?, threshold = ? WHERE isbn = ?";
		  
		  $result = runQuery($pdo, $sql, Array($cost, $price, $publisher_percent, $stock, $threshold, $isbn));
		  $pdo = null;
		  
		  return "Changes Saved";
	  }
	  
	  $pdo = null;
	  return "Invalid Changes";	  
  }
?>
