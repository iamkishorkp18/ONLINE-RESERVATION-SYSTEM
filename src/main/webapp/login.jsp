<%@ page language="java" contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<link rel="stylesheet" href="style.css">
</head>

<body>

<div class="login-container">

    <h2 class="error-title">Authentication Failed</h2>

    <%
    String errorMessage =
            (String) request.getAttribute("errorMessage");

    if(errorMessage != null){
    %>

    <div class="error-box">
        <%= errorMessage %>
    </div>

    <%
    }
    %>

    <a href="index.html" class="back-btn">
        Back To Login
    </a>

</div>

</body>
</html>