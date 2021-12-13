<?php
    require_once('includes/header.inc.php');
    require_once('includes/liber-config.inc.php');
    require_once('includes/database.inc.php');
    require_once('includes/classes.inc.php');

    if (!isset($_SESSION['User'])){
        header("Location: login.php");
    } 
?>

<main class="ui segment doubling stackable grid container">

<section class="five wide column">
    <form class="ui form" method="GET">
        <h4 class="ui dividing header">Track your order</h4>

        <div class="field">
            <label>Order Number</label>
            <div class="ui mini icon input">
                <input name="order_number" type="text" placeholder="order number...">
            </div>
        </div>    

        <button class="small ui orange button" type="submit">
            Track
        </button>    
    </form>

    <?php
        if ($_SERVER["REQUEST_METHOD"] == "GET"){
            if (isset($_GET["order_number"])){

                $status = getOrderStatus($_SESSION["ID"], $_GET["order_number"]);

                if ($status == "PENDING"){
                    echo '<h2> Your order is still pending </h2>';
                    echo '<img src="images/shipping/pending.jpg">';
                } else if ($status == "SHIPPED"){
                    echo '<h2> Your order has been shipped </h2>';
                    echo '<img src="images/shipping/shipped.jpg">';
                } else if ($status == "ARRIVED"){
                    echo '<h2> Your order has been arrived! </h2>';
                    echo '<img src="images/shipping/arrived.jpg">';
                } else {
                    echo '<h2> Could not find your order :( </h2>';
                }
            }
        }
    ?>
</section>
</main>   

