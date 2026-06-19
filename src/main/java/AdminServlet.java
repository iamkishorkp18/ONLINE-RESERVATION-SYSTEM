import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer isAdmin = (Integer) session.getAttribute("is_admin");

        // ✅ Block non-admins
        if (isAdmin == null || isAdmin != 1) {
            response.sendRedirect("index.html");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();

            // ── Fetch all users ──
            List<Map<String, String>> users = new ArrayList<>();
            PreparedStatement ps1 = con.prepareStatement(
                "SELECT userid, fullname, email, phone, gender, is_admin FROM users ORDER BY userid"
            );
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                Map<String, String> u = new HashMap<>();
                u.put("userid",   rs1.getString("userid"));
                u.put("fullname", rs1.getString("fullname"));
                u.put("email",    rs1.getString("email"));
                u.put("phone",    rs1.getString("phone") != null ? rs1.getString("phone") : "—");
                u.put("gender",   rs1.getString("gender") != null ? rs1.getString("gender") : "—");
                u.put("is_admin", rs1.getString("is_admin"));
                users.add(u);
            }
            rs1.close();
            ps1.close();

            // ── Fetch all bookings ──
            List<Map<String, String>> bookings = new ArrayList<>();
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT * FROM reservations ORDER BY booked_on DESC"
            );
            ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                Map<String, String> b = new HashMap<>();
                b.put("pnr",         rs2.getString("pnr"));
                b.put("userid",      rs2.getString("userid"));
                b.put("name",        rs2.getString("name"));
                b.put("fromPlace",   rs2.getString("fromPlace"));
                b.put("toPlace",     rs2.getString("toPlace"));
                b.put("journeyDate", rs2.getString("journeyDate"));
                b.put("classType",   rs2.getString("classType"));
                b.put("travel_type", rs2.getString("travel_type") != null ? rs2.getString("travel_type") : "train");
                b.put("status",      rs2.getString("status")      != null ? rs2.getString("status")      : "CONFIRMED");
                b.put("booked_on",   rs2.getString("booked_on")   != null ? rs2.getString("booked_on")   : "—");
                bookings.add(b);
            }
            rs2.close();
            ps2.close();

            // ── Fetch stats ──
            // Total users
            PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(*) FROM users");
            ResultSet rs3 = ps3.executeQuery();
            int totalUsers = rs3.next() ? rs3.getInt(1) : 0;
            rs3.close(); ps3.close();

            // Total bookings
            PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) FROM reservations");
            ResultSet rs4 = ps4.executeQuery();
            int totalBookings = rs4.next() ? rs4.getInt(1) : 0;
            rs4.close(); ps4.close();

            // Confirmed bookings
            PreparedStatement ps5 = con.prepareStatement("SELECT COUNT(*) FROM reservations WHERE status='CONFIRMED'");
            ResultSet rs5 = ps5.executeQuery();
            int confirmedBookings = rs5.next() ? rs5.getInt(1) : 0;
            rs5.close(); ps5.close();

            // Cancelled bookings
            PreparedStatement ps6 = con.prepareStatement("SELECT COUNT(*) FROM reservations WHERE status='CANCELLED'");
            ResultSet rs6 = ps6.executeQuery();
            int cancelledBookings = rs6.next() ? rs6.getInt(1) : 0;
            rs6.close(); ps6.close();

            con.close();

            request.setAttribute("users",            users);
            request.setAttribute("bookings",         bookings);
            request.setAttribute("totalUsers",       totalUsers);
            request.setAttribute("totalBookings",    totalBookings);
            request.setAttribute("confirmedBookings",confirmedBookings);
            request.setAttribute("cancelledBookings",cancelledBookings);

            request.getRequestDispatcher("admin.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}