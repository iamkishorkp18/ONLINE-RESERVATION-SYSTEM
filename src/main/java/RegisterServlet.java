import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // DEBUG: Check button click
        System.out.println("Register Button Clicked!");

        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String userid = request.getParameter("userid");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // DEBUG: Check form values
        System.out.println("Fullname: " + fullname);
        System.out.println("Email: " + email);
        System.out.println("UserID: " + userid);
        System.out.println("Password: " + password);

        Connection con = null;
        PreparedStatement checkUser = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {

            // Empty field check
            if (fullname == null || fullname.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                userid == null || userid.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty()) {

                System.out.println("Empty Fields Found!");
                response.sendRedirect("register.html?msg=empty");
                return;
            }

            // Password mismatch
            if (!password.equals(confirmPassword)) {

                System.out.println("Password Mismatch!");
                response.sendRedirect("register.html?msg=password");
                return;
            }

            // Database connection
            System.out.println("Trying Database Connection...");
            con = DBConnection.getConnection();

            if (con == null) {

                System.out.println("Database Connection Failed!");
                response.getWriter().println("Database not connected! Check DBConnection.java");
                return;
            }

            System.out.println("Database Connected Successfully!");

            // Check existing user
            checkUser = con.prepareStatement("SELECT userid FROM users WHERE userid=?");
            checkUser.setString(1, userid);

            rs = checkUser.executeQuery();

            if (rs.next()) {

                System.out.println("User Already Exists!");
                response.sendRedirect("register.html?msg=exists");
                return;
            }

            // Insert new user
            ps = con.prepareStatement(
                "INSERT INTO users(fullname, email, userid, password) VALUES (?, ?, ?, ?)"
            );

            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, userid);
            ps.setString(4, password);

            int result = ps.executeUpdate();

            // DEBUG: Insert status
            System.out.println("Inserted Rows: " + result);

            if (result > 0) {

                System.out.println("Registration Successful!");
                response.sendRedirect("index.html?msg=success");

            } else {

                System.out.println("Registration Failed!");
                response.sendRedirect("register.html?msg=error");
            }

        } catch (Exception e) {

            System.out.println("Registration Exception Found!");
            e.printStackTrace();
            response.getWriter().println("Registration Error: " + e.getMessage());

        } finally {

            try {
                if (rs != null) rs.close();
                if (checkUser != null) checkUser.close();
                if (ps != null) ps.close();
                if (con != null) con.close();

                System.out.println("Resources Closed Successfully!");

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}