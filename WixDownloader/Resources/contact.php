<?php

if (isset ($POST['to']))
{
	$to = "<user@email.com>";
	$subject = $POST['subject'];
	$message = $POST['htmlMessage'];
	$headers = "From: " . $POST['personal'] . " <". $_POST['address'] . ">";
	mail($to, $subject, $message, $headers);
	
	echo '{"errorCode":0,"errorDescription":"OK","success":true,"payload":{}}';
}
else
{
	echo '{"errorCode":1,"errorDescription":"ERROR","success":false,"payload":{}}';
}
?>