# WorkerHub : Phase 3

ISAC RUSSELL PAULBERT 297454

Final Project:
Extend the existing WTMS app to include submission history viewing, task submission editing, and profile updating features for the logged-in worker. Improve app usability with a refined tab/slide navigation.

**WorkerHub** is a Flutter-based mobile application designed to streamline task management between workers and administrators. It enables workers to register, view assigned tasks, submit work (with image uploads), and track their progress, while administrators can monitor and manage submissions efficiently. This is Phase 3 of the project, which includes image handling, profile features, and progress tracking.

---

## 🌟 Features

- 🔐 **User Authentication**: Secure login and registration with profile image support.
- 👤 **Profile Management**: View and update personal details with image upload.
- 📋 **Task List**: View assigned tasks with real-time filtering.
- ✅ **Submission System**: Submit task work with optional image attachments.
- 🕓 **Edit Submissions**: Update previously submitted work.
- 📊 **Progress Tracker**: View task completion progress in MainScreen.
- 📂 **Submission History**: Review completed and ongoing submissions.
- 🧾 **About Page**: View app version and developer credits.

---

## 🧰 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: PHP (REST API)
- **Database**: MySQL (via `dbconnect.php`)
- **Image Handling**: Base64 encoding with image upload to server directories

---

## 🚀 Getting Started
```text
📱 Flutter App & 🖥️ Backend Setup (Localhost using XAMPP or similar)

1. Clone the repository:
   git clone https://github.com/ApocalypsePhoenix/WorkerHub.git
   cd WorkerHub
   git checkout Phase3

2. Install Flutter dependencies:
   flutter pub get

3. Run the app:
   flutter run

4. Set up the backend:
   - Place all PHP files inside your XAMPP server root directory:
     htdocs/WorkerHub/php/

   - Create folders for storing uploaded images:
     htdocs/WorkerHub/assets/images/profiles/
     htdocs/WorkerHub/assets/images/submissions/

   - Create a MySQL database and import your schema (refer to dbconnect.php for DB name and credentials).

5. Update your Flutter app's base URL (usually in user.dart or a config file):
   const String baseUrl = "http://192.168.0.X/WorkerHub/api/";

   Replace 192.168.0.X with your machine’s local IP address.
   Make sure your test device (emulator or phone) is connected to the same network.
```


