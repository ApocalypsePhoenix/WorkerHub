<?php
include_once("dbconnect.php");

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $worker_id = $_POST['worker_id'];
        $full_name = $_POST['full_name'];
        $email = $_POST['email'];
        $phone = $_POST['phone'];
        $address = $_POST['address'];
        $image = isset($_POST['image']) ? $_POST['image'] : null;

        if ($image) {
            // Decode base64 image
            $decoded_image = base64_decode($image);
            
            // Ensure folder exists
            $folder_path = "../assets/images/profiles/";
            if (!is_dir($folder_path)) {
                mkdir($folder_path, 0755, true);
            }

            // Set image file path (relative to your project root)
            $image_path = "assets/images/profiles/" . $worker_id . ".png";
            $full_save_path = "../" . $image_path;

            // Save the image file
            file_put_contents($full_save_path, $decoded_image);

            // Update with image path
            $sql = "UPDATE tbl_users SET full_name = ?, email = ?, phone = ?, address = ?, image = ? WHERE worker_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sssssi", $full_name, $email, $phone, $address, $image_path, $worker_id);
        } else {
            // Update without image
            $sql = "UPDATE tbl_users SET full_name = ?, email = ?, phone = ?, address = ? WHERE worker_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ssssi", $full_name, $email, $phone, $address, $worker_id);
        }

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Update successful"]);
        } else {
            echo json_encode(["status" => "failed", "message" => "Update failed"]);
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "failed", "message" => "Invalid request method"]);
    }
} catch (Exception $e) {
    echo json_encode(["status" => "failed", "message" => $e->getMessage()]);
}
$conn->close();
?>
