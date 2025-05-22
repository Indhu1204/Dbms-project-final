# Dbms-project-final
<?php
session_start();
require 'db.php'; // Your DB connection file

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

if (isset($_GET['animal_id'])) {
    $animal_id = intval($_GET['animal_id']);
    $user_id = $_SESSION['user_id'];

    // Check if this favorite already exists
    $check_sql = "SELECT id FROM favorites WHERE user_id = ? AND animal_id = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ii", $user_id, $animal_id);
    $check_stmt->execute();
    $check_stmt->store_result();

    if ($check_stmt->num_rows === 0) {
        // Add to favorites
        $insert_sql = "INSERT INTO favorites (user_id, animal_id, created_at) VALUES (?, ?, NOW())";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bind_param("ii", $user_id, $animal_id);
        $insert_stmt->execute();
    }

    // Redirect to favorites page
    header("Location: favorites.php");
    exit();
} else {
    echo "Invalid request. No animal selected.";
}
?>

<?php
session_start();

// Database connection
$host = 'localhost';
$dbname = 'paws';
$username = 'root'; // Change as per your database configuration
$password = '2424'; // Change as per your database configuration

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

// Initialize variables
$error = '';

// Handle login form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $admin_username = trim($_POST['username']);
    $admin_password = trim($_POST['password']);
    
    if (empty($admin_username) || empty($admin_password)) {
        $error = 'Please fill in all fields.';
    } else {
        // Check admin credentials
        $stmt = $pdo->prepare("SELECT id, name, username, password FROM admins WHERE username = ?");
        $stmt->execute([$admin_username]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($admin) {
            // Check if password is hashed or plain text
            if (password_verify($admin_password, $admin['password'])) {
                // Password is hashed and verified
                $login_success = true;
            } elseif ($admin_password === $admin['password']) {
                // Password is stored as plain text (not recommended for production)
                $login_success = true;
            } else {
                $login_success = false;
            }
            
            if ($login_success) {
                // Login successful
                $_SESSION['admin_id'] = $admin['id'];
                $_SESSION['admin_name'] = $admin['name'];
                $_SESSION['admin_username'] = $admin['username'];
                
                header('Location: admin_portal.php');
                exit();
            } else {
                $error = 'Invalid username or password.';
            }
        } else {
            $error = 'Invalid username or password.';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - PAWS</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .login-container {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .logo h1 {
            color: #333;
            font-size: 2rem;
            font-weight: bold;
        }
        
        .logo p {
            color: #666;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #333;
            font-weight: 500;
        }
        
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }
        
        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .login-btn {
            width: 100%;
            padding: 0.75rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s ease;
        }
        
        .login-btn:hover {
            transform: translateY(-2px);
        }
        
        .error {
            background: #ffebee;
            color: #c62828;
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            text-align: center;
            border: 1px solid #ffcdd2;
        }
        
        .back-link {
            text-align: center;
            margin-top: 1.5rem;
        }
        
        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .back-link a:hover {
            text-decoration: underline;
        }
        
        .debug-info {
            background: #f5f5f5;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <h1>🐾 PAWS Admin</h1>
            <p>Animal Shelter Management System</p>
        </div>
        
        
        
        <?php if ($error): ?>
            <div class="error"><?php echo htmlspecialchars($error); ?></div>
        <?php endif; ?>
        
        <form method="POST" action="">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" 
                       value="<?php echo isset($_POST['username']) ? htmlspecialchars($_POST['username']) : ''; ?>" 
                       required>
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <button type="submit" class="login-btn">Login to Admin Portal</button>
        </form>
        
        <div class="back-link">
            <a href="home.php">← Back to Main Site</a>
        </div>
    </div>
</body>
</html>
<?php
session_start();

// Check if admin is logged in
if (!isset($_SESSION['admin_id'])) {
    header('Location: admin_login.php');
    exit();
}

// Database connection
$servername = "localhost";
$username = "root";
$password = "2424";
$dbname = "paws";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['action'])) {
        switch ($_POST['action']) {
            case 'approve_request':
                $request_id = $_POST['request_id'];
                $animal_id = $_POST['animal_id'];
                $stmt = $pdo->prepare("UPDATE adoption_requests SET status = 'approved', processed_by = ?, processed_date = NOW() WHERE id = ?");
                $stmt->execute([$_SESSION['admin_id'], $request_id]);
                
                // Update animal status to adopted
                $stmt = $pdo->prepare("UPDATE animals SET status = 'adopted' WHERE id = ?");
                $stmt->execute([$animal_id]);
                
                echo "<script>alert('Request approved successfully!');</script>";
                break;
                
            case 'reject_request':
                $request_id = $_POST['request_id'];
                $stmt = $pdo->prepare("UPDATE adoption_requests SET status = 'rejected', processed_by = ?, processed_date = NOW() WHERE id = ?");
                $stmt->execute([$_SESSION['admin_id'], $request_id]);
                echo "<script>alert('Request rejected successfully!');</script>";
                break;
                
            case 'update_animal':
                $animal_id = $_POST['animal_id'];
                $name = $_POST['name'];
                $status = $_POST['status'];
                $description = $_POST['description'];
                
                $stmt = $pdo->prepare("UPDATE animals SET name = ?, status = ?, description = ? WHERE id = ?");
                $stmt->execute([$name, $status, $description, $animal_id]);
                echo "<script>alert('Animal updated successfully!');</script>";
                break;
                
            case 'update_cancellation_status':
                $cancellation_id = $_POST['cancellation_id'];
                $status = $_POST['status'];
                
                try {
                    // First, let's check the current structure of the cancellations table
                    $stmt = $pdo->prepare("SHOW COLUMNS FROM cancellations LIKE 'status'");
                    $stmt->execute();
                    $statusColumn = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if (!$statusColumn) {
                        // Status column doesn't exist, create it
                        $pdo->exec("ALTER TABLE cancellations ADD COLUMN status ENUM('pending', 'approved', 'rejected', 'processed') DEFAULT 'pending'");
                        echo "<script>alert('Status column created successfully!');</script>";
                    } else {
                        // Check the ENUM values in the existing status column
                        $type = $statusColumn['Type'];
                        preg_match("/enum\((.+)\)/i", $type, $matches);
                        if (isset($matches[1])) {
                            $enumValues = str_getcsv($matches[1], ',', "'");
                            
                            // If the current status value is not in the ENUM, we need to update the column
                            if (!in_array($status, $enumValues)) {
                                // Get current enum values and add our missing ones
                                $newEnumValues = array_unique(array_merge($enumValues, ['pending', 'approved', 'rejected', 'processed']));
                                $enumString = "'" . implode("','", $newEnumValues) . "'";
                                
                                $alterQuery = "ALTER TABLE cancellations MODIFY COLUMN status ENUM($enumString) DEFAULT 'pending'";
                                $pdo->exec($alterQuery);
                                echo "<script>alert('Status column updated with new values!');</script>";
                            }
                        }
                    }
                    
                    // Validate the status value before updating
                    $valid_statuses = ['pending', 'approved', 'rejected', 'processed'];
                    if (!in_array($status, $valid_statuses)) {
                        throw new Exception("Invalid status value: " . $status);
                    }
                    
                    // Now update the status
                    $stmt = $pdo->prepare("UPDATE cancellations SET status = ? WHERE id = ?");
                    $stmt->execute([$status, $cancellation_id]);
                    echo "<script>alert('Cancellation status updated successfully!');</script>";
                } catch (Exception $e) {
                    echo "<script>alert('Error updating cancellation status: " . addslashes($e->getMessage()) . "');</script>";
                }
                break;
        }
    }
}

// Fetch data for display with error handling
try {
    $pending_requests = $pdo->query("
        SELECT ar.*, u.first_name, u.last_name, u.email, a.name as animal_name 
        FROM adoption_requests ar 
        JOIN users u ON ar.user_id = u.id 
        JOIN animals a ON ar.animal_id = a.id 
        WHERE ar.status = 'pending'
        ORDER BY ar.request_date DESC
    ")->fetchAll(PDO::FETCH_ASSOC);

    $all_requests = $pdo->query("
        SELECT ar.*, u.first_name, u.last_name, u.email, a.name as animal_name 
        FROM adoption_requests ar 
        JOIN users u ON ar.user_id = u.id 
        JOIN animals a ON ar.animal_id = a.id 
        ORDER BY ar.request_date DESC
    ")->fetchAll(PDO::FETCH_ASSOC);

    $animals = $pdo->query("SELECT * FROM animals ORDER BY name")->fetchAll(PDO::FETCH_ASSOC);

    // Modified cancellations query to handle cases where status column might not exist
    try {
        $cancellations = $pdo->query("
            SELECT c.*, u.first_name, u.last_name, u.email, a.name as animal_name 
            FROM cancellations c 
            JOIN users u ON c.user_id = u.id 
            JOIN animals a ON c.animal_id = a.id 
            ORDER BY c.cancelled_date DESC
        ")->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        // If there's an error (possibly due to missing status column), try without status
        $cancellations = $pdo->query("
            SELECT c.*, u.first_name, u.last_name, u.email, a.name as animal_name 
            FROM cancellations c 
            JOIN users u ON c.user_id = u.id 
            JOIN animals a ON c.animal_id = a.id 
            ORDER BY c.cancelled_date DESC
        ")->fetchAll(PDO::FETCH_ASSOC);
        
        // Add default status to each row if it doesn't exist
        foreach ($cancellations as &$cancellation) {
            if (!isset($cancellation['status'])) {
                $cancellation['status'] = 'pending';
            }
        }
    }
} catch (PDOException $e) {
    echo "<script>alert('Database error: " . addslashes($e->getMessage()) . "');</script>";
    // Initialize with empty arrays if queries fail
    $pending_requests = [];
    $all_requests = [];
    $animals = [];
    $cancellations = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Portal - PAWS</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f4f4f4;
        }
        
        .header {
            background: #2c3e50;
            color: white;
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }
        
        .nav {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
        }
        
        .nav h1 {
            font-size: 2rem;
        }
        
        .nav-links {
            display: flex;
            gap: 20px;
        }
        
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 10px 15px;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav-links a:hover {
            background: #34495e;
        }
        
        .container {
            max-width: 1200px;
            margin: 80px auto 20px;
            padding: 20px;
        }
        
        .tab-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .tab-buttons {
            display: flex;
            border-bottom: 1px solid #ddd;
        }
        
        .tab-button {
            padding: 15px 25px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 16px;
            color: #666;
            transition: all 0.3s;
        }
        
        .tab-button.active {
            background: #3498db;
            color: white;
        }
        
        .tab-content {
            display: none;
            padding: 20px;
        }
        
        .tab-content.active {
            display: block;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        
        tr:hover {
            background-color: #f5f5f5;
        }
        
        .btn {
            padding: 8px 16px;
            margin: 2px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .btn-approve {
            background: #27ae60;
            color: white;
        }
        
        .btn-reject {
            background: #e74c3c;
            color: white;
        }
        
        .btn-edit {
            background: #3498db;
            color: white;
        }
        
        .btn:hover {
            opacity: 0.8;
            transform: translateY(-2px);
        }
        
        .status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-pending {
            background: #f39c12;
            color: white;
        }
        
        .status-approved {
            background: #27ae60;
            color: white;
        }
        
        .status-rejected {
            background: #e74c3c;
            color: white;
        }
        
        .status-processed {
            background: #8e44ad;
            color: white;
        }
        
        .status-available {
            background: #2ecc71;
            color: white;
        }
        
        .status-adopted {
            background: #9b59b6;
            color: white;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border-radius: 10px;
            width: 80%;
            max-width: 500px;
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close:hover {
            color: black;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <header class="header">
        <nav class="nav">
            <h1>PAWS Admin Portal</h1>
            <div class="nav-links">
                <span>Welcome, <?php echo isset($_SESSION['admin_name']) ? htmlspecialchars($_SESSION['admin_name']) : 'Admin'; ?></span>
                <a href="logout.php">Logout</a>
            </div>
        </nav>
    </header>

    <div class="container">
        <div class="tab-container">
            <div class="tab-buttons">
                <button class="tab-button active" onclick="openTab(event, 'pending-requests')">Pending Requests</button>
                <button class="tab-button" onclick="openTab(event, 'all-requests')">All Requests</button>
                <button class="tab-button" onclick="openTab(event, 'animals')">Animals</button>
                <button class="tab-button" onclick="openTab(event, 'cancellations')">Cancellations</button>
            </div>

            <!-- Pending Requests Tab -->
            <div id="pending-requests" class="tab-content active">
                <h2>Pending Adoption Requests</h2>
                <?php if (empty($pending_requests)): ?>
                    <p>No pending requests found.</p>
                <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Email</th>
                            <th>Animal</th>
                            <th>Request Date</th>
                            <th>Notes</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($pending_requests as $request): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($request['id']); ?></td>
                            <td><?php echo htmlspecialchars($request['first_name'] . ' ' . $request['last_name']); ?></td>
                            <td><?php echo htmlspecialchars($request['email']); ?></td>
                            <td><?php echo htmlspecialchars($request['animal_name']); ?></td>
                            <td><?php echo date('Y-m-d H:i', strtotime($request['request_date'])); ?></td>
                            <td><?php echo htmlspecialchars($request['notes'] ?: 'None'); ?></td>
                            <td>
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="action" value="approve_request">
                                    <input type="hidden" name="request_id" value="<?php echo $request['id']; ?>">
                                    <input type="hidden" name="animal_id" value="<?php echo $request['animal_id']; ?>">
                                    <button type="submit" class="btn btn-approve" onclick="return confirm('Approve this request?')">Approve</button>
                                </form>
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="action" value="reject_request">
                                    <input type="hidden" name="request_id" value="<?php echo $request['id']; ?>">
                                    <button type="submit" class="btn btn-reject" onclick="return confirm('Reject this request?')">Reject</button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php endif; ?>
            </div>

            <!-- All Requests Tab -->
            <div id="all-requests" class="tab-content">
                <h2>All Adoption Requests</h2>
                <?php if (empty($all_requests)): ?>
                    <p>No requests found.</p>
                <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Animal</th>
                            <th>Request Date</th>
                            <th>Status</th>
                            <th>Processed Date</th>
                            <th>Notes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($all_requests as $request): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($request['id']); ?></td>
                            <td><?php echo htmlspecialchars($request['first_name'] . ' ' . $request['last_name']); ?></td>
                            <td><?php echo htmlspecialchars($request['animal_name']); ?></td>
                            <td><?php echo date('Y-m-d H:i', strtotime($request['request_date'])); ?></td>
                            <td>
                                <span class="status status-<?php echo $request['status']; ?>">
                                    <?php echo ucfirst($request['status']); ?>
                                </span>
                            </td>
                            <td><?php echo $request['processed_date'] ? date('Y-m-d H:i', strtotime($request['processed_date'])) : 'N/A'; ?></td>
                            <td><?php echo htmlspecialchars($request['notes'] ?: 'None'); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php endif; ?>
            </div>

            <!-- Animals Tab -->
            <div id="animals" class="tab-content">
                <h2>Animals Management</h2>
                <?php if (empty($animals)): ?>
                    <p>No animals found.</p>
                <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Breed</th>
                            <th>Age Group</th>
                            <th>Size</th>
                            <th>Gender</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($animals as $animal): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($animal['id']); ?></td>
                            <td><?php echo htmlspecialchars($animal['name']); ?></td>
                            <td><?php echo ucfirst(htmlspecialchars($animal['animal_type'])); ?></td>
                            <td><?php echo htmlspecialchars($animal['breed']); ?></td>
                            <td><?php echo ucfirst(htmlspecialchars($animal['age_group'])); ?></td>
                            <td><?php echo ucfirst(htmlspecialchars($animal['size'])); ?></td>
                            <td><?php echo ucfirst(htmlspecialchars($animal['gender'])); ?></td>
                            <td>
                                <span class="status status-<?php echo $animal['status']; ?>">
                                    <?php echo ucfirst($animal['status']); ?>
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-edit" onclick="editAnimal(<?php echo htmlspecialchars(json_encode($animal)); ?>)">Edit</button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php endif; ?>
            </div>

            <!-- Cancellations Tab -->
            <div id="cancellations" class="tab-content">
                <h2>Cancellations Management</h2>
                <?php if (empty($cancellations)): ?>
                    <p>No cancellations found.</p>
                <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Animal</th>
                            <th>Cancelled Date</th>
                            <th>Reason</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cancellations as $cancellation): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($cancellation['id']); ?></td>
                            <td><?php echo htmlspecialchars($cancellation['first_name'] . ' ' . $cancellation['last_name']); ?></td>
                            <td><?php echo htmlspecialchars($cancellation['animal_name']); ?></td>
                            <td><?php echo date('Y-m-d H:i', strtotime($cancellation['cancelled_date'])); ?></td>
                            <td><?php echo $cancellation['reason'] ? ucfirst(str_replace('_', ' ', htmlspecialchars($cancellation['reason']))) : 'N/A'; ?></td>
                            <td>
                                <?php $status = $cancellation['status'] ?? 'pending'; ?>
                                <span class="status status-<?php echo $status; ?>">
                                    <?php echo ucfirst($status); ?>
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-edit" onclick="editCancellation(<?php echo $cancellation['id']; ?>, '<?php echo $status; ?>')">Update Status</button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Edit Animal Modal -->
    <div id="animalModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h3>Edit Animal</h3>
            <form method="POST">
                <input type="hidden" name="action" value="update_animal">
                <input type="hidden" name="animal_id" id="edit_animal_id">
                
                <div class="form-group">
                    <label for="edit_name">Name:</label>
                    <input type="text" name="name" id="edit_name" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_status">Status:</label>
                    <select name="status" id="edit_status" required>
                        <option value="available">Available</option>
                        <option value="pending">Pending</option>
                        <option value="adopted">Adopted</option>
                        <option value="fostered">Fostered</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="edit_description">Description:</label>
                    <textarea name="description" id="edit_description"></textarea>
                </div>
                
                <button type="submit" class="btn btn-approve">Update Animal</button>
            </form>
        </div>
    </div>

    <!-- Edit Cancellation Modal -->
    <div id="cancellationModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h3>Update Cancellation Status</h3>
            <form method="POST">
                <input type="hidden" name="action" value="update_cancellation_status">
                <input type="hidden" name="cancellation_id" id="edit_cancellation_id">
                
                <div class="form-group">
                    <label for="edit_cancellation_status">Status:</label>
                    <select name="status" id="edit_cancellation_status" required>
                        <option value="pending">Pending</option>
                        <option value="approved">Approved</option>
                        <option value="rejected">Rejected</option>
                        <option value="processed">Processed</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-approve">Update Status</button>
            </form>
        </div>
    </div>

    <script>
        function openTab(evt, tabName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].classList.remove("active");
            }
            tablinks = document.getElementsByClassName("tab-button");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].classList.remove("active");
            }
            document.getElementById(tabName).classList.add("active");
            evt.currentTarget.classList.add("active");
        }

        function editAnimal(animal) {
            document.getElementById('edit_animal_id').value = animal.id;
            document.getElementById('edit_name').value = animal.name;
            document.getElementById('edit_status').value = animal.status;
            document.getElementById('edit_description').value = animal.description || '';
            document.getElementById('animalModal').style.display = 'block';
        }

        function editCancellation(id, status) {
            document.getElementById('edit_cancellation_id').value = id;
            document.getElementById('edit_cancellation_status').value = status || 'pending';
            document.getElementById('cancellationModal').style.display = 'block';
        }

        // Modal close functionality
        var modals = document.getElementsByClassName('modal');
        var closes = document.getElementsByClassName('close');

        for (let i = 0; i < closes.length; i++) {
            closes[i].onclick = function() {
                modals[i].style.display = 'none';
            }
        }

        window.onclick = function(event) {
            for (let i = 0; i < modals.length; i++) {
                if (event.target == modals[i]) {
                    modals[i].style.display = 'none';
                }
            }
        }
    </script>
</body>
</html>
<?php
// At the top of animal_details.php, add this code to get the animal ID from URL
// and fetch animal data from database
session_start();
require 'db.php';

// Get animal ID from URL
$animal_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Fetch animal details from database
if ($animal_id > 0) {
    $sql = "SELECT * FROM animals WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $animal_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $animal = $result->fetch_assoc();
    
    // If animal not found, redirect to animals page
    if (!$animal) {
        header("Location: animals.php");
        exit();
    }
} else {
    header("Location: animals.php");
    exit();
}

// Now you have $animal with all data from the database
// You can use $animal['id'], $animal['name'], etc. throughout your page
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buddy - Paws & Hearts</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
    /* Reset & Base Styles */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        background-color: #f8f9fa;
        color: #333;
    }
    a {
        text-decoration: none;
        color: #007bff;
    }
    ul {
        list-style: none;
    }

    /* Header */
    header {
        background: #fff;
        border-bottom: 1px solid #ddd;
        padding: 10px 0;
    }
    nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
        max-width: 1200px;
        margin: auto;
        padding: 0 20px;
    }
    .logo h1 {
        font-size: 24px;
        color: #ff6b6b;
    }
    .nav-links {
        display: flex;
        gap: 20px;
        align-items: center;
    }
    .nav-links a.btn {
        padding: 6px 14px;
        background-color: #ff6b6b;
        color: #fff;
        border-radius: 4px;
    }

    /* Animal Detail */
    .animal-detail {
        padding: 40px 20px;
    }
    .container {
        max-width: 1200px;
        margin: auto;
    }
    .breadcrumbs {
        margin-bottom: 20px;
        font-size: 14px;
    }
    .animal-detail-container {
        display: flex;
        flex-wrap: wrap;
        gap: 40px;
    }

    .animal-gallery {
        flex: 1;
        min-width: 300px;
    }
    .main-image img {
        width: 100%;
        border-radius: 8px;
    }
    .thumbnail-images {
        margin-top: 10px;
        display: flex;
        gap: 10px;
    }
    .thumbnail {
        width: 60px;
        height: 60px;
        object-fit: cover;
        border-radius: 4px;
        cursor: pointer;
        border: 2px solid transparent;
    }
    .thumbnail.active {
        border-color: #ff6b6b;
    }

    .animal-info {
        flex: 1;
        min-width: 300px;
    }
    .animal-info h1 {
        font-size: 32px;
        margin-bottom: 10px;
    }
    .animal-meta {
        margin-bottom: 20px;
    }
    .animal-id {
        display: inline-block;
        margin-right: 20px;
        font-weight: bold;
    }
    .animal-status {
        padding: 4px 10px;
        border-radius: 4px;
        background: #28a745;
        color: #fff;
        font-size: 14px;
    }

    .animal-details .detail-row {
        display: flex;
        margin-bottom: 10px;
    }
    .detail-label {
        width: 100px;
        font-weight: bold;
    }

    .animal-description {
        margin-top: 20px;
    }
    .animal-actions {
        margin-top: 20px;
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    .btn {
        padding: 10px 16px;
        border: none;
        cursor: pointer;
        border-radius: 4px;
        font-weight: bold;
    }
    .btn-primary {
        background: #ff6b6b;
        color: white;
    }
    .btn-secondary {
        background: #6c757d;
        color: white;
    }
    .btn-outline {
        background: transparent;
        border: 2px solid #6c757d;
        color: #6c757d;
    }

    /* Tabs */
    .animal-tabs {
        margin-top: 40px;
    }
    .tab-nav {
        display: flex;
        gap: 20px;
        border-bottom: 2px solid #ddd;
        margin-bottom: 20px;
    }
    .tab-nav li a {
        padding: 10px 0;
        display: inline-block;
        font-weight: bold;
        color: #333;
    }
    .tab-nav li.active a {
        border-bottom: 3px solid #ff6b6b;
        color: #ff6b6b;
    }
    .tab-content {
        display: none;
    }
    .tab-content.active {
        display: block;
    }

    /* Sections inside Tabs */
    .health-details,
    .behavior-details,
    .requirements-list {
        display: flex;
        flex-wrap: wrap;
        gap: 30px;
    }
    .health-status,
    .behavior-traits,
    .behavior-notes,
    .requirement {
        flex: 1;
        min-width: 250px;
    }
    .traits-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 10px;
    }
    .trait-rating i {
        color: #ff6b6b;
    }

    .adoption-process {
        margin-top: 20px;
    }

    /* Similar Animals */
    .similar-animals {
        margin-top: 60px;
    }
    .animals-grid.mini-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 20px;
    }

    /* Footer */
    footer {
        background: #333;
        color: #fff;
        text-align: center;
        padding: 20px 0;
        margin-top: 40px;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .animal-detail-container {
            flex-direction: column;
        }
        .tab-nav {
            flex-direction: column;
        }
    }
</style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="about.html">About</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="login.php" class="btn">Login</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="animal-detail">
        <div class="container">
            <div class="breadcrumbs">
                <a href="home.php">Home</a> / <a href="animals.php">Animals</a> / <span>Buddy</span>
            </div>
            
            <div class="animal-detail-container">
                <div class="animal-gallery">
                    <div class="main-image">
                        <img src="https://images.unsplash.com/photo-1561037404-61cd46aa615b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Buddy" id="mainImage">
                    </div>
                    <div class="thumbnail-images">
                        <img src="https://images.unsplash.com/photo-1561037404-61cd46aa615b?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="Buddy" class="thumbnail active">
                        <img src="https://images.unsplash.com/photo-1586671267731-da2cf3ceeb80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="Buddy playing" class="thumbnail">
                        <img src="https://images.unsplash.com/photo-1588943211346-0908a1fb0b01?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="Buddy sleeping" class="thumbnail">
                        <img src="https://images.unsplash.com/photo-1586671267731-da2cf3ceeb80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="Buddy with toy" class="thumbnail">
                    </div>
                </div>
                
                <div class="animal-info">
                    <h1>Buddy</h1>
                    <div class="animal-meta">
                        <span class="animal-id">ID: PAWS-2456</span>
                        <span class="animal-status available">Available</span>
                    </div>
                    
                    <div class="animal-details">
                        <div class="detail-row">
                            <span class="detail-label">Breed:</span>
                            <span class="detail-value">Golden Retriever</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Age:</span>
                            <span class="detail-value">2 years</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Gender:</span>
                            <span class="detail-value">Male</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Size:</span>
                            <span class="detail-value">Large</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Color:</span>
                            <span class="detail-value">Golden</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Location:</span>
                            <span class="detail-value">Main Shelter</span>
                        </div>
                    </div>
                    
                    <div class="animal-description">
                        <h3>About Buddy</h3>
                        <p>Buddy is a sweet and gentle Golden Retriever who loves everyone he meets. He was surrendered to our shelter when his previous owners could no longer care for him. Buddy is house-trained, knows basic commands, and walks well on a leash. He's great with kids and other dogs, and would make a wonderful addition to any active family.</p>
                        <p>Buddy enjoys long walks, playing fetch, and cuddling on the couch. He has a calm demeanor but also loves to play. He would do best in a home with a yard where he can run around, but he also adapts well to apartment living as long as he gets plenty of exercise.</p>
                    </div>
                    
                    <div class="animal-actions">
                        <a href="add_to_favorites.php?animal_id=<?php echo $animal_id; ?>" class="btn btn-primary"><i class="fas fa-heart"></i> Add to Favorites</a>
                        <button class="btn btn-secondary"><i class="fas fa-file-alt"></i> Apply to Adopt</button>
                        <button class="btn btn-outline"><i class="fas fa-share-alt"></i> Share</button>
                    </div>
                </div>
            </div>
            
            <div class="animal-tabs">
                <ul class="tab-nav">
                    <li class="active"><a href="#health" data-tab="health">Health Information</a></li>
                    <li><a href="#behavior" data-tab="behavior">Behavior & Training</a></li>
                    <li><a href="#history" data-tab="history">History</a></li>
                    <li><a href="#requirements" data-tab="requirements">Adoption Requirements</a></li>
                </ul>
                
                <div class="tab-content active" id="health">
                    <h3>Health Information</h3>
                    <div class="health-details">
                        <div class="health-status">
                            <h4>Vaccination Status</h4>
                            <ul>
                                <li><i class="fas fa-check-circle success"></i> Rabies</li>
                                <li><i class="fas fa-check-circle success"></i> Distemper</li>
                                <li><i class="fas fa-check-circle success"></i> Parvovirus</li>
                                <li><i class="fas fa-check-circle success"></i> Bordetella</li>
                            </ul>
                        </div>
                        <div class="health-status">
                            <h4>Medical Notes</h4>
                            <ul>
                                <li>Neutered</li>
                                <li>Microchipped</li>
                                <li>No known health issues</li>
                                <li>Current on flea/tick/heartworm prevention</li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <div class="tab-content" id="behavior">
                    <h3>Behavior & Training</h3>
                    <div class="behavior-details">
                        <div class="behavior-traits">
                            <h4>Personality Traits</h4>
                            <div class="traits-grid">
                                <div class="trait">
                                    <span class="trait-name">Energy Level</span>
                                    <div class="trait-rating">
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="far fa-circle"></i>
                                    </div>
                                </div>
                                <div class="trait">
                                    <span class="trait-name">Friendliness</span>
                                    <div class="trait-rating">
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                    </div>
                                </div>
                                <div class="trait">
                                    <span class="trait-name">Trainability</span>
                                    <div class="trait-rating">
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="far fa-circle"></i>
                                    </div>
                                </div>
                                <div class="trait">
                                    <span class="trait-name">Playfulness</span>
                                    <div class="trait-rating">
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                        <i class="fas fa-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="behavior-notes">
                            <h4>Training & Behavior Notes</h4>
                            <ul>
                                <li>Knows basic commands: Sit, Stay, Come</li>
                                <li>Walks well on leash</li>
                                <li>House-trained</li>
                                <li>Good with children of all ages</li>
                                <li>Gets along with other dogs</li>
                                <li>Not tested with cats</li>
                                <li>Mild separation anxiety - does best when left with a toy</li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <div class="tab-content" id="history">
                    <h3>History</h3>
                    <p>Buddy was surrendered to our shelter in March 2023 when his previous owners moved to an apartment that didn't allow pets. He lived with them since he was a puppy and was well cared for. Buddy has no known history of abuse or neglect.</p>
                    <p>Since arriving at our shelter, Buddy has been a favorite among staff and volunteers. He participates in our "Doggy Day Out" program where volunteers take shelter dogs on outings, and he always receives glowing reviews from his temporary hosts.</p>
                </div>
                
                <div class="tab-content" id="requirements">
                    <h3>Adoption Requirements</h3>
                    <div class="requirements-list">
                        <div class="requirement">
                            <i class="fas fa-home"></i>
                            <h4>Suitable Home</h4>
                            <p>Buddy would do best in a home with a yard, though apartment living is possible with sufficient exercise.</p>
                        </div>
                        <div class="requirement">
                            <i class="fas fa-clock"></i>
                            <h4>Time Commitment</h4>
                            <p>Buddy needs an owner who can provide daily exercise and attention. He shouldn't be left alone for extended periods.</p>
                        </div>
                        <div class="requirement">
                            <i class="fas fa-users"></i>
                            <h4>Family Situation</h4>
                            <p>Buddy is great with families, singles, or couples. He's gentle with children but may accidentally knock over very small kids.</p>
                        </div>
                        <div class="requirement">
                            <i class="fas fa-heart"></i>
                            <h4>Adoption Fee</h4>
                            <p>$250 which includes neuter, microchip, vaccinations, and a free vet check within 14 days of adoption.</p>
                        </div>
                    </div>
                    <div class="adoption-process">
                        <h4>Adoption Process</h4>
                        <ol>
                            <li>Submit an adoption application</li>
                            <li>Meet with an adoption counselor</li>
                            <li>Schedule a meet-and-greet with Buddy</li>
                            <li>Home visit (for renters, we'll need landlord approval)</li>
                            <li>Finalize adoption paperwork and pay fee</li>
                            <li>Take Buddy home!</li>
                        </ol>
                        <div class="text-center">
                            <button class="btn btn-primary btn-lg"><i class="fas fa-file-alt"></i> Begin Adoption Application</button>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="similar-animals">
                <h2>You Might Also Like</h2>
                <div class="animals-grid mini-grid">
                    <!-- Dynamically loaded from animals.js -->
                </div>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
    // JavaScript to handle tab functionality
    document.addEventListener('DOMContentLoaded', function() {
        // Tab functionality
        const tabLinks = document.querySelectorAll('.tab-nav a');
        tabLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Hide all tab contents
                const tabContents = document.querySelectorAll('.tab-content');
                tabContents.forEach(content => {
                    content.classList.remove('active');
                });
                
                // Remove active class from all tab links
                tabLinks.forEach(tabLink => {
                    tabLink.parentElement.classList.remove('active');
                });
                
                // Show the selected tab content
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
                
                // Add active class to the clicked tab link
                this.parentElement.classList.add('active');
            });
        });
        
        // Thumbnail image gallery
        const thumbnails = document.querySelectorAll('.thumbnail');
        const mainImage = document.getElementById('mainImage');
        
        thumbnails.forEach(thumbnail => {
            thumbnail.addEventListener('click', function() {
                // Update main image
                mainImage.src = this.src.replace('w=200', 'w=800');
                
                // Update active thumbnail
                thumbnails.forEach(thumb => {
                    thumb.classList.remove('active');
                });
                this.classList.add('active');
            });
        });
        
        // Load similar animals from JS
        loadSimilarAnimals();
    });
    
    function loadSimilarAnimals() {
        // Example similar animals (would normally be loaded from animals.js)
        const similarAnimals = [
            {
                id: 'PAWS-2457',
                name: 'Max',
                breed: 'Labrador Retriever',
                age: '3 years',
                image: 'https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'
            },
            {
                id: 'PAWS-2458',
                name: 'Lucy',
                breed: 'Golden Retriever',
                age: '1 year',
                image: 'https://images.unsplash.com/photo-1560807707-8cc77767d783?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'
            },
            {
                id: 'PAWS-2459',
                name: 'Charlie',
                breed: 'Beagle',
                age: '2 years',
                image: 'https://images.unsplash.com/photo-1505628346881-b72b27e84530?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'
            },
            {
                id: 'PAWS-2460',
                name: 'Bella',
                breed: 'Labrador Mix',
                age: '4 years',
                image: 'https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'
            }
        ];
        
        const grid = document.querySelector('.animals-grid.mini-grid');
        
        similarAnimals.forEach(animal => {
            const card = document.createElement('div');
            card.className = 'animal-card';
            card.innerHTML = `
                <a href="animal_details.php?id=${animal.id}">
                    <div class="card-image">
                        <img src="${animal.image}" alt="${animal.name}">
                    </div>
                    <div class="card-content">
                        <h3>${animal.name}</h3>
                        <p>${animal.breed}, ${animal.age}</p>
                    </div>
                </a>
            `;
            grid.appendChild(card);
        });
    }
    </script>
