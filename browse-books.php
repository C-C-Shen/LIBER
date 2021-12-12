<?php
  require_once('includes/header.inc.php');
  require_once('includes/liber-config.inc.php');
  require_once('includes/database.inc.php');
  require_once('includes/classes.inc.php');

  $genres = getGenres();
?>

<main class="ui segment doubling stackable grid container">

    <section class="five wide column">
        <form class="ui form" method="GET">
          <h4 class="ui dividing header">Browse Books</h4>

          <div class="field">
            <label>ISBN</label>
            <div class="ui mini icon input">
                <input name="isbn" type="text" placeholder="isbn...">
                <i class="search icon"></i>
            </div>
          </div>  

          <div class="field">
            <label>Title</label>
              <div class="ui mini icon input">
                <input name="title" type="text" placeholder="title...">
                <i class="search icon"></i>
              </div>
          </div> 

          <div class="field">
            <label>Author</label>
            <div class="ui mini icon input">
                <input name="author" type="text" placeholder="author...">
                <i class="search icon"></i>
            </div>
          </div>   

          <div class="field">
            <label>Genre</label>
            <select name="genre" class="ui fluid dropdown">
              <option></option>  
              <?php 
                foreach($genres as $genre){
                  echo '<option>'.$genre->genreName.'</option>';
                }
              ?>
            </select>
          </div> 

          <button class="small ui orange button" type="submit">
            <i class="filter icon"></i> Search 
          </button>    

        </form>
    </section>
    

    <section class="eleven wide column">
        <h1 class="ui header">Books</h1>
        <ul class="ui divided items" id="booksList">

        
        <?php 
          $isbn = "";
          $title = ""; 
          $author = "";
          $genre = "";

          if ($_SERVER["REQUEST_METHOD"] == "GET"){
            if (isset($_GET["isbn"]) && isset($_GET["title"]) && isset($_GET["author"])  && isset($_GET["genre"])){
              $isbn = $_GET["isbn"];
              $title = $_GET["title"];
              $author = $_GET["author"];
              $genre = $_GET["genre"];
            } 
          }

          $books = fetchBooks($isbn, $title, $author, $genre) or die("Failed to connect to the database");
        
          
          foreach($books as $book){
            echo '
              <li class="item">
              <div class="content">
                <a class="header" href="single-book.php?isbn='.$book->isbn.'">'.$book->title.'</a>
                <div class="meta"><span class="cinema">'.$book->author_name.'</span></div>        
                <div class="meta">     
                    <strong>$'.$book->price.'</strong>        
                </div>        
                <div class="extra">
                  <a class="ui icon orange button" href="addToCart.php?isbn='.$book->isbn.'"><i class="add to cart icon"></i></a>
                </div>        
              </div>      
            </li>';
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