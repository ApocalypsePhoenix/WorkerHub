<?php
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'];
if (!$worker_id) {
    echo json_encode([]);
    exit();
}

$sql = "SELECT 
            s.submission_id,
            s.work_id,
            w.title,
            s.submission_text,
            s.submitted_at
        FROM tbl_submissions s
        JOIN tbl_works w ON s.work_id = w.work_id
        WHERE s.worker_id = ?
        ORDER BY s.submitted_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$submissions = array();
while ($row = $result->fetch_assoc()) {
    $submissions[] = $row;
}

echo json_encode($submissions);
$stmt->close();
$conn->close();
?>
