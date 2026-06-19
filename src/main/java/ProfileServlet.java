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

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

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
                "SELECT fullname, email, age, phone, gender, profile_image FROM users WHERE userid=?");
            ps.setString(1, userid);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String fullname     = rs.getString("fullname");
                String email        = rs.getString("email");
                String age          = rs.getString("age");
                String phone        = rs.getString("phone");
                String gender       = rs.getString("gender");
                String profileImage = rs.getString("profile_image");

                // ✅ Always update session with latest image from DB
                if (profileImage != null && !profileImage.isEmpty()) {
                    session.setAttribute("profileImage", profileImage);
                }

                request.setAttribute("fullname",     fullname);
                request.setAttribute("email",        email);
                request.setAttribute("age",          age);
                request.setAttribute("phone",        phone);
                request.setAttribute("gender",       gender);
                request.setAttribute("profileImage", profileImage);
            }

            rs.close();
            ps.close();
            con.close();

            request.getRequestDispatcher("profile.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}