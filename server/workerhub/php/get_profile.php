<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include_once("dbconnect.php");

$worker_id = isset($_POST['worker_id']) ? $_POST['worker_id'] : '';

if (empty($worker_id)) {
    echo json_encode(['status' => 'failed', 'message' => 'worker_id missing']);
    exit();
}

$sql = "SELECT worker_id, full_name, email, phone, address, image FROM tbl_workers WHERE worker_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    // Return image path if available, otherwise return empty string
    $row['image'] = !empty($row['image']) ? $row['image'] : "";

    echo json_encode(['status' => 'success', 'data' => $row]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'User not found']);
}

$stmt->close();
$conn->close();
?>