</body>
</html>
<?php
// Start session
session_start();

// Include database connection
require_once 'db.php';

// Check if user is logged in
$isLoggedIn = isset($_SESSION['user_id']);
$userId = $isLoggedIn ? $_SESSION['user_id'] : null;
$userType = $isLoggedIn ? $_SESSION['user_type'] : null;

// Initialize variables
$animals = [];
$filterType = isset($_GET['type']) ? $_GET['type'] : 'all';
$filterAge = isset($_GET['age']) ? $_GET['age'] : 'all';
$filterSize = isset($_GET['size']) ? $_GET['size'] : 'all';

// Prepare base query
$query = "SELECT * FROM animals WHERE 1=1";
$params = [];

// Add filters
if ($filterType != 'all') {
    $query .= " AND animal_type = ?";
    $params[] = $filterType;
}

if ($filterAge != 'all') {
    $query .= " AND age_group = ?";
    $params[] = $filterAge;
}

if ($filterSize != 'all') {
    $query .= " AND size = ?";
    $params[] = $filterSize;
}

// If user is logged in as a foster, show only their fostered pets
if ($isLoggedIn && $userType == 'foster') {
    $query .= " AND (foster_id = ? OR foster_id IS NULL)";
    $params[] = $userId;
}

// Prepare and execute statement
$stmt = $conn->prepare($query);

