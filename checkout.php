<?php
    require_once('includes/header.inc.php');

    if (!isset($_SESSION['User'])){
        header("Location: login.php");
    } 
?>

<main class="ui segment doubling stackable grid container">

<section class="five wide column">
    <h3 class="ui dividing header">Checkout</h3>

    <?php
        if ($_SERVER["REQUEST_METHOD"] == "GET"){
            if (isset($_GET["account"]) && isset($_GET["building_num"]) && isset($_GET["street"]) && isset($_GET["city"]) 
                && isset($_GET["state"]) && isset($_GET["country"]) && isset($_GET["postal"])){

                $account = $_GET["account"];
                $building_num = $_GET["building_num"];
                $street = $_GET["street"];
      
                $city = $_GET["city"];
                $state = $_GET["state"];
                $country = $_GET["country"];
      
                $postal = $_GET["postal"];

                if ($_SESSION['CartTotal'] == 0){
                    echo '<h2> Your cart is empty </h2>';
                } else if (!canAffordOrder($account,$_SESSION['CartTotal'])){
                    echo '<h2> Your do not have enough money in your account :( </h2>';
                } else {
                    updateClientAccount($_SESSION["ID"], $account);
                    
                    $address_id = createAddress($building_num, $street, $city, $state, $country, $postal);
                    $order_number = place_order($_SESSION["ID"], $address_id);

                    $cart_items = $_SESSION['Cart'];

                    foreach($cart_items as $book){
                        checkout($book[0], $account, $order_number, $book[2]);
                    }

                    echo '<h2> Your order was placed successfuly! Your order number is '.$order_number.' </h2>';

                    $_SESSION["Cart"] = Array();
                    $_SESSION["CartTotal"] = 0;

                    return;
                }
                    
            }
        }
    ?>

<form class="ui form" method="GET">
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
            Checkout
        </button>     
    </form>

</section>
</main>  

  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>

