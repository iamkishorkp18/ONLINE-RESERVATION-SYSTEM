<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<%
String userid = (String)session.getAttribute("userid");
if(userid == null){
    response.sendRedirect("index.html");
    return;
}
String profileImage = (String)session.getAttribute("profileImage");
if(profileImage == null) profileImage = "https://cdn-icons-png.flaticon.com/512/847/847969.png";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>KP Travels – Online Reservation System</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&family=Inter:wght@400;500&display=swap" rel="stylesheet">
<style>
/* ── Reset & Base ── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
    --navy:   #071739;
    --sky:    #00c6ff;
    --gold:   #ffe66d;
    --white:  #ffffff;
    --light:  #f0f6ff;
    --glass:  rgba(255,255,255,0.12);
    --shadow: 0 8px 32px rgba(7,23,57,0.18);
}

html { scroll-behavior: smooth; }

body {
    font-family: 'Inter', sans-serif;
    background: #f0f6ff;
    color: #1a1a2e;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

/* ── Header ── */
.main-header {
    width: 100%;
    height: 70px;
    position: fixed;
    top: 0; left: 0; z-index: 100;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 40px;
    background: rgba(7,23,57,0.82);
    backdrop-filter: blur(14px);
    border-bottom: 1px solid rgba(255,255,255,0.08);
}

.header-logo {
    color: var(--white);
    font-family: 'Poppins', sans-serif;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 0.5px;
    display: flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
}

.header-logo span { color: var(--sky); }

.header-nav { display: flex; gap: 6px; align-items: center; }

.header-nav a {
    color: rgba(255,255,255,0.85);
    text-decoration: none;
    font-size: 15px;
    font-weight: 500;
    padding: 7px 16px;
    border-radius: 8px;
    transition: all 0.2s;
}

.header-nav a:hover { background: rgba(255,255,255,0.12); color: var(--white); }

