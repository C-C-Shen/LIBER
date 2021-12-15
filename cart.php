<?php
    require_once('includes/header.inc.php');
?>

<section class="eleven wide column">
    <ul class="ui divided items" id="booksList">

    <h1 class="ui header">Cart</h1>

    <li class="item">
        <a class="ui icon button" href="removeFromCart.php?isbn=-1">
            Empty Cart
        </a>

        <a class="ui icon button" href="checkout.php" style="margin-left:80%;">
            Checkout
        </a>
    </li>
    <table style ="width:100%;border-spacing: 0 15px;border-collapse: separate;">
        <tr>
            <th>Title</th>
            <th>Quantity</th>
            <th>Price</th>
            <th>Total</th>
            <th>Action</th>
        </tr>
    <?php 
        $total = 0;
        if (isset($_SESSION['Cart'])){
            $cart_items = $_SESSION['Cart'];

            foreach($cart_items as $book){
                $total += $book[3] * $book[2];
                
                echo '<tr>
                        <td style="text-align: center;">
                            <a class="header" href="single-book.php?isbn='.$book[0].'">'.$book[1].'</a>
                        </td>

                        <td style="text-align: center;">'.$book[2].'</td>
                        <td style="text-align: center;">$'.$book[3].'</td>
                        <td style="text-align: center;">$'.$book[2] * $book[3].'</td>

                        <td style="text-align: center;">
                            <a class="ui icon button" href="removeFromCart.php?isbn='.$book[0].'">
                                Remove from Cart
                            </a>
                        </td>
                    
                    </tr>';
            }

            $_SESSION['CartTotal'] = $total * 1.13;
        }
    ?> 

    </table>

    <li class="item">
        <h2> Cart Total: $
        <?php
            echo $total.'</h2>';
        ?>
    </li>

    <li class="item">
        <h2> Cart Total After Tax: $
        <?php
            echo number_format($total * 1.13,2,'.',',').'</h2>';
        ?>
    </li>
    
</ul>        
</section>  

  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>

