<?php
  require_once('includes/header.inc.php');
  
  if (!isset($_SESSION['User']) && !($_SESSION['UserType'] == "staff")){
	header("Location: login.php");
  } 

  $genres = getGenres();
?>

<main class="ui segment doubling stackable grid container">
	<section class="five wide column">
        <form class="ui form" method="GET">
          <h4 class="ui dividing header">Sales To View</h4>

          <div class="field">
            <label>By ISBN Of Specific Book</label>
            <div class="ui mini icon input">
                <input name="isbn" type="text" placeholder="isbn...">
                <i class="search icon"></i>
            </div>
          </div>
		  <div class="field">
            <label>By Genre</label>
            <select name="genre" class="ui fluid dropdown">
              <option></option>  
              <?php 
                foreach($genres as $genre){
                  echo '<option>'.$genre->genreName.'</option>';
                }
              ?>
            </select>
          </div>
		  <div class="field">
            <label>By Author</label>
            <div class="ui mini icon input">
                <input name="author_name" type="text" placeholder="author...">
                <i class="search icon"></i>
            </div>
          </div>
		  <div class="field">
            <label>By Publisher</label>
            <div class="ui mini icon input">
                <input name="publisher" type="text" placeholder="publisher...">
                <i class="search icon"></i>
            </div>
          </div>
		  <div class="field">
            <label>Date Range: [From] -> [To]</label>
            <div class="ui mini icon input">
                <input name="from_date" type="month">
				<input name="to_date" type="month">
            </div>
          </div>    

          <button class="small ui orange button" type="submit">
            <i class="filter icon"></i> Continue 
          </button>    
        </form>
    </section>
	
	<section class="eleven wide column">
		<h1 class="ui header">Sales Information Panel</h1>
		<ul class="ui divided items" id="booksList">
			
		<?php
		  $isbn = "";
		  
		  if ($_SERVER["REQUEST_METHOD"] == "GET"){
			if (isset($_GET["isbn"]) && isset($_GET["genre"]) && isset($_GET["author_name"]) && isset($_GET["publisher"]) && isset($_GET["from_date"]) && isset($_GET["to_date"])){
			  $isbn = $_GET["isbn"];
			  $genre = $_GET["genre"];
			  $author_name = $_GET["author_name"];
			  $publisher = $_GET["publisher"];
			  $from_date = $_GET["from_date"];
			  $to_date = $_GET["to_date"];
			  
			  // Use this to make a chart?
			  $allSalesData = getSalesFig($isbn, $author_name, $genre, $publisher, $from_date, $to_date);
			}
		  }
		 ?>
	</section>
</main>    
    
  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>