.header-nav a.logout {
    background: rgba(255,100,100,0.15);
    color: #ff8a8a;
}
.header-nav a.logout:hover { background: rgba(255,100,100,0.28); color: #ffbcbc; }

.header-profile {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
}

.header-profile img {
    width: 42px; height: 42px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid var(--sky);
}

.header-profile span {
    color: var(--white);
    font-size: 14px;
    font-weight: 500;
}

/* ── Hero ── */
.hero {
    margin-top: 70px;
    min-height: 520px;
    background: linear-gradient(135deg, #071739 0%, #0a2a6e 50%, #0d3b8e 100%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 60px 20px 80px;
    position: relative;
    overflow: hidden;
}

.hero::before {
    content: '';
    position: absolute;
    width: 600px; height: 600px;
    background: radial-gradient(circle, rgba(0,198,255,0.15) 0%, transparent 70%);
    top: -100px; right: -100px;
    pointer-events: none;
}

.hero-badge {
    display: inline-block;
    background: rgba(0,198,255,0.15);
    border: 1px solid rgba(0,198,255,0.4);
    color: var(--sky);
    font-size: 13px;
    font-weight: 600;
    padding: 5px 16px;
    border-radius: 20px;
    margin-bottom: 20px;
    letter-spacing: 1px;
    text-transform: uppercase;
}

.hero h1 {
    font-family: 'Poppins', sans-serif;
    font-size: clamp(28px, 5vw, 52px);
    font-weight: 800;
    color: var(--white);
    line-height: 1.15;
    margin-bottom: 16px;
}

.hero h1 span { color: var(--gold); }

.hero p {
    color: rgba(255,255,255,0.72);
    font-size: 17px;
    max-width: 520px;
    margin-bottom: 40px;
    line-height: 1.6;
}

/* ── Search Box ── */
.search-box {
    background: var(--white);
    border-radius: 16px;
    padding: 28px 32px;
    width: 100%;
    max-width: 820px;
    box-shadow: var(--shadow);
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    align-items: flex-end;
}

.search-field {
    display: flex;
    flex-direction: column;
    flex: 1;
    min-width: 160px;
}

.search-field label {
    font-size: 12px;
    font-weight: 600;
    color: #888;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 6px;
}

.search-field select,
.search-field input {
    border: 1.5px solid #e0e8f0;
    border-radius: 10px;
    padding: 11px 14px;
    font-size: 15px;
    color: #1a1a2e;
    background: #f8faff;
    font-family: 'Inter', sans-serif;
    outline: none;
    transition: border 0.2s;
}

.search-field select:focus,
.search-field input:focus { border-color: var(--sky); background: #fff; }

.search-btn {
    background: linear-gradient(135deg, #00c6ff, #0072ff);
    color: white;
    border: none;
    border-radius: 10px;
    padding: 12px 28px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    font-family: 'Poppins', sans-serif;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: transform 0.15s, box-shadow 0.15s;
    white-space: nowrap;
}

.search-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,114,255,0.35); }

/* ── Section Titles ── */
.section-title {
    text-align: center;
    margin-bottom: 40px;
}

.section-title h2 {
    font-family: 'Poppins', sans-serif;
    font-size: 30px;
    font-weight: 800;
    color: var(--navy);
}

.section-title p { color: #666; margin-top: 8px; font-size: 15px; }

.section-title .line {
    width: 50px; height: 4px;
    background: linear-gradient(90deg, var(--sky), #0072ff);
    border-radius: 2px;
    margin: 12px auto 0;
}

/* ── Services ── */
.services-section {
    padding: 70px 40px;
    background: var(--light);
}

.services-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 24px;
    max-width: 1100px;
    margin: 0 auto;
}

.service-card {
    background: white;
    border-radius: 18px;
    padding: 34px 28px;
    text-align: center;
    box-shadow: 0 4px 20px rgba(7,23,57,0.08);
    transition: transform 0.25s, box-shadow 0.25s;
    border: 1.5px solid transparent;
    cursor: pointer;
}

.service-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 12px 36px rgba(7,23,57,0.14);
    border-color: var(--sky);
}

.service-icon {
    font-size: 48px;
    margin-bottom: 18px;
    display: block;
}

.service-card h3 {
    font-family: 'Poppins', sans-serif;
    font-size: 20px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 10px;
}

.service-card p { color: #666; font-size: 14px; line-height: 1.6; margin-bottom: 22px; }

.book-btn {
    display: inline-block;
    background: linear-gradient(135deg, #00c6ff, #0072ff);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 10px 24px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    font-family: 'Poppins', sans-serif;
    text-decoration: none;
    transition: opacity 0.2s, transform 0.15s;
}

.book-btn:hover { opacity: 0.9; transform: scale(1.03); }

/* ── Why Us ── */
.why-section {
    padding: 70px 40px;
    background: white;
}

.why-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 28px;
    max-width: 1100px;
    margin: 0 auto;
}

.why-card {
    text-align: center;
    padding: 28px 20px;
}

.why-icon {
    width: 64px; height: 64px;
    background: linear-gradient(135deg, rgba(0,198,255,0.12), rgba(0,114,255,0.12));
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 18px;
    font-size: 26px;
}

.why-card h4 {
    font-family: 'Poppins', sans-serif;
    font-size: 17px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 8px;
}

.why-card p { color: #777; font-size: 14px; line-height: 1.6; }

/* ── Stats Bar ── */
.stats-bar {
    background: linear-gradient(135deg, #071739, #0a2a6e);
    padding: 50px 40px;
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 40px;
}

.stat-item { text-align: center; }

.stat-item .number {
    font-family: 'Poppins', sans-serif;
    font-size: 38px;
    font-weight: 800;
    color: var(--sky);
    line-height: 1;
}

.stat-item .label {
    color: rgba(255,255,255,0.65);
    font-size: 14px;
    margin-top: 6px;
}

/* ── Footer ── */
.footer {
    background: var(--navy);
    color: white;
    padding: 60px 40px 0;
    margin-top: auto;
}

.footer-grid {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr 1fr;
    gap: 40px;
    max-width: 1100px;
    margin: 0 auto 50px;
    flex-wrap: wrap;
}

.footer-brand h2 {
    font-family: 'Poppins', sans-serif;
    font-size: 22px;
    font-weight: 800;
    color: var(--sky);
    margin-bottom: 12px;
}

.footer-brand p { color: rgba(255,255,255,0.6); font-size: 14px; line-height: 1.7; max-width: 260px; }

.footer-col h4 {
    font-family: 'Poppins', sans-serif;
    font-size: 15px;
    font-weight: 700;
    color: var(--sky);
    margin-bottom: 16px;
}

.footer-col a {
    display: block;
    color: rgba(255,255,255,0.65);
    text-decoration: none;
    font-size: 14px;
    margin-bottom: 10px;
    transition: color 0.2s;
}

.footer-col a:hover { color: white; }

.footer-col p { color: rgba(255,255,255,0.65); font-size: 14px; margin-bottom: 10px; }

.social-links { display: flex; gap: 14px; margin-top: 6px; }

.social-links a {
    width: 38px; height: 38px;
    background: rgba(255,255,255,0.08);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 16px;
    text-decoration: none;
    transition: background 0.2s;
}

.social-links a:hover { background: var(--sky); }

.footer-bottom {
    border-top: 1px solid rgba(255,255,255,0.1);
    text-align: center;
    padding: 18px 0;
    color: rgba(255,255,255,0.4);
    font-size: 13px;
    max-width: 1100px;
    margin: 0 auto;
}

/* ── Responsive ── */
@media (max-width: 768px) {
    .main-header { padding: 0 16px; }
    .header-nav a { padding: 6px 10px; font-size: 13px; }
    .services-section, .why-section { padding: 50px 20px; }
    .search-box { padding: 20px; }
    .footer { padding: 40px 20px 0; }
    .footer-grid { grid-template-columns: 1fr 1fr; }
    .hero { padding: 50px 16px 70px; }
}

@media (max-width: 480px) {
    .footer-grid { grid-template-columns: 1fr; }
    .header-profile span { display: none; }
}
</style>
</head>
<body>

<!-- ── Header ── -->
<header class="main-header">
    <a href="home.jsp" class="header-logo">
        <i class="fas fa-paper-plane"></i>
        KP <span>Travels</span>
    </a>

    <nav class="header-nav">
        <a href="home.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="BookingHistoryServlet"><i class="fas fa-ticket-alt"></i> Bookings</a>
        <a href="ProfileServlet"><i class="fas fa-user"></i> Profile</a>
        <a href="cancel.html"><i class="fas fa-times-circle"></i> Cancel</a>
        <a href="about.html"><i class="fas fa-info-circle"></i> About</a>
        <a href="LogoutServlet" class="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>

    <div class="header-profile" onclick="location.href='ProfileServlet'">
        <img src="<%= profileImage %>" alt="Profile">
        
    </div>
</header>

<!-- ── Hero ── -->
<section class="hero">
    <div class="hero-badge"><i class="fas fa-bolt"></i> Fast & Secure Booking</div>
    <h1>Travel Smarter with<br><span>KP Travels</span></h1>
    <p>Book trains, buses, and flights across India in seconds. One platform for all your travel needs.</p>

    <!-- Search Box -->
    <div class="search-box">
        <div class="search-field">
            <label><i class="fas fa-bus"></i> Travel Type</label>
            <select id="travelType">
                <option value="">Select Type</option>
                <option value="train">🚆 Train</option>
                <option value="bus">🚌 Bus</option>
                <option value="flight">✈ Flight</option>
            </select>
        </div>
        <div class="search-field">
            <label><i class="fas fa-map-marker-alt"></i> From</label>
            <input type="text" id="fromCity" placeholder="e.g. Hyderabad">
        </div>
        <div class="search-field">
            <label><i class="fas fa-map-pin"></i> To</label>
            <input type="text" id="toCity" placeholder="e.g. Chennai">
        </div>
        <div class="search-field">
            <label><i class="fas fa-calendar"></i> Date</label>
            <input type="date" id="travelDate">
        </div>
        <button class="search-btn" onclick="handleSearch()">
            <i class="fas fa-search"></i> Search
        </button>
    </div>
</section>

<!-- ── Services ── -->
<section class="services-section">
    <div class="section-title">
        <h2>Our Services</h2>
        <p>Choose from our wide range of travel options</p>
        <div class="line"></div>
    </div>

    <div class="services-grid">
        <div class="service-card">
            <span class="service-icon">🚆</span>
            <h3>Train Reservation</h3>
            <p>Book train tickets across India with real-time seat availability and instant confirmation.</p>
            <a href="reservation.html?type=train" class="book-btn">Book Train</a>
        </div>

        <div class="service-card">
            <span class="service-icon">🚌</span>
            <h3>Bus Reservation</h3>
            <p>Reserve seats in top bus services. Sleeper, semi-sleeper, and AC options available.</p>
            <a href="reservation.html?type=bus" class="book-btn">Book Bus</a>
        </div>

        <div class="service-card">
            <span class="service-icon">✈️</span>
            <h3>Flight Reservation</h3>
            <p>Find and book domestic and international flights at the best available prices.</p>
            <a href="reservation.html?type=flight" class="book-btn">Book Flight</a>
        </div>

        <div class="service-card">
            <span class="service-icon">📋</span>
            <h3>My Bookings</h3>
            <p>View, manage, and cancel your existing reservations from one convenient place.</p>
            <a href="BookingHistoryServlet" class="book-btn">View Bookings</a>
        </div>
    </div>
</section>

<!-- ── Stats ── -->
<div class="stats-bar">
    <div class="stat-item">
        <div class="number">50K+</div>
        <div class="label">Happy Travellers</div>
    </div>
    <div class="stat-item">
        <div class="number">1,200+</div>
        <div class="label">Routes Available</div>
    </div>
    <div class="stat-item">
        <div class="number">98%</div>
        <div class="label">On-Time Bookings</div>
    </div>
    <div class="stat-item">
        <div class="number">24/7</div>
        <div class="label">Customer Support</div>
    </div>
</div>

<!-- ── Why Us ── -->
<section class="why-section">
    <div class="section-title">
        <h2>Why Choose KP Travels?</h2>
        <p>We make every journey comfortable and stress-free</p>
        <div class="line"></div>
    </div>

    <div class="why-grid">
        <div class="why-card">
            <div class="why-icon">⚡</div>
            <h4>Instant Booking</h4>
            <p>Confirm your seat in under 60 seconds with our fast and reliable booking engine.</p>
        </div>
        <div class="why-card">
            <div class="why-icon">🔒</div>
            <h4>Secure Payments</h4>
            <p>All transactions are encrypted and processed through trusted payment gateways.</p>
        </div>
        <div class="why-card">
            <div class="why-icon">🎫</div>
            <h4>Easy Cancellation</h4>
            <p>Cancel bookings hassle-free with transparent refund policies and quick processing.</p>
        </div>
        <div class="why-card">
            <div class="why-icon">📱</div>
            <h4>Mobile Friendly</h4>
            <p>Book on the go from any device — phone, tablet, or desktop — anytime, anywhere.</p>
        </div>
    </div>
</section>

<!-- ── Footer ── -->
<footer class="footer">
    <div class="footer-grid">
        <div class="footer-brand">
            <h2><i class="fas fa-paper-plane"></i> KP Travels</h2>
            <p>Explore more, worry less. One platform for all your travel reservations — fast, secure, and reliable.</p>
            <div class="social-links" style="margin-top:18px;">
                <a href="https://www.instagram.com/" target="_blank"><i class="fab fa-instagram"></i></a>
				<a href="https://www.facebook.com/"  target="_blank"><i class="fab fa-facebook"></i></a>
				<a href="https://www.linkedin.com/"  target="_blank"><i class="fab fa-linkedin"></i></a>
				<a href="https://www.twitter.com/"   target="_blank"><i class="fab fa-twitter"></i></a>
            </div>
        </div>

        <div class="footer-col">
            <h4>Quick Links</h4>
            <a href="home.jsp">Home</a>
            <a href="reservation.html">Book Ticket</a>
            <a href="cancel.html">Cancel Booking</a>
            <a href="ProfileServlet">My Profile</a>
        </div>

        <div class="footer-col">
            <h4>Services</h4>
            <a href="reservation.html?type=train">Train Booking</a>
            <a href="reservation.html?type=bus">Bus Booking</a>
            <a href="reservation.html?type=flight">Flight Booking</a>
        </div>

        <div class="footer-col">
           <h4>Contact Us</h4>
<p style="display:flex; align-items:center; gap:8px; margin-bottom:10px;">
    <span>📧</span>
    <a href="mailto:kptravels19@gmail.com" style="color:rgba(255,255,255,0.65);text-decoration:none;">kptravels19@gmail.com</a>
</p>
<p style="display:flex; align-items:center; gap:8px; margin-bottom:10px;">
    <span>📞</span>
    <a href="tel:+917416243708" style="color:rgba(255,255,255,0.65);text-decoration:none;">+91 7416243708</a>
</p>
<p style="display:flex; align-items:center; gap:8px; margin-bottom:10px;">
    <span>📍</span>
    <a href="https://maps.google.com/?q=Andhra+Pradesh,India" target="_blank" style="color:rgba(255,255,255,0.65);text-decoration:none;">Andhra Pradesh, India</a>
</p>
        </div>
    </div>

    <div class="footer-bottom">
        © 2026 KP Travels | All Rights Reserved | Designed with ❤ in India
    </div>
</footer>

<script>
// Set min date to today for travel date input
document.addEventListener('DOMContentLoaded', function() {
    const dateInput = document.getElementById('travelDate');
    const today = new Date().toISOString().split('T')[0];
    dateInput.min = today;
    dateInput.value = today;
});

// Search handler — redirects to reservation page with query params
function handleSearch() {
    const type  = document.getElementById('travelType').value;
    const from  = document.getElementById('fromCity').value.trim();
    const to    = document.getElementById('toCity').value.trim();
    const date  = document.getElementById('travelDate').value;

    if (!type) { alert('Please select a travel type.'); return; }
    if (!from) { alert('Please enter your departure city.'); return; }
    if (!to)   { alert('Please enter your destination city.'); return; }
    if (!date) { alert('Please select a travel date.'); return; }

    const params = new URLSearchParams({ type, from, to, date });
    window.location.href = 'reservation.html?' + params.toString();
}
</script>

</body>
</html>
