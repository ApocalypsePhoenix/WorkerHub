<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'] ?? '';

if (empty($worker_id)) {
    echo json_encode(['status' => 'failed', 'message' => 'worker_id missing']);
    exit();
}

$sql = "SELECT worker_id, full_name, email, phone, address FROM tbl_workers WHERE worker_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    $imagePath = "workerhub/assets/images/profiles/$worker_id.png";
    if (file_exists("../assets/images/profiles/$worker_id.png")) {
        $row['image'] = $imagePath;
    } else {
        $row['image'] = ""; // default will be used in frontend
    }

    echo json_encode(['status' => 'success', 'data' => $row]);
} else {
    echo json_encode(['status' => 'failed', 'message' => 'User not found']);
}

$stmt->close();
$conn->close();
?>
