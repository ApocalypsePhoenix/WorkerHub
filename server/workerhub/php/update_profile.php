<?php
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'] ?? '';
$full_name = $_POST['full_name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';
$image = $_POST['image'] ?? '';

if (empty($worker_id) || empty($full_name) || empty($email) || empty($phone) || empty($address)) {
    echo json_encode(["status" => "failed", "message" => "Missing fields"]);
    exit();
}

// Update profile
$sql = "UPDATE tbl_workers SET full_name = ?, email = ?, phone = ?, address = ? WHERE worker_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssi", $full_name, $email, $phone, $address, $worker_id);

if ($stmt->execute()) {
    // Handle image if provided
    if (!empty($image)) {
        $folder = "../assets/images/profiles/";
        if (!is_dir($folder)) {
            mkdir($folder, 0755, true);
        }
        $filename = $worker_id . ".png";
        $imageData = base64_decode($image);
        file_put_contents($folder . $filename, $imageData);
    }

    echo json_encode(["status" => "success", "message" => "Profile updated"]);
} else {
    echo json_encode(["status" => "failed", "message" => "Update failed"]);
}

$stmt->close();
$conn->close();
?>
