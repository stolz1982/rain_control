<!DOCTYPE HTML>
<html>  
<body>

<form action="rain.php" method="post">

<select name="GPIO">
<option value="15">Blumenbeet</option>
<option value="10">Hausvorgarten/Garageneinfahrt</option>
<option value="11">Mittelstück hinten links</option>
<option value="12">Mittelstück / Anfang</option>
<option value="13">Mittenstück hinten rechts</option>
<option value="17">Gewächshaus (Zulauf)</option>
<option value="18">Gewächshaus (Ablauf)</option>
<option value="2">Vor dem Grundstück</option>
<option value="3">Endstück Sichtschutzzaun</option>
<option value="4">Endstück Hecke</option>
<option value="5">Endstück Pflanzenbeet</option>
</select>
<br>
Dauer: <input type="number" min=1 max=30 name="DAUER" value="15" size="4"> Minuten<br>

<input type="submit" name="start" value="STARTEN">
</form>
</body>
</html>
