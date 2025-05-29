<?php
include_once("dbconnect.php"); // make sure this connects to your DB

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['worker_id'];
    $full_name = $_POST['full_name'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $address = $_POST['address'];

    $sql = "UPDATE `tbl_workers` SET `full_name` = ?, `email` = ?, `phone` = ?, `address` = ? WHERE worker_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssi", $full_name, $email, $phone, $address, $id);

    if ($stmt->execute()) {
        $response = array("status" => "success", "message" => "Update successful");
    } else {
        $response = array("status" => "failed", "message" => "Update failed");
    }

    echo json_encode($response);
} else {
    echo json_encode(array("status" => "failed", "message" => "Invalid request method"));
}
?>
