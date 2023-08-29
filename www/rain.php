<html>
<body>

</body>
</html>

<?php
$dauer = $_POST["DAUER"];
$gpio = $_POST["GPIO"];

if ( $dauer > 0 ) {
echo "Beregnung wird gestart!";
$dauer = $dauer*60;
$exec = "echo www-data | /usr/bin/sudo -S /home/user01/rain_control/rain_control.sh -t $dauer -V $gpio -n";
exec($exec,$out,$rcode);
echo "Beregnung beendet!";

}
?>

