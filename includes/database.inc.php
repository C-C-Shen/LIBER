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
    $pdo = setConnectionInfo();

    $warehouse_id = getWarehouseID();

    $sql = "SELECT place_order(".$client_id.", ".$address_id.", ".$warehouse_id.") AS order_number";

    $res = runQuery($pdo, $sql);
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
   * @param cost the new cost to the bookstore.
   * @param price the new price to the client.
   * @param publisher_percent the new publisher percentage to assign.
   * @param stock the new number of books in stock.
   * @param threshold the new book threshold value.
   */
  function manage_existing_book($isbn, $cost, $price, $publisher_percent, $stock, $threshold) {
	  $pdo = setConnectionInfo();
	  
	  if (!($t_book = getBookByISBN($isbn))) {
		  return "Could Not Find" . $isbn;
	  }
	  
	  // If none of the attributes are different, then an update is not needed.
	  if ($t_book->cost == $cost && $t_book->price == $price && $t_book->publisher_percent == $publisher_percent
		  && $t_book->stock == $stock && $t_book->threshold == $threshold) {
		$pdo = null;
		
		return "No Changes To Save";
	  }
	  
	  // Check if the changes are valid values.
	  if ($cost >= 0 && $cost <= 99 && $price >= 0 && $price <= 99 && $publisher_percent >= 0 && $publisher_percent <= 99 && $stock >= 0 && $threshold >= 0) {
		  $sql = "UPDATE Book SET cost = ?, price = ?, publisher_percent = ?, stock = ?, threshold = ? WHERE isbn = ?";
		  
		  $result = runQuery($pdo, $sql, Array($cost, $price, $publisher_percent, $stock, $threshold, $isbn));
		  $pdo = null;
		  
		  echo '<script> location.reload(); </script>';
		  return "Changes Saved";
	  }
	  
	  $pdo = null;
	  return "Invalid Changes";	  
  }
  
  /**
   * Insert/create a new book tuple in the Book table
   * @param isbn the target book.
   * @param title the title of new book.
   * @param author_name the author of the new book.
   * @param genre the publisher percent cut of the new book.
   * @param publisher the publisher of the new book.
   * @param num_pages the number of pages in the new book.
   * @param cost the cost of the book to the bookstore.
   * @param price the new price of the book to the client.
   * @param publisher_percent the publisher percentage cut for the book.
   * @param stock the number of books in stock.
   * @param threshold the restock threshold.
   */
  function add_new_book($isbn, $title, $author_name, $genre, $publisher, $num_pages, $cost, $price, $publisher_percent, $stock, $threshold) {
	  $sql = "SELECT * FROM Publisher WHERE publisher_id = ?";
	  $pdo = setConnectionInfo();
	  
	  // Check if he publisher exists
	  $result = runQuery($pdo, $sql, Array($publisher));
	  
	  // Checkl that the ISBN does not already exist, then check if the publisher is valid
	  if (getBookByISBN($isbn)) {
		  return $isbn . " Already Exists, Add Cancelled";
	  } else if (!($row = $result->fetch())) {
		  return $publisher . " Publisher Could Not Be Found, Add Cancelled";
	  }
	  
	  // Check if the values of the book to add are valid.
	  if ($title != "" && $author_name != "" && $genre != "" && $num_pages > 0 && $cost >= 0 && $cost <= 99 && $price >= 0 && $price <= 99 && $publisher_percent >= 0 && $publisher_percent <= 99
		  && $stock >= 0 && $threshold >= 0) {
		  $sql = "INSERT INTO Book VALUEs(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		  
		  $result = runQuery($pdo, $sql, Array($isbn, $title, $author_name, $genre, $publisher, $num_pages, $cost, $price, $publisher_percent, $stock, $threshold));
		  $pdo = null;
		  
		  echo '<script> location.reload(); </script>';
		  return "Book Added";
	  }
	  
	  $pdo = null;
	  return "Invalid Book Parameters";	 
  }
  
  /**
   * Deletes a book tuple from Book table
   * @param isbn the target book to delete.
   */
  function delete_book($isbn) {
	  $sql = "DELETE FROM Book WHERE isbn = ?";
	  $pdo = setConnectionInfo();
	  
    $result = runQuery($pdo, $sql, Array($isbn));
	  $pdo = null; 
  }

  /**
   * Returns a random warehouse_id from the list of warehouses.
   */
  function getWarehouseID(){
    $sql = "SELECT warehouse_id FROM Warehouse";
	$pdo = setConnectionInfo();

    $result = runQuery($pdo, $sql);
	  $pdo = null; 

    $warehouses = Array();
    $rows = $result->fetchAll();
    foreach($rows as $row){
        $warehouses[] = $row['warehouse_id'];
    }

    $warehouse_index = rand(0, sizeof($warehouses) - 1);

    return $warehouses[$warehouse_index];
  }
  
  /**
   * Returns all sales reports that match a search parameters, along with revenue and expense values
   * @param isbn the target book.
   * @param author_name the target author..
   * @param genre the target genre.
   * @param publisher the target publisher.
   * @param from_date lower bound of date search.
   * @param to_date upper bound of date serach.
   */
  function getSalesFig($isbn, $author_name, $genre, $publisher, $from_date, $to_date) {
	  $pdo = setConnectionInfo();
	  
	  $currYM = date('Y-m');
	  $currY = date('Y');
	  
	  $viewToUse = 'allSales';
	  
	  // If one of the date values is blank (but not the other), treat is as a single month range
	  if ($from_date == "" && $to_date != "") {
		  $from_date = $to_date;
	  } else if ($from_date != "" && $to_date == "") {
		  $to_date = $from_date;
	  }
	  
	  $fromY = 'true';
	  $fromM = 'true';
	  $toM = 'true';
	  $toY = 'true'; 
	  
	  if ($from_date != "" && $to_date != "") {
		  // position [0] is the year, position [1] is the month
		  $fromArr = explode('-', $from_date);
		  $fromY = (int)$fromArr[0];
		  $fromM = date("F", mktime(0, 0, 0, (int)$fromArr[1], 10));  // convert to string
		  $toArr =  explode('-', $to_date);
		  $toY = (int)$toArr[0];
		  $toM = date("F", mktime(0, 0, 0, (int)$toArr[1], 10));  // convert to string
	  }
	  
	  // Check if the date range given is the current month
	  if (strcmp($currYM, $from_date) == 0 && strcmp($currYM, $to_date) == 0) {
		  $viewToUse = 'allCurrMonthSales';
	  } else if (strcmp($currY . '-01', $from_date) == 0 && strcmp($currY . '-12', $to_date) == 0) {
		  $viewToUse = 'allCurrYearSales';
	  }
	  $sql = "select * from ". $viewToUse ." NATURAL JOIN Book WHERE";
	  $filters = "";
	  
	  // Check if a specific ISBN is specified
	  if ($isbn != "") {
		  $filters = $filters." isbn = ?";
		  $sql = $sql." isbn = ?"; 
	  } else {
		  $isbn = 'true';
		  $sql = $sql." ?"; 
	  }
	  $sql = $sql." AND"; 
	  
	  // If using the single month view (on current month) or if no date range is specified, we do not need to include the complex WHERE condition
	  if ($from_date != "" && $to_date != "" && strcmp($viewToUse, 'allCurrMonthSales') != 0) {
		  $filters = $filters." from_date = ?, to_date = ?";
		  // where TRUE and ((to_date(month, 'Month') >= to_date('April', 'Month') AND year >= 2020) OR (year > 2020)) AND ((to_date(month, 'Month') <= to_date('November', 'Month') AND year <= 2021) OR (year < 2021))
		  $sql = $sql." ((to_date(month, 'Month') >= to_date(?, 'Month') AND year >= ?) OR (year > ?)) AND ((to_date(month, 'Month') <= to_date(?, 'Month') AND year <= ?) OR (year < ?)) AND"; 
	  } else {
		  $from_date = 'true';
		  $to_date = 'true';
		  $sql = $sql." ? AND ? AND ? AND ? AND ? AND ? AND"; 
	  }	  
	  
	  if ($author_name == "" || $author_name == "null"){
		  $author_name = 'true';
		  $sql = $sql." ? AND";
	  } else {
		  $filters = $filters." author_name = '".$author_name."'";
		  $author_name = '%'.strtoupper($author_name).'%';
		  $sql = $sql." upper(Book.author_name) LIKE ? AND";
	  }

	  if ($genre == "" || $genre == "null"){
		  $genre = 'true';
		  $sql = $sql." ? AND";
	  } else {
		  $filters = $filters." genre = '".$genre."'";
		  $sql = $sql." Book.genre = ? AND";
	  }
		
	  if ($publisher == "" || $publisher == "null"){
		  $publisher = 'true';
		  $sql = $sql." ?";
	  } else {
		  $filters = $filters." title = '".$publisher."'";
		  $sql = $sql." Book.publisher_id = ?";
	  }

	  $result = runQuery($pdo, $sql, Array($isbn, $fromM, $fromY, $fromY, $toM, $toY, $toY, $author_name, $genre, $publisher));

      $rows = $result->fetchAll();	  
	  $salesArr = Array();
	  foreach($rows as $row){
		  $salesArr[] = new Sales($row);
	  }
	  foreach($salesArr as $singleSale) {
		  $tempBook = getBookByISBN($singleSale->isbn);
		  $total = $tempBook->price * $singleSale->quantity;
		  $singleSale->revenue = $total - ($total * $tempBook->publisher_percent * 0.01);
		  $singleSale->expense = $tempBook->cost * $singleSale->quantity;
		  
		  print $singleSale->isbn . " [Date] " . $singleSale->month . " " . $singleSale->year . " Quantity of: " .
		  $singleSale->quantity . " Total Revenue of: " . $singleSale->revenue . " Total Expense of: " . $singleSale->expense;
		  echo '<br>';
	  }
	  
	  $pdo = null;
	  return $salesArr;
  }
?>
