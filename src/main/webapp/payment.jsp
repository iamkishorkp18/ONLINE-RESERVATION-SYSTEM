<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%
String userid = (String) session.getAttribute("userid");
if (userid == null) { response.sendRedirect("index.html"); return; }

String name           = (String) request.getAttribute("name");
String age             = (String) request.getAttribute("age");
String passengerEmail  = (String) request.getAttribute("passengerEmail");
String passengerPhone  = (String) request.getAttribute("passengerPhone");
String trainNo         = (String) request.getAttribute("trainNo");
String trainName       = (String) request.getAttribute("trainName");
String classType       = (String) request.getAttribute("classType");
String journeyDate     = (String) request.getAttribute("journeyDate");
String fromPlace       = (String) request.getAttribute("fromPlace");
String toPlace         = (String) request.getAttribute("toPlace");
String travelType      = (String) request.getAttribute("travelType");
if (travelType == null) travelType = "train";
int fare = request.getAttribute("fare") != null ? (int) request.getAttribute("fare") : 1500;
String icon = "flight".equals(travelType) ? "✈️" : "bus".equals(travelType) ? "🚌" : "🚆";
int gst     = (int)(fare * 0.05);
int total   = fare + gst;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KP Travels – Payment</title>
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

        .page-wrap { margin-top:70px; padding:40px 20px; flex:1; display:flex; justify-content:center; align-items:flex-start; gap:28px; flex-wrap:wrap; max-width:1100px; margin-left:auto; margin-right:auto; width:100%; }

        /* Progress Bar */
        .progress-bar {
            width:100%; max-width:700px; margin:80px auto 0;
            display:flex; align-items:center; justify-content:center;
            padding:0 20px 30px;
        }
        .step { display:flex; flex-direction:column; align-items:center; gap:6px; }
        .step-circle {
            width:36px; height:36px; border-radius:50%;
            display:flex; align-items:center; justify-content:center;
            font-size:14px; font-weight:700; font-family:'Poppins',sans-serif;
        }
        .step-circle.done   { background:linear-gradient(135deg,#00c6ff,#0072ff); color:white; }
        .step-circle.active { background:linear-gradient(135deg,#00c6ff,#0072ff); color:white; box-shadow:0 0 0 4px rgba(0,198,255,0.2); }
        .step-circle.pending{ background:#e0e8f0; color:#aaa; }
        .step-label { font-size:12px; font-weight:600; color:#888; }
        .step-label.active  { color:#0072ff; }
        .step-line { flex:1; height:2px; background:#e0e8f0; margin:0 8px; margin-bottom:22px; }
        .step-line.done { background:linear-gradient(90deg,#00c6ff,#0072ff); }

        /* Left — Payment Form */
        .payment-card { background:white; border-radius:20px; padding:32px; box-shadow:0 8px 32px rgba(7,23,57,0.10); flex:1; min-width:300px; max-width:480px; }
        .payment-card h2 { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#071739; margin-bottom:24px; padding-bottom:14px; border-bottom:1.5px solid #f0f0f0; display:flex; align-items:center; gap:10px; }

        /* Payment Method Tabs */
        .pay-tabs { display:flex; gap:10px; margin-bottom:24px; flex-wrap:wrap; }
        .pay-tab {
            flex:1; min-width:80px; padding:12px 8px; border-radius:12px;
            border:1.5px solid #e0e8f0; background:white; cursor:pointer;
            text-align:center; transition:all 0.2s; font-family:'Poppins',sans-serif;
        }
        .pay-tab .tab-icon { font-size:22px; display:block; margin-bottom:4px; }
        .pay-tab .tab-label { font-size:12px; font-weight:600; color:#555; }
        .pay-tab.active { border-color:#00c6ff; background:rgba(0,198,255,0.06); }
        .pay-tab.active .tab-label { color:#0072ff; }

        /* Form Sections */
        .pay-section { display:none; }
        .pay-section.show { display:block; }

        .form-group { margin-bottom:18px; }
        .form-group label { display:block; font-size:12px; font-weight:700; color:#888; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:6px; }
        .form-group input, .form-group select {
            width:100%; padding:12px 14px; border:1.5px solid #e0e8f0; border-radius:10px;
            font-size:15px; color:#1a1a2e; background:#f8faff; font-family:'Inter',sans-serif; outline:none; transition:border 0.2s;
        }
        .form-group input:focus, .form-group select:focus { border-color:#00c6ff; background:white; }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }

        /* Card Preview */
        .card-preview {
            background:linear-gradient(135deg,#071739,#0a2a6e);
            border-radius:16px; padding:22px 24px; margin-bottom:22px; position:relative; overflow:hidden;
        }
        .card-preview::before {
            content:''; position:absolute; width:160px; height:160px;
            background:rgba(0,198,255,0.12); border-radius:50%; top:-40px; right:-40px;
        }
        .card-chip { font-size:28px; margin-bottom:14px; }
        .card-number-display { color:rgba(255,255,255,0.7); font-size:16px; letter-spacing:4px; margin-bottom:16px; font-family:'Poppins',sans-serif; }
        .card-bottom { display:flex; justify-content:space-between; align-items:flex-end; }
        .card-holder-label { color:rgba(255,255,255,0.5); font-size:10px; text-transform:uppercase; letter-spacing:1px; }
        .card-holder-name  { color:white; font-size:14px; font-weight:600; font-family:'Poppins',sans-serif; }
        .card-logo { color:#00c6ff; font-size:28px; }

        /* UPI Section */
        .upi-box {
            background:#f8faff; border:1.5px dashed #c0d8f0; border-radius:14px;
            padding:24px; text-align:center; margin-bottom:18px;
        }
        .upi-box .upi-icon { font-size:48px; margin-bottom:12px; display:block; }
        .upi-box p { color:#666; font-size:14px; margin-bottom:14px; }
        .upi-apps { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
        .upi-app {
            padding:8px 16px; border-radius:10px; border:1.5px solid #e0e8f0;
            background:white; font-size:13px; font-weight:600; cursor:pointer;
            color:#333; transition:all 0.2s; display:flex; align-items:center; gap:6px;
        }
        .upi-app.selected { border-color:#00c6ff; background:rgba(0,198,255,0.08); color:#0072ff; }
        .upi-app:hover { border-color:#00c6ff; }

        /* Netbanking */
        .bank-grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:18px; }
        .bank-item {
            padding:12px; border:1.5px solid #e0e8f0; border-radius:10px;
            text-align:center; font-size:13px; font-weight:600; cursor:pointer;
            transition:all 0.2s; color:#333; background:white;
        }
        .bank-item.selected { border-color:#00c6ff; background:rgba(0,198,255,0.08); color:#0072ff; }
        .bank-item:hover { border-color:#00c6ff; }

        /* Passenger Contact Box (NEW) */
        .contact-box {
            background:#f0f6ff; border:1.5px solid #c0d8f0; border-radius:12px;
            padding:14px 16px; margin-bottom:20px;
        }
        .contact-box .c-title {
            font-size:12px; font-weight:700; color:#0072ff; text-transform:uppercase;
            letter-spacing:0.8px; margin-bottom:8px; display:flex; align-items:center; gap:6px;
        }
        .contact-row { display:flex; align-items:center; gap:8px; font-size:13px; color:#333; margin-bottom:4px; }
        .contact-row i { color:#0072ff; width:16px; }

        /* Security Badge */
        .security-badge {
            display:flex; align-items:center; gap:8px; background:#f0fff4;
            border:1px solid #b2dfdb; border-radius:10px; padding:10px 14px;
            margin-bottom:20px; font-size:13px; color:#2e7d52;
        }
        .security-badge i { color:#00a651; }

        /* Pay Button */
        .btn-pay {
            width:100%; padding:15px; background:linear-gradient(135deg,#00c6ff,#0072ff);
            color:white; border:none; border-radius:12px; font-size:17px; font-weight:700;
            font-family:'Poppins',sans-serif; cursor:pointer; transition:transform 0.15s, box-shadow 0.15s;
            display:flex; align-items:center; justify-content:center; gap:10px;
        }
        .btn-pay:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,114,255,0.4); }

        /* Right — Order Summary */
        .summary-card { background:white; border-radius:20px; padding:28px; box-shadow:0 8px 32px rgba(7,23,57,0.10); width:100%; max-width:320px; height:fit-content; position:sticky; top:90px; }
        .summary-card h3 { font-family:'Poppins',sans-serif; font-size:17px; font-weight:800; color:#071739; margin-bottom:20px; padding-bottom:12px; border-bottom:1.5px solid #f0f0f0; }

        .summary-route {
            background:linear-gradient(135deg,#071739,#0a2a6e);
            border-radius:14px; padding:16px; margin-bottom:18px; text-align:center;
        }
        .summary-route .s-icon { font-size:28px; margin-bottom:8px; display:block; }
        .summary-route .s-route { color:white; font-family:'Poppins',sans-serif; font-size:15px; font-weight:700; }
        .summary-route .s-date  { color:rgba(255,255,255,0.6); font-size:12px; margin-top:4px; }

        .summary-item { display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid #f5f5f5; font-size:14px; }
        .summary-item:last-of-type { border-bottom:none; }
        .summary-item .s-label { color:#666; }
        .summary-item .s-value { font-weight:600; color:#1a1a2e; text-align:right; max-width:160px; word-break:break-word; }

        .summary-total { display:flex; justify-content:space-between; align-items:center; padding:14px 0 0; border-top:2px solid #f0f0f0; margin-top:6px; }
        .summary-total .t-label { font-family:'Poppins',sans-serif; font-size:16px; font-weight:800; color:#071739; }
        .summary-total .t-value { font-family:'Poppins',sans-serif; font-size:20px; font-weight:800; color:#0072ff; }

        .notify-note {
            background:#fff8e1; border:1px solid #ffe082; border-radius:10px;
            padding:10px 12px; margin-top:16px; font-size:12px; color:#7a5800;
            display:flex; gap:8px; align-items:flex-start; line-height:1.5;
        }
        .notify-note i { margin-top:1px; color:#f59e0b; }

        .footer { background:#071739; color:rgba(255,255,255,0.4); text-align:center; padding:22px; font-size:13px; margin-top:auto; }

        @media(max-width:768px){
            .page-wrap { flex-direction:column; align-items:center; }
            .summary-card { max-width:100%; position:static; }
            .payment-card { max-width:100%; }
            .main-header { padding:0 16px; }
            .header-nav a { font-size:13px; padding:6px 8px; }
        }
    </style>
</head>
<body>

<header class="main-header">
    <a href="home.jsp" class="header-logo"><i class="fas fa-paper-plane"></i> KP <span>Travels</span></a>
    <nav class="header-nav">
        <a href="home.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="LogoutServlet" style="color:#ff8a8a;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
</header>

<!-- Progress Bar -->
<div class="progress-bar">
    <div class="step">
        <div class="step-circle done"><i class="fas fa-check"></i></div>
        <div class="step-label">Details</div>
    </div>
    <div class="step-line done"></div>
    <div class="step">
        <div class="step-circle active">2</div>
        <div class="step-label active">Payment</div>
    </div>
    <div class="step-line"></div>
    <div class="step">
        <div class="step-circle pending">3</div>
        <div class="step-label">Confirmed</div>
    </div>
</div>

<div class="page-wrap">

    <!-- LEFT: Payment Form -->
    <div class="payment-card">
        <h2><i class="fas fa-credit-card" style="color:#00c6ff;"></i> Payment Details</h2>

        <!-- ✅ Passenger Contact Confirmation Box -->
        <div class="contact-box">
            <div class="c-title"><i class="fas fa-bell"></i> Ticket will be sent to</div>
            <div class="contact-row"><i class="fas fa-envelope"></i> <%= passengerEmail != null ? passengerEmail : "—" %></div>
            <div class="contact-row"><i class="fas fa-phone"></i> <%= passengerPhone != null ? passengerPhone : "—" %></div>
        </div>

        <!-- Payment Method Tabs -->
        <div class="pay-tabs">
            <div class="pay-tab active" onclick="switchPayment('card', this)">
                <span class="tab-icon">💳</span>
                <span class="tab-label">Card</span>
            </div>
            <div class="pay-tab" onclick="switchPayment('upi', this)">
                <span class="tab-icon">📱</span>
                <span class="tab-label">UPI</span>
            </div>
            <div class="pay-tab" onclick="switchPayment('netbanking', this)">
                <span class="tab-icon">🏦</span>
                <span class="tab-label">Net Banking</span>
            </div>
            <div class="pay-tab" onclick="switchPayment('wallet', this)">
                <span class="tab-icon">👛</span>
                <span class="tab-label">Wallet</span>
            </div>
        </div>

        <form action="PaymentServlet" method="post" onsubmit="return validatePayment()">
            <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="Credit/Debit Card">

            <!-- ✅ Carry passenger contact details through to PaymentServlet -->
            <input type="hidden" name="passengerEmail" value="<%= passengerEmail != null ? passengerEmail : "" %>">
            <input type="hidden" name="passengerPhone" value="<%= passengerPhone != null ? passengerPhone : "" %>">

            <!-- CARD Section -->
            <div class="pay-section show" id="section-card">
                <div class="card-preview">
                    <div class="card-chip">💳</div>
                    <div class="card-number-display" id="cardNumDisplay">•••• •••• •••• ••••</div>
                    <div class="card-bottom">
                        <div>
                            <div class="card-holder-label">Card Holder</div>
                            <div class="card-holder-name" id="cardNameDisplay">YOUR NAME</div>
                        </div>
                        <div class="card-logo"><i class="fas fa-credit-card"></i></div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Card Holder Name</label>
                    <input type="text" id="cardName" name="cardName" placeholder="Name on card"
                           oninput="document.getElementById('cardNameDisplay').textContent = this.value.toUpperCase() || 'YOUR NAME'">
                </div>
                <div class="form-group">
                    <label>Card Number</label>
                    <input type="text" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19"
                           oninput="formatCardNumber(this)">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Expiry Date</label>
                        <input type="text" id="expiry" placeholder="MM/YY" maxlength="5"
                               oninput="formatExpiry(this)">
                    </div>
                    <div class="form-group">
                        <label>CVV</label>
                        <input type="password" id="cvv" placeholder="•••" maxlength="3">
                    </div>
                </div>
            </div>

            <!-- UPI Section -->
            <div class="pay-section" id="section-upi">
                <div class="upi-box">
                    <span class="upi-icon">📱</span>
                    <p>Select your UPI app to pay</p>
                    <div class="upi-apps">
                        <div class="upi-app" onclick="selectUpi(this, 'Google Pay')">🟢 GPay</div>
                        <div class="upi-app" onclick="selectUpi(this, 'PhonePe')">🟣 PhonePe</div>
                        <div class="upi-app" onclick="selectUpi(this, 'Paytm')">🔵 Paytm</div>
                        <div class="upi-app" onclick="selectUpi(this, 'BHIM')">🟠 BHIM</div>
                    </div>
                </div>
                <div class="form-group">
                    <label>UPI ID</label>
                    <input type="text" id="upiId" placeholder="yourname@upi">
                </div>
            </div>

            <!-- Net Banking Section -->
            <div class="pay-section" id="section-netbanking">
                <div class="bank-grid">
                    <div class="bank-item" onclick="selectBank(this, 'SBI')">🏦 SBI</div>
                    <div class="bank-item" onclick="selectBank(this, 'HDFC')">🏦 HDFC</div>
                    <div class="bank-item" onclick="selectBank(this, 'ICICI')">🏦 ICICI</div>
                    <div class="bank-item" onclick="selectBank(this, 'Axis')">🏦 Axis</div>
                    <div class="bank-item" onclick="selectBank(this, 'Kotak')">🏦 Kotak</div>
                    <div class="bank-item" onclick="selectBank(this, 'PNB')">🏦 PNB</div>
                </div>
                <div class="form-group">
                    <label>Net Banking User ID</label>
                    <input type="text" id="netbankingId" placeholder="Enter your User ID">
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" id="netbankingPass" placeholder="Enter your Password">
                </div>
            </div>

            <!-- Wallet Section -->
            <div class="pay-section" id="section-wallet">
                <div class="upi-box">
                    <span class="upi-icon">👛</span>
                    <p>Select your wallet</p>
                    <div class="upi-apps">
                        <div class="upi-app" onclick="selectUpi(this, 'Paytm Wallet')">🔵 Paytm</div>
                        <div class="upi-app" onclick="selectUpi(this, 'Amazon Pay')">🟡 Amazon Pay</div>
                        <div class="upi-app" onclick="selectUpi(this, 'Mobikwik')">🔴 Mobikwik</div>
                    </div>
                </div>
                <div class="form-group">
                    <label>Registered Mobile Number</label>
                    <input type="text" id="walletPhone" placeholder="+91 XXXXX XXXXX" maxlength="13">
                </div>
            </div>

            <!-- Security Badge -->
            <div class="security-badge">
                <i class="fas fa-shield-alt"></i>
                Your payment is 100% secure and encrypted with SSL
            </div>

            <button type="submit" class="btn-pay">
                <i class="fas fa-lock"></i> Pay ₹<%= total %>  Securely
            </button>
        </form>
    </div>

    <!-- RIGHT: Order Summary -->
    <div class="summary-card">
        <h3><i class="fas fa-receipt" style="color:#00c6ff;"></i> Order Summary</h3>

        <div class="summary-route">
            <span class="s-icon"><%= icon %></span>
            <div class="s-route"><%= fromPlace %> → <%= toPlace %></div>
            <div class="s-date"><%= journeyDate %></div>
        </div>

        <div class="summary-item">
            <span class="s-label">Passenger</span>
            <span class="s-value"><%= name %></span>
        </div>
        <div class="summary-item">
            <span class="s-label">Age</span>
            <span class="s-value"><%= age %></span>
        </div>
        <div class="summary-item">
            <span class="s-label">Travel Type</span>
            <span class="s-value"><%= travelType.toUpperCase() %></span>
        </div>
        <div class="summary-item">
            <span class="s-label">Class</span>
            <span class="s-value"><%= classType %></span>
        </div>
        <% if (trainName != null && !trainName.isEmpty()) { %>
        <div class="summary-item">
            <span class="s-label">Service</span>
            <span class="s-value"><%= trainName %></span>
        </div>
        <% } %>
        <div class="summary-item">
            <span class="s-label">Base Fare</span>
            <span class="s-value">₹<%= fare %></span>
        </div>
        <div class="summary-item">
            <span class="s-label">GST (5%)</span>
            <span class="s-value">₹<%= gst %></span>
        </div>

        <div class="summary-total">
            <span class="t-label">Total</span>
            <span class="t-value">₹<%= total %></span>
        </div>

        <div class="notify-note">
            <i class="fas fa-info-circle"></i>
            <span>E-Ticket and confirmation will be sent to the passenger's email/phone shown on the left, not your account email.</span>
        </div>
    </div>

</div>

<footer class="footer">© 2026 KP Travels | All Rights Reserved</footer>

<script>
    // Switch Payment Method
    function switchPayment(type, btn) {
        document.querySelectorAll('.pay-tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.pay-section').forEach(s => s.classList.remove('show'));
        btn.classList.add('active');
        document.getElementById('section-' + type).classList.add('show');
        const labels = { card:'Credit/Debit Card', upi:'UPI', netbanking:'Net Banking', wallet:'Wallet' };
        document.getElementById('paymentMethodInput').value = labels[type];
    }

    // Format card number with spaces
    function formatCardNumber(input) {
        let val = input.value.replace(/\D/g, '').substring(0, 16);
        input.value = val.replace(/(.{4})/g, '$1 ').trim();
        const display = val.padEnd(16, '•').replace(/(.{4})/g, '$1 ').trim();
        document.getElementById('cardNumDisplay').textContent = display;
    }

    // Format expiry MM/YY
    function formatExpiry(input) {
        let val = input.value.replace(/\D/g, '').substring(0, 4);
        if (val.length >= 2) val = val.substring(0,2) + '/' + val.substring(2);
        input.value = val;
    }

    // Select UPI App
    function selectUpi(el, name) {
        el.closest('.upi-apps').querySelectorAll('.upi-app').forEach(a => a.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('paymentMethodInput').value = name;
    }

    // Select Bank
    function selectBank(el, name) {
        document.querySelectorAll('.bank-item').forEach(b => b.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('paymentMethodInput').value = name + ' Net Banking';
    }

    // Validate before submit
    function validatePayment() {
        const method = document.getElementById('paymentMethodInput').value;
        if (method === 'Credit/Debit Card') {
            const num = document.getElementById('cardNumber').value.replace(/\s/g,'');
            const exp = document.getElementById('expiry').value;
            const cvv = document.getElementById('cvv').value;
            const nm  = document.getElementById('cardName').value;
            if (!nm)          { alert('Please enter card holder name.'); return false; }
            if (num.length < 16) { alert('Please enter a valid 16-digit card number.'); return false; }
            if (exp.length < 5)  { alert('Please enter expiry date (MM/YY).'); return false; }
            if (cvv.length < 3)  { alert('Please enter CVV.'); return false; }
        }
        if (method === 'UPI') {
            const upi = document.getElementById('upiId').value;
            if (!upi.includes('@')) { alert('Please enter a valid UPI ID (e.g. name@upi).'); return false; }
        }

        // Show processing animation
        const btn = document.querySelector('.btn-pay');
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing Payment...';
        btn.disabled = true;
        return true;
    }
</script>
</body>
</html>