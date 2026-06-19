import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        try {
            Connection con = DBConnection.getConnection();

            // ✅ Check if email exists
            PreparedStatement ps = con.prepareStatement(
                "SELECT userid, fullname FROM users WHERE email = ?"
            );
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String userid   = rs.getString("userid");
                String fullname = rs.getString("fullname");
                rs.close();
                ps.close();

                // ✅ Generate 6-digit OTP
                String otp = String.valueOf(100000 + new Random().nextInt(900000));
                long expiryTime = System.currentTimeMillis() + (10 * 60 * 1000); // 10 mins

                // ✅ Save OTP to DB
                PreparedStatement updatePs = con.prepareStatement(
                    "UPDATE users SET reset_otp = ?, otp_expiry = ? WHERE email = ?"
                );
                updatePs.setString(1, otp);
                updatePs.setLong(2, expiryTime);
                updatePs.setString(3, email);
                updatePs.executeUpdate();
                updatePs.close();
                con.close();

                // ✅ Save email in session temporarily for verify step
                HttpSession session = request.getSession();
                session.setAttribute("reset_email", email);
                session.setAttribute("reset_userid", userid);

                // ✅ Send OTP email in background thread
                final String fEmail = email;
                final String fName  = fullname;
                final String fOtp   = otp;
                new Thread(() -> {
                    EmailService.sendOtpEmail(fEmail, fName, fOtp);
                }).start();

                response.sendRedirect("verify-otp.html?msg=sent");

            } else {
                rs.close();
                ps.close();
                con.close();
                response.sendRedirect("forgot-password.html?msg=notfound");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}