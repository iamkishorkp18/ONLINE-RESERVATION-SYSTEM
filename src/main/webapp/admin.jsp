<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%
Integer isAdmin = (Integer) session.getAttribute("is_admin");
if (isAdmin == null || isAdmin != 1) {
    response.sendRedirect("index.html");
    return;
}
String adminId = (String) session.getAttribute("userid");
List<Map<String,String>> users    = (List<Map<String,String>>) request.getAttribute("users");
List<Map<String,String>> bookings = (List<Map<String,String>>) request.getAttribute("bookings");
int totalUsers       = request.getAttribute("totalUsers")        != null ? (int) request.getAttribute("totalUsers")        : 0;
int totalBookings    = request.getAttribute("totalBookings")     != null ? (int) request.getAttribute("totalBookings")     : 0;
int confirmedBookings= request.getAttribute("confirmedBookings") != null ? (int) request.getAttribute("confirmedBookings") : 0;
int cancelledBookings= request.getAttribute("cancelledBookings") != null ? (int) request.getAttribute("cancelledBookings") : 0;
String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KP Travels – Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&family=Inter:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; min-height:100vh; background:#f0f6ff; display:flex; }

        /* Sidebar */
        .sidebar {
            width:240px; min-height:100vh; background:linear-gradient(180deg,#071739,#0a2a6e);
            position:fixed; top:0; left:0; z-index:100; display:flex; flex-direction:column;
            padding:0 0 20px; box-shadow:4px 0 20px rgba(0,0,0,0.2);
        }
        .sidebar-logo {
            padding:24px 20px; border-bottom:1px solid rgba(255,255,255,0.08);
            font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:white;
            display:flex; align-items:center; gap:10px;
        }
        .sidebar-logo span { color:#00c6ff; }
        .sidebar-badge {
            background:rgba(255,230,109,0.15); border:1px solid rgba(255,230,109,0.3);
            color:#ffe66d; font-size:11px; font-weight:700; padding:2px 10px;
            border-radius:20px; margin:12px 20px; text-align:center; letter-spacing:1px;
        }
        .sidebar-menu { padding:10px 12px; flex:1; }
        .menu-item {
            display:flex; align-items:center; gap:12px; padding:11px 14px;
            border-radius:10px; color:rgba(255,255,255,0.7); font-size:14px;
            font-weight:500; cursor:pointer; transition:all 0.2s; text-decoration:none;
            margin-bottom:4px;
        }
        .menu-item:hover, .menu-item.active { background:rgba(255,255,255,0.10); color:white; }
        .menu-item i { width:18px; text-align:center; }
        .menu-label { font-size:11px; color:rgba(255,255,255,0.3); text-transform:uppercase; letter-spacing:1px; padding:14px 14px 6px; }
        .sidebar-footer { padding:14px 20px; border-top:1px solid rgba(255,255,255,0.08); }
        .sidebar-footer a { color:rgba(255,255,255,0.5); font-size:13px; text-decoration:none; display:flex; align-items:center; gap:8px; }
        .sidebar-footer a:hover { color:#ff8a8a; }

        /* Main Content */
        .main { margin-left:240px; flex:1; display:flex; flex-direction:column; min-height:100vh; }

        /* Top Bar */
        .topbar {
            background:white; padding:0 32px; height:68px; display:flex;
            align-items:center; justify-content:space-between;
            border-bottom:1px solid #e8edf5; position:sticky; top:0; z-index:50;
            box-shadow:0 2px 10px rgba(7,23,57,0.06);
        }
        .topbar h1 { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#071739; }
        .topbar-right { display:flex; align-items:center; gap:14px; }
        .admin-badge { background:rgba(255,230,109,0.15); border:1px solid rgba(255,230,109,0.4); color:#b8960a; font-size:12px; font-weight:700; padding:4px 12px; border-radius:20px; }

        /* Content Area */
        .content { padding:28px 32px; flex:1; }

        /* Toast */
        .toast { padding:12px 18px; border-radius:10px; font-size:14px; font-weight:600; margin-bottom:22px; display:flex; align-items:center; gap:10px; animation:slideIn 0.3s ease; }
        .toast.success { background:rgba(0,166,81,0.1);  border:1px solid rgba(0,166,81,0.3);  color:#00a651; }
        .toast.deleted { background:rgba(255,65,108,0.1); border:1px solid rgba(255,65,108,0.3); color:#ff416c; }
        @keyframes slideIn { from{opacity:0;transform:translateY(-8px);} to{opacity:1;transform:translateY(0);} }

        /* Stats Grid */
        .stats-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:18px; margin-bottom:28px; }
        .stat-card { background:white; border-radius:16px; padding:22px; box-shadow:0 4px 16px rgba(7,23,57,0.07); display:flex; align-items:center; gap:16px; }
        .stat-icon { width:52px; height:52px; border-radius:14px; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .stat-icon.blue   { background:rgba(0,198,255,0.12); }
        .stat-icon.green  { background:rgba(0,166,81,0.12);  }
        .stat-icon.red    { background:rgba(255,65,108,0.12);}
        .stat-icon.yellow { background:rgba(255,230,109,0.15);}
        .stat-num   { font-family:'Poppins',sans-serif; font-size:26px; font-weight:800; color:#071739; line-height:1; }
        .stat-label { font-size:13px; color:#888; margin-top:4px; }

        /* Section */
        .section { background:white; border-radius:18px; padding:24px; box-shadow:0 4px 16px rgba(7,23,57,0.07); margin-bottom:24px; }
        .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; padding-bottom:14px; border-bottom:1.5px solid #f0f0f0; }
        .section-header h2 { font-family:'Poppins',sans-serif; font-size:17px; font-weight:800; color:#071739; display:flex; align-items:center; gap:10px; }
        .count-badge { background:#f0f6ff; color:#0072ff; font-size:12px; font-weight:700; padding:3px 10px; border-radius:20px; }

        /* Search */
        .search-input {
            padding:8px 14px; border:1.5px solid #e0e8f0; border-radius:8px;
            font-size:14px; outline:none; font-family:'Inter',sans-serif; width:220px;
        }
        .search-input:focus { border-color:#00c6ff; }

        /* Table */
        .table-wrap { overflow-x:auto; }
        table { width:100%; border-collapse:collapse; font-size:14px; }
        thead th { background:#f8faff; color:#888; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:0.8px; padding:12px 14px; text-align:left; border-bottom:1.5px solid #f0f0f0; }
        tbody td { padding:13px 14px; border-bottom:1px solid #f5f5f5; color:#1a1a2e; vertical-align:middle; }
        tbody tr:hover { background:#fafcff; }
        tbody tr:last-child td { border-bottom:none; }

        /* Badges */
        .badge { display:inline-flex; align-items:center; gap:4px; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge.confirmed { background:rgba(0,166,81,0.1);  color:#00a651; }
        .badge.cancelled { background:rgba(255,65,108,0.1); color:#ff416c; }
        .badge.admin     { background:rgba(255,230,109,0.15); color:#b8960a; }
        .badge.user      { background:rgba(0,198,255,0.1);  color:#0072ff; }

        /* Action Buttons */
        .btn-sm {
            padding:6px 12px; border-radius:8px; font-size:12px; font-weight:600;
            font-family:'Poppins',sans-serif; cursor:pointer; border:none;
            display:inline-flex; align-items:center; gap:5px; transition:all 0.2s;
        }
        .btn-cancel { background:rgba(255,150,0,0.1); color:#e08000; border:1px solid rgba(255,150,0,0.3); }
        .btn-cancel:hover { background:rgba(255,150,0,0.2); }
        .btn-delete { background:rgba(255,65,108,0.1); color:#ff416c; border:1px solid rgba(255,65,108,0.3); }
        .btn-delete:hover { background:rgba(255,65,108,0.2); }

        /* Modal */
        .modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:200; align-items:center; justify-content:center; }
        .modal-overlay.show { display:flex; }
        .modal { background:white; border-radius:20px; padding:36px 32px; max-width:400px; width:90%; text-align:center; box-shadow:0 20px 60px rgba(0,0,0,0.3); animation:popIn 0.3s ease; }
        @keyframes popIn { from{transform:scale(0.8);opacity:0;} to{transform:scale(1);opacity:1;} }
        .modal-icon { font-size:48px; margin-bottom:14px; display:block; }
        .modal h3 { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#071739; margin-bottom:8px; }
        .modal p  { color:#666; font-size:14px; margin-bottom:24px; line-height:1.6; }
        .modal-highlight { font-family:'Poppins',sans-serif; font-weight:800; color:#ff416c; }
        .modal-btns { display:flex; gap:12px; }
        .modal-btn-keep    { flex:1; padding:12px; background:white; color:#071739; border:1.5px solid #e0e8f0; border-radius:10px; font-size:15px; font-weight:600; font-family:'Poppins',sans-serif; cursor:pointer; }
        .modal-btn-confirm { flex:1; padding:12px; color:white; border:none; border-radius:10px; font-size:15px; font-weight:700; font-family:'Poppins',sans-serif; cursor:pointer; width:100%; }
        .modal-btn-confirm.red    { background:linear-gradient(135deg,#ff416c,#ff4b2b); }
        .modal-btn-confirm.orange { background:linear-gradient(135deg,#ff9600,#e08000); }

        .footer { background:white; border-top:1px solid #e8edf5; padding:16px 32px; text-align:center; color:#aaa; font-size:13px; }

        @media(max-width:900px){
            .sidebar { width:200px; }
            .main { margin-left:200px; }
            .stats-grid { grid-template-columns:1fr 1fr; }
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-logo"><i class="fas fa-paper-plane"></i> KP <span>Travels</span></div>
    <div class="sidebar-badge">⭐ ADMIN PANEL</div>
    <nav class="sidebar-menu">
        <div class="menu-label">Dashboard</div>
        <a href="#dashboard" class="menu-item active"><i class="fas fa-chart-pie"></i> Overview</a>
        <div class="menu-label">Manage</div>
        <a href="#users" class="menu-item"><i class="fas fa-users"></i> All Users</a>
        <a href="#bookings" class="menu-item"><i class="fas fa-ticket-alt"></i> All Bookings</a>
    </nav>
    <div class="sidebar-footer">
        <a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</div>

<!-- Main -->
<div class="main">

    <!-- Top Bar -->
    <div class="topbar">
        <h1 id="dashboard"><i class="fas fa-shield-alt" style="color:#00c6ff;margin-right:10px;"></i>Admin Dashboard</h1>
        <div class="topbar-right">
            <span class="admin-badge">⭐ Admin: <%= adminId %></span>
        </div>
    </div>

    <div class="content">

        <!-- Toast -->
        <% if ("userdeleted".equals(msg)) { %>
        <div class="toast deleted"><i class="fas fa-trash-alt"></i> User and their bookings deleted successfully.</div>
        <% } else if ("cancelled".equals(msg)) { %>
        <div class="toast success"><i class="fas fa-check-circle"></i> Booking cancelled successfully.</div>
        <% } else if ("bookingdeleted".equals(msg)) { %>
        <div class="toast deleted"><i class="fas fa-trash-alt"></i> Booking deleted successfully.</div>
        <% } %>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">👥</div>
                <div><div class="stat-num"><%= totalUsers %></div><div class="stat-label">Total Users</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon yellow">🎫</div>
                <div><div class="stat-num"><%= totalBookings %></div><div class="stat-label">Total Bookings</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">✅</div>
                <div><div class="stat-num"><%= confirmedBookings %></div><div class="stat-label">Confirmed</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">❌</div>
                <div><div class="stat-num"><%= cancelledBookings %></div><div class="stat-label">Cancelled</div></div>
            </div>
        </div>

        <!-- Users Table -->
        <div class="section" id="users">
            <div class="section-header">
                <h2><i class="fas fa-users" style="color:#00c6ff;"></i> All Users <span class="count-badge"><%= totalUsers %></span></h2>
                <input type="text" class="search-input" placeholder="🔍 Search users..." onkeyup="searchTable(this,'usersTable')">
            </div>
            <div class="table-wrap">
                <table id="usersTable">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Gender</th>
                            <th>Role</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (users != null) { for (Map<String,String> u : users) {
                        boolean uIsAdmin = "1".equals(u.get("is_admin"));
                    %>
                    <tr>
                        <td><strong><%= u.get("userid") %></strong></td>
                        <td><%= u.get("fullname") != null ? u.get("fullname") : "—" %></td>
                        <td><%= u.get("email")    != null ? u.get("email")    : "—" %></td>
                        <td><%= u.get("phone") %></td>
                        <td><%= u.get("gender") %></td>
                        <td>
                            <span class="badge <%= uIsAdmin ? "admin" : "user" %>">
                                <i class="fas fa-<%= uIsAdmin ? "star" : "user" %>"></i>
                                <%= uIsAdmin ? "Admin" : "User" %>
                            </span>
                        </td>
                        <td>
                            <% if (!uIsAdmin) { %>
                            <button class="btn-sm btn-delete" onclick="confirmAction('deleteUser','<%= u.get("userid") %>','Delete user <%= u.get("userid") %>? All their bookings will also be deleted.')">
                                <i class="fas fa-trash-alt"></i> Delete
                            </button>
                            <% } else { %>
                            <span style="color:#aaa;font-size:12px;">Protected</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Bookings Table -->
        <div class="section" id="bookings">
            <div class="section-header">
                <h2><i class="fas fa-ticket-alt" style="color:#00c6ff;"></i> All Bookings <span class="count-badge"><%= totalBookings %></span></h2>
                <input type="text" class="search-input" placeholder="🔍 Search bookings..." onkeyup="searchTable(this,'bookingsTable')">
            </div>
            <div class="table-wrap">
                <table id="bookingsTable">
                    <thead>
                        <tr>
                            <th>PNR</th>
                            <th>User ID</th>
                            <th>Passenger</th>
                            <th>Route</th>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Class</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (bookings != null) { for (Map<String,String> b : bookings) {
                        boolean isCancelled = "CANCELLED".equals(b.get("status"));
                        String bIcon = "flight".equals(b.get("travel_type")) ? "✈️"
                                     : "bus".equals(b.get("travel_type"))    ? "🚌" : "🚆";
                    %>
                    <tr>
                        <td><strong style="color:#0072ff;"><%= b.get("pnr") %></strong></td>
                        <td><%= b.get("userid") %></td>
                        <td><%= b.get("name") %></td>
                        <td><%= b.get("fromPlace") %> → <%= b.get("toPlace") %></td>
                        <td><%= b.get("journeyDate") %></td>
                        <td><%= bIcon %> <%= b.get("travel_type").toUpperCase() %></td>
                        <td><%= b.get("classType") %></td>
                        <td>
                            <span class="badge <%= isCancelled ? "cancelled" : "confirmed" %>">
                                <i class="fas fa-circle" style="font-size:7px;"></i>
                                <%= b.get("status") %>
                            </span>
                        </td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap;">
                            <% if (!isCancelled) { %>
                            <button class="btn-sm btn-cancel" onclick="confirmAction('cancelBooking','<%= b.get("pnr") %>','Cancel booking PNR: <%= b.get("pnr") %>?')">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                            <% } %>
                            <button class="btn-sm btn-delete" onclick="confirmAction('deleteBooking','<%= b.get("pnr") %>','Permanently delete PNR: <%= b.get("pnr") %>?')">
                                <i class="fas fa-trash-alt"></i> Delete
                            </button>
                        </td>
                    </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <div class="footer">© 2026 KP Travels Admin Panel | All Rights Reserved</div>
</div>

<!-- Action Modal -->
<div class="modal-overlay" id="actionModal">
    <div class="modal">
        <span class="modal-icon">⚠️</span>
        <h3 id="modalTitle">Confirm Action</h3>
        <p id="modalMessage">Are you sure?</p>
        <div class="modal-btns">
            <button class="modal-btn-keep" onclick="closeModal()">Cancel</button>
            <form id="actionForm" action="AdminActionServlet" method="post" style="flex:1;">
                <input type="hidden" name="action" id="actionInput">
                <input type="hidden" name="userid" id="useridInput">
                <input type="hidden" name="pnr"    id="pnrInput">
                <button type="submit" class="modal-btn-confirm red" style="width:100%;" id="confirmBtn">Confirm</button>
            </form>
        </div>
    </div>
</div>

<script>
    function confirmAction(action, value, message) {
        document.getElementById('modalMessage').textContent = message;
        document.getElementById('actionInput').value = action;
        if (action === 'deleteUser') {
            document.getElementById('useridInput').value = value;
            document.getElementById('pnrInput').value    = '';
        } else {
            document.getElementById('pnrInput').value    = value;
            document.getElementById('useridInput').value = '';
        }
        document.getElementById('actionModal').classList.add('show');
    }

    function closeModal() {
        document.getElementById('actionModal').classList.remove('show');
    }

    document.getElementById('actionModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });

    // Search filter for tables
    function searchTable(input, tableId) {
        const filter = input.value.toLowerCase();
        const rows   = document.getElementById(tableId).getElementsByTagName('tr');
        for (let i = 1; i < rows.length; i++) {
            const text = rows[i].textContent.toLowerCase();
            rows[i].style.display = text.includes(filter) ? '' : 'none';
        }
    }

    // Sidebar smooth scroll
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function() {
            document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
            this.classList.add('active');
        });
    });
</script>
</body>
</html>