// Check if prepare was successful
if ($stmt === false) {
    die("Error preparing statement: " . $conn->error);
}

// Bind parameters dynamically
if (!empty($params)) {
    $types = str_repeat('s', count($params));
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

// Fetch all animals
while ($row = $result->fetch_assoc()) {
    $animals[] = $row;
}

// Get user's favorite animals if logged in
$favorites = [];
if ($isLoggedIn) {
    $favStmt = $conn->prepare("SELECT animal_id FROM favorites WHERE user_id = ?");
    if ($favStmt === false) {
        die("Error preparing favorites statement: " . $conn->error);
    }
    $favStmt->bind_param("i", $userId);
    $favStmt->execute();
    $favResult = $favStmt->get_result();
    
    while ($row = $favResult->fetch_assoc()) {
        $favorites[] = $row['animal_id'];
    }
    $favStmt->close();
}

// Process actions
if ($isLoggedIn && isset($_POST['action'])) {
    if ($_POST['action'] == 'favorite' && isset($_POST['animal_id'])) {
        $animalId = $_POST['animal_id'];
        
        // Check if already favorited
        $checkStmt = $conn->prepare("SELECT * FROM favorites WHERE user_id = ? AND animal_id = ?");
        if ($checkStmt === false) {
            die("Error preparing check favorites statement: " . $conn->error);
        }
        $checkStmt->bind_param("ii", $userId, $animalId);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();
        
        if ($checkResult->num_rows == 0) {
            // Add to favorites
            $addStmt = $conn->prepare("INSERT INTO favorites (user_id, animal_id) VALUES (?, ?)");
            if ($addStmt === false) {
                die("Error preparing add favorites statement: " . $conn->error);
            }
            $addStmt->bind_param("ii", $userId, $animalId);
            $addStmt->execute();
            $addStmt->close();
            
            // Add to favorites array for the current page view
            $favorites[] = $animalId;
        } else {
            // Remove from favorites
            $removeStmt = $conn->prepare("DELETE FROM favorites WHERE user_id = ? AND animal_id = ?");
            if ($removeStmt === false) {
                die("Error preparing remove favorites statement: " . $conn->error);
            }
            $removeStmt->bind_param("ii", $userId, $animalId);
            $removeStmt->execute();
            $removeStmt->close();
            
            // Remove from favorites array for the current page view
            $key = array_search($animalId, $favorites);
            if ($key !== false) {
                unset($favorites[$key]);
            }
        }
        
        $checkStmt->close();
        
        // Redirect to avoid form resubmission
        header("Location: animals.php" . ($_SERVER['QUERY_STRING'] ? '?'.$_SERVER['QUERY_STRING'] : ''));
        exit();
    }
    
    if ($userType == 'adopter' && $_POST['action'] == 'adopt' && isset($_POST['animal_id'])) {
        $animalId = $_POST['animal_id'];
        
        // Create adoption request
        $adoptStmt = $conn->prepare("INSERT INTO adoption_requests (user_id, animal_id, request_date, status) VALUES (?, ?, NOW(), 'pending')");
        if ($adoptStmt === false) {
            die("Error preparing adoption statement: " . $conn->error);
        }
        $adoptStmt->bind_param("ii", $userId, $animalId);
        $adoptStmt->execute();
        $adoptStmt->close();
        
        // Redirect with success message
        header("Location: animals.php?adoption_requested=true");
        exit();
    }
    
    if ($userType == 'foster' && $_POST['action'] == 'foster' && isset($_POST['animal_id'])) {
        $animalId = $_POST['animal_id'];
        
        // Create foster request in adoption_requests table
        $fosterStmt = $conn->prepare("INSERT INTO adoption_requests (user_id, animal_id, request_date, status, notes) VALUES (?, ?, NOW(), 'pending', 'Foster request')");
        if ($fosterStmt === false) {
            die("Error preparing foster request statement: " . $conn->error);
        }
        $fosterStmt->bind_param("ii", $userId, $animalId);
        $fosterStmt->execute();
        $fosterStmt->close();
        
        // Update animal to be fostered by this user (optional - depends on your business logic)
        // You may want to keep this commented out if you want admin approval first
        // $updateStmt = $conn->prepare("UPDATE animals SET foster_id = ? WHERE id = ? AND foster_id IS NULL");
        // if ($updateStmt === false) {
        //     die("Error preparing animal update statement: " . $conn->error);
        // }
        // $updateStmt->bind_param("ii", $userId, $animalId);
        // $updateStmt->execute();
        // $updateStmt->close();
        
        // Redirect with success message
        header("Location: animals.php?foster_requested=true");
        exit();
    }
}

// Close the database connection
$stmt->close();
$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Animals - Paws & Hearts</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Base Reset */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        a {
            color: #e07a5f;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .container {
            width: 90%;
            max-width: 1200px;
            margin: auto;
        }

        /* Header */
        header {
            background-color: #fff;
            padding: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo h1 {
            font-size: 1.8rem;
            color: #e07a5f;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 20px;
        }

        .nav-links li a {
            padding: 8px 12px;
            border-radius: 5px;
            font-weight: 500;
        }

        .nav-links li a:hover,
        .nav-links li a.active {
            background-color: #e07a5f;
            color: white;
        }

        .burger {
            display: none;
            font-size: 24px;
            cursor: pointer;
        }

        /* Banner */
        .banner {
            background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('https://images.unsplash.com/photo-1587300003388-59208cc962cb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');
            background-size: cover;
            background-position: center;
            color: white;
            text-align: center;
            padding: 80px 0;
        }

        .banner h2 {
            font-size: 2.5rem;
            margin-bottom: 20px;
        }

        .banner p {
            font-size: 1.2rem;
            max-width: 800px;
            margin: 0 auto 30px;
        }

        /* Filter Section */
        .filter-section {
            background-color: #fff;
            padding: 20px;
            border-radius: 10px;
            margin: -30px auto 30px;
            max-width: 1000px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            position: relative;
        }

        .filter-form {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
        }

        .filter-group {
            flex: 1;
            min-width: 150px;
        }

        .filter-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .filter-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }

        .filter-button {
            display: flex;
            align-items: flex-end;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #e07a5f;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .btn:hover {
            background-color: #cf6143;
        }

        /* Animals Grid */
        .animals-section {
            padding: 30px 0;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 5px;
            text-align: center;
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }

        .animals-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
        }

        .animal-card {
            background-color: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .animal-card:hover {
            transform: translateY(-5px);
        }

        .animal-image {
            height: 200px;
            overflow: hidden;
            position: relative;
        }

        .animal-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .favorite-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(255, 255, 255, 0.8);
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border: none;
            font-size: 18px;
            color: #ccc;
        }

        .favorite-btn.active {
            color: #e74c3c;
        }

        .animal-info {
            padding: 20px;
        }

        .animal-name {
            font-size: 1.5rem;
            margin-bottom: 5px;
            color: #333;
        }

        .animal-breed {
            color: #666;
            margin-bottom: 10px;
        }

        .animal-description {
            margin-bottom: 15px;
            line-height: 1.5;
        }

        .animal-details {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }

        .detail {
            display: flex;
            align-items: center;
            gap: 5px;
            color: #666;
        }

        .detail i {
            color: #e07a5f;
        }

        .animal-actions {
            display: flex;
            gap: 10px;
        }

        .btn-outline {
            background-color: transparent;
            border: 1px solid #e07a5f;
            color: #e07a5f;
        }

        .btn-outline:hover {
            background-color: #e07a5f;
            color: white;
        }

        /* Footer */
        footer {
            background-color: #f1f1f1;
            padding: 20px 0;
            text-align: center;
            font-size: 0.9rem;
            color: #666;
            margin-top: 40px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .burger {
                display: block;
            }

            .filter-form {
                flex-direction: column;
            }

            .animals-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            }
        }

        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
            gap: 5px;
        }

        .pagination a {
            display: inline-block;
            padding: 8px 15px;
            background-color: #f1f1f1;
            border-radius: 5px;
            color: #333;
        }

        .pagination a.active {
            background-color: #e07a5f;
            color: white;
        }

        .no-animals {
            text-align: center;
            padding: 40px 0;
            font-size: 1.2rem;
            color: #666;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php" class="active">Animals</a></li>
                    <li><a href="about.html">About</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <?php if ($isLoggedIn): ?>
                        <li><a href="dashboard.php">My Profile</a></li>
                        <li><a href="logout.php">Logout</a></li>
                    <?php else: ?>
                        <li><a href="login.php">Login</a></li>
                        <li><a href="register.php" class="btn">Register</a></li>
                    <?php endif; ?>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="banner">
        <div class="container">
            <h2>Find Your Perfect Companion</h2>
            <p>Browse our directory of lovable pets waiting for their forever homes.</p>
        </div>
    </section>

    <section class="filter-section">
        <div class="container">
            <form action="animals.php" method="GET" class="filter-form">
                <div class="filter-group">
                    <label for="type">Animal Type</label>
                    <select name="type" id="type">
                        <option value="all" <?php echo $filterType == 'all' ? 'selected' : ''; ?>>All Types</option>
                        <option value="dog" <?php echo $filterType == 'dog' ? 'selected' : ''; ?>>Dogs</option>
                        <option value="cat" <?php echo $filterType == 'cat' ? 'selected' : ''; ?>>Cats</option>
                        <option value="bird" <?php echo $filterType == 'bird' ? 'selected' : ''; ?>>Birds</option>
                        <option value="small_animal" <?php echo $filterType == 'small_animal' ? 'selected' : ''; ?>>Small Animals</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="age">Age</label>
                    <select name="age" id="age">
                        <option value="all" <?php echo $filterAge == 'all' ? 'selected' : ''; ?>>All Ages</option>
                        <option value="baby" <?php echo $filterAge == 'baby' ? 'selected' : ''; ?>>Baby</option>
                        <option value="young" <?php echo $filterAge == 'young' ? 'selected' : ''; ?>>Young</option>
                        <option value="adult" <?php echo $filterAge == 'adult' ? 'selected' : ''; ?>>Adult</option>
                        <option value="senior" <?php echo $filterAge == 'senior' ? 'selected' : ''; ?>>Senior</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="size">Size</label>
                    <select name="size" id="size">
                        <option value="all" <?php echo $filterSize == 'all' ? 'selected' : ''; ?>>All Sizes</option>
                        <option value="small" <?php echo $filterSize == 'small' ? 'selected' : ''; ?>>Small</option>
                        <option value="medium" <?php echo $filterSize == 'medium' ? 'selected' : ''; ?>>Medium</option>
                        <option value="large" <?php echo $filterSize == 'large' ? 'selected' : ''; ?>>Large</option>
                    </select>
                </div>
                <div class="filter-button">
                    <button type="submit" class="btn">Filter</button>
                </div>
            </form>
        </div>
    </section>

    <section class="animals-section">
        <div class="container">
            <?php if (isset($_GET['adoption_requested']) && $_GET['adoption_requested'] == 'true'): ?>
                <div class="alert">
                    <p>Your adoption request has been submitted! Our team will contact you soon.</p>
                </div>
            <?php endif; ?>
            
            <?php if (isset($_GET['foster_requested']) && $_GET['foster_requested'] == 'true'): ?>
                <div class="alert">
                    <p>Thank you for offering to foster! Our team will contact you with next steps.</p>
                </div>
            <?php endif; ?>
            
            <?php if (empty($animals)): ?>
                <div class="no-animals">
                    <p>No animals found matching your criteria. Please try different filters.</p>
                </div>
            <?php else: ?>
                <div class="animals-grid">
                    <?php foreach ($animals as $animal): ?>
                        <div class="animal-card">
                            <div class="animal-image">
                                <img src="<?php echo htmlspecialchars($animal['image_url']); ?>" alt="<?php echo htmlspecialchars($animal['name']); ?>">
                                <?php if ($isLoggedIn): ?>
                                    <form method="post">
                                        <input type="hidden" name="action" value="favorite">
                                        <input type="hidden" name="animal_id" value="<?php echo $animal['id']; ?>">
                                        <button type="submit" class="favorite-btn <?php echo in_array($animal['id'], $favorites) ? 'active' : ''; ?>">
                                            <i class="fas fa-heart"></i>
                                        </button>
                                    </form>
                                <?php endif; ?>
                            </div>
                            <div class="animal-info">
                                <h3 class="animal-name"><?php echo htmlspecialchars($animal['name']); ?></h3>
                                <p class="animal-breed"><?php echo htmlspecialchars($animal['breed']); ?></p>
                                <p class="animal-description"><?php echo htmlspecialchars($animal['description']); ?></p>
                                <div class="animal-details">
                                    <div class="detail">
                                        <i class="fas fa-birthday-cake"></i>
                                        <span><?php echo htmlspecialchars($animal['age_group']); ?></span>
                                    </div>
                                    <div class="detail">
                                        <i class="fas fa-weight"></i>
                                        <span><?php echo htmlspecialchars($animal['size']); ?></span>
                                    </div>
                                    <div class="detail">
                                        <i class="fas fa-venus-mars"></i>
                                        <span><?php echo htmlspecialchars($animal['gender']); ?></span>
                                    </div>
                                </div>
                                <div class="animal-actions">
                                    <a href="animal_details.php?id=<?php echo $animal['id']; ?>" class="btn btn-outline">More Info</a>
                                    
                                    <?php if ($isLoggedIn): ?>
                                        <?php if ($userType == 'adopter' && $animal['status'] == 'available'): ?>
                                            <form method="post" onsubmit="return confirm('Are you sure you want to submit an adoption request for <?php echo htmlspecialchars($animal['name']); ?>?');">
                                                <input type="hidden" name="action" value="adopt">
                                                <input type="hidden" name="animal_id" value="<?php echo $animal['id']; ?>">
                                                <button type="submit" class="btn">Adopt Me</button>
                                            </form>
                                        <?php elseif ($userType == 'foster' && $animal['foster_id'] == null): ?>
                                            <form method="post" onsubmit="return confirm('Are you sure you want to foster <?php echo htmlspecialchars($animal['name']); ?>?');">
                                                <input type="hidden" name="action" value="foster">
                                                <input type="hidden" name="animal_id" value="<?php echo $animal['id']; ?>">
                                                <button type="submit" class="btn">Foster Me</button>
                                            </form>
                                        <?php elseif ($userType == 'foster' && $animal['foster_id'] == $userId): ?>
                                            <span class="btn btn-outline">Currently Fostering</span>
                                        <?php endif; ?>
                                    <?php else: ?>
                                        <a href="login.php" class="btn">Login to Adopt</a>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
            
            <!-- Pagination example - to be implemented based on total records -->
            <div class="pagination">
                <a href="#" class="active">1</a>
                <a href="#">2</a>
                <a href="#">3</a>
                <a href="#">Next</a>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; <?php echo date('Y'); ?> Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Toggle navigation menu for mobile
            const burger = document.querySelector('.burger');
            const nav = document.querySelector('.nav-links');
            
            if(burger) {
                burger.addEventListener('click', function() {
                    nav.style.display = nav.style.display === 'flex' ? 'none' : 'flex';
                });
            }
            
            // Check if any "More Info" buttons exist and ensure they're properly functioning
            const moreInfoLinks = document.querySelectorAll('.animal-actions .btn-outline');
            moreInfoLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    // You can add click tracking or other logic here if needed
                    // This is just to ensure the links are properly set up with event listeners
                    console.log('Navigating to animal details page');
                });
            });
        });
    </script>
