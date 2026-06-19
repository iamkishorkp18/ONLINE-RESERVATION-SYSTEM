import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminActionServlet")
public class AdminActionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer isAdmin = (Integer) session.getAttribute("is_admin");

        // ✅ Block non-admins
        if (isAdmin == null || isAdmin != 1) {
            response.sendRedirect("index.html");
            return;
        }

        String action = request.getParameter("action");

        try {
            Connection con = DBConnection.getConnection();

            if ("deleteUser".equals(action)) {
                String userid = request.getParameter("userid");
                // Delete user bookings first
                PreparedStatement ps1 = con.prepareStatement(
                    "DELETE FROM reservations WHERE userid = ?"
                );
                ps1.setString(1, userid);
                ps1.executeUpdate();
                ps1.close();
                // Delete user
                PreparedStatement ps2 = con.prepareStatement(
                    "DELETE FROM users WHERE userid = ? AND is_admin = 0"
                );
                ps2.setString(1, userid);
                ps2.executeUpdate();
                ps2.close();
                con.close();
                response.sendRedirect("AdminServlet?msg=userdeleted");

            } else if ("cancelBooking".equals(action)) {
                String pnr = request.getParameter("pnr");
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE reservations SET status = 'CANCELLED' WHERE pnr = ?"
                );
                ps.setString(1, pnr);
                ps.executeUpdate();
                ps.close();
                con.close();
                response.sendRedirect("AdminServlet?msg=cancelled");

            } else if ("deleteBooking".equals(action)) {
                String pnr = request.getParameter("pnr");
                PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM reservations WHERE pnr = ?"
                );
                ps.setString(1, pnr);
                ps.executeUpdate();
                ps.close();
                con.close();
                response.sendRedirect("AdminServlet?msg=bookingdeleted");

            } else {
                con.close();
                response.sendRedirect("AdminServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}