<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%
String userid = (String) session.getAttribute("userid");
if (userid == null) {
    response.sendRedirect("index.html");
    return;
}
List<Map<String, String>> bookings =
    (List<Map<String, String>>) request.getAttribute("bookings");
String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KP Travels – My Bookings</title>
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

        .page-wrap { margin-top:90px; padding:30px 20px; flex:1; max-width:900px; margin-left:auto; margin-right:auto; width:100%; }

        .page-title { margin-bottom:28px; }
        .page-title h1 { font-family:'Poppins',sans-serif; font-size:28px; font-weight:800; color:#071739; }
        .page-title p  { color:#666; margin-top:4px; font-size:15px; }

        /* Toast */
        .toast {
            padding:14px 20px; border-radius:12px; font-size:14px; font-weight:600;
            margin-bottom:24px; display:flex; align-items:center; gap:10px;
            animation:slideIn 0.4s ease;
        }
        .toast.success { background:rgba(0,166,81,0.1);  border:1px solid rgba(0,166,81,0.3);  color:#00a651; }
        .toast.deleted { background:rgba(255,65,108,0.1); border:1px solid rgba(255,65,108,0.3); color:#ff416c; }
        .toast.error   { background:rgba(255,150,0,0.1);  border:1px solid rgba(255,150,0,0.3);  color:#ff9600; }
        @keyframes slideIn { from{opacity:0;transform:translateY(-10px);} to{opacity:1;transform:translateY(0);} }

        /* Stats */
        .stats-row { display:flex; gap:16px; margin-bottom:28px; flex-wrap:wrap; }
        .stat-card { flex:1; min-width:140px; background:white; border-radius:14px; padding:18px 20px; box-shadow:0 4px 16px rgba(7,23,57,0.07); display:flex; align-items:center; gap:14px; }
        .stat-icon { width:44px; height:44px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .stat-icon.blue  { background:rgba(0,198,255,0.12); }
        .stat-icon.green { background:rgba(0,166,81,0.12);  }
        .stat-icon.red   { background:rgba(255,65,108,0.12);}
        .stat-num   { font-family:'Poppins',sans-serif; font-size:22px; font-weight:800; color:#071739; }
        .stat-label { font-size:12px; color:#888; }

        /* Filter */
        .filter-tabs { display:flex; gap:8px; margin-bottom:20px; flex-wrap:wrap; }
        .filter-btn { padding:8px 18px; border-radius:20px; border:1.5px solid #e0e8f0; background:white; font-size:13px; font-weight:600; cursor:pointer; color:#555; transition:all 0.2s; font-family:'Poppins',sans-serif; }
        .filter-btn.active, .filter-btn:hover { background:linear-gradient(135deg,#00c6ff,#0072ff); color:white; border-color:transparent; }

        /* Empty */
        .empty-state { text-align:center; padding:60px 20px; }
        .empty-state .empty-icon { font-size:60px; margin-bottom:16px; display:block; }
        .empty-state h3 { font-family:'Poppins',sans-serif; font-size:20px; color:#071739; margin-bottom:8px; }
        .empty-state p  { color:#888; margin-bottom:24px; }
        .btn-book { display:inline-block; padding:12px 28px; background:linear-gradient(135deg,#00c6ff,#0072ff); color:white; border-radius:12px; text-decoration:none; font-weight:700; font-family:'Poppins',sans-serif; font-size:15px; }

        /* Booking Card */
        .booking-card { background:white; border-radius:18px; margin-bottom:18px; box-shadow:0 4px 20px rgba(7,23,57,0.08); border:1.5px solid transparent; transition:border 0.2s, transform 0.2s; overflow:hidden; }
        .booking-card:hover { border-color:#00c6ff; transform:translateY(-2px); }
        .booking-card.cancelled { opacity:0.75; }

        .card-header { background:linear-gradient(135deg,#071739,#0a2a6e); padding:16px 24px; display:flex; align-items:center; justify-content:space-between; }
        .card-header .left { display:flex; align-items:center; gap:12px; }
        .travel-icon { font-size:26px; }
        .pnr-num    { color:#00c6ff; font-family:'Poppins',sans-serif; font-size:16px; font-weight:800; letter-spacing:1px; }
        .booked-on  { color:rgba(255,255,255,0.5); font-size:12px; margin-top:2px; }

        .status-pill { padding:5px 14px; border-radius:20px; font-size:12px; font-weight:700; display:flex; align-items:center; gap:5px; }
        .status-pill.confirmed { background:rgba(0,166,81,0.2);  color:#00a651; border:1px solid rgba(0,166,81,0.3); }
        .status-pill.cancelled { background:rgba(255,65,108,0.2); color:#ff416c; border:1px solid rgba(255,65,108,0.3); }

        .card-body { padding:20px 24px; }
        .route-row { display:flex; align-items:center; gap:12px; margin-bottom:18px; padding-bottom:16px; border-bottom:1.5px dashed #f0f0f0; }
        .route-city { flex:1; }
        .city  { font-family:'Poppins',sans-serif; font-size:18px; font-weight:800; color:#071739; }
        .label { font-size:11px; color:#aaa; text-transform:uppercase; letter-spacing:1px; margin-top:2px; }
        .right-city { text-align:right; }
        .route-mid { text-align:center; color:#00c6ff; font-size:18px; flex-shrink:0; }

        .details-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:18px; }
        .d-label { font-size:11px; color:#aaa; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:3px; }
        .d-value { font-size:14px; font-weight:600; color:#1a1a2e; }

        /* Card Footer Buttons */
        .card-footer { display:flex; justify-content:flex-end; gap:10px; padding-top:4px; flex-wrap:wrap; }

        .btn-cancel-booking {
            padding:9px 18px; background:rgba(255,150,0,0.08);
            border:1.5px solid rgba(255,150,0,0.35); color:#e08000;
            border-radius:10px; font-size:13px; font-weight:600;
            font-family:'Poppins',sans-serif; cursor:pointer; transition:all 0.2s;
            display:flex; align-items:center; gap:6px;
        }
        .btn-cancel-booking:hover { background:rgba(255,150,0,0.16); }

        .btn-delete-booking {
            padding:9px 18px; background:rgba(255,65,108,0.08);
            border:1.5px solid rgba(255,65,108,0.3); color:#ff416c;
            border-radius:10px; font-size:13px; font-weight:600;
            font-family:'Poppins',sans-serif; cursor:pointer; transition:all 0.2s;
            display:flex; align-items:center; gap:6px;
        }
        .btn-delete-booking:hover { background:rgba(255,65,108,0.16); }

        .cancelled-label { padding:9px 18px; background:#f5f5f5; color:#aaa; border-radius:10px; font-size:13px; font-weight:600; display:flex; align-items:center; gap:6px; }

        /* Modals */
        .modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:200; align-items:center; justify-content:center; }
        .modal-overlay.show { display:flex; }
        .modal { background:white; border-radius:20px; padding:36px 32px; max-width:400px; width:90%; text-align:center; box-shadow:0 20px 60px rgba(0,0,0,0.3); animation:popIn 0.3s ease; }
        @keyframes popIn { from{transform:scale(0.8);opacity:0;} to{transform:scale(1);opacity:1;} }
        .modal-icon { font-size:50px; margin-bottom:14px; display:block; }
        .modal h3 { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#071739; margin-bottom:8px; }
        .modal p  { color:#666; font-size:14px; margin-bottom:24px; line-height:1.6; }
        .modal-pnr { font-family:'Poppins',sans-serif; font-weight:800; color:#00c6ff; }
        .modal-btns { display:flex; gap:12px; }
        .modal-btn-keep { flex:1; padding:12px; background:white; color:#071739; border:1.5px solid #e0e8f0; border-radius:10px; font-size:15px; font-weight:600; font-family:'Poppins',sans-serif; cursor:pointer; }
        .modal-btn-confirm { flex:1; padding:12px; color:white; border:none; border-radius:10px; font-size:15px; font-weight:700; font-family:'Poppins',sans-serif; cursor:pointer; width:100%; }
        .modal-btn-confirm.orange { background:linear-gradient(135deg,#ff9600,#e08000); }
        .modal-btn-confirm.red    { background:linear-gradient(135deg,#ff416c,#ff4b2b); }

        .footer { background:#071739; color:rgba(255,255,255,0.4); text-align:center; padding:22px; font-size:13px; margin-top:auto; }

        @media(max-width:600px){
            .details-grid{grid-template-columns:1fr 1fr;}
            .main-header{padding:0 16px;}
            .header-nav a{font-size:13px;padding:6px 8px;}
            .card-footer{justify-content:center;}
        }
    </style>
</head>
<body>

<header class="main-header">
    <a href="home.jsp" class="header-logo"><i class="fas fa-paper-plane"></i> KP <span>Travels</span></a>
    <nav class="header-nav">
        <a href="home.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="reservation.html"><i class="fas fa-ticket-alt"></i> Book</a>
        <a href="ProfileServlet"><i class="fas fa-user"></i> Profile</a>
        <a href="LogoutServlet" style="color:#ff8a8a;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<!-- Cancel Modal -->
<div class="modal-overlay" id="cancelModal">
    <div class="modal">
        <span class="modal-icon">⚠️</span>
        <h3>Cancel Booking?</h3>
        <p>Are you sure you want to cancel PNR <span class="modal-pnr" id="cancelModalPnr"></span>?<br>Status will change to CANCELLED.</p>
        <div class="modal-btns">
            <button class="modal-btn-keep" onclick="closeModal('cancelModal')">Keep It</button>
            <form id="cancelForm" action="CancelServlet" method="post" style="flex:1;">
                <input type="hidden" name="pnr"    id="cancelPnrInput">
                <input type="hidden" name="action" value="cancel">
                <button type="submit" class="modal-btn-confirm orange" style="width:100%;">Yes, Cancel</button>
            </form>
        </div>
    </div>
</div>

<!-- Delete Modal -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <span class="modal-icon">🗑️</span>
        <h3>Delete Booking?</h3>
        <p>Are you sure you want to permanently delete PNR <span class="modal-pnr" id="deleteModalPnr"></span>?<br><strong>This cannot be undone.</strong></p>
        <div class="modal-btns">
            <button class="modal-btn-keep" onclick="closeModal('deleteModal')">Keep It</button>
            <form id="deleteForm" action="CancelServlet" method="post" style="flex:1;">
                <input type="hidden" name="pnr"    id="deletePnrInput">
                <input type="hidden" name="action" value="delete">
                <button type="submit" class="modal-btn-confirm red" style="width:100%;">Yes, Delete</button>
            </form>
        </div>
    </div>
</div>

<div class="page-wrap">

    <div class="page-title">
        <h1><i class="fas fa-list-alt" style="color:#00c6ff;"></i> My Bookings</h1>
        <p>View and manage all your travel reservations</p>
    </div>

    <!-- Toast Messages -->
    <% if ("cancelled".equals(msg)) { %>
    <div class="toast success"><i class="fas fa-check-circle"></i> Booking cancelled. Refund will be processed in 5–7 days.</div>
    <% } else if ("deleted".equals(msg)) { %>
    <div class="toast deleted"><i class="fas fa-trash-alt"></i> Booking permanently deleted.</div>
    <% } else if ("error".equals(msg)) { %>
    <div class="toast error"><i class="fas fa-exclamation-circle"></i> Something went wrong. Please try again.</div>
    <% } %>

    <%
    int total = 0, confirmed = 0, cancelled = 0;
    if (bookings != null) {
        total = bookings.size();
        for (Map<String,String> b : bookings) {
            if ("CONFIRMED".equals(b.get("status"))) confirmed++;
            else cancelled++;
        }
    }
    %>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon blue">🎫</div>
            <div><div class="stat-num"><%= total %></div><div class="stat-label">Total Bookings</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">✅</div>
            <div><div class="stat-num"><%= confirmed %></div><div class="stat-label">Confirmed</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red">❌</div>
            <div><div class="stat-num"><%= cancelled %></div><div class="stat-label">Cancelled</div></div>
        </div>
    </div>

    <!-- Filter -->
    <div class="filter-tabs">
        <button class="filter-btn active" onclick="filterBookings('all', this)">All (<%= total %>)</button>
        <button class="filter-btn" onclick="filterBookings('confirmed', this)">Confirmed (<%= confirmed %>)</button>
        <button class="filter-btn" onclick="filterBookings('cancelled', this)">Cancelled (<%= cancelled %>)</button>
    </div>

    <!-- Cards -->
    <% if (bookings == null || bookings.isEmpty()) { %>
    <div class="empty-state">
        <span class="empty-icon">🎫</span>
        <h3>No Bookings Yet</h3>
        <p>You haven't made any reservations yet. Start your journey!</p>
        <a href="reservation.html" class="btn-book"><i class="fas fa-plus"></i> Book a Ticket</a>
    </div>
    <% } else { %>
    <div id="bookingsList">
    <% for (Map<String, String> b : bookings) {
        String type        = b.get("travel_type");
        String status      = b.get("status");
        String bIcon       = "flight".equals(type) ? "✈️" : "bus".equals(type) ? "🚌" : "🚆";
        boolean isCancelled = "CANCELLED".equals(status);
        String bookedOn    = b.get("booked_on");
        if (bookedOn != null && bookedOn.length() >= 10) bookedOn = bookedOn.substring(0,10);
        else bookedOn = "—";
    %>
    <div class="booking-card <%= isCancelled ? "cancelled" : "" %>" data-status="<%= status.toLowerCase() %>">

        <div class="card-header">
            <div class="left">
                <span class="travel-icon"><%= bIcon %></span>
                <div>
                    <div class="pnr-num">PNR: <%= b.get("pnr") %></div>
                    <div class="booked-on">Booked: <%= bookedOn %></div>
                </div>
            </div>
            <span class="status-pill <%= isCancelled ? "cancelled" : "confirmed" %>">
                <i class="fas fa-circle" style="font-size:8px;"></i> <%= status %>
            </span>
        </div>

        <div class="card-body">
            <div class="route-row">
                <div class="route-city">
                    <div class="city"><%= b.get("fromPlace") %></div>
                    <div class="label">From</div>
                </div>
                <div class="route-mid"><i class="fas fa-long-arrow-alt-right"></i></div>
                <div class="route-city right-city">
                    <div class="city"><%= b.get("toPlace") %></div>
                    <div class="label">To</div>
                </div>
            </div>

            <div class="details-grid">
                <div><div class="d-label">Passenger</div><div class="d-value"><%= b.get("name") %></div></div>
                <div><div class="d-label">Journey Date</div><div class="d-value"><%= b.get("journeyDate") %></div></div>
                <div><div class="d-label">Class</div><div class="d-value"><%= b.get("classType") %></div></div>
                <div><div class="d-label">Service Name</div><div class="d-value"><%= b.get("trainName") != null && !b.get("trainName").isEmpty() ? b.get("trainName") : "—" %></div></div>
                <div><div class="d-label">Train / Flight No</div><div class="d-value"><%= b.get("trainNo") != null && !b.get("trainNo").isEmpty() ? b.get("trainNo") : "—" %></div></div>
                <div><div class="d-label">Age</div><div class="d-value"><%= b.get("age") %></div></div>
            </div>

            <div class="card-footer">
                <% if (!isCancelled) { %>
                <!-- Cancel Button -->
                <button class="btn-cancel-booking" onclick="confirmCancel('<%= b.get("pnr") %>')">
                    <i class="fas fa-times-circle"></i> Cancel
                </button>
                <% } else { %>
                <span class="cancelled-label"><i class="fas fa-ban"></i> Cancelled</span>
                <% } %>
                <!-- Delete Button always visible -->
                <button class="btn-delete-booking" onclick="confirmDelete('<%= b.get("pnr") %>')">
                    <i class="fas fa-trash-alt"></i> Delete
                </button>
            </div>
        </div>
    </div>
    <% } %>
    </div>
    <% } %>

</div>

<footer class="footer">© 2026 KP Travels | All Rights Reserved</footer>

<script>
    function confirmCancel(pnr) {
        document.getElementById('cancelModalPnr').textContent = pnr;
        document.getElementById('cancelPnrInput').value       = pnr;
        document.getElementById('cancelModal').classList.add('show');
    }

    function confirmDelete(pnr) {
        document.getElementById('deleteModalPnr').textContent = pnr;
        document.getElementById('deletePnrInput').value       = pnr;
        document.getElementById('deleteModal').classList.add('show');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    // Close on outside click
    document.querySelectorAll('.modal-overlay').forEach(m => {
        m.addEventListener('click', function(e) {
            if (e.target === this) this.classList.remove('show');
        });
    });

    function filterBookings(type, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        document.querySelectorAll('.booking-card').forEach(card => {
            card.style.display = (type === 'all' || card.dataset.status === type) ? 'block' : 'none';
        });
    }
</script>
</body>
</html>