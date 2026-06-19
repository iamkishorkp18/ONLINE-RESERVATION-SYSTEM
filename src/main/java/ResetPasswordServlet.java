import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("reset_email");
        Boolean otpVerified = (Boolean) session.getAttribute("otp_verified");

        if (email == null || otpVerified == null || !otpVerified) {
            response.sendRedirect("forgot-password.html");
            return;
        }

        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("reset-password.html?msg=mismatch");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "UPDATE users SET password = ?, reset_otp = NULL, otp_expiry = NULL WHERE email = ?"
            );
            ps.setString(1, newPassword);
            ps.setString(2, email);
            ps.executeUpdate();
            ps.close();
            con.close();

            // ✅ Clear reset session data
            session.removeAttribute("reset_email");
            session.removeAttribute("reset_userid");
            session.removeAttribute("otp_verified");

            response.sendRedirect("index.html?msg=resetsuccess");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}