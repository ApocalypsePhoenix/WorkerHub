<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *"); // running as chrome app

if (!isset($_POST)) {   //check if request method is POST
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php"); //include database connection file

$email = $_POST['email'];  //retrieve email and password from POST request
$password = sha1($_POST['password']); //sha for hashing

$sqllogin = "SELECT * FROM `tbl_workers` WHERE `email` = '$email' AND `password` = '$password'";

$result = $conn->query($sqllogin);  //sql query to validate login
if ($result->num_rows > 0) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;  //collect each user row into array
    }
    $response = array('status' => 'success', 'data' =>  $sentArray);
    sendJsonResponse($response);
}else{
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}	


function sendJsonResponse($sentArray)  //function to return Json response
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>