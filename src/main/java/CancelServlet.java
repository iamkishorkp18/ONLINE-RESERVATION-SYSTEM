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

@WebServlet("/CancelServlet")
public class CancelServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");

        if (userid == null) {
            response.sendRedirect("index.html");
            return;
        }

        String pnr    = request.getParameter("pnr");
        String action = request.getParameter("action"); // "cancel" or "delete"

        try {
            Connection con = DBConnection.getConnection();

            // Verify booking belongs to this user
            PreparedStatement check = con.prepareStatement(
                "SELECT pnr FROM reservations WHERE pnr = ? AND userid = ?"
            );
            check.setString(1, pnr);
            check.setString(2, userid);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                rs.close();
                check.close();

                if ("delete".equals(action)) {
                    // ✅ Permanently DELETE the booking
                    PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM reservations WHERE pnr = ? AND userid = ?"
                    );
                    ps.setString(1, pnr);
                    ps.setString(2, userid);
                    ps.executeUpdate();
                    ps.close();
                    con.close();
                    response.sendRedirect("BookingHistoryServlet?msg=deleted");

                } else {
                    // ✅ CANCEL — update status only
                    PreparedStatement ps = con.prepareStatement(
                        "UPDATE reservations SET status = 'CANCELLED' WHERE pnr = ? AND userid = ?"
                    );
                    ps.setString(1, pnr);
                    ps.setString(2, userid);
                    ps.executeUpdate();
                    ps.close();
                    con.close();
                    response.sendRedirect("BookingHistoryServlet?msg=cancelled");
                }

            } else {
                rs.close();
                check.close();
                con.close();
                response.sendRedirect("BookingHistoryServlet?msg=error");
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