<?php
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'] ?? '';

if (empty($worker_id)) {
    echo json_encode(["status" => "failed", "message" => "Missing worker_id"]);
    exit();
}

$sql = "SELECT 
            COUNT(*) AS total,
            SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS completed 
        FROM tbl_works 
        WHERE assigned_to = ?";
        
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();

echo json_encode([
    "status" => "success",
    "total" => (int)$data['total'],
    "completed" => (int)$data['completed']
]);

$stmt->close();
$conn->close();
?>
