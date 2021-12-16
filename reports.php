<?php
  require_once('includes/header.inc.php');
  
  if (!isset($_SESSION['User']) && !($_SESSION['UserType'] == "staff")){
	  header("Location: login.php");
  } 
?>

<main class="ui segment doubling stackable grid container">
	<section class="five wide column">
        <form class="ui form" method="GET">
          <h4 class="ui dividing header">Sales To View</h4>

          <div class="field">
            <label>By ISBN of a Specific Book</label>
            <div class="ui mini icon input">
                <input name="isbn" type="text" placeholder="isbn...">
                <i class="search icon"></i>
            </div>
          </div>
          
		    <div class="field">
            <label>By Genre</label>
            <select name="genre" class="ui fluid dropdown">
              <option></option>  
              <?php 
                $genres = getGenres();

                foreach($genres as $genre){
                  echo '<option>'.$genre->genreName.'</option>';
                }
              ?>
            </select>
        </div>

		    <div class="field">
            <label>By Author</label>
            <div class="ui mini icon input">
                <input name="author_name" type="text" placeholder="author...">
                <i class="search icon"></i>
            </div>
        </div>

		    <div class="field">
            <label>By Publisher</label>
            <div class="ui mini icon input">
                <input name="publisher" type="text" placeholder="publisher...">
                <i class="search icon"></i>
            </div>
        </div>

		    <div class="field">
            <label>Date Range:</label>
            <label>From: </label>
            <input name="from_date" type="month">
        </div>    

          <div class="field">
            <label>To: </label>
				    <input name="to_date" type="month">
          </div>

          <button class="small ui orange button" type="submit">
            <i class="filter icon"></i> Continue 
          </button>    
        </form>
    </section>
	
	<section class="eleven wide column">
		<h1 class="ui header">Sales Information Panel</h1>
		<ul class="ui divided items" id="booksList">

			
		<?php
		  $isbn = "";
		  
      $allSalesData = Array();
		  if ($_SERVER["REQUEST_METHOD"] == "GET"){
        if (isset($_GET["isbn"]) && isset($_GET["genre"]) && isset($_GET["author_name"]) && isset($_GET["publisher"]) && isset($_GET["from_date"]) && isset($_GET["to_date"])){
          $isbn = $_GET["isbn"];
          $genre = $_GET["genre"];
          $author_name = $_GET["author_name"];
          $publisher = $_GET["publisher"];
          $from_date = $_GET["from_date"];
          $to_date = $_GET["to_date"];
          
          // Use this to make a chart?
          $allSalesData = getSalesFig($isbn, $author_name, $genre, $publisher, $from_date, $to_date);
        }
      }
    ?>
    
    <table style ="width:100%;border-spacing: 0 15px;border-collapse: separate;border: 1px solid black;">
        <tr>
          <th> ISBN </th>
          <th> Month </th>
          <th> Year </th>
          <th> Quantity </th>
          <th> Total Revenue </th>
          <th> Total Expense </th>
        </tr>

      <?php
        foreach($allSalesData as $singleSale) {
          $tempBook = getBookByISBN($singleSale->isbn);
          $total = $tempBook->price * $singleSale->quantity;
          $singleSale->revenue = number_format($total - ($total * $tempBook->publisher_percent * 0.01), 2, '.', '');
          $singleSale->expense = number_format($tempBook->cost * $singleSale->quantity, 2, '.', '');
                
          echo '<tr><td style="text-align: center;">'.$singleSale->isbn.'</td>
                    <td style="text-align: center;">'.$singleSale->month.'</td>
                    <td style="text-align: center;">'.$singleSale->year.'</td>
                    <td style="text-align: center;">'.$singleSale->quantity.'</td>
                    <td style="text-align: center;">$'.$singleSale->revenue.'</td>
                    <td style="text-align: center;">$'.$singleSale->expense.'</td></tr>';            
          }
      ?>
    </table>

    <br>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
      <div class="container">
          <canvas id="saleschart" width="100" height="50"></canvas>
      </div>
        
    <script>
            <?php
              $isbns = "[";
              foreach($allSalesData as $singleSale) {
                $isbns = $isbns."'".$singleSale->isbn."', ";
              }
              $isbns = $isbns."]";

              echo 'var dataArray = '.$isbns.';';
            ?>

            var ctx = document.getElementById("saleschart");
            var myChart = new Chart(ctx, {
                type: "bar",
                data: {
                    labels: dataArray,
                    datasets: [{
                            label: "Expenses",

                            <?php
                              $data = "[";
                              foreach($allSalesData as $singleSale) {
                                $data = $data.$singleSale->expense.", ";
                              }
                              $data = $data."]";

                              echo 'data: '.$data.',';
                            ?>

                            borderColor: [
                                "rgba(255,0,0,1)",
                            ],
                            borderWidth: 1
                        },{
                            label: "Revenues",

                            <?php
                              $data = "[";
                              foreach($allSalesData as $singleSale) {
                                $data = $data.$singleSale->revenue.", ";
                              }
                              $data = $data."]";

                              echo 'data: '.$data.',';
                            ?>

                            borderColor: [
                                "rgba(0,255,0,1)",
                            ],
                            borderWidth: 1
                        }]
                },
                options: {
                    scales: {
                        yAxes: [{
                                ticks: {
                                    beginAtZero: true
                                }
                            }]
                    }
                }
            });
        </script>
	</section>
</main>    
    
  <footer class="ui black inverted segment">
      <div class="ui container">LIBER Bookstore - www.LIBER.com</div>
  </footer>
</body>
</html>