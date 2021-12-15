<?php
  require_once('includes/header.inc.php');
  
  if (!isset($_SESSION['User']) && !($_SESSION['UserType'] == "staff")){
	header("Location: login.php");
  } 
?>

<main class="ui segment doubling stackable grid container">
	<section class="five wide column">
        <form class="ui form" method="GET">
          <h4 class="ui dividing header">Book To Manage</h4>

          <div class="field">
            <label>ISBN Of Book To Manage/Add</label>
            <div class="ui mini icon input">
                <input name="isbn" type="text" placeholder="isbn...">
                <i class="search icon"></i>
            </div>
          </div>  

          <button class="small ui orange button" type="submit">
            <i class="filter icon"></i> Continue 
          </button>    

        </form>
    </section>
	
	
	<section class="eleven wide column">
        <h1 class="ui header">Book Information Panel</h1>
        <ul class="ui divided items" id="booksList">

        
        <?php
		  $isbn = "";
		  
          if ($_SERVER["REQUEST_METHOD"] == "GET"){
            if (isset($_GET["isbn"]) && $_GET["isbn"] != ""){
              $isbn = $_GET["isbn"];
			  
			  // $books = getBookByISBN($isbn) or die("Failed to connect to the database");
			  $books = getBookByISBN($isbn);
			  
			  // value is "" for adding, is "disabled" for existing books
			  $addMode = "disabled";
			  $panelTitle = "Manage Book With ISBN " . $isbn;
			  $buttonName = "Save Changes";
			  
			  // $isbn = "";
			  $title = "?";
			  $author_name = "?";
			  $genre = "?";
			  $publisher = 0;
			  $num_pages = 0;
			  $cost = 0.00;
			  $price = 0.00;
			  $publisher_percent = 0.00;
			  $stock = 0;
			  $threshold = 0;
			  
			  if (is_null($books)) {
				  $addMode = "";
				  $panelTitle = "Add New Book To Store";
				  $buttonName = "Add Book";
			  } else {
				  $isbn = $books->isbn;
				  $title = $books->title;
				  $author_name = $books->author_name;
				  $genre = $books->genre;
				  $publisher = $books->publisher;
				  $num_pages = $books->num_pages;
				  $cost = $books->cost;
				  $price = $books->price;
				  $publisher_percent = $books->publisher_percent;
				  $stock = $books->stock;
				  $threshold = $books->threshold;
			  }
			  
			  echo '
				<form class="ui form" method="GET">
					<h4 class="ui dividing header">'.$panelTitle.'</h4>
					<div class="field">
						<label>ISBN</label>
						<div class="ui mini icon input">
							<input name="isbn" type="text" value='.$isbn.' readonly>
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Title</label>
						<div class="ui mini icon input">
							<input name="title" type="text" value="'.$title.'" '.$addMode.'>
							<i class="search icon"></i>
						</div>
					</div> 
					<div class="field">
						<label>Author</label>
						<div class="ui mini icon input">
							<input name="author_name" type="text" value="'.$author_name.'" '.$addMode.'>
							<i class="search icon"></i>
						</div>
					</div>  
					<div class="field">
						<label>Genre</label>
						<div class="ui mini icon input">
							<input name="genre" type="text" value="'.$genre.'" '.$addMode.'>
							<i class="search icon"></i>
						</div>
					</div> 		
					<div class="field">
						<label>Publisher</label>
						<div class="ui mini icon input">
							<input name="publisher" type="text" value="'.$publisher.'" '.$addMode.'>
							<i class="search icon"></i>
						</div>
					</div> 		
					<div class="field">
						<label>Number of Pages</label>
						<div class="ui mini icon input">
							<input name="num_pages" type="text" value="'.$num_pages.'" '.$addMode.'>
							<i class="search icon"></i>
						</div>
					</div> 	
					<div class="field">
						<label>Cost</label>
						<div class="ui mini icon input">
							<input name="cost" type="text" value="'.$cost.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Price</label>
						<div class="ui mini icon input">
							<input name="price" type="text" value="'.$price.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Publisher % Cut</label>
						<div class="ui mini icon input">
							<input name="publisher_percent" type="text" value="'.$publisher_percent.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Stock</label>
						<div class="ui mini icon input">
							<input name="stock" type="text" value="'.$stock.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Threshold</label>
						<div class="ui mini icon input">
							<input name="threshold" type="text" value="'.$threshold.'">
							<i class="search icon"></i>
						</div>
					</div>

					<button class="small ui orange button" type="submit">
					<i class="filter icon"></i> '.$buttonName.' 
					</button>					
				</form>';
				
				if ($addMode == "disabled") {
					echo '
						<form class="ui form" method="POST">
							<div class="field">
								<input name="to_delete" type="hidden" value="'.$isbn.'">
							</div>

							<button class="small ui orange button" type="submit">
							<i class="filter icon"></i> Remove Book 
							</button>					
						</form>';
				}
            } 
          }

		  if ($_SERVER["REQUEST_METHOD"] == "GET") {
			if (isset($_GET["isbn"]) && isset($_GET["cost"]) && isset($_GET["price"]) && isset($_GET["publisher_percent"]) && isset($_GET["stock"]) && isset($_GET["threshold"])){				
				$isbn = $_GET["isbn"];
				$cost = $_GET["cost"];
				$price = $_GET["price"];
				$publisher_percent = $_GET["publisher_percent"];
				$stock = $_GET["stock"];
				$threshold = $_GET["threshold"];
				
				
				if (isset($_GET["title"]) && isset($_GET["author_name"]) && isset($_GET["genre"]) && isset($_GET["publisher"]) && isset($_GET["num_pages"])) {
					$title = $_GET["title"];
					$author_name = $_GET["author_name"];
					$genre = $_GET["genre"];
					$publisher = $_GET["publisher"];
					$num_pages = $_GET["num_pages"];
					$ret = add_new_book($isbn, $title, $author_name, $genre, $publisher, $num_pages, $cost, $price, $publisher_percent, $stock, $threshold);
				} else {
					$ret = manage_existing_book($isbn, $cost, $price, $publisher_percent, $stock, $threshold);
				}
			}
		  }
		  if ($_SERVER["REQUEST_METHOD"] == "POST") {
			  if (isset($_POST["to_delete"])) {
				    $isbn = $_POST["to_delete"];
					delete_book($isbn);
					print $isbn . " Removed";
			  }
		  }
        ?>
        </ul>        
    </section>
</main>    
    
  <footer class="ui black inverted segment">
      <div class="ui container">footer for later</div>
  </footer>
</body>
</html>