</body>
</html>
<?php
// Initialize the session
session_start();

// Check if the user is logged in, if not redirect to login page
if (!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true) {
    header("location: login.php");
    exit;
}

// Make sure user ID is set before proceeding - FIXED: changed from "id" to "user_id"
if (!isset($_SESSION["user_id"])) {
    // Redirect to login page if user ID is not set
    header("location: login.php");
    exit;
}

// Database connection
$servername = "localhost";
$username = "root";
$password = "2424";
$dbname = "paws";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Define variables and initialize with empty values
$request_id = $error = $success_message = "";
$reason = $additional_notes = "";

// Processing form data when form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Validate request ID
    if (empty(trim($_POST["request_id"]))) {
        $error = "Invalid request.";
    } else {
        $request_id = trim($_POST["request_id"]);
        $reason = !empty($_POST["reason"]) ? trim($_POST["reason"]) : NULL;
        $additional_notes = !empty($_POST["additional_notes"]) ? trim($_POST["additional_notes"]) : NULL;
        
        // Check if the request belongs to the logged-in user - FIXED: changed from "id" to "user_id"
        $user_id = $_SESSION["user_id"];
        $sql = "SELECT ar.*, a.id as animal_id FROM adoption_requests ar 
                JOIN animals a ON ar.animal_id = a.id 
                WHERE ar.id = ? AND ar.user_id = ?";
        
        if ($stmt = $conn->prepare($sql)) {
            $stmt->bind_param("ii", $request_id, $user_id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows == 1) {
                $request_data = $result->fetch_assoc();
                
                // Begin transaction
                $conn->begin_transaction();
                
                try {
                    // Insert into cancellations table
                    $insert_sql = "INSERT INTO cancellations (request_id, user_id, animal_id, reason, additional_notes, original_request_date, cancelled_by) 
                                  VALUES (?, ?, ?, ?, ?, ?, 'user')";
                    
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->bind_param("iiisss", $request_id, $user_id, $request_data['animal_id'], $reason, $additional_notes, $request_data['request_date']);
                    $insert_stmt->execute();
                    $insert_stmt->close();
                    
                    // Delete from adoption_requests
                    $delete_sql = "DELETE FROM adoption_requests WHERE id = ?";
                    $delete_stmt = $conn->prepare($delete_sql);
                    $delete_stmt->bind_param("i", $request_id);
                    $delete_stmt->execute();
                    $delete_stmt->close();
                    
                    // Commit transaction
                    $conn->commit();
                    $success_message = "Your adoption request has been successfully cancelled.";
                    
                } catch (Exception $e) {
                    // Rollback transaction on error
                    $conn->rollback();
                    $error = "Something went wrong. Please try again later.";
                }
            } else {
                $error = "You don't have permission to cancel this request or the request doesn't exist.";
            }
            $stmt->close();
        }
    }
}

// Fetch all adoption requests for the current user - FIXED: changed from "id" to "user_id"
$user_id = $_SESSION["user_id"];
$sql = "SELECT ar.id, ar.request_date, ar.status, a.name, a.animal_type, a.breed 
        FROM adoption_requests ar 
        JOIN animals a ON ar.animal_id = a.id 
        WHERE ar.user_id = ? 
        ORDER BY ar.request_date DESC";

$requests = [];
if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $requests[] = $row;
    }
    $stmt->close();
}

// Debug: Check if user ID is correct and if there are any adoption requests in the database
$debug_message = "";
if (empty($requests)) {
    // Check if user ID exists in the session - FIXED: changed from "id" to "user_id"
    $debug_message .= "User ID: " . (isset($_SESSION["user_id"]) ? $_SESSION["user_id"] : "Not set") . "<br>";
    
    // Check if there are any adoption requests in the database for this user
    $check_sql = "SELECT COUNT(*) as count FROM adoption_requests WHERE user_id = ?";
    if ($check_stmt = $conn->prepare($check_sql)) {
        $check_stmt->bind_param("i", $user_id);
        $check_stmt->execute();
        $check_result = $check_stmt->get_result();
        $check_row = $check_result->fetch_assoc();
        $debug_message .= "Number of adoption requests found: " . $check_row['count'];
        $check_stmt->close();
    }
}

// Fetch all cancellations for the current user
$cancellations = [];
$sql = "SELECT c.id, c.cancelled_date, c.reason, c.additional_notes, c.original_request_date, 
        a.name, a.animal_type, a.breed 
        FROM cancellations c 
        JOIN animals a ON c.animal_id = a.id 
        WHERE c.user_id = ? 
        ORDER BY c.cancelled_date DESC";

if ($stmt = $conn->prepare($sql)) {
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        // Format the reason to be more user-friendly
        switch($row["reason"]) {
            case "changed_mind":
                $row["formatted_reason"] = "Changed my mind";
                break;
            case "found_another_pet":
                $row["formatted_reason"] = "Found another pet";
                break;
            case "personal_circumstances":
                $row["formatted_reason"] = "Personal circumstances changed";
                break;
            case "other":
                $row["formatted_reason"] = "Other";
                break;
            default:
                $row["formatted_reason"] = $row["reason"] ? ucfirst(str_replace('_', ' ', $row["reason"])) : "Not specified";
        }
        
        $cancellations[] = $row;
    }
    $stmt->close();
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Adoption Requests - PAWS Animal Shelter</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
            color: #333;
        }
        
        .container {
            width: 80%;
            margin: 2rem auto;
            padding: 2rem;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        
        h1, h2 {
            color: #4A6FA5;
            margin-bottom: 1.5rem;
        }
        
        h1 {
            text-align: center;
        }
        
        .section {
            margin-bottom: 2.5rem;
        }
        
        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 4px;
            text-align: center;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 2rem;
        }
        
        th, td {
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        
        th {
            background-color: #f0f0f0;
        }
        
        tr:hover {
            background-color: #f8f9fa;
        }
        
        .btn {
            display: inline-block;
            font-weight: 400;
            text-align: center;
            white-space: nowrap;
            vertical-align: middle;
            user-select: none;
            border: 1px solid transparent;
            padding: 0.375rem 0.75rem;
            font-size: 0.9rem;
            line-height: 1.5;
            border-radius: 0.25rem;
            transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out;
            text-decoration: none;
            cursor: pointer;
        }
        
        .btn-danger {
            color: #fff;
            background-color: #dc3545;
            border-color: #dc3545;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }
        
        .btn-primary {
            color: #fff;
            background-color: #4A6FA5;
            border-color: #4A6FA5;
        }
        
        .btn-primary:hover {
            background-color: #3d5c8a;
            border-color: #38557f;
        }
        
        .back-link {
            display: block;
            text-align: center;
            margin-top: 1rem;
        }
        
        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #6c757d;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
            border-radius: 8px;
        }
        
        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-control {
            display: block;
            width: 100%;
            padding: 0.375rem 0.75rem;
            font-size: 1rem;
            line-height: 1.5;
            color: #495057;
            background-color: #fff;
            background-clip: padding-box;
            border: 1px solid #ced4da;
            border-radius: 0.25rem;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        
        select.form-control {
            height: calc(2.25rem + 2px);
        }
        
        textarea.form-control {
            height: auto;
        }
        
        label {
            display: inline-block;
            margin-bottom: 0.5rem;
        }
        
        .text-warning {
            color: #ffc107;
        }
        
        .text-success {
            color: #28a745;
        }
        
        .text-danger {
            color: #dc3545;
        }
        
        .tab-navigation {
            display: flex;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #dee2e6;
        }
        
        .tab-button {
            padding: 0.75rem 1rem;
            background: none;
            border: none;
            border-bottom: 3px solid transparent;
            cursor: pointer;
            font-weight: 500;
            margin-right: 1rem;
            transition: all 0.3s;
        }
        
        .tab-button.active {
            color: #4A6FA5;
            border-bottom-color: #4A6FA5;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .notes-cell {
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .show-notes {
            color: #4A6FA5;
            cursor: pointer;
            text-decoration: underline;
        }
        
        .notes-modal {
            max-width: 600px !important;
        }

        .debug-info {
            margin-top: 20px;
            padding: 10px;
            background-color: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Manage Adoption Requests</h1>
        
        <?php if(!empty($error)): ?>
            <div class="alert alert-danger">
                <?php echo $error; ?>
            </div>
        <?php endif; ?>
        
        <?php if(!empty($success_message)): ?>
            <div class="alert alert-success">
                <?php echo $success_message; ?>
            </div>
        <?php endif; ?>
        
        <div class="tab-navigation">
            <button class="tab-button active" data-tab="active-requests">Active Requests</button>
            <button class="tab-button" data-tab="cancelled-requests">Cancelled Requests</button>
        </div>
        
        <div id="active-requests" class="tab-content active">
            <?php if(!empty($debug_message)): ?>
                <div class="alert alert-info">
                    <p>Debug Information:</p>
                    <?php echo $debug_message; ?>
                </div>
            <?php endif; ?>
            
            <?php if(empty($requests)): ?>
                <div class="empty-state">
                    <p>You don't have any active adoption requests.</p>
                    <a href="animals.php" class="btn btn-primary">Browse Animals</a>
                </div>
            <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>Animal</th>
                            <th>Type</th>
                            <th>Breed</th>
                            <th>Request Date</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($requests as $request): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($request["name"]); ?></td>
                                <td><?php echo htmlspecialchars(ucfirst($request["animal_type"])); ?></td>
                                <td><?php echo htmlspecialchars($request["breed"]); ?></td>
                                <td><?php echo date("M d, Y", strtotime($request["request_date"])); ?></td>
                                <td>
                                    <?php 
                                        $status_class = "";
                                        switch($request["status"]) {
                                            case "pending":
                                                $status_class = "text-warning";
                                                break;
                                            case "approved":
                                                $status_class = "text-success";
                                                break;
                                            case "rejected":
                                                $status_class = "text-danger";
                                                break;
                                        }
                                    ?>
                                    <span class="<?php echo $status_class; ?>">
                                        <?php echo ucfirst($request["status"]); ?>
                                    </span>
                                </td>
                                <td>
                                    <?php if($request["status"] == "pending"): ?>
                                        <button class="btn btn-danger" onclick="openModal(<?php echo $request['id']; ?>, '<?php echo htmlspecialchars($request["name"]); ?>')">Cancel</button>
                                    <?php else: ?>
                                        <span>-</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
        
        <div id="cancelled-requests" class="tab-content">
            <?php if(empty($cancellations)): ?>
                <div class="empty-state">
                    <p>You don't have any cancelled adoption requests.</p>
                </div>
            <?php else: ?>
                <table>
                    <thead>
                        <tr>
                            <th>Animal</th>
                            <th>Type</th>
                            <th>Breed</th>
                            <th>Original Request Date</th>
                            <th>Cancelled Date</th>
                            <th>Reason</th>
                            <th>Notes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($cancellations as $cancellation): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($cancellation["name"]); ?></td>
                                <td><?php echo htmlspecialchars(ucfirst($cancellation["animal_type"])); ?></td>
                                <td><?php echo htmlspecialchars($cancellation["breed"]); ?></td>
                                <td><?php echo date("M d, Y", strtotime($cancellation["original_request_date"])); ?></td>
                                <td><?php echo date("M d, Y", strtotime($cancellation["cancelled_date"])); ?></td>
                                <td><?php echo htmlspecialchars($cancellation["formatted_reason"]); ?></td>
                                <td>
                                    <?php if(!empty($cancellation["additional_notes"])): ?>
                                        <div class="notes-cell">
                                            <?php echo htmlspecialchars($cancellation["additional_notes"]); ?>
                                        </div>
                                        <span class="show-notes" onclick="showNotes('<?php echo htmlspecialchars(addslashes($cancellation["additional_notes"])); ?>')">Show full notes</span>
                                    <?php else: ?>
                                        <span>-</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
        
        <a href="dashboard.php" class="back-link">Back to Dashboard</a>
    </div>
    
    <!-- Confirmation Modal -->
    <div id="confirmModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Confirm Cancellation</h2>
            <p>Are you sure you want to cancel your adoption request for <span id="animalName"></span>?</p>
            
            <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
                <div class="form-group">
                    <label for="reason">Reason for cancellation:</label>
                    <select name="reason" id="reason" class="form-control">
                        <option value="changed_mind">Changed my mind</option>
                        <option value="found_another_pet">Found another pet</option>
                        <option value="personal_circumstances">Personal circumstances changed</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="additional_notes">Additional notes (optional):</label>
                    <textarea name="additional_notes" id="additional_notes" class="form-control" rows="3"></textarea>
                </div>
                
                <input type="hidden" id="requestIdInput" name="request_id" value="">
                
                <div class="modal-actions">
                    <button type="button" class="btn btn-primary" onclick="closeModal()">No, Keep Request</button>
                    <button type="submit" class="btn btn-danger">Yes, Cancel Request</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Notes Modal -->
    <div id="notesModal" class="modal">
        <div class="modal-content notes-modal">
            <span class="close" onclick="closeNotesModal()">&times;</span>
            <h2>Additional Notes</h2>
            <div id="notesContent" style="margin-top: 1rem; white-space: pre-wrap;"></div>
            <div class="modal-actions">
                <button type="button" class="btn btn-primary" onclick="closeNotesModal()">Close</button>
            </div>
        </div>
    </div>
    
    <script>
        // Get the modals
        var confirmModal = document.getElementById("confirmModal");
        var notesModal = document.getElementById("notesModal");
        
        // Function to open the confirmation modal
        function openModal(requestId, animalName) {
            document.getElementById('requestIdInput').value = requestId;
            document.getElementById('animalName').textContent = animalName;
            confirmModal.style.display = "block";
        }
        
        // Function to close the confirmation modal
        function closeModal() {
            confirmModal.style.display = "none";
        }
        
        // Function to show notes in modal
        function showNotes(notes) {
            document.getElementById('notesContent').textContent = notes;
            notesModal.style.display = "block";
        }
        
        // Function to close the notes modal
        function closeNotesModal() {
            notesModal.style.display = "none";
        }
        
        // Close the modals when clicking outside of them
        window.onclick = function(event) {
            if (event.target == confirmModal) {
                closeModal();
            }
            if (event.target == notesModal) {
                closeNotesModal();
            }
        }
        
        // Tab navigation
        document.addEventListener('DOMContentLoaded', function() {
            const tabButtons = document.querySelectorAll('.tab-button');
            const tabContents = document.querySelectorAll('.tab-content');
            
            tabButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const tabId = this.getAttribute('data-tab');
                    
                    // Remove active class from all buttons and contents
                    tabButtons.forEach(btn => btn.classList.remove('active'));
                    tabContents.forEach(content => content.classList.remove('active'));
                    
                    // Add active class to clicked button and corresponding content
                    this.classList.add('active');
                    document.getElementById(tabId).classList.add('active');
                });
            });
        });
    </script>
