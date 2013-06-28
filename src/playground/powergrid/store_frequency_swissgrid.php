<html>
<head>
<title>Store Frequency Swissgrid</title>
</head>
<body>
<?php
 include("spiderbook/LIB_parse.php");
 include("conf/config.inc.php");
 
 echo "<h3>Store Frequency Swissgrid</h3>";
 echo "<p>Parsing...</p>";
 $frequency=-1;
 $networkdiff=-1;
 
 $lines = file("frequency.html");
 $hugepage = '';
 for ( $i = 0; $i < sizeof( $lines ); $i++ ) {
   if (strpos($lines[$i], 'frequencymark.gif"')>0) $lines[$i]='    src="gadgets/netfrequency/img/frequencymark.gif"';
   if (strpos($lines[$i], 'frequencyband.gif"')>0) $lines[$i]='    src="gadgets/netfrequency/img/frequencyband.gif"';
   
   $hugepage = $hugepage . $lines[$i];
 }
 $table = return_between($hugepage, '<table class="data">', '</table>', INCL);
 echo "<br><b>Table</b><br>";
 echo $table;
 
 echo "<br><b>Strings</b><br>";
 $frequencyrow = return_between($table, '<strong>Aktuelle Frequenz</strong>','</tr>', EXCL);
 $frequencystr = return_between($frequencyrow, '<span>','</span>', EXCL);
 echo "*$frequencystr*<br>";
 
 $netdiffrow = return_between($table, '<strong>Aktuelle Netzabweichung</strong>','</tr>', EXCL);
 $netdiffstr = return_between($netdiffrow, '<span>','</span>', EXCL);
 echo "*$netdiffstr*<br>";
 
 echo "<br><b>Values</b><br>";
 $frequency = str_replace(" Hz", "", $frequencystr);
 $frequency = str_replace(",", ".", $frequency);
 echo "*$frequency*<br>";
 
 $netdiff = str_replace(" s", "", $netdiffstr);
 $netdiff = str_replace(",", ".", $netdiff);
 echo "*$netdiff*<br>";
 
 /*
 $lastprice=-1;
 $high=-1;
 $low=-1;
 $volume=-1;
 $avg=-1;
 
 $lines = file("bitcoincharts.html");
 $hugepage = '';
 for ( $i = 0; $i < sizeof( $lines ); $i++ ) {
   $hugepage = $hugepage . $lines[$i];
 }
 $table = return_between($hugepage, '<table class="data">', '</table>', INCL);
 echo $table;
 
 $mtgox = return_between($table, '<a href="/markets/mtgoxUSD.html">mtgoxUSD</a>','</tr>', EXCL); 
 $mtgox = str_replace ('<td class="right">', '' , $mtgox);
 $mtgox = str_replace ('</td>', '' , $mtgox);
 
 echo "<pre>";
 echo $mtgox;
 echo "</pre>";
 
 $lines = explode("\n", $mtgox);
 echo "<pre>";
 for ( $i = 0; $i < sizeof( $lines ); $i++ ) {
    echo $i . ' '. $lines[$i] . ' ';
 }
 echo "</pre>";
 
 
 $lastprice = trim($lines[2]);
 $avg       = trim($lines[3]);
 $change    = trim($lines[4]);
 $volume    = trim($lines[5]);
  
 $change = str_replace ('%', '' , $change); 
 $change = str_replace ('+', '' , $change); 
 $change = $change / 100;
 
 $volume = $volume / 30;
 
 echo "<table>";
         echo "<tr><td>Last Price:</td><td>$lastprice</td></tr>";
         echo "<tr><td>Exchange Average:</td><td>$avg</td></tr>";
         echo "<tr><td>Change:</td><td>$change</td></tr>";
         echo "<tr><td>Volume:</td><td>$volume</td></tr>";
 echo "</table>";

 mysql_connect($dbserver, $username, $password);
@mysql_select_db($database) or die("Unable to select database");
 
 echo "<p>Calculating thresholds...</p>";
 
 $thlowquery = "select min(price) from pricevalue where create_dt >= (NOW() - INTERVAL $th_day_interval DAY);";
 echo "<p>$thlowquery</p>";
 $thlowresult = mysql_query($thlowquery);
 $th_low=mysql_result($thlowresult, 0, "min(price)");
 
 $thhighquery = "select max(price) from pricevalue where create_dt >= (NOW() - INTERVAL $th_day_interval DAY);";
 echo "<p>$thhighquery</p>";
 $thhighresult = mysql_query($thhighquery);
 $th_high=mysql_result($thhighresult, 0, "max(price)");
 
 
 $highquery = "select max(price) from pricevalue where create_dt >= (NOW() - INTERVAL 5 DAY);";
 echo "<p>$highquery</p>";
 $highresult = mysql_query($highquery);
 $high=mysql_result($highresult, 0, "max(price)");

 $lowquery = "select min(price) from pricevalue where create_dt >= (NOW() - INTERVAL 5 DAY);";
 echo "<p>$lowquery</p>";
 $lowresult = mysql_query($lowquery);
 $low=mysql_result($lowresult, 0, "min(price)");
 
 
 $avgquery = "select avg(price) from pricevalue where create_dt >= (NOW() - INTERVAL $th_day_interval DAY);";
 echo "<p>$avgquery</p>";
 $avgresult = mysql_query($avgquery);
 $myavg=mysql_result($avgresult, 0, "avg(price)");
  
 echo "<p>Storing...</p>";
 
 if ($lastprice!="") {
    $query="INSERT INTO pricevalue (id, create_dt, price, high, low, volume, avgexchange, myavg, th_low, th_high, changepct, create_user) VALUES('',
                                    NOW(), $lastprice, $high, $low, $volume, $avg, $myavg, $th_low, $th_high, $change, 'mainloop');";
                                 
 } else {
    $query="INSERT INTO log (id, message, level, create_dt) VALUES('', 'Could not retrieve prices!', 'ERROR', NOW());";
 }
 echo "<p>$query</p>";                                 
 mysql_query($query);
 mysql_close();

 echo "<p>Over.</p>";
 */
?>
</body>
</html>