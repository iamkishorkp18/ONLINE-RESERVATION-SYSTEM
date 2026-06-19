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

@WebServlet("/BookingHistoryServlet")
public class BookingHistoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");

        if (userid == null) {
            response.sendRedirect("index.html");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM reservations WHERE userid = ? ORDER BY booked_on DESC"
            );
            ps.setString(1, userid);
            ResultSet rs = ps.executeQuery();

            List<Map<String, String>> bookings = new ArrayList<>();

            while (rs.next()) {
                Map<String, String> b = new HashMap<>();
                b.put("pnr",         rs.getString("pnr"));
                b.put("name",        rs.getString("name"));
                b.put("age",         rs.getString("age"));
                b.put("trainNo",     rs.getString("trainNo"));
                b.put("trainName",   rs.getString("trainName"));
                b.put("classType",   rs.getString("classType"));
                b.put("journeyDate", rs.getString("journeyDate"));
                b.put("fromPlace",   rs.getString("fromPlace"));
                b.put("toPlace",     rs.getString("toPlace"));
                b.put("travel_type", rs.getString("travel_type") != null ? rs.getString("travel_type") : "train");
                b.put("status",      rs.getString("status")      != null ? rs.getString("status")      : "CONFIRMED");
                b.put("booked_on",   rs.getString("booked_on")   != null ? rs.getString("booked_on")   : "");
                bookings.add(b);
            }

            rs.close();
            ps.close();
            con.close();

            request.setAttribute("bookings", bookings);
            request.getRequestDispatcher("bookingHistory.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}