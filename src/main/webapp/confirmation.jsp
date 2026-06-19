<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%
String pnr         = (String) request.getAttribute("pnr");
String name        = (String) request.getAttribute("name");
String age         = (String) request.getAttribute("age");
String trainNo     = (String) request.getAttribute("trainNo");
String trainName   = (String) request.getAttribute("trainName");
String classType   = (String) request.getAttribute("classType");
String journeyDate = (String) request.getAttribute("journeyDate");
String fromPlace   = (String) request.getAttribute("fromPlace");
String toPlace     = (String) request.getAttribute("toPlace");
String travelType  = (String) request.getAttribute("travelType");
String fare        = (String) request.getAttribute("fare");
String paymentMethod = (String) request.getAttribute("paymentMethod");
if (travelType == null) travelType = "train";
if (paymentMethod == null) paymentMethod = "Online";
String icon = travelType.equals("flight") ? "✈️" : travelType.equals("bus") ? "🚌" : "🚆";

// Calculate total with GST
int fareInt = 0;
try { fareInt = Integer.parseInt(fare != null ? fare : "0"); } catch(Exception e) {}
int gst   = (int)(fareInt * 0.05);
int total = fareInt + gst;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KP Travels – Booking Confirmed</title>
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

        .page-wrap { margin-top:70px; padding:50px 20px; flex:1; display:flex; flex-direction:column; align-items:center; }

        /* Success Icon */
        .success-icon {
            width:80px; height:80px; background:linear-gradient(135deg,#00c6ff,#0072ff);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
            margin:0 auto 20px; animation:popIn 0.5s ease;
        }
        .success-icon i { color:white; font-size:36px; }
        @keyframes popIn { 0%{transform:scale(0);} 70%{transform:scale(1.15);} 100%{transform:scale(1);} }

        .confirm-title { font-family:'Poppins',sans-serif; font-size:28px; font-weight:800; color:#071739; text-align:center; margin-bottom:6px; }
        .confirm-sub   { color:#666; text-align:center; font-size:15px; margin-bottom:32px; }

        /* Ticket */
        .ticket {
            background:white; border-radius:20px; width:100%; max-width:580px;
            box-shadow:0 8px 32px rgba(7,23,57,0.12); overflow:hidden;
            animation:slideUp 0.5s ease; margin-bottom:24px;
        }
        @keyframes slideUp { from{opacity:0;transform:translateY(30px);} to{opacity:1;transform:translateY(0);} }

        .ticket-header {
            background:linear-gradient(135deg,#071739,#0a2a6e);
            padding:24px 28px; display:flex; align-items:center; justify-content:space-between;
        }
        .travel-icon { font-size:36px; }
        .pnr-label  { color:rgba(255,255,255,0.6); font-size:12px; letter-spacing:1px; text-transform:uppercase; }
        .pnr-number { color:#00c6ff; font-family:'Poppins',sans-serif; font-size:22px; font-weight:800; letter-spacing:2px; }

        .ticket-route {
            padding:24px 28px; display:flex; align-items:center; gap:12px;
            border-bottom:1.5px dashed #e0e8f0;
        }
        .route-city { flex:1; }
        .city-name  { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#071739; }
        .city-label { color:#888; font-size:12px; text-transform:uppercase; letter-spacing:1px; margin-top:2px; }
        .right-city { text-align:right; }
        .route-arrow { color:#00c6ff; font-size:22px; flex-shrink:0; }

        .ticket-details {
            padding:24px 28px; display:grid; grid-template-columns:1fr 1fr;
            gap:18px; border-bottom:1.5px dashed #e0e8f0;
        }
        .d-label { font-size:11px; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:4px; }
        .d-value { font-size:15px; font-weight:600; color:#1a1a2e; }

        /* Fare Breakdown */
        .fare-section { padding:20px 28px; border-bottom:1.5px dashed #e0e8f0; }
        .fare-row { display:flex; justify-content:space-between; font-size:14px; color:#666; margin-bottom:8px; }
        .fare-total { display:flex; justify-content:space-between; font-family:'Poppins',sans-serif; font-size:17px; font-weight:800; color:#071739; padding-top:10px; border-top:1.5px solid #f0f0f0; margin-top:4px; }
        .fare-total span:last-child { color:#0072ff; }

        .ticket-status { padding:18px 28px; display:flex; align-items:center; justify-content:space-between; }
        .status-badge { background:rgba(0,198,100,0.1); border:1px solid rgba(0,198,100,0.3); color:#00a651; padding:6px 18px; border-radius:20px; font-size:13px; font-weight:700; display:flex; align-items:center; gap:6px; }

        /* Action Buttons */
        .btn-row { display:flex; gap:14px; width:100%; max-width:580px; flex-wrap:wrap; }
        .btn-print {
            flex:1; padding:13px; background:linear-gradient(135deg,#00c6ff,#0072ff);
            color:white; border:none; border-radius:12px; font-size:15px; font-weight:700;
            font-family:'Poppins',sans-serif; cursor:pointer;
            display:flex; align-items:center; justify-content:center; gap:8px;
            transition:transform 0.15s, box-shadow 0.15s;
        }
        .btn-print:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,114,255,0.35); }
        .btn-download {
            flex:1; padding:13px; background:linear-gradient(135deg,#00a651,#007a3d);
            color:white; border:none; border-radius:12px; font-size:15px; font-weight:700;
            font-family:'Poppins',sans-serif; cursor:pointer;
            display:flex; align-items:center; justify-content:center; gap:8px;
            transition:transform 0.15s, box-shadow 0.15s;
        }
        .btn-download:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,166,81,0.35); }
        .btn-home {
            flex:1; padding:13px; background:white; color:#071739;
            border:1.5px solid #e0e8f0; border-radius:12px; font-size:15px; font-weight:600;
            font-family:'Poppins',sans-serif; cursor:pointer; text-decoration:none;
            display:flex; align-items:center; justify-content:center; gap:8px; transition:all 0.2s;
        }
        .btn-home:hover { border-color:#00c6ff; color:#0072ff; }

        .footer { background:#071739; color:rgba(255,255,255,0.4); text-align:center; padding:22px; font-size:13px; margin-top:auto; }

        /* ✅ PRINT STYLES — only ticket shows when printing */
        @media print {
            * { -webkit-print-color-adjust:exact !important; print-color-adjust:exact !important; }

            body { background:white !important; margin:0; padding:0; }

            /* Hide everything except ticket */
            .main-header,
            .success-icon,
            .confirm-title,
            .confirm-sub,
            .btn-row,
            .footer { display:none !important; }

            .page-wrap { margin:0 !important; padding:10px !important; }

            .ticket {
                box-shadow:none !important;
                border:2px solid #e0e8f0 !important;
                border-radius:12px !important;
                max-width:100% !important;
                width:100% !important;
                margin:0 !important;
                page-break-inside:avoid;
            }

            .ticket-header {
                background:linear-gradient(135deg,#071739,#0a2a6e) !important;
                -webkit-print-color-adjust:exact !important;
            }

            /* Watermark */
            .ticket::after {
                content:'KP TRAVELS';
                position:fixed;
                top:50%; left:50%;
                transform:translate(-50%,-50%) rotate(-45deg);
                font-size:80px;
                font-weight:900;
                color:rgba(0,198,255,0.06);
                pointer-events:none;
                z-index:0;
                font-family:'Poppins',sans-serif;
                letter-spacing:10px;
            }

            /* Print header */
            .print-header { display:block !important; }
        }

        .print-header {
            display:none;
            text-align:center;
            margin-bottom:16px;
            font-family:'Poppins',sans-serif;
        }
        .print-header h2 { font-size:22px; color:#071739; }
        .print-header p  { font-size:12px; color:#888; margin-top:4px; }

        @media(max-width:600px){
            .ticket-details { grid-template-columns:1fr; }
            .main-header { padding:0 16px; }
            .btn-row { flex-direction:column; }
        }
    </style>
</head>
<body>

<header class="main-header">
    <a href="home.jsp" class="header-logo"><i class="fas fa-paper-plane"></i> KP <span>Travels</span></a>
    <nav class="header-nav">
        <a href="home.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="BookingHistoryServlet"><i class="fas fa-list"></i> My Bookings</a>
        <a href="LogoutServlet" style="color:#ff8a8a;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<div class="page-wrap">

    <div class="success-icon"><i class="fas fa-check"></i></div>
    <h1 class="confirm-title">Booking Confirmed! 🎉</h1>
    <p class="confirm-sub">Your ticket is booked. Save or print your ticket below.</p>

    <!-- Print Header (only shows when printing) -->
    <div class="print-header">
        <h2>✈ KP Travels — E-Ticket</h2>
        <p>Booking Reference | Please carry this during your journey</p>
    </div>

    <div class="ticket" id="ticketToPrint">

        <div class="ticket-header">
            <div>
                <div class="pnr-label">PNR Number</div>
                <div class="pnr-number"><%= pnr %></div>
            </div>
            <div class="travel-icon"><%= icon %></div>
        </div>

        <div class="ticket-route">
            <div class="route-city">
                <div class="city-name"><%= fromPlace %></div>
                <div class="city-label">From</div>
            </div>
            <div class="route-arrow"><i class="fas fa-long-arrow-alt-right"></i></div>
            <div class="route-city right-city">
                <div class="city-name"><%= toPlace %></div>
                <div class="city-label">To</div>
            </div>
        </div>

        <div class="ticket-details">
            <div>
                <div class="d-label">Passenger Name</div>
                <div class="d-value"><%= name %></div>
            </div>
            <div>
                <div class="d-label">Age</div>
                <div class="d-value"><%= age %></div>
            </div>
            <div>
                <div class="d-label">Journey Date</div>
                <div class="d-value"><%= journeyDate %></div>
            </div>
            <div>
                <div class="d-label">Class / Seat</div>
                <div class="d-value"><%= classType %></div>
            </div>
            <div>
                <div class="d-label"><%= travelType.equals("flight") ? "Flight No" : "Train No" %></div>
                <div class="d-value"><%= trainNo != null && !trainNo.isEmpty() ? trainNo : "—" %></div>
            </div>
            <div>
                <div class="d-label">Service Name</div>
                <div class="d-value"><%= trainName != null && !trainName.isEmpty() ? trainName : "—" %></div>
            </div>
            <div>
                <div class="d-label">Travel Type</div>
                <div class="d-value"><%= travelType.toUpperCase() %></div>
            </div>
            <div>
                <div class="d-label">Payment Method</div>
                <div class="d-value"><%= paymentMethod %></div>
            </div>
        </div>

        <!-- Fare Breakdown -->
        <div class="fare-section">
            <div class="fare-row"><span>Base Fare</span><span>Rs. <%= fareInt %></span></div>
            <div class="fare-row"><span>GST (5%)</span><span>Rs. <%= gst %></span></div>
            <div class="fare-total"><span>Total Paid</span><span>Rs. <%= total %></span></div>
        </div>

        <div class="ticket-status">
            <span style="color:#666; font-size:13px;">Booked on: <%= new java.util.Date() %></span>
            <span class="status-badge"><i class="fas fa-circle" style="font-size:8px;"></i> CONFIRMED</span>
        </div>

    </div>

    <!-- Action Buttons -->
    <div class="btn-row">
        <button class="btn-print" onclick="printTicket()">
            <i class="fas fa-print"></i> Print Ticket
        </button>
        <button class="btn-download" onclick="downloadPDF()">
            <i class="fas fa-file-pdf"></i> Download PDF
        </button>
        <a href="home.jsp" class="btn-home">
            <i class="fas fa-home"></i> Back to Home
        </a>
    </div>

</div>

<footer class="footer">© 2026 KP Travels | All Rights Reserved</footer>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
<script>
    // ✅ Print Ticket
    function printTicket() {
        window.print();
    }

    // ✅ Download as PDF using html2pdf.js
    function downloadPDF() {
        const btn = document.querySelector('.btn-download');
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Generating PDF...';
        btn.disabled  = true;

        const ticket = document.getElementById('ticketToPrint');

        const opt = {
            margin:      [10, 10, 10, 10],
            filename:    'KPTravels_Ticket_<%= pnr %>.pdf',
            image:       { type:'jpeg', quality:0.98 },
            html2canvas: { scale:2, useCORS:true, backgroundColor:'#ffffff' },
            jsPDF:       { unit:'mm', format:'a5', orientation:'portrait' }
        };

        html2pdf().set(opt).from(ticket).save().then(() => {
            btn.innerHTML = '<i class="fas fa-check"></i> Downloaded!';
            btn.style.background = 'linear-gradient(135deg,#00a651,#007a3d)';
            setTimeout(() => {
                btn.innerHTML = '<i class="fas fa-file-pdf"></i> Download PDF';
                btn.disabled  = false;
                btn.style.background = '';
            }, 3000);
        });
    }
</script>

</body>
</html>