</body>
</html>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard - Paws & Hearts</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
/* General Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f5f6fa;
    color: #333;
}
a {
    text-decoration: none;
    color: inherit;
}
ul {
    list-style: none;
}

/* Header */
header {
    background-color: #fff;
    border-bottom: 1px solid #ddd;
    padding: 1rem 0;
}
nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.logo h1 {
    font-size: 1.5rem;
    color: #e67e22;
}
.nav-links {
    display: flex;
    gap: 1rem;
}
.nav-links li a {
    padding: 0.5rem 1rem;
    color: #555;
    font-weight: 500;
}
.nav-links li a.active,
.nav-links li a:hover {
    color: #e67e22;
}
.btn {
    background-color: #e67e22;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-weight: bold;
}
.burger {
    display: none;
}

/* Layout */
.dashboard-container {
    display: flex;
    margin-top: 2rem;
    gap: 2rem;
}
.dashboard-sidebar {
    width: 250px;
    background-color: #fff;
    padding: 1rem;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0,0,0,0.05);
}
.dashboard-content {
    flex: 1;
}

/* Profile */
.user-profile {
    text-align: center;
    margin-bottom: 2rem;
}
.profile-image img {
    width: 80px;
    height: 80px;
    border-radius: 50%;
}
.profile-info h3 {
    margin: 0.5rem 0 0.2rem;
}
.profile-info p {
    font-size: 0.9rem;
    color: #888;
}

/* Sidebar Navigation */
.dashboard-menu ul li {
    margin: 0.7rem 0;
}
.dashboard-menu ul li a {
    display: flex;
    align-items: center;
    padding: 0.6rem;
    border-radius: 5px;
    color: #333;
    transition: background 0.3s;
}
.dashboard-menu ul li a i {
    margin-right: 0.6rem;
}
.dashboard-menu ul li a:hover,
.dashboard-menu ul li.active a {
    background-color: #e67e22;
    color: white;
}

/* Dashboard Header */
.dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
}
.dashboard-header h2 {
    font-size: 1.5rem;
}

