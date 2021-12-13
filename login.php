<?php
    require_once('includes/header.inc.php');
    require_once('includes/liber-config.inc.php');
    require_once('includes/database.inc.php');
    require_once('includes/classes.inc.php');


    if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["id"]) && isset($_GET["email"]) && isset($_GET["type"])){
          $id = $_GET["id"];
          $email = $_GET["email"];
          $type = $_GET["type"];


          if ($type == "client" && $client = verifyClient($id, $email)){
            $_SESSION['User'] = $client;
            $_SESSION['UserType'] = "client";
            $_SESSION['ID'] = $client->id;
            header("Location: home.php");
          } else if ($type == "staff" && $staff = verifyStaff($id, $email)){
            $_SESSION['User'] = $staff;
            $_SESSION['UserType'] = "staff";
            $_SESSION['ID'] = $staff->id;
            header("Location: home.php");
          } else {
            echo '<p> Could not verify you sorry! </p>';
          }
        } 
      }
?>

<main class="ui segment doubling stackable grid container">

<section class="five wide column">
    <form class="ui form" method="GET">
        <h4 class="ui dividing header">Login</h4>

        <div class="field">
            <label>ID</label>
            <div class="ui mini icon input">
                <input name="id" type="text" placeholder="id...">
            </div>
        </div>  

        <div class="field">
            <label>Email</label>
                <div class="ui mini icon input">
                    <input name="email" type="text" placeholder="email...">
                </div>
            </div> 

        <div class="field">
            <label>Type</label>
            <div class="ui medium icon input">
                <label for="staff_type">staff</label>
                <input id="staff_type" type="radio" name="type" value="staff">

                <label>client</label>
                <input type="radio" name="type" value = "client">
            </div>
        </div>   

        <button class="small ui orange button" type="submit">
            Sign in
        </button>    

        <a class="ui icon button" href="register.php">
            sign up
        </a> 
    </form>
</section>
</main>    
