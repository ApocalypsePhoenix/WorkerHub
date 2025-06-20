<?php
include_once("dbconnect.php");

$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$password = sha1($_POST['password'] ?? '');
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';
$image = $_POST['image'] ?? '';

if (empty($name) || empty($email) || empty($password) || empty($phone) || empty($address)) {
    echo json_encode(["status" => "failed", "message" => "Missing fields"]);
    exit();
}

$sql = "INSERT INTO tbl_workers (full_name, email, password, phone, address) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $name, $email, $password, $phone, $address);

if ($stmt->execute()) {
    $worker_id = $conn->insert_id;
    $imagePath = "";

    if (!empty($image)) {
        $folder = "../assets/images/profiles/";
        if (!is_dir($folder)) mkdir($folder, 0755, true);

        $filename = "$worker_id.png";
        $imagePath = "assets/images/profiles/$filename";
        file_put_contents($folder . $filename, base64_decode($image));

        $update = $conn->prepare("UPDATE tbl_workers SET image = ? WHERE worker_id = ?");
        $update->bind_param("si", $imagePath, $worker_id);
        $update->execute();
        $update->close();
    }

    echo json_encode(["status" => "success", "message" => "Registration successful"]);
} else {
    echo json_encode(["status" => "failed", "message" => "Email exists or error"]);
}

$stmt->close();
$conn->close();
?>
