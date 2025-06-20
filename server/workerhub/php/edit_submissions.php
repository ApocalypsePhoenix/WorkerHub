<?php
include_once("dbconnect.php");

$submission_id = $_POST['submission_id'] ?? '';
$submission_text = $_POST['submission_text'] ?? '';

if (empty($submission_id) || empty($submission_text)) {
    echo json_encode(["status" => "failed", "message" => "Missing data"]);
    exit();
}

$sql = "UPDATE tbl_submissions 
        SET submission_text = ?, submitted_at = CURRENT_TIMESTAMP 
        WHERE submission_id = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $submission_text, $submission_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Submission updated"]);
} else {
    echo json_encode(["status" => "failed", "message" => "Failed to update"]);
}

$stmt->close();
$conn->close();
?>
