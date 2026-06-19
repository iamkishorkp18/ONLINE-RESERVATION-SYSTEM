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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String userid   = request.getParameter("userid");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();

            // ✅ STEP 1 — Check if userid exists at all
            PreparedStatement checkUser = con.prepareStatement(
                "SELECT * FROM users WHERE userid = ?"
            );
            checkUser.setString(1, userid);
            ResultSet userRs = checkUser.executeQuery();

            if (!userRs.next()) {
                // ❌ User ID does not exist
                userRs.close();
                checkUser.close();
                con.close();
                response.sendRedirect("index.html?msg=notfound");
                return;
            }

            // ✅ STEP 2 — User exists, now check password
            String storedPassword = userRs.getString("password");
            userRs.close();
            checkUser.close();

            if (!storedPassword.equals(password)) {
                // ❌ Wrong password
                con.close();
                response.sendRedirect("index.html?msg=wrongpass");
                return;
            }

            // ✅ STEP 3 — Login successful, fetch full details
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM users WHERE userid = ? AND password = ?"
            );
            ps.setString(1, userid);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("userid",       rs.getString("userid"));
                session.setAttribute("fullname",     rs.getString("fullname"));
                session.setAttribute("email",        rs.getString("email"));
                session.setAttribute("profileImage", rs.getString("profile_image"));

                int isAdmin = rs.getInt("is_admin");
                session.setAttribute("is_admin", isAdmin);

                rs.close();
                ps.close();
                con.close();

                if (isAdmin == 1) {
                    response.sendRedirect("AdminServlet");
                } else {
                    response.sendRedirect("home.jsp");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}