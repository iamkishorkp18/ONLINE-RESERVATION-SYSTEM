import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize       = 1024 * 1024 * 10,
    maxRequestSize    = 1024 * 1024 * 50
)
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");

        try {
            String fullname = request.getParameter("fullname");
            String email    = request.getParameter("email");
            String age      = request.getParameter("age");
            String phone    = request.getParameter("phone");
            String gender   = request.getParameter("gender");

            String imagePath = null;
            Part filePart = request.getPart("profileImage");

            if (filePart != null
                    && filePart.getSize() > 0
                    && filePart.getSubmittedFileName() != null
                    && !filePart.getSubmittedFileName().isEmpty()) {

                String fileName = filePart.getSubmittedFileName();

                // Save to webapp/uploads folder
                String uploadPath = request.getServletContext().getRealPath("/uploads");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                filePart.write(uploadPath + File.separator + fileName);

                // ✅ Web-accessible URL path (not file system path)
                imagePath = request.getContextPath() + "/uploads/" + fileName;

                // ✅ Save to session so it persists everywhere
                session.setAttribute("profileImage", imagePath);
            }

            // If no new image, get existing from session or DB
            if (imagePath == null) {
                imagePath = (String) session.getAttribute("profileImage");
            }

            Connection con = DBConnection.getConnection();
            PreparedStatement ps;

            // Save the web URL path to DB
            String dbImagePath = imagePath != null ? imagePath : "";

            ps = con.prepareStatement(
                "UPDATE users SET fullname=?, email=?, age=?, phone=?, gender=?, profile_image=? WHERE userid=?");
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, age);
            ps.setString(4, phone);
            ps.setString(5, gender);
            ps.setString(6, dbImagePath);
            ps.setString(7, userid);

            int rows = ps.executeUpdate();
            ps.close();

            // If no image in session, fetch from DB
            if (imagePath == null || imagePath.isEmpty()) {
                PreparedStatement ps2 = con.prepareStatement(
                    "SELECT profile_image FROM users WHERE userid=?");
                ps2.setString(1, userid);
                ResultSet rs = ps2.executeQuery();
                if (rs.next()) {
                    String dbImg = rs.getString("profile_image");
                    if (dbImg != null && !dbImg.isEmpty()) {
                        imagePath = dbImg;
                        session.setAttribute("profileImage", imagePath);
                    }
                }
                rs.close();
                ps2.close();
            }

            con.close();

            if (rows > 0) {
                request.setAttribute("fullname",     fullname);
                request.setAttribute("email",        email);
                request.setAttribute("age",          age);
                request.setAttribute("phone",        phone);
                request.setAttribute("gender",       gender);
                request.setAttribute("profileImage", imagePath);
                request.setAttribute("updateMsg",    "success");

                request.getRequestDispatcher("profile.jsp")
                       .forward(request, response);
            } else {
                response.getWriter().println("Profile update failed!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}