<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%
String fullname     = (String) request.getAttribute("fullname");
String email        = (String) request.getAttribute("email");
String age          = request.getAttribute("age") != null ? request.getAttribute("age").toString() : "";
String phone        = (String) request.getAttribute("phone");
String gender       = (String) request.getAttribute("gender");

// ✅ Check request → session → default (in that order)
String profileImage = (String) request.getAttribute("profileImage");
if (profileImage == null || profileImage.isEmpty())
    profileImage = (String) session.getAttribute("profileImage");
if (profileImage == null || profileImage.isEmpty())
    profileImage = "https://cdn-icons-png.flaticon.com/512/847/847969.png";

String userid = (String) session.getAttribute("userid");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KP Travels – My Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&family=Inter:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; min-height:100vh; background:#f0f6ff; display:flex; flex-direction:column; }

        .main-header {
            width:100%; height:70px; position:fixed; top:0; left:0; z-index:100;
            display:flex; align-items:center; justify-content:space-between; padding:0 40px;
            background:rgba(7,23,57,0.92); backdrop-filter:blur(14px);
            border-bottom:1px solid rgba(255,255,255,0.08);
        }
        .header-logo { color:white; font-family:'Poppins',sans-serif; font-size:22px; font-weight:800; text-decoration:none; display:flex; align-items:center; gap:10px; }
        .header-logo span { color:#00c6ff; }
        .header-nav { display:flex; gap:6px; }
        .header-nav a { color:rgba(255,255,255,0.8); text-decoration:none; font-size:15px; font-weight:500; padding:7px 14px; border-radius:8px; transition:all 0.2s; }
        .header-nav a:hover { background:rgba(255,255,255,0.12); color:white; }
        .header-nav a.logout { color:#ff8a8a; }

        .page-wrap { margin-top:70px; padding:50px 20px; flex:1; display:flex; flex-direction:column; align-items:center; }

        .toast {
            position:fixed; top:82px; right:24px; z-index:999;
            background:#071739; border:1px solid #00c6ff; color:white;
            padding:14px 22px; border-radius:12px; font-size:14px; font-weight:600;
            display:flex; align-items:center; gap:10px;
            box-shadow:0 8px 24px rgba(0,0,0,0.3);
            animation:slideIn 0.4s ease forwards;
        }
        .toast i { color:#00c6ff; font-size:18px; }
        @keyframes slideIn { from{opacity:0;transform:translateX(60px);} to{opacity:1;transform:translateX(0);} }

        .profile-banner {
            width:100%; max-width:780px;
            background:linear-gradient(135deg,#071739,#0a2a6e,#0d3b8e);
            border-radius:20px; padding:36px 40px;
            display:flex; align-items:center; gap:28px;
            box-shadow:0 8px 32px rgba(7,23,57,0.2); margin-bottom:32px;
            position:relative; overflow:hidden;
        }
        .profile-banner::before {
            content:''; position:absolute; width:300px; height:300px;
            background:radial-gradient(circle,rgba(0,198,255,0.15) 0%,transparent 70%);
            top:-80px; right:-60px; pointer-events:none;
        }
        .banner-avatar { position:relative; flex-shrink:0; }
        .banner-avatar img {
            width:90px; height:90px; border-radius:50%; object-fit:cover;
            border:3px solid #00c6ff; box-shadow:0 0 20px rgba(0,198,255,0.4);
        }
        .banner-avatar .edit-overlay {
            position:absolute; bottom:0; right:0; width:28px; height:28px;
            background:#00c6ff; border-radius:50%; display:flex; align-items:center;
            justify-content:center; color:white; font-size:12px; cursor:pointer; border:2px solid white;
        }
        .banner-info h2 { font-family:'Poppins',sans-serif; font-size:22px; font-weight:800; color:white; margin-bottom:4px; }
        .banner-info p  { color:rgba(255,255,255,0.6); font-size:14px; }
        .banner-info .user-id {
            display:inline-block; background:rgba(0,198,255,0.15);
            border:1px solid rgba(0,198,255,0.3); color:#00c6ff;
            font-size:12px; padding:3px 12px; border-radius:20px; margin-top:8px; letter-spacing:1px;
        }

        .form-card { background:white; border-radius:20px; padding:36px 40px; box-shadow:0 8px 32px rgba(7,23,57,0.10); width:100%; max-width:780px; }
        .form-card h3 { font-family:'Poppins',sans-serif; font-size:18px; font-weight:700; color:#071739; margin-bottom:24px; padding-bottom:14px; border-bottom:1.5px solid #f0f0f0; display:flex; align-items:center; gap:10px; }

        .image-upload-section {
            display:flex; align-items:center; gap:20px;
            background:#f8faff; border:1.5px dashed #c0d8f0;
            border-radius:14px; padding:20px; margin-bottom:24px;
        }
        .image-upload-section img { width:72px; height:72px; border-radius:50%; object-fit:cover; border:3px solid #00c6ff; }
        .upload-info { flex:1; }
        .upload-info p { font-size:13px; color:#888; margin-top:4px; }
        .upload-info label {
            display:inline-block; background:linear-gradient(135deg,#00c6ff,#0072ff);
            color:white; padding:8px 18px; border-radius:8px;
            font-size:13px; font-weight:600; font-family:'Poppins',sans-serif; cursor:pointer;
        }
        .upload-info input[type=file] { display:none; }

        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:18px; }
        .form-group { display:flex; flex-direction:column; }
        .form-group.full { grid-column:1/-1; }
        .form-group label { font-size:12px; font-weight:700; color:#888; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:6px; }
        .form-group input, .form-group select {
            padding:12px 14px; border:1.5px solid #e0e8f0; border-radius:10px;
            font-size:15px; color:#1a1a2e; background:#f8faff;
            font-family:'Inter',sans-serif; outline:none; transition:border 0.2s;
        }
        .form-group input:focus, .form-group select:focus { border-color:#00c6ff; background:white; }

        .btn-row { display:flex; gap:14px; margin-top:8px; }
        .btn-update {
            flex:1; padding:13px; background:linear-gradient(135deg,#00c6ff,#0072ff);
            color:white; border:none; border-radius:12px; font-size:16px; font-weight:700;
            font-family:'Poppins',sans-serif; cursor:pointer; transition:transform 0.15s, box-shadow 0.15s;
            display:flex; align-items:center; justify-content:center; gap:8px;
        }
        .btn-update:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,114,255,0.35); }
        .btn-back {
            padding:13px 24px; background:white; color:#071739; border:1.5px solid #e0e8f0;
            border-radius:12px; font-size:15px; font-weight:600; font-family:'Poppins',sans-serif;
            cursor:pointer; text-decoration:none; display:flex; align-items:center; gap:8px; transition:all 0.2s;
        }
        .btn-back:hover { border-color:#00c6ff; color:#0072ff; }

        .footer { background:#071739; color:rgba(255,255,255,0.4); text-align:center; padding:22px; font-size:13px; margin-top:auto; }

        @media(max-width:640px){
            .form-card{padding:24px 16px;} .form-grid{grid-template-columns:1fr;}
            .profile-banner{flex-direction:column;text-align:center;padding:28px 20px;}
            .main-header{padding:0 16px;} .header-nav a{font-size:13px;padding:6px 8px;} .btn-row{flex-direction:column;}
        }
    </style>
</head>
<body>

<header class="main-header">
    <a href="home.jsp" class="header-logo"><i class="fas fa-paper-plane"></i> KP <span>Travels</span></a>
    <nav class="header-nav">
        <a href="home.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="reservation.html"><i class="fas fa-ticket-alt"></i> Book</a>
        <a href="cancel.html"><i class="fas fa-times-circle"></i> Cancel</a>
        <a href="LogoutServlet" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<%
String savedMsg = (String) request.getAttribute("updateMsg");
if ("success".equals(savedMsg)) {
%>
<div class="toast" id="toast">
    <i class="fas fa-check-circle"></i> Profile updated successfully!
</div>
<script>
    setTimeout(() => {
        const t = document.getElementById('toast');
        if(t){ t.style.opacity='0'; t.style.transition='opacity 0.5s'; setTimeout(()=>t.remove(),500); }
    }, 3000);
</script>
<% } %>

<div class="page-wrap">

    <div class="profile-banner">
        <div class="banner-avatar">
            <img id="bannerImg" src="<%= profileImage %>" alt="Profile"
                 onerror="this.src='https://cdn-icons-png.flaticon.com/512/847/847969.png'">
            <div class="edit-overlay" onclick="document.getElementById('profileImageInput').click()">
                <i class="fas fa-camera"></i>
            </div>
        </div>
        <div class="banner-info">
            <h2><%= fullname != null ? fullname : "User" %></h2>
            <p><i class="fas fa-envelope" style="margin-right:6px;"></i><%= email != null ? email : "" %></p>
            <span class="user-id"><i class="fas fa-user"></i> <%= userid != null ? userid : "" %></span>
        </div>
    </div>

    <div class="form-card">
        <h3><i class="fas fa-user-edit" style="color:#00c6ff;"></i> Edit Profile</h3>

        <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">

            <div class="image-upload-section">
                <img id="previewImg" src="<%= profileImage %>" alt="Preview"
                     onerror="this.src='https://cdn-icons-png.flaticon.com/512/847/847969.png'">
                <div class="upload-info">
                    <label for="profileImageInput"><i class="fas fa-upload"></i> Choose Photo</label>
                    <input type="file" id="profileImageInput" name="profileImage"
                           accept="image/*" onchange="previewImage(event)">
                    <p>JPG, PNG or GIF — Max 2MB</p>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label><i class="fas fa-id-card"></i> Full Name</label>
                    <input type="text" name="fullname" value="<%= fullname != null ? fullname : "" %>" placeholder="Your full name">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-envelope"></i> Email Address</label>
                    <input type="email" name="email" value="<%= email != null ? email : "" %>" placeholder="your@email.com">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-birthday-cake"></i> Age</label>
                    <input type="number" name="age" value="<%= age %>" placeholder="Your age" min="1" max="120">
                </div>
                <div class="form-group">
                    <label><i class="fas fa-phone"></i> Phone Number</label>
                    <input type="text" name="phone" value="<%= phone != null ? phone : "" %>" placeholder="+91 XXXXX XXXXX">
                </div>
                <div class="form-group full">
                    <label><i class="fas fa-venus-mars"></i> Gender</label>
                    <select name="gender">
                        <option value="">Select Gender</option>
                        <option value="Male"   <%= "Male".equals(gender)   ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                        <option value="Other"  <%= "Other".equals(gender)  ? "selected" : "" %>>Other</option>
                    </select>
                </div>
            </div>

            <div class="btn-row">
                <a href="home.jsp" class="btn-back"><i class="fas fa-arrow-left"></i> Back</a>
                <button type="submit" class="btn-update"><i class="fas fa-save"></i> Save Changes</button>
            </div>

        </form>
    </div>
</div>

<footer class="footer">© 2026 KP Travels | All Rights Reserved</footer>

<script>
    function previewImage(event) {
        const file = event.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('previewImg').src = e.target.result;
            document.getElementById('bannerImg').src  = e.target.result;
        };
        reader.readAsDataURL(file);
    }
</script>
</body>
</html>