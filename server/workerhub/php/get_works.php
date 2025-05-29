<?php
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'];
if (!$worker_id) {
    echo json_encode([]);
    exit();
}

$sql = "SELECT * FROM tbl_works WHERE assigned_to = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$tasks = array();
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode($tasks);
$stmt->close();
$conn->close();
?>