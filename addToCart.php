<?php
    require_once('includes/header.inc.php');

    if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["isbn"])){
            $isbn = $_GET["isbn"];
        } else {
            $isbn = '273-21-86363-55-0';
        }

        if (isset($_GET["quantity"])){
            $quantity = $_GET["quantity"];
        } else {
            $quantity = 1;
        }

        if (isset($_SESSION['Cart'])){
            $cart_items = $_SESSION['Cart'];
        } else {
            $cart_items = Array();
        }

        $book = getBookByISBN($isbn);

        $cart_items[$isbn] = Array($isbn, $book->title, $quantity, $book->price);

        $_SESSION['Cart'] = $cart_items;

        header("Location: cart.php");
    }
?>