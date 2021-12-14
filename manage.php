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
            <label>ISBN</label>
            <div class="ui mini icon input">
                <input name="isbn" type="text" placeholder="isbn...">
                <i class="search icon"></i>
            </div>
          </div>  

          <button class="small ui orange button" type="submit">
            <i class="filter icon"></i> Search 
          </button>    

        </form>
    </section>
	
	
	<section class="eleven wide column">
        <h1 class="ui header">Book Information Panel</h1>
        <ul class="ui divided items" id="booksList">

        
        <?php
		  $isbn = "";
		  
          if ($_SERVER["REQUEST_METHOD"] == "GET"){
            if (isset($_GET["isbn"])){
              $isbn = $_GET["isbn"];
			  
			  $books = getBookByISBN($isbn) or die("Failed to connect to the database");
			  
			  echo '
				<form class="ui form" method="GET">
					<h4 class="ui dividing header">Book Found Through ISBN</h4>
					<div class="field">
						<label>ISBN</label>
						<div class="ui mini icon input">
							<input name="isbn" type="text" value='.$books->isbn.' readonly>
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Title</label>
						<div class="ui mini icon input">
							<input name="title" type="text" value="'.$books->title.'" disabled>
							<i class="search icon"></i>
						</div>
					</div> 
					<div class="field">
						<label>Author</label>
						<div class="ui mini icon input">
							<input name="author_name" type="text" value="'.$books->author_name.'" disabled>
							<i class="search icon"></i>
						</div>
					</div>  
					<div class="field">
						<label>Genre</label>
						<div class="ui mini icon input">
							<input name="genre" type="text" value="'.$books->genre.'" disabled>
							<i class="search icon"></i>
						</div>
					</div> 		
					<div class="field">
						<label>Publisher</label>
						<div class="ui mini icon input">
							<input name="publisher" type="text" value="'.$books->publisher.'" disabled>
							<i class="search icon"></i>
						</div>
					</div> 		
					<div class="field">
						<label>Number of Pages</label>
						<div class="ui mini icon input">
							<input name="num_pages" type="text" value="'.$books->num_pages.'" disabled>
							<i class="search icon"></i>
						</div>
					</div> 	
					<div class="field">
						<label>Cost</label>
						<div class="ui mini icon input">
							<input name="cost" type="text" value="'.$books->cost.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Price</label>
						<div class="ui mini icon input">
							<input name="price" type="text" value="'.$books->price.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Publisher % Cut</label>
						<div class="ui mini icon input">
							<input name="publisher_percent" type="text" value="'.$books->publisher_percent.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Stock</label>
						<div class="ui mini icon input">
							<input name="stock" type="text" value="'.$books->stock.'">
							<i class="search icon"></i>
						</div>
					</div>
					<div class="field">
						<label>Threshold</label>
						<div class="ui mini icon input">
							<input name="threshold" type="text" value="'.$books->threshold.'">
							<i class="search icon"></i>
						</div>
					</div>

					<button class="small ui orange button" type="submit">
					<i class="filter icon"></i> Save Changes 
					</button>    

				</form>';
				
            } 
          }
		  if ($_SERVER["REQUEST_METHOD"] == "GET"){
			if (isset($_GET["isbn"]) && isset($_GET["cost"]) && isset($_GET["price"]) && isset($_GET["publisher_percent"]) && isset($_GET["stock"]) && isset($_GET["threshold"])){
				$isbn = $_GET["isbn"];
				$cost = $_GET["cost"];
				$price = $_GET["price"];
				$publisher_percent = $_GET["publisher_percent"];
				$stock = $_GET["stock"];
				$threshold = $_GET["threshold"];
				
				$ret = manage_existing_book($isbn, $cost, $price, $publisher_percent, $stock, $threshold);
				if ($ret == "Changes Saved") {
					echo '<script> location.reload(); </script>';
				}
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