/* Widgets */
.dashboard-widgets {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}
.widget {
    background: white;
    padding: 1rem;
    border-radius: 10px;
    display: flex;
    align-items: center;
    gap: 1rem;
    box-shadow: 0 0 10px rgba(0,0,0,0.05);
}
.widget-icon {
    font-size: 1.8rem;
    padding: 0.8rem;
    border-radius: 50%;
    color: white;
}
.success { background: #2ecc71; }
.warning { background: #f1c40f; }
.primary { background: #e67e22; }
.info { background: #3498db; }
.widget-info h3 {
    margin-bottom: 0.3rem;
    font-size: 1rem;
}
.widget-info p {
    font-size: 1.2rem;
    font-weight: bold;
}

/* Table */
.dashboard-section {
    margin-top: 2rem;
}
.dashboard-section h3 {
    margin-bottom: 1rem;
}
.table-responsive {
    overflow-x: auto;
}
.applications-table {
    width: 100%;
    border-collapse: collapse;
}
.applications-table th,
.applications-table td {
    padding: 0.8rem;
    border-bottom: 1px solid #eee;
    text-align: left;
}
.animal-info {
    display: flex;
    align-items: center;
    gap: 0.8rem;
}
.animal-info img {
    width: 50px;
    height: 50px;
    border-radius: 10px;
}
.status-badge {
    padding: 0.3rem 0.7rem;
    border-radius: 15px;
    font-size: 0.85rem;
    color: white;
}
.status-badge.approved {
    background-color: #2ecc71;
}
.status-badge.pending {
    background-color: #f39c12;
}
.btn-sm {
    padding: 0.3rem 0.7rem;
    font-size: 0.85rem;
}
.btn-link {
    color: #e67e22;
    font-weight: bold;
}
.text-right {
    text-align: right;
}

/* Animals grid */
.animals-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 1rem;
}
.mini-grid {
    margin-top: 1rem;
}

/* Footer */
footer {
    margin-top: 3rem;
    background-color: #fff;
    padding: 1rem;
    text-align: center;
    font-size: 0.9rem;
    color: #999;
    border-top: 1px solid #ddd;
}
</style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="dashboard.php" class="active">Dashboard</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="#" id="logoutBtn" class="btn">Logout</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="dashboard">
        <div class="container">
            <div class="dashboard-container">
                <aside class="dashboard-sidebar">
                    <div class="user-profile">
                        <div class="profile-image">
                            <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="User profile">
                        </div>
                        <div class="profile-info">
                            <h3>John Doe</h3>
                            <p>Member since: June 2022</p>
                        </div>
                    </div>
                    <nav class="dashboard-menu">
                        <ul>
                            <li class="active"><a href="dashboard.php"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                            <li><a href="dashboard-applications.php"><i class="fas fa-file-alt"></i> My Applications</a></li>
                            <li><a href="favorites.php"><i class="fas fa-heart"></i> Favorites</a></li>
                            <li><form method="GET" action="cancel.php" style="margin:0;padding:0;">
                                <button type="submit" style="background: none; border: none; display: flex; align-items: center; padding: 0.6rem; width: 100%; text-align: left; cursor: pointer;">
                                    <i class="fas fa-times-circle" style="margin-right: 0.6rem;"></i> Cancellations
                                </button>
                            </form></li>
                        </ul>
                    </nav>
                </aside>
                <main class="dashboard-content">
                    <div class="dashboard-header">
                        <h2>My Dashboard</h2>
                        <div class="dashboard-actions">
                            <a href="animals.php" class="btn btn-primary"><i class="fas fa-paw"></i> Browse Animals</a>
                        </div>
                    </div>
                    
                    <div class="dashboard-widgets">
                        <div class="widget">
                            <div class="widget-icon success">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Approved Applications</h3>
                                <p>2</p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon warning">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Pending Applications</h3>
                                <p>1</p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon primary">
                                <i class="fas fa-heart"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Favorite Animals</h3>
                                <p>5</p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon info">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="widget-info">
                                <h3>New Messages</h3>
                                <p>3</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="dashboard-section">
                        <h3>Recent Applications</h3>
                        <div class="table-responsive">
                            <table class="applications-table">
                                <thead>
                                    <tr>
                                        <th>Animal</th>
                                        <th>Date Applied</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <div class="animal-info">
                                                <img src="https://images.unsplash.com/photo-1561037404-61cd46aa615b?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Buddy">
                                                <span>Buddy</span>
                                            </div>
                                        </td>
                                        <td>June 15, 2023</td>
                                        <td><span class="status-badge approved">Approved</span></td>
                                        <td>
                                            <button class="btn btn-sm btn-primary">View</button>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="animal-info">
                                                <img src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Whiskers">
                                                <span>Whiskers</span>
                                            </div>
                                        </td>
                                        <td>June 10, 2023</td>
                                        <td><span class="status-badge pending">Pending</span></td>
                                        <td>
                                            <button class="btn btn-sm btn-primary">View</button>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="animal-info">
                                                <img src="https://images.unsplash.com/photo-1586671267731-da2cf3ceeb80?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Max">
                                                <span>Max</span>
                                            </div>
                                        </td>
                                        <td>May 28, 2023</td>
                                        <td><span class="status-badge approved">Approved</span></td>
                                        <td>
                                            <button class="btn btn-sm btn-primary">View</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="text-right">
                            <a href="dashboard-applications.php" class="btn btn-link">View All Applications</a>
                        </div>
                    </div>
                    
                    <div class="dashboard-section">
                        <h3>Recommended Animals</h3>
                        <div class="animals-grid mini-grid">
                            <!-- Dynamically loaded from animals.js -->
                        </div>
                    </div>
                </main>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // Disable any JavaScript that might be interfering with navigation
        document.addEventListener('DOMContentLoaded', function() {
            // Find and temporarily disable potentially problematic scripts
            const disableScripts = function() {
                try {
                    // Store original functions that might be causing issues
                    if (window.originalAddEventListener === undefined && window.addEventListener) {
                        window.originalAddEventListener = window.addEventListener;
                        window.addEventListener = function(type, listener, options) {
                            // Allow only essential events, block potential navigation interceptors
                            if (type !== 'click' && type !== 'beforeunload') {
                                window.originalAddEventListener(type, listener, options);
                            }
                        };
                    }
                } catch (e) {
                    console.error("Error disabling scripts:", e);
                }
            };
            
            disableScripts();
        });
    </script>
    
    <script src="js/auth.js"></script>
    <script src="js/animals.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
<?php
// Start the session to access user info
session_start();

// Check if user is logged in, if not redirect to login page
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

// Database connection
$servername = "localhost";
$username = "root"; // Replace with your DB username
$password = "2424"; // Replace with your DB password
$dbname = "paws"; // Replace with your DB name

// Create connection with mysqli
try {
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }
    
    // Get current user ID from session
    $user_id = $_SESSION['user_id'];
    
    // User query
    $userQuery = "SELECT * FROM users WHERE id = ?";
    $userStmt = $conn->prepare($userQuery);
    
    if (!$userStmt) {
        throw new Exception("User prepare failed: " . $conn->error);
    }
    
    $userStmt->bind_param("i", $user_id);
    $userStmt->execute();
    $userResult = $userStmt->get_result();
    
    if (!$userResult) {
        throw new Exception("User query failed: " . $conn->error);
    }
    
    $userData = $userResult->fetch_assoc();
    
    if (!$userData) {
        throw new Exception("No user data found for ID: " . $user_id);
    }

    // Check if the tables exist
    $check_tables = $conn->query("SHOW TABLES LIKE 'adoption_requests'");
    $adoption_requests_exists = $check_tables->num_rows > 0;
    $check_tables = $conn->query("SHOW TABLES LIKE 'animals'");
    $animals_exists = $check_tables->num_rows > 0;

    if (!$adoption_requests_exists || !$animals_exists) {
        throw new Exception("Error: One or more required tables don't exist. adoption_requests exists: " . 
            ($adoption_requests_exists ? "Yes" : "No") . ", animals exists: " . 
            ($animals_exists ? "Yes" : "No"));
    }

    // Query for adoption requests - Corrected JOIN clause with animal fields
    $sql = "SELECT ar.*, a.name as animal_name, a.image_url as animal_image, a.animal_type as species, a.breed 
            FROM adoption_requests ar
            JOIN animals a ON ar.animal_id = a.id
            WHERE ar.user_id = ?
            ORDER BY ar.request_date DESC";

    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        // Prepare failed, use error handling with a direct query as fallback
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    // Count applications by status
    $countSql = "SELECT 
                COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_count,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
                COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_count,
                COUNT(*) as total_count
            FROM adoption_requests 
            WHERE user_id = ?";
    
    $countStmt = $conn->prepare($countSql);
    
    if (!$countStmt) {
        throw new Exception("Count prepare failed: " . $conn->error);
    }
    
    $countStmt->bind_param("i", $user_id);
    $countStmt->execute();
    $countResult = $countStmt->get_result();
    
    if (!$countResult) {
        throw new Exception("Count query failed: " . $conn->error);
    }
    
    $counts = $countResult->fetch_assoc();
    
    // If no counts found, provide default values
    if (!$counts) {
        $counts = [
            'approved_count' => 0,
            'pending_count' => 0,
            'rejected_count' => 0,
            'total_count' => 0
        ];
    }

} catch (Exception $e) {
    // Display error message
    echo "<div style='margin: 50px auto; max-width: 800px; padding: 20px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 5px;'>";
    echo "<h2 style='color: #721c24;'>Database Error</h2>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p>Please contact the administrator with this error message.</p>";
    echo "</div>";
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - Paws & Hearts</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* General Reset */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
            color: #333;
        }
        a {
            text-decoration: none;
            color: inherit;
        }
        ul {
            list-style: none;
        }
        .container {
            width: 90%;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Header */
        header {
            background-color: #fff;
            border-bottom: 1px solid #ddd;
            padding: 1rem 0;
        }
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo h1 {
            font-size: 1.5rem;
            color: #e67e22;
        }
        .nav-links {
            display: flex;
            gap: 1rem;
        }
        .nav-links li a {
            padding: 0.5rem 1rem;
            color: #555;
            font-weight: 500;
        }
        .nav-links li a.active,
        .nav-links li a:hover {
            color: #e67e22;
        }
        .btn {
            background-color: #e67e22;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: bold;
            border: none;
            cursor: pointer;
        }
        .burger {
            display: none;
        }

        /* Layout */
        .dashboard-container {
            display: flex;
            margin-top: 2rem;
            gap: 2rem;
        }
        .dashboard-sidebar {
            width: 250px;
            background-color: #fff;
            padding: 1rem;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        .dashboard-content {
            flex: 1;
        }

        /* Profile */
        .user-profile {
            text-align: center;
            margin-bottom: 2rem;
        }
        .profile-image img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
        }
        .profile-info h3 {
            margin: 0.5rem 0 0.2rem;
        }
        .profile-info p {
            font-size: 0.9rem;
            color: #888;
        }

        /* Sidebar Navigation */
        .dashboard-menu ul li {
            margin: 0.7rem 0;
        }
        .dashboard-menu ul li a {
            display: flex;
            align-items: center;
            padding: 0.6rem;
            border-radius: 5px;
            color: #333;
            transition: background 0.3s;
        }
        .dashboard-menu ul li a i {
            margin-right: 0.6rem;
        }
        .dashboard-menu ul li a:hover,
        .dashboard-menu ul li.active a {
            background-color: #e67e22;
            color: white;
        }

        /* Dashboard Header */
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .dashboard-header h2 {
            font-size: 1.5rem;
        }

        /* Widgets */
        .dashboard-widgets {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .widget {
            background: white;
            padding: 1rem;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        .widget-icon {
            font-size: 1.8rem;
            padding: 0.8rem;
            border-radius: 50%;
            color: white;
        }
        .success { background: #2ecc71; }
        .warning { background: #f1c40f; }
        .danger { background: #e74c3c; }
        .primary { background: #e67e22; }
        .info { background: #3498db; }
        .widget-info h3 {
            margin-bottom: 0.3rem;
            font-size: 1rem;
        }
        .widget-info p {
            font-size: 1.2rem;
            font-weight: bold;
        }

        /* Table */
        .dashboard-section {
            margin-top: 2rem;
            background-color: #fff;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        .dashboard-section h3 {
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #eee;
        }
        .table-responsive {
            overflow-x: auto;
        }
        .applications-table {
            width: 100%;
            border-collapse: collapse;
        }
        .applications-table th,
        .applications-table td {
            padding: 0.8rem;
            border-bottom: 1px solid #eee;
            text-align: left;
        }
        .applications-table th {
            background-color: #f8f9fa;
        }
        .animal-info {
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }
        .animal-info img {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            object-fit: cover;
        }
        .animal-details h4 {
            margin-bottom: 0.3rem;
        }
        .animal-details p {
            font-size: 0.85rem;
            color: #888;
        }
        .status-badge {
            padding: 0.3rem 0.7rem;
            border-radius: 15px;
            font-size: 0.85rem;
            color: white;
            display: inline-block;
        }
        .status-badge.approved {
            background-color: #2ecc71;
        }
        .status-badge.pending {
            background-color: #f39c12;
        }
        .status-badge.rejected {
            background-color: #e74c3c;
        }
        .btn-sm {
            padding: 0.3rem 0.7rem;
            font-size: 0.85rem;
        }
        .btn-link {
            color: #e67e22;
            font-weight: bold;
        }
        .text-right {
            text-align: right;
        }
        .date-info {
            font-size: 0.9rem;
            color: #666;
        }
        .notes {
            font-style: italic;
            color: #777;
            margin-top: 0.3rem;
        }
        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #888;
        }
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #ddd;
        }
        .text-muted {
            color: #888;
            font-style: italic;
        }
        .mt-3 {
            margin-top: 1rem;
        }
        
        /* Footer */
        footer {
            margin-top: 3rem;
            background-color: #fff;
            padding: 1rem;
            text-align: center;
            font-size: 0.9rem;
            color: #999;
            border-top: 1px solid #ddd;
        }
        
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: #fff;
            margin: 10% auto;
            padding: 1.5rem;
            border-radius: 10px;
            width: 80%;
            max-width: 600px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #eee;
        }
        .modal-body {
            margin-bottom: 1.5rem;
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.5rem;
        }
        .close {
            color: #aaa;
            font-size: 1.5rem;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: #555;
        }
        .application-detail-item {
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #eee;
        }
        .application-detail-item:last-child {
            border-bottom: none;
        }
        .application-detail-item h4 {
            margin-bottom: 0.5rem;
            color: #555;
        }
        .animal-info-container {
            display: flex;
            align-items: center;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .dashboard-container {
                flex-direction: column;
            }
            .dashboard-sidebar {
                width: 100%;
            }
            .nav-links {
                display: none;
            }
            .nav-links.active {
                display: flex;
                flex-direction: column;
                position: absolute;
                top: 60px;
                left: 0;
                right: 0;
                background: white;
                padding: 1rem;
                box-shadow: 0 5px 10px rgba(0,0,0,0.1);
                z-index: 10;
            }
            .burger {
                display: block;
                cursor: pointer;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="dashboard.php">Dashboard</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="#" id="logoutBtn" class="btn">Logout</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="dashboard">
        <div class="container">
            <div class="dashboard-container">
                <aside class="dashboard-sidebar">
                    <div class="user-profile">
                        <div class="profile-image">
                            <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="User profile">
                        </div>
                        <div class="profile-info">
                            <h3><?php echo htmlspecialchars($userData['first_name'] . ' ' . $userData['last_name']); ?></h3>
                            <p>Member since: <?php echo date('F Y', strtotime($userData['created_at'])); ?></p>
                        </div>
                    </div>
                    <nav class="dashboard-menu">
                        <ul>
                            <li><a href="dashboard.php"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                            <li class="active"><a href="dashboard-applications.php"><i class="fas fa-file-alt"></i> My Applications</a></li>
                            <li><a href="dashboard-favorites.php"><i class="fas fa-heart"></i> Favorites</a></li>
                        </ul>
                    </nav>
                </aside>
                <main class="dashboard-content">
                    <div class="dashboard-header">
                        <h2>My Applications</h2>
                        <div class="dashboard-actions">
                            <a href="animals.php" class="btn btn-primary"><i class="fas fa-paw"></i> Browse Animals</a>
                        </div>
                    </div>
                    
                    <div class="dashboard-widgets">
                        <div class="widget">
                            <div class="widget-icon success">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Approved</h3>
                                <p><?php echo $counts['approved_count']; ?></p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon warning">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Pending</h3>
                                <p><?php echo $counts['pending_count']; ?></p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon danger">
                                <i class="fas fa-times-circle"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Rejected</h3>
                                <p><?php echo $counts['rejected_count']; ?></p>
                            </div>
                        </div>
                        <div class="widget">
                            <div class="widget-icon primary">
                                <i class="fas fa-file-alt"></i>
                            </div>
                            <div class="widget-info">
                                <h3>Total Applications</h3>
                                <p><?php echo $counts['total_count']; ?></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="dashboard-section">
                        <h3>All Applications</h3>
                        <div class="table-responsive">
                            <?php if (isset($result) && $result->num_rows > 0): ?>
                            <table class="applications-table">
                                <thead>
                                    <tr>
                                        <th>Animal</th>
                                        <th>Date Applied</th>
                                        <th>Status</th>
                                        <th>Notes</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php while($row = $result->fetch_assoc()): ?>
                                    <tr data-id="<?php echo $row['id']; ?>">
                                        <td>
                                            <div class="animal-info">
                                                <img src="<?php echo !empty($row['animal_image']) ? htmlspecialchars($row['animal_image']) : 'https://images.unsplash.com/photo-1561037404-61cd46aa615b?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80'; ?>" alt="<?php echo htmlspecialchars($row['animal_name']); ?>">
                                                <div class="animal-details">
                                                    <h4><?php echo htmlspecialchars($row['animal_name']); ?></h4>
                                                    <p><?php echo htmlspecialchars($row['species'] . ' • ' . $row['breed']); ?></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="date-info">
                                                <?php echo date('F d, Y', strtotime($row['request_date'])); ?>
                                                <p><?php echo date('h:i A', strtotime($row['request_date'])); ?></p>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="status-badge <?php echo strtolower($row['status']); ?>">
                                                <?php echo ucfirst($row['status']); ?>
                                            </span>
                                            <?php if($row['processed_date']): ?>
                                                <p class="date-info">Processed on: <?php echo date('M d, Y', strtotime($row['processed_date'])); ?></p>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <?php if(!empty($row['notes'])): ?>
                                                <div class="notes"><?php echo htmlspecialchars($row['notes']); ?></div>
                                            <?php else: ?>
                                                <span class="text-muted">No notes</span>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-primary view-application" data-id="<?php echo $row['id']; ?>">View Details</button>
                                        </td>
                                    </tr>
                                    <?php endwhile; ?>
                                </tbody>
                            </table>
                            <?php else: ?>
                            <div class="empty-state">
                                <i class="fas fa-file-alt"></i>
                                <h3>No Applications Yet</h3>
                                <p>You haven't submitted any adoption applications yet.</p>
                                <a href="animals.php" class="btn btn-primary mt-3">Browse Animals to Adopt</a>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    </section>

    <!-- Application Details Modal -->
    <div id="applicationModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Application Details</h3>
                <span class="close">&times;</span>
            </div>
            <div class="modal-body" id="applicationDetails">
                <!-- Application details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button class="btn" id="closeModal">Close</button>
            </div>
        </div>
    </div>

    <footer>
        <div class="container">
            <p>&copy; 2025 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // Modal functionality
        const modal = document.getElementById("applicationModal");
        const closeBtn = document.getElementsByClassName("close")[0];
        const closeModalBtn = document.getElementById("closeModal");
        const applicationDetails = document.getElementById("applicationDetails");
        
        // Get all "View Details" buttons
        const viewButtons = document.querySelectorAll(".view-application");
        
        // Add click event to all view buttons
        viewButtons.forEach(button => {
            button.addEventListener("click", function() {
                const applicationId = this.getAttribute("data-id");
                // Here you would normally make an AJAX call to get the application details
                // For now, we'll just use the row data
                const row = this.closest("tr");
                
                // Get data from the row
                const animalInfo = row.querySelector(".animal-info").innerHTML;
                const dateInfo = row.querySelector(".date-info").innerHTML;
                const status = row.querySelector(".status-badge").outerHTML;
                const notes = row.querySelector("td:nth-child(4)").innerHTML;
                
                // Populate modal
                applicationDetails.innerHTML = `
                    <div class="application-detail-item">
                        <h4>Animal Information</h4>
                        <div class="animal-info-container">
                            ${animalInfo}
                        </div>
                    </div>
                    <div class="application-detail-item">
                        <h4>Application Status</h4>
                        <p>${status}</p>
                    </div>
                    <div class="application-detail-item">
                        <h4>Date Submitted</h4>
                        <p>${dateInfo}</p>
                    </div>
                    <div class="application-detail-item">
                        <h4>Notes</h4>
                        <div>${notes}</div>
                    </div>
                `;
                
                // Show modal
                modal.style.display = "block";
            });
        });
        
        // Close modal when clicking the X
        closeBtn.onclick = function() {
            modal.style.display = "none";
        }
        
        // Close modal when clicking the Close button
        closeModalBtn.onclick = function() {
            modal.style.display = "none";
        }
        
        // Close modal when clicking outside of it
        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
        
        // Mobile menu toggle
        const burger = document.querySelector('.burger');
        const navLinks = document.querySelector('.nav-links');
        
        burger.addEventListener('click', function() {
            navLinks.classList.toggle('active');
        });
        
        // Logout functionality
        document.getElementById('logoutBtn').addEventListener('click', function(e) {
            e.preventDefault();
            window.location.href = 'logout.php';
        });
    </script>
</body>
</html>

<?php
// Close database connection
$stmt->close();
$userStmt->close();
$countStmt->close();
$conn->close();
?>
<?php
// Start session
session_start();

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    // User is not logged in, redirect to login page
    header("Location: login.php");
    exit();
}

// Database connection
$host = "localhost";
$dbname = "paws";
$username = "root"; // Change this to your database username
$password = "2424"; // Change this to your database password

// Process favorite action if requested (add or remove)
$message = "";
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action']) && isset($_POST['animal_id'])) {
    $action = $_POST['action'];
    $animal_id = $_POST['animal_id'];
    $user_id = $_SESSION['user_id'];
    
    try {
        // Create a new PDO instance
        $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
        
        // Set the PDO error mode to exception
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        if ($action == "add") {
            // Check if already favorited
            $check_sql = "SELECT * FROM favorites WHERE user_id = :user_id AND animal_id = :animal_id";
            $check_stmt = $pdo->prepare($check_sql);
            $check_stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
            $check_stmt->bindParam(":animal_id", $animal_id, PDO::PARAM_INT);
            $check_stmt->execute();
            
            if ($check_stmt->rowCount() == 0) {
                // Insert new favorite
                $insert_sql = "INSERT INTO favorites (user_id, animal_id, created_at) VALUES (:user_id, :animal_id, NOW())";
                $insert_stmt = $pdo->prepare($insert_sql);
                $insert_stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
                $insert_stmt->bindParam(":animal_id", $animal_id, PDO::PARAM_INT);
                $insert_stmt->execute();
                $message = "Animal added to favorites successfully!";
            } else {
                $message = "This animal is already in your favorites.";
            }
        } elseif ($action == "remove") {
            // Remove from favorites
            $remove_sql = "DELETE FROM favorites WHERE user_id = :user_id AND animal_id = :animal_id";
            $remove_stmt = $pdo->prepare($remove_sql);
            $remove_stmt->bindParam(":user_id", $user_id, PDO::PARAM_INT);
            $remove_stmt->bindParam(":animal_id", $animal_id, PDO::PARAM_INT);
            $remove_stmt->execute();
            $message = "Animal removed from favorites successfully!";
        }
    } catch(PDOException $e) {
        $message = "Database error: " . $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Favorites - Paws & Hearts</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
    /* General Reset */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f5f6fa;
        color: #333;
    }
    a {
        text-decoration: none;
        color: inherit;
    }
    ul {
        list-style: none;
    }

    /* Header */
    header {
        background-color: #fff;
        border-bottom: 1px solid #ddd;
        padding: 1rem 0;
    }
    nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .logo h1 {
        font-size: 1.5rem;
        color: #e67e22;
    }
    .nav-links {
        display: flex;
        gap: 1rem;
    }
    .nav-links li a {
        padding: 0.5rem 1rem;
        color: #555;
        font-weight: 500;
    }
    .nav-links li a.active,
    .nav-links li a:hover {
        color: #e67e22;
    }
    .btn {
        background-color: #e67e22;
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 20px;
        font-weight: bold;
        border: none;
        cursor: pointer;
    }
    .btn:hover {
        background-color: #d35400;
    }
    .burger {
        display: none;
    }

    /* Container */
    .container {
        width: 90%;
        max-width: 1200px;
        margin: 0 auto;
    }

    /* Layout */
    .dashboard-container {
        display: flex;
        margin-top: 2rem;
        gap: 2rem;
    }
    .dashboard-sidebar {
        width: 250px;
        background-color: #fff;
        padding: 1rem;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
    }
    .dashboard-content {
        flex: 1;
    }

    /* Profile */
    .user-profile {
        text-align: center;
        margin-bottom: 2rem;
    }
    .profile-image img {
        width: 80px;
        height: 80px;
        border-radius: 50%;
    }
    .profile-info h3 {
        margin: 0.5rem 0 0.2rem;
    }
    .profile-info p {
        font-size: 0.9rem;
        color: #888;
    }

    /* Sidebar Navigation */
    .dashboard-menu ul li {
        margin: 0.7rem 0;
    }
    .dashboard-menu ul li a {
        display: flex;
        align-items: center;
        padding: 0.6rem;
        border-radius: 5px;
        color: #333;
        transition: background 0.3s;
    }
    .dashboard-menu ul li a i {
        margin-right: 0.6rem;
    }
    .dashboard-menu ul li a:hover,
    .dashboard-menu ul li.active a {
        background-color: #e67e22;
        color: white;
    }

    /* Dashboard Header */
    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
    }
    .dashboard-header h2 {
        font-size: 1.5rem;
    }

    /* Alert Message */
    .alert {
        padding: 1rem;
        margin-bottom: 1.5rem;
        border-radius: 5px;
        background-color: #f8f9fa;
        border-left: 4px solid #e67e22;
    }
    .alert.success {
        background-color: #d4edda;
        border-left-color: #28a745;
        color: #155724;
    }
    .alert.error {
        background-color: #f8d7da;
        border-left-color: #dc3545;
        color: #721c24;
    }

    /* Favorites Grid */
    .favorites-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 1.5rem;
    }
    .favorite-card {
        background-color: #fff;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
        transition: transform 0.3s ease;
    }
    .favorite-card:hover {
        transform: translateY(-5px);
    }
    .favorite-image {
        height: 180px;
        overflow: hidden;
        position: relative;
    }
    .favorite-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .favorite-heart {
        position: absolute;
        top: 10px;
        right: 10px;
        background-color: rgba(255, 255, 255, 0.9);
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    .favorite-heart i {
        color: #e74c3c;
        font-size: 1.2rem;
    }
    .favorite-heart:hover {
        background-color: #fff;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .favorite-info {
        padding: 1rem;
    }
    .favorite-info h3 {
        margin-bottom: 0.5rem;
        font-size: 1.2rem;
    }
    .favorite-meta {
        display: flex;
        justify-content: space-between;
        margin-bottom: 0.8rem;
        font-size: 0.9rem;
        color: #777;
    }
    .favorite-actions {
        display: flex;
        gap: 0.5rem;
    }
    .btn-sm {
        padding: 0.3rem 0.7rem;
        font-size: 0.85rem;
    }
    .empty-favorites {
        text-align: center;
        padding: 3rem;
        background-color: #fff;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
    }
    .empty-favorites i {
        font-size: 4rem;
        color: #ddd;
        margin-bottom: 1rem;
    }
    .empty-favorites h3 {
        margin-bottom: 1rem;
    }

    /* Footer */
    footer {
        margin-top: 3rem;
        background-color: #fff;
        padding: 1rem;
        text-align: center;
        font-size: 0.9rem;
        color: #999;
        border-top: 1px solid #ddd;
    }

    /* Responsive */
    @media (max-width: 992px) {
        .dashboard-container {
            flex-direction: column;
        }
        .dashboard-sidebar {
            width: 100%;
        }
    }
    @media (max-width: 768px) {
        .favorites-grid {
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        }
        .nav-links {
            display: none;
        }
        .burger {
            display: block;
            cursor: pointer;
        }
    }
    @media (max-width: 480px) {
        .favorites-grid {
            grid-template-columns: 1fr;
        }
        .favorite-actions {
            flex-direction: column;
        }
    }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="dashboard.php">Dashboard</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="#" id="logoutBtn" class="btn">Logout</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="dashboard">
        <div class="container">
            <div class="dashboard-container">
                <aside class="dashboard-sidebar">
                    <div class="user-profile">
                        <div class="profile-image">
                            <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80" alt="User profile">
                        </div>
                        <div class="profile-info">
                            <h3><?php echo $_SESSION['first_name'] . ' ' . $_SESSION['last_name']; ?></h3>
                            <p>Member since: <?php echo date('F Y', strtotime('-' . rand(1, 12) . ' months')); ?></p>
                        </div>
                    </div>
                    <nav class="dashboard-menu">
                        <ul>
                            <li><a href="dashboard.php"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                            <li><a href="dashboard-applications.php"><i class="fas fa-file-alt"></i> My Applications</a></li>
                            <li class="active"><a href="favorites.php"><i class="fas fa-heart"></i> Favorites</a></li>
                        </ul>
                    </nav>
                </aside>
                <main class="dashboard-content">
                    <div class="dashboard-header">
                        <h2>My Favorites</h2>
                        <div class="dashboard-actions">
                            <a href="animals.php" class="btn btn-primary"><i class="fas fa-paw"></i> Browse More Animals</a>
                        </div>
                    </div>
                    
                    <?php if (!empty($message)): ?>
                    <div class="alert <?php echo strpos($message, 'error') !== false ? 'error' : 'success'; ?>">
                        <?php echo $message; ?>
                    </div>
                    <?php endif; ?>
                    
                    <?php
                    try {
                        // Create a new PDO instance
                        $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
                        
                        // Set the PDO error mode to exception
                        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                        
                        // Get user's favorites with animal details
                        $sql = "SELECT a.*, f.created_at as favorited_at 
                                FROM favorites f 
                                JOIN animals a ON f.animal_id = a.id 
                                WHERE f.user_id = :user_id 
                                ORDER BY f.created_at DESC";
                        
                        $stmt = $pdo->prepare($sql);
                        $stmt->bindParam(":user_id", $_SESSION['user_id'], PDO::PARAM_INT);
                        $stmt->execute();
                        
                        $favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    } catch(PDOException $e) {
                        echo "<div class='alert error'>Database error: " . $e->getMessage() . "</div>";
                        $favorites = [];
                    }
                    ?>
                    
                    <?php if (count($favorites) > 0): ?>
                    <div class="favorites-grid">
                        <?php foreach ($favorites as $animal): ?>
                        <div class="favorite-card">
                            <div class="favorite-image">
                                <img src="<?php echo !empty($animal['image_url']) ? $animal['image_url'] : 'https://images.unsplash.com/photo-1601758125946-6ec2ef64daf8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80'; ?>" alt="<?php echo $animal['name']; ?>">
                                <form method="post" class="favorite-heart-form">
                                    <input type="hidden" name="animal_id" value="<?php echo $animal['id']; ?>">
                                    <input type="hidden" name="action" value="remove">
                                    <button type="submit" class="favorite-heart" title="Remove from favorites">
                                        <i class="fas fa-heart"></i>
                                    </button>
                                </form>
                            </div>
                            <div class="favorite-info">
                                <h3><?php echo $animal['name']; ?></h3>
                                <div class="favorite-meta">
                                    <span><i class="fas fa-paw"></i> <?php echo ucfirst($animal['species']); ?></span>
                                    <span><i class="fas fa-birthday-cake"></i> <?php echo $animal['age']; ?> years</span>
                                </div>
                                <p><?php echo substr($animal['description'], 0, 80) . '...'; ?></p>
                                <div class="favorite-actions">
                                    <a href="animal-details.php?id=<?php echo $animal['id']; ?>" class="btn btn-sm">View Details</a>
                                    <a href="apply.php?id=<?php echo $animal['id']; ?>" class="btn btn-sm">Apply to Adopt</a>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <?php else: ?>
                    <div class="empty-favorites">
                        <i class="far fa-heart"></i>
                        <h3>No Favorites Yet</h3>
                        <p>You haven't added any animals to your favorites list.</p>
                        <a href="animals.php" class="btn">Find Animals to Love</a>
                    </div>
                    <?php endif; ?>
                </main>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Toggle mobile navigation
        const burger = document.querySelector('.burger');
        const navLinks = document.querySelector('.nav-links');
        
        if (burger) {
            burger.addEventListener('click', function() {
                navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
            });
        }
        
        // Logout functionality
        document.getElementById('logoutBtn').addEventListener('click', function(e) {
            e.preventDefault();
            // Create a form to post to logout.php
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'logout.php';
            document.body.appendChild(form);
            form.submit();
        });
    });
    </script>
</body>
</html>
<?php
// Database connection
$db_host = 'localhost';
$db_user = 'root';  // Change as per your MySQL credentials
$db_pass = '2424';      // Change as per your MySQL credentials
$db_name = 'paws';

// Create connection
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
<?php
session_start();
require 'db.php'; // Assumes you have a DB connection file

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

$user_id = $_SESSION['user_id'];

// Fetch user's favorite animals
$sql = "SELECT a.id, a.name, a.breed, a.animal_type, a.image_url, a.age_group, a.gender 
        FROM favorites f
        JOIN animals a ON f.animal_id = a.id
        WHERE f.user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
?>

<!DOCTYPE html>
<html>
<head>
    <title>My Favorites</title>
    <style>
        .animal-card {
            border: 1px solid #ccc;
            border-radius: 10px;
            padding: 10px;
            margin: 10px;
            display: inline-block;
            width: 200px;
            text-align: center;
        }
        .animal-card img {
            width: 100%;
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <h2>Your Favorite Animals</h2>
    <div class="animal-list">
        <?php
        if ($result->num_rows > 0) {
            while ($animal = $result->fetch_assoc()) {
                echo '<div class="animal-card">';
                echo '<img src="' . htmlspecialchars($animal['image_url']) . '" alt="' . htmlspecialchars($animal['name']) . '">';
                echo '<h4>' . htmlspecialchars($animal['name']) . '</h4>';
                echo '<p>Type: ' . htmlspecialchars($animal['animal_type']) . '</p>';
                echo '<p>Breed: ' . htmlspecialchars($animal['breed']) . '</p>';
                echo '<p>Age: ' . htmlspecialchars($animal['age_group']) . '</p>';
                echo '<p>Gender: ' . htmlspecialchars($animal['gender']) . '</p>';
                echo '</div>';
            }
        } else {
            echo "<p>You haven't added any favorites yet.</p>";
        }
        ?>
    </div>
</body>
</html>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paws & Hearts - Animal Adoption</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: Arial, sans-serif;
    }

    body {
        line-height: 1.6;
        background: #fefefe;
        color: #333;
    }

    a {
        text-decoration: none;
        color: inherit;
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }

    header {
        background: #ff6f61;
        padding: 15px 0;
    }

    nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
    }

    .logo h1 {
        color: #fff;
        font-size: 1.8rem;
    }

    .nav-links {
        list-style: none;
        display: flex;
        gap: 20px;
    }

    .nav-links li a {
        color: #fff;
        font-weight: bold;
        padding: 8px 12px;
        border-radius: 5px;
    }

    .nav-links li a.active, .nav-links li a:hover {
        background: #fff;
        color: #ff6f61;
    }

    .btn {
        background: #fff;
        color: #ff6f61;
        padding: 8px 16px;
        border-radius: 5px;
        font-weight: bold;
    }

    .hero {
        background: url('https://images.unsplash.com/photo-1518717758536-85ae29035b6d') center/cover no-repeat;
        color: #fff;
        padding: 100px 0;
        text-align: center;
    }

    .hero h1 {
        font-size: 2.5rem;
        margin-bottom: 20px;
    }

    .hero p {
        font-size: 1.2rem;
        margin-bottom: 30px;
    }

    .hero-buttons a {
        margin: 0 10px;
    }

    .btn-primary {
        background: #fff;
        color: #ff6f61;
    }

    .btn-secondary {
        background: transparent;
        border: 2px solid #fff;
        color: #fff;
    }

    .how-it-works, .featured-animals, .about, .contact {
        padding: 60px 0;
        text-align: center;
    }

    .steps {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-around;
        margin-top: 40px;
    }

    .step {
        flex: 1 1 200px;
        padding: 20px;
    }

    .step-icon {
        font-size: 2rem;
        margin-bottom: 15px;
        color: #ff6f61;
    }

    .animals-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        justify-content: center;
        margin-top: 30px;
    }

    .about-content {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 40px;
        text-align: left;
    }

    .about-text {
        flex: 1;
    }

    .about-image img {
        width: 100%;
        max-width: 500px;
        border-radius: 10px;
    }

    .contact-container {
        display: flex;
        flex-wrap: wrap;
        gap: 40px;
        justify-content: space-between;
        text-align: left;
    }

    .contact-info {
        flex: 1;
    }

    .contact-form {
        flex: 1;
    }

    .form-group {
        margin-bottom: 15px;
    }

    .form-group input, .form-group textarea {
        width: 100%;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    footer {
        background: #333;
        color: #fff;
        padding-top: 40px;
    }

    .footer-content {
        display: flex;
        flex-wrap: wrap;
        gap: 40px;
        justify-content: space-between;
        padding-bottom: 20px;
    }

    .footer-section h3 {
        margin-bottom: 15px;
    }

    .footer-section ul {
        list-style: none;
    }

    .footer-section ul li {
        margin-bottom: 8px;
    }

    .footer-section ul li a {
        color: #fff;
        font-size: 0.9rem;
    }

    .newsletter-form {
        display: flex;
        gap: 10px;
        margin-top: 10px;
    }

    .newsletter-form input {
        flex: 1;
        padding: 8px;
        border: none;
        border-radius: 5px;
    }

    .newsletter-form button {
        padding: 8px 12px;
        background: #ff6f61;
        border: none;
        color: #fff;
        border-radius: 5px;
    }

    .footer-bottom {
        background: #222;
        text-align: center;
        padding: 10px 0;
        font-size: 0.9rem;
    }

    .social-links a {
        margin-right: 10px;
        color: #fff;
        font-size: 1.2rem;
    }

    .burger {
        display: none;
        font-size: 1.5rem;
        color: #fff;
        cursor: pointer;
    }

    @media (max-width: 768px) {
        .nav-links {
            display: none;
            flex-direction: column;
            background: #ff6f61;
            position: absolute;
            top: 70px;
            right: 20px;
            padding: 20px;
            border-radius: 8px;
        }

        .burger {
            display: block;
        }

        .about-content, .contact-container {
            flex-direction: column;
        }

        .steps {
            flex-direction: column;
            align-items: center;
        }
    }
</style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php" class="active">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="about.html">About</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="dashboard.php" class="btn">My Dashboard</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="hero">
        <div class="container">
            <div class="hero-content">
                <h1>Find Your Perfect Furry Friend</h1>
                <p>Thousands of animals are waiting for a loving home. Could you be their perfect match?</p>
                <div class="hero-buttons">
                    <a href="animals.php" class="btn btn-primary">Adopt Now</a>
                    <a href="#how-it-works" class="btn btn-secondary">How It Works</a>
                </div>
            </div>
        </div>
    </section>

    <section id="how-it-works" class="how-it-works">
        <div class="container">
            <h2>How Our Adoption Process Works</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-icon"><i class="fas fa-search"></i></div>
                    <h3>1. Browse Animals</h3>
                    <p>View our available animals and find one that matches your lifestyle.</p>
                </div>
                <div class="step">
                    <div class="step-icon"><i class="fas fa-file-alt"></i></div>
                    <h3>2. Submit Application</h3>
                    <p>Fill out our adoption application form with your details.</p>
                </div>
                <div class="step">
                    <div class="step-icon"><i class="fas fa-home"></i></div>
                    <h3>3. Home Visit</h3>
                    <p>We'll schedule a home visit to ensure a good match.</p>
                </div>
                <div class="step">
                    <div class="step-icon"><i class="fas fa-heart"></i></div>
                    <h3>4. Finalize Adoption</h3>
                    <p>Complete paperwork and welcome your new family member!</p>
                </div>
            </div>
        </div>
    </section>

    <section class="featured-animals">
        <div class="container">
            <h2>Featured Pets</h2>
            <div class="animals-grid" id="featured-animals">
                <!-- Dynamically loaded from animals.js -->
            </div>
            <div class="text-center">
                <a href="animals.php" class="btn btn-primary">View All Animals</a>
            </div>
        </div>
    </section>

    <section id="about" class="about">
        <div class="container">
            <div class="about-content">
                <div class="about-text">
                    <h2>About Paws & Hearts</h2>
                    <p>We are a non-profit organization dedicated to rescuing abandoned and abused animals and finding them loving forever homes. Since our founding in 2010, we've helped over 5,000 animals find their perfect families.</p>
                    <p>Our team of volunteers and staff work tirelessly to provide medical care, rehabilitation, and love to animals in need until they can be placed with adopters who will cherish them.</p>
                    <a href="#" class="btn btn-secondary">Learn More About Us</a>
                </div>
                <div class="about-image">
                    <img src="https://images.unsplash.com/photo-1455103493930-a116f655b6c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Volunteer with dog">
                </div>
            </div>
        </div>
    </section>

    <section id="contact" class="contact">
        <div class="container">
            <h2>Contact Us</h2>
            <div class="contact-container">
                <div class="contact-info">
                    <h3>Get in Touch</h3>
                    <p><i class="fas fa-map-marker-alt"></i> 123 Pet Lane, Animal City, AC 12345</p>
                    <p><i class="fas fa-phone"></i> (123) 456-7890</p>
                    <p><i class="fas fa-envelope"></i> info@pawsandhearts.org</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-facebook"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
                <form class="contact-form">
                    <div class="form-group">
                        <input type="text" placeholder="Your Name" required>
                    </div>
                    <div class="form-group">
                        <input type="email" placeholder="Your Email" required>
                    </div>
                    <div class="form-group">
                        <input type="text" placeholder="Subject">
                    </div>
                    <div class="form-group">
                        <textarea placeholder="Your Message" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Send Message</button>
                </form>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h3>Paws & Hearts</h3>
                    <p>Dedicated to rescuing animals and finding them loving homes since 2010.</p>
                </div>
                <div class="footer-section">
                    <h3>Quick Links</h3>
                    <ul>
                        <li><a href="home.php">Home</a></li>
                        <li><a href="animals.php">Adopt</a></li>
                        <li><a href="about.html">About Us</a></li>
                        <li><a href="contact.html">Contact</a></li>
                    </ul>
                </div>
                <div class="footer-section">
                    <h3>Adoption Info</h3>
                    <ul>
                        <li><a href="#">Adoption Process</a></li>
                        <li><a href="#">Fees</a></li>
                        <li><a href="#">Pre-Adoption Form</a></li>
                        <li><a href="#">FAQ</a></li>
                    </ul>
                </div>
                <div class="footer-section">
                    <h3>Newsletter</h3>
                    <p>Subscribe to our newsletter for updates on new arrivals and events.</p>
                    <form class="newsletter-form">
                        <input type="email" placeholder="Your Email">
                        <button type="submit"><i class="fas fa-paper-plane"></i></button>
                    </form>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <div class="container">
                <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script src="js/main.js"></script>
    <script src="js/animals.js"></script>
</body>
</html>
<?php
// Start session
session_start();

// Check if user is already logged in
if (isset($_SESSION['user_id'])) {
    // User is already logged in, redirect to home page
    header("Location: home.php");
    exit();
}

// Database connection - UPDATED CONNECTION METHOD
// Use try-catch to better handle connection errors
try {
    // First attempt: try with modified connection parameters
    $host = "127.0.0.1"; // Using IP instead of 'localhost' can resolve socket issues
    $dbname = "paws";
    $username = "root";
    $password = "2424";
    $port = 3306; // Explicitly specify the port
    
    // Create MySQL connection with PDO and explicit options
    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    
    $pdo = new PDO($dsn, $username, $password, $options);
    
    // Successfully connected!
} catch (PDOException $e) {
    // If first connection attempt failed, try alternative approach
    try {
        // Alternative: try connecting without database name first
        $dsn = "mysql:host=127.0.0.1;port=3306";
        $pdo = new PDO($dsn, $username, $password, $options);
        
        // Check if database exists, create it if it doesn't
        $stmt = $pdo->query("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$dbname'");
        if ($stmt->rowCount() === 0) {
            // Database doesn't exist - create it
            $pdo->exec("CREATE DATABASE `$dbname`");
        }
        
        // Now connect with the database name
        $pdo = new PDO("mysql:host=127.0.0.1;port=3306;dbname=$dbname", $username, $password, $options);
    } catch (PDOException $innerException) {
        // Both connection attempts failed - display error
        die("Database connection failed: " . $innerException->getMessage());
    }
}

// Initialize variables
$email = $password = "";
$email_err = $password_err = $login_err = "";

// Process form data when form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Add debug logging
    error_log("Form submitted");
    error_log("Email: " . $_POST["email"]);
    error_log("Password: " . $_POST["password"]);
    
    // Validate email
    if (empty(trim($_POST["email"]))) {
        $email_err = "Please enter your email.";
    } else {
        $email = trim($_POST["email"]);
    }
    
    // Validate password
    if (empty(trim($_POST["password"]))) {
        $password_err = "Please enter your password.";
    } else {
        $password = trim($_POST["password"]);
    }
    
    // Check if there are no validation errors
    if (empty($email_err) && empty($password_err)) {
        try {
            // Prepare a select statement
            $sql = "SELECT id, first_name, last_name, email, password, user_type FROM users WHERE email = :email";
            
            if ($stmt = $pdo->prepare($sql)) {
                // Bind variables to the prepared statement as parameters
                $stmt->bindParam(":email", $param_email, PDO::PARAM_STR);
                
                // Set parameters
                $param_email = $email;
                
                // Execute the prepared statement
                $stmt->execute();
                
                // Check if email exists
                if ($stmt->rowCount() == 1) {
                    if ($row = $stmt->fetch()) {
                        $id = $row["id"];
                        $firstname = $row["first_name"];
                        $lastname = $row["last_name"];
                        $email = $row["email"];
                        $hashed_password = $row["password"];
                        $user_type = $row["user_type"];
                        
                        // Verify password
                        if (password_verify($password, $hashed_password)) {
                            // Password is correct, start a new session
                            session_start();
                            
                            // Store data in session variables
                            $_SESSION["user_id"] = $id;
                            $_SESSION["first_name"] = $firstname;
                            $_SESSION["last_name"] = $lastname;
                            $_SESSION["email"] = $email;
                            $_SESSION["user_type"] = $user_type;
                            $_SESSION["loggedin"] = true;
                            
                            // Remember me functionality
                            if (isset($_POST["remember"]) && $_POST["remember"] == "on") {
                                // Create cookies that expire in 30 days
                                setcookie("user_email", $email, time() + (86400 * 30), "/");
                                setcookie("user_password", $password, time() + (86400 * 30), "/");
                            } else {
                                // Reset any existing cookies
                                if (isset($_COOKIE["user_email"])) {
                                    setcookie("user_email", "", time() - 3600, "/");
                                }
                                if (isset($_COOKIE["user_password"])) {
                                    setcookie("user_password", "", time() - 3600, "/");
                                }
                            }
                            
                            // Redirect user to home page
                            header("Location: home.php");
                            exit();
                        } else {
                            // Password is not valid
                            $login_err = "Invalid email or password.";
                        }
                    }
                } else {
                    // Email doesn't exist
                    $login_err = "Invalid email or password.";
                }
            } else {
                $login_err = "Oops! Something went wrong. Please try again later.";
            }
            
            // Close statement
            unset($stmt);
            
        } catch(PDOException $e) {
            $login_err = "Database error: " . $e->getMessage();
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Paws & Hearts</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
    /* Reset and base styles */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f9f9f9;
        color: #333;
        line-height: 1.6;
    }

    a {
        color: #e07a5f;
        text-decoration: none;
    }

    a:hover {
        text-decoration: underline;
    }

    .container {
        width: 90%;
        max-width: 1200px;
        margin: auto;
    }

    /* Header */
    header {
        background-color: #fff;
        padding: 20px 0;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    }

    nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .logo h1 {
        font-size: 1.8rem;
        color: #e07a5f;
    }

    .nav-links {
        list-style: none;
        display: flex;
        gap: 20px;
    }

    .nav-links li a {
        font-weight: 500;
        padding: 8px 12px;
        border-radius: 5px;
        transition: background 0.3s ease;
    }

    .nav-links li a:hover,
    .nav-links li a.btn {
        background-color: #e07a5f;
        color: white;
    }

    .burger {
        display: none;
        font-size: 24px;
        cursor: pointer;
    }

    /* Auth Section */
    .auth-section {
        padding: 60px 0;
        background-color: #fff;
    }

    .auth-container {
        display: flex;
        flex-wrap: wrap;
        gap: 40px;
        align-items: center;
        justify-content: center;
    }

    .auth-image img {
        max-width: 400px;
        width: 100%;
        border-radius: 10px;
    }

    .auth-form {
        max-width: 400px;
        width: 100%;
        background: #fefefe;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 0 15px rgba(0,0,0,0.05);
    }

    .auth-form h2 {
        color: #e07a5f;
        margin-bottom: 10px;
    }

    .auth-form p {
        margin-bottom: 20px;
    }

    .form-group {
        margin-bottom: 15px;
        position: relative;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
    }

    .form-group input {
        width: 100%;
        padding: 10px 35px 10px 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    .form-group i {
        position: absolute;
        top: 50%;
        right: 10px;
        transform: translateY(-50%);
        color: #888;
    }

    .form-options {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        font-size: 0.9rem;
    }

    .btn {
        display: inline-block;
        padding: 10px 20px;
        background-color: #e07a5f;
        color: #fff;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        transition: background 0.3s ease;
    }

    .btn:hover {
        background-color: #cf6143;
    }

    .btn-block {
        width: 100%;
        text-align: center;
    }

    .auth-alternative {
        text-align: center;
        margin-top: 15px;
    }

    .auth-social {
        margin-top: 30px;
        text-align: center;
    }

    .social-buttons {
        display: flex;
        justify-content: center;
        gap: 15px;
        margin-top: 10px;
    }

    .btn-social {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 15px;
        border: none;
        border-radius: 5px;
        color: #fff;
        cursor: pointer;
    }

    .btn-facebook {
        background-color: #3b5998;
    }

    .btn-google {
        background-color: #db4437;
    }

    footer {
        background-color: #f1f1f1;
        padding: 20px 0;
        text-align: center;
        font-size: 0.9rem;
        color: #666;
        margin-top: 40px;
    }

    /* Error message styling */
    .alert {
        padding: 10px;
        margin-bottom: 15px;
        border-radius: 5px;
        color: #721c24;
        background-color: #f8d7da;
        border: 1px solid #f5c6cb;
    }

    .text-danger {
        color: #dc3545;
        font-size: 0.85rem;
        margin-top: 5px;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .auth-container {
            flex-direction: column;
            text-align: center;
        }

        .nav-links {
            display: none;
        }

        .burger {
            display: block;
        }
    }
</style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.php">Animals</a></li>
                    <li><a href="about.html">About</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="register.php" class="btn">Register</a></li>
                    <li><a href="dashboard.html" class="btn">My Dashboard</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="auth-section">
        <div class="container">
            <div class="auth-container">
                <div class="auth-image">
                    <img src="https://images.unsplash.com/photo-1583511655826-05700442b31b?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Happy dog">
                </div>
                <div class="auth-form">
                    <h2>Welcome Back!</h2>
                    <p>Login to your account to continue your adoption journey.</p>
                    
                    <?php 
                    if(!empty($login_err)){
                        echo '<div class="alert">' . $login_err . '</div>';
                    }        
                    ?>
                    
                    <form id="loginForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" required value="<?php echo isset($_COOKIE['user_email']) ? $_COOKIE['user_email'] : $email; ?>">
                            <i class="fas fa-envelope"></i>
                            <?php if (!empty($email_err)) { echo '<span class="text-danger">' . $email_err . '</span>'; } ?>
                        </div>
                        <div class="form-group">
                            <label for="password">Password</label>
                            <input type="password" id="password" name="password" required value="<?php echo isset($_COOKIE['user_password']) ? $_COOKIE['user_password'] : ''; ?>">
                            <i class="fas fa-lock"></i>
                            <?php if (!empty($password_err)) { echo '<span class="text-danger">' . $password_err . '</span>'; } ?>
                        </div>
                        <div class="form-options">
                            <div class="remember-me">
                                <input type="checkbox" id="remember" name="remember" <?php if(isset($_COOKIE['user_email'])) { echo "checked"; } ?>>
                                <label for="remember">Remember me</label>
                            </div>
                            <a href="forgot_password.php" class="forgot-password">Forgot password?</a>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Login</button>
                        <div class="auth-alternative">
                            <p>Don't have an account? <a href="register.php">Register here</a></p>
                        </div>
                    </form>
                    
                    <div class="auth-social">
                        <p>Or login with</p>
                        <div class="social-buttons">
                            <button class="btn btn-social btn-facebook">
                                <i class="fab fa-facebook-f"></i> Facebook
                            </button>
                            <button class="btn btn-social btn-google">
                                <i class="fab fa-google"></i> Google
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Toggle navigation menu for mobile
        const burger = document.querySelector('.burger');
        const nav = document.querySelector('.nav-links');
        
        if(burger) {
            burger.addEventListener('click', function() {
                nav.style.display = nav.style.display === 'flex' ? 'none' : 'flex';
            });
        }
    });
    </script>
</body>
</html>
<?php
// Include database connection
require_once 'db.php';

// Initialize variables
$errors = [];
$success = false;

// Process form data when form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Validate and sanitize input
    $firstName = trim($_POST['firstName']);
    $lastName = trim($_POST['lastName']);
    $email = filter_var(trim($_POST['email']), FILTER_SANITIZE_EMAIL);
    $phone = trim($_POST['phone']);
    $address = trim($_POST['address']);
    $password = trim($_POST['password']);
    $confirmPassword = trim($_POST['confirmPassword']);
    $userType = trim($_POST['userType']);
    
    // Perform validation
    if (empty($firstName)) {
        $errors[] = "First name is required";
    }
    
    if (empty($lastName)) {
        $errors[] = "Last name is required";
    }
    
    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Valid email is required";
    } else {
        // Check if email already exists
        $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $errors[] = "Email already exists. Please use a different email or login.";
        }
        $stmt->close();
    }
    
    if (empty($phone)) {
        $errors[] = "Phone number is required";
    }
    
    if (empty($address)) {
        $errors[] = "Address is required";
    }
    
    if (empty($password)) {
        $errors[] = "Password is required";
    } elseif (strlen($password) < 8) {
        $errors[] = "Password must be at least 8 characters long";
    }
    
    if ($password !== $confirmPassword) {
        $errors[] = "Passwords do not match";
    }
    
    if (!isset($_POST['terms'])) {
        $errors[] = "You must agree to the Terms of Service and Privacy Policy";
    }
    
    // If no errors, insert user into database
    if (empty($errors)) {
        // Hash password for security
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        // Prepare statement to prevent SQL injection
        $stmt = $conn->prepare("INSERT INTO users (first_name, last_name, email, phone, address, password, user_type) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssss", $firstName, $lastName, $email, $phone, $address, $hashedPassword, $userType);
        
        if ($stmt->execute()) {
            $success = true;
            
            // Automatically log the user in (set session)
            session_start();
            $_SESSION['user_id'] = $stmt->insert_id;
            $_SESSION['first_name'] = $firstName;
            $_SESSION['last_name'] = $lastName;
            $_SESSION['email'] = $email;
            $_SESSION['user_type'] = $userType;
            
            // Redirect to home page after successful registration
            header("Location: home.php");
            exit();
        } else {
            $errors[] = "Registration failed: " . $conn->error;
        }
        
        $stmt->close();
    }
}

// Close the database connection
$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Paws & Hearts</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
    /* Base Reset */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #f9f9f9;
        color: #333;
    }

    a {
        color: #e07a5f;
        text-decoration: none;
    }

    a:hover {
        text-decoration: underline;
    }

    .container {
        width: 90%;
        max-width: 1200px;
        margin: auto;
    }

    /* Header */
    header {
        background-color: #fff;
        padding: 20px 0;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }

    nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .logo h1 {
        font-size: 1.8rem;
        color: #e07a5f;
    }

    .nav-links {
        list-style: none;
        display: flex;
        gap: 20px;
    }

    .nav-links li a {
        padding: 8px 12px;
        border-radius: 5px;
        font-weight: 500;
    }

    .nav-links li a:hover,
    .nav-links li a.btn {
        background-color: #e07a5f;
        color: white;
    }

    .burger {
        display: none;
        font-size: 24px;
        cursor: pointer;
    }

    /* Auth Section */
    .auth-section {
        padding: 60px 0;
        background-color: #fff;
    }

    .auth-container {
        display: flex;
        flex-wrap: wrap;
        gap: 40px;
        align-items: flex-start;
        justify-content: center;
    }

    .auth-image img {
        max-width: 400px;
        width: 100%;
        border-radius: 10px;
    }

    .auth-form {
        max-width: 600px;
        width: 100%;
        background: #fefefe;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 0 15px rgba(0,0,0,0.05);
    }

    .auth-form h2 {
        color: #e07a5f;
        margin-bottom: 10px;
    }

    .auth-form p {
        margin-bottom: 20px;
    }

    .form-group {
        margin-bottom: 15px;
        position: relative;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
    }

    .form-group input,
    .form-group select {
        width: 100%;
        padding: 10px 35px 10px 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    .form-group i {
        position: absolute;
        top: 50%;
        right: 10px;
        transform: translateY(-50%);
        color: #888;
    }

    .form-row {
        display: flex;
        gap: 15px;
    }

    .form-row .form-group {
        flex: 1;
    }

    .form-group.terms {
        display: flex;
        align-items: center;
        font-size: 0.9rem;
    }

    .form-group.terms input[type="checkbox"] {
        margin-right: 10px;
    }

    .btn {
        display: inline-block;
        padding: 10px 20px;
        background-color: #e07a5f;
        color: #fff;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        transition: background 0.3s ease;
    }

    .btn:hover {
        background-color: #cf6143;
    }

    .btn-block {
        width: 100%;
        text-align: center;
    }

    .auth-alternative {
        text-align: center;
        margin-top: 15px;
    }

    footer {
        background-color: #f1f1f1;
        padding: 20px 0;
        text-align: center;
        font-size: 0.9rem;
        color: #666;
        margin-top: 40px;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .auth-container {
            flex-direction: column;
            text-align: center;
        }

        .form-row {
            flex-direction: column;
        }

        .nav-links {
            display: none;
        }

        .burger {
            display: block;
        }
    }
    
    /* Error messages */
    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border: 1px solid transparent;
        border-radius: 5px;
    }
    
    .alert-danger {
        color: #721c24;
        background-color: #f8d7da;
        border-color: #f5c6cb;
    }
    
    .alert-success {
        color: #155724;
        background-color: #d4edda;
        border-color: #c3e6cb;
    }
