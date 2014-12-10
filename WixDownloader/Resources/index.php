
<?php
if(isset($_GET['_escaped_fragment_']))
{
        $htm = file_get_contents("./seo/". $_GET['_escaped_fragment_']. ".html");
        echo ($htm);
}
else
{
    include ("./index.html");
}
?>