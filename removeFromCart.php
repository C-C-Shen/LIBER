<?php
    require_once('includes/header.inc.php');
    
    if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["isbn"])){
            $isbn = $_GET["isbn"];
        } else {
            $isbn = '273-21-86363-55-0';
        }

        // Checks to see if one painting should be removed.
        if ($isbn == -1) {
            $cart_items = Array();
        } else {
        // Removing an individual painting.
        if (isset($_SESSION['Cart'])){
            $cart_items = $_SESSION['Cart'];
        } else {
            $cart_items = Array();
        }

        if (isset($cart_items[$isbn])){
            unset($cart_items[$isbn]);
        }  
        }

        // Setting up the new favourites list.
        $_SESSION['Cart'] = $cart_items;

        header("Location: cart.php");
    }
?>