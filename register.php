
<?php
    require_once('includes/header.inc.php');

    if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["name"]) && isset($_GET["email"]) && isset($_GET["phone"]) && isset($_GET["account"]) && isset($_GET["building_num"]) && isset($_GET["street"])
            && isset($_GET["city"]) && isset($_GET["state"]) && isset($_GET["country"]) && isset($_GET["postal"]) ){
          $name = $_GET["name"];
          $email = $_GET["email"];
          $phone = $_GET["phone"];

          $account = $_GET["account"];
          $building_num = $_GET["building_num"];
          $street = $_GET["street"];

          $city = $_GET["city"];
          $state = $_GET["state"];
          $country = $_GET["country"];

          $postal = $_GET["postal"];


          if ($client = registerClient($name, $email, $phone, $account, $building_num, $street, $city, $state, $country, $postal)){
            $_SESSION['User'] = $client;
            $_SESSION['UserType'] = "client";
            $_SESSION['ID'] = $client->id;
            header("Location: home.php");
          } else {
            echo '<p> Registration failed :( </p>';
          }
        } 
      }
?>

<main class="ui segment doubling stackable grid container">

<section class="five wide column">
    <h3 class="ui dividing header">Register</h3>
    <form class="ui form" method="GET">
        <h4 class="ui dividing header">Personal Information</h4>

        <div class="field">
            <label>Name</label>
            <div class="ui mini icon input">
                <input name="name" type="text" placeholder="name...">
            </div>
        </div>  

        <div class="field">
            <label>Email</label>
                <div class="ui mini icon input">
                    <input name="email" type="text" placeholder="email...">
                </div>
            </div> 

        <div class="field">
            <label>Phone Number</label>
            <div class="ui medium icon input">
                <input name="phone" type="text" placeholder="phone number...">
            </div>
        </div>   

        <h4 class="ui dividing header">Banking Information</h4>

        <div class="field">
            <label>Account Number</label>
            <div class="ui medium icon input">
                <input name="account" type="text" placeholder="account number...">
            </div>
        </div>   

        <h4 class="ui dividing header">Address</h4>

        <div class="field">
            <label>Building Number</label>
            <div class="ui mini icon input">
                <input name="building_num" type="text" placeholder="building number...">
            </div>
        </div>  

        <div class="field">
            <label>Street</label>
                <div class="ui mini icon input">
                    <input name="street" type="text" placeholder="street...">
                </div>
            </div> 

        <div class="field">
            <label>City</label>
            <div class="ui medium icon input">
                <input name="city" type="text" placeholder="city...">
            </div>
        </div>   

        <div class="field">
            <label>State</label>
                <div class="ui mini icon input">
                    <input name="state" type="text" placeholder="state...">
                </div>
            </div> 

        <div class="field">
            <label>Country</label>
            <div class="ui medium icon input">
                <input name="country" type="text" placeholder="country...">
            </div>
        </div>   

        <div class="field">
            <label>Postal Code</label>
            <div class="ui medium icon input">
                <input name="postal" type="text" placeholder="postal code...">
            </div>
        </div>   

        <button class="small ui orange button" type="submit">
            Register
        </button>    
    </form>
</section>
</main>    
