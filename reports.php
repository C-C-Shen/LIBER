<?php
  require_once('includes/header.inc.php');
  
  if (!isset($_SESSION['User']) && !($_SESSION['UserType'] == "staff")){
	header("Location: login.php");
  } 
?>

<main class="ui segment doubling stackable grid container">
	Nothing here yet...
</main>    
    
  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>