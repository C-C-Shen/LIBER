<?php  
  require_once('includes/header.inc.php');

  // Create a new DOM Document
  $dom = new DOMDocument('1.0', 'iso-8859-1');
    
  // Enable validate on parse
  $dom->validateOnParse = true;
?>

<main >
    <?php 
      if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["isbn"])){
          $isbn = $_GET["isbn"];
        } else {
          $isbn = '273-21-86363-55-0';
        }

        $book = getBookByISBN($isbn);
      }
    ?>
    
    <!-- Main section about painting -->
    <section class="ui segment grey100">
        <div class="ui doubling stackable grid container">
              <div class="nine wide column">
			
            <div class="seven wide column">
                
                <!-- Main Info -->
                <div class="item">
          
          <?php
					    echo '<h2 class="header">'.$book->title.'</h2>
					          <h3>'.$book->author_name.'</h3>';
          ?>

					<div class="meta">
            </div>  
                </div>                          
                  
                <!-- Tabs For Details, Museum, Genre, Subjects -->
                <div class="ui top attached tabular menu ">
                    <a class="active item" data-tab="details"><i class="image icon"></i>Details</a> 
                </div>
                
                <div class="ui bottom attached active tab segment" data-tab="details">
                    <table class="ui definition very basic collapsing celled table">

                    <tbody>
                      <tr>
                    <td>
                        Author
                      </td>
                      <td>
                        <?php
                          echo '<a href="https://en.wikipedia.org/wiki/'.$book->author_name.'">'.$book->author_name.'</a>';
                        ?>
                      </td>                       
                      </tr>
                    <tr>                       
                      <td>
                        Publisher
                      <?php
                          echo '<td>'.$book->publisher.'</td>';
                      ?>
                    </tr>       
                    <tr>
                      <td>
                        Stock
                      </td>
                      <?php
                          echo '<td>'.$book->stock.'</td>';
                      ?>
                    </tr>  
                    <tr>
                      <td>
                        Number of Pages
                      </td>
                      <?php
                          echo '<td>'.$book->num_pages.'</td>';
                      ?>
                    </tr>        
                    </tbody>
                  </table>
                
                <!-- Cart and Price -->
                <div class="ui segment">
                  <form class="ui form" method="GET" action="addToCart.php">
                      <div class="ui form">
                          <div class="ui tiny statistic">
                            <div class="value">
                              <?php 
                                echo '$'.$book->price;
                              ?>
                            </div>
                          </div>
                          <div class="four fields">
                              <div class="three wide field">
                                <?php
                                  echo '<input name="isbn" type="hidden" value="'.$isbn.'">';
                                ?>
                              </div>                                         
                          </div>  
                          <div class="four fields">
                              <div class="three wide field">
                                  <label>Quantity</label>
                                  <?php
                                    echo '<input name="quantity" type="number" value="1" min="1" max="'.$book->stock.'">';
                                  ?>
                              </div>                                         
                          </div>                      
                      </div>

                      <div class="ui divider"></div>

                      <button class="small ui orange button" type="submit">
                        <i class="add to cart icon"></i> Add to Cart 
                      </button> 
                  </form>
                </div>     <!-- END Cart -->                      
                          
            </div>	<!-- END RIGHT data Column --> 
        </div>		<!-- END Grid --> 
    </section>		<!-- END Main Section --> 
</main>    
    

    
  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>