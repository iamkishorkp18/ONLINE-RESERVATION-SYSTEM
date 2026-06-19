import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/VerifyOtpServlet")
public class VerifyOtpServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("reset_email");

        if (email == null) {
            response.sendRedirect("forgot-password.html");
            return;
        }

        String enteredOtp = request.getParameter("otp");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT reset_otp, otp_expiry FROM users WHERE email = ?"
            );
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedOtp = rs.getString("reset_otp");
                long expiry      = rs.getLong("otp_expiry");
                rs.close();
                ps.close();
                con.close();

                long now = System.currentTimeMillis();

                if (storedOtp == null || !storedOtp.equals(enteredOtp)) {
                    response.sendRedirect("verify-otp.html?msg=wrongotp");
                    return;
                }

                if (now > expiry) {
                    response.sendRedirect("verify-otp.html?msg=expired");
                    return;
                }

                // ✅ OTP correct — allow password reset
                session.setAttribute("otp_verified", true);
                response.sendRedirect("reset-password.html");

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