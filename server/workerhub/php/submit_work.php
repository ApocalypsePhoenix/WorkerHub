<?php
include_once("dbconnect.php");

$work_id = $_POST['work_id'];
$worker_id = $_POST['worker_id'];
$submission_text = $_POST['submission_text'];
$image_base64 = $_POST['image'] ?? "";
$filename = $_POST['filename'] ?? "";

if (!$work_id || !$worker_id || !$submission_text) {
    echo json_encode(["status" => "failed", "message" => "Missing fields"]);
    exit();
}

// Insert submission into DB
$sql_insert = "INSERT INTO tbl_submissions (work_id, worker_id, submission_text) VALUES (?, ?, ?)";
$stmt_insert = $conn->prepare($sql_insert);
$stmt_insert->bind_param("iis", $work_id, $worker_id, $submission_text);

if ($stmt_insert->execute()) {
    // Update work status
    $sql_update = "UPDATE tbl_works SET status = 'success' WHERE work_id = ? AND assigned_to = ?";
    $stmt_update = $conn->prepare($sql_update);
    $stmt_update->bind_param("ii", $work_id, $worker_id);
    $stmt_update->execute();

    // Save image if provided
    if (!empty($image_base64) && !empty($filename)) {
        $folder = "../assets/images/submissions/";
        if (!is_dir($folder)) {
            mkdir($folder, 0755, true);
        }
        $image_data = base64_decode($image_base64);
        file_put_contents($folder . $filename, $image_data);
    }

    echo json_encode(["status" => "success", "message" => "Submission successful"]);
} else {
    echo json_encode(["status" => "failed", "message" => "Submission failed"]);
}

$stmt_insert->close();
$conn->close();
?>
