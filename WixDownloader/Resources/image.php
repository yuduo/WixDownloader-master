<?php
    require_once('DynamicImageResizer.php');
    
    if (isset ($GET['size']))
    {
    	$dynamic_size = explode('_', $GET['size']);
    	$resizer = new DynamicImageResizer('./media/', 'file='. pathinfo($_SERVER["SCRIPT_NAME"], PATHINFO_FILENAME) .'&ext='. pathinfo($_SERVER["SCRIPT_NAME"], PATHINFO_EXTENSION) .'&size='. $dynamic_size[2] .'x'. $dynamic_size[3]);
    	$resizer->output();
    }
 ?>