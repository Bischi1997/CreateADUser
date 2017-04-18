<?php

	$vorname = $_POST['vorname'];
	$name = $_POST['name'];
	$pid = $_POST['pid'];
	$firma = $_POST['firma'];
	$abteilung = $_POST['abteilung'];
	$telnummer = $_POST['telnummer'];
	
	$list = array (
		array('Vorname','Name','PID','Firma','Abteilung','Telnummer'),
		array($vorname,$name,$pid,$firma,$abteilung,$telnummer),
	);

	$fp = fopen('users.csv', 'w');
	
	foreach ($list as $fields) {
		fputcsv($fp, $fields);
	}

	fclose($fp);
	
	echo "Die Informationen wurden gespeichert.";
	
?>