</style>
</head>
<body>
    <header>
        <div class="container">
            <nav>
                <div class="logo">
                    <h1><i class="fas fa-paw"></i> Paws & Hearts</h1>
                </div>
                <ul class="nav-links">
                    <li><a href="home.php">Home</a></li>
                    <li><a href="animals.html">Animals</a></li>
                    <li><a href="about.html">About</a></li>
                    <li><a href="contact.html">Contact</a></li>
                    <li><a href="login.php" class="btn">Login</a></li>
                </ul>
                <div class="burger">
                    <i class="fas fa-bars"></i>
                </div>
            </nav>
        </div>
    </header>

    <section class="auth-section">
        <div class="container">
            <div class="auth-container">
                <div class="auth-image">
                    <img src="https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Happy cat">
                </div>
                <div class="auth-form">
                    <h2>Create Your Account</h2>
                    <p>Join our community to start your adoption journey today.</p>
                    
                    <?php if (!empty($errors)): ?>
                        <div class="alert alert-danger">
                            <?php foreach ($errors as $error): ?>
                                <p><?php echo $error; ?></p>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                    
                    <?php if ($success): ?>
                        <div class="alert alert-success">
                            <p>Registration successful! Redirecting to home page...</p>
                        </div>
                    <?php endif; ?>
                    
                    <form id="registerForm" method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="firstName">First Name</label>
                                <input type="text" id="firstName" name="firstName" required value="<?php echo isset($firstName) ? htmlspecialchars($firstName) : ''; ?>">
                                <i class="fas fa-user"></i>
                            </div>
                            <div class="form-group">
                                <label for="lastName">Last Name</label>
                                <input type="text" id="lastName" name="lastName" required value="<?php echo isset($lastName) ? htmlspecialchars($lastName) : ''; ?>">
                                <i class="fas fa-user"></i>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" required value="<?php echo isset($email) ? htmlspecialchars($email) : ''; ?>">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" id="phone" name="phone" required value="<?php echo isset($phone) ? htmlspecialchars($phone) : ''; ?>">
                            <i class="fas fa-phone"></i>
                        </div>
                        <div class="form-group">
                            <label for="address">Address</label>
                            <input type="text" id="address" name="address" required value="<?php echo isset($address) ? htmlspecialchars($address) : ''; ?>">
                            <i class="fas fa-home"></i>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="password">Password</label>
                                <input type="password" id="password" name="password" required>
                                <i class="fas fa-lock"></i>
                            </div>
                            <div class="form-group">
                                <label for="confirmPassword">Confirm Password</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" required>
                                <i class="fas fa-lock"></i>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="userType">I want to:</label>
                            <select id="userType" name="userType">
                                <option value="adopter" <?php echo (isset($userType) && $userType == 'adopter') ? 'selected' : ''; ?>>Adopt a pet</option>
                                <option value="volunteer" <?php echo (isset($userType) && $userType == 'volunteer') ? 'selected' : ''; ?>>Volunteer</option>
                                <option value="foster" <?php echo (isset($userType) && $userType == 'foster') ? 'selected' : ''; ?>>Foster pets</option>
                            </select>
                        </div>
                        <div class="form-group terms">
                            <input type="checkbox" id="terms" name="terms" required>
                            <label for="terms">I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a></label>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Register</button>
                        <div class="auth-alternative">
                            <p>Already have an account? <a href="login.php">Login here</a></p>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2023 Paws & Hearts Animal Adoption. All rights reserved.</p>
        </div>
    </footer>

    <script src="js/main.js"></script>
</body>
</html>
