<!DOCTYPE html>
<html lang=en>
<head>
<meta charset=utf-8>
    <link href='http://fonts.googleapis.com/css?family=Merriweather' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
    
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script src="css/semantic.js"></script>
	<script src="js/misc.js"></script>
    
    <link href="css/semantic.css" rel="stylesheet" >
    <link href="css/icon.css" rel="stylesheet" >
    <link href="css/styles.css" rel="stylesheet">  

    <link rel="shortcut icon" type="image/x-icon" href="images/logo.jpg" />
</head>
<body >
<header>
    <?php
      session_start();
    ?>

    <div class="ui attached stackable grey inverted  menu">
        <div class="ui container">
            <nav class="right menu">            
                <div class="ui simple  dropdown item">
                  <i class="user icon"></i>
                  Account
                    <i class="dropdown icon"></i>
                  <div class="menu">
                    <a class="item" href="login.php"><i class="sign in icon"></i> Login</a>
                  </div>
                </div>       
                <a class=" item" href = "cart.php">
                  <i class="shop icon"></i> Cart &nbsp;
                  <?php
                      if (isset($_SESSION['Cart'])){
                        $cart_items = $_SESSION['Cart'];
                        $bookCount = count($cart_items);
                      } else {
                        $bookCount = 0;
                      }

                      echo '<i class = "inverted bordered red icon">'.$bookCount.'</i>';
                  ?>
                </a> 
                <p>
                  <?php
                    if (isset($_SESSION['User'])){
                      echo 'Logged in as: '.$_SESSION['UserType'].'<br/> ID: '.$_SESSION['ID'];
                    } else {
                      echo 'Not logged in';
                    }
                  ?> 
              </p>                                    
            </nav>            
        </div>     
    </div>   
    
    <div class="ui attached stackable borderless huge menu">
        <div class="ui container">
            <h2 class="header item">
              <a href="home.php">
                <img src="images/logo.jpg" class="ui small image">
              </a>
            </h2>  
            <a class="item" href="home.php">
              <i class="home icon"></i> Home
            </a> 
            <a class="item" href="track.php">
              <i class="globe icon"></i> Track Your Order
            </a>  
            <a class="item" href="manage.php">
              <i class="edit icon"></i> Manage Books
            </a>                        
        </div>
    </div>       
</header> 