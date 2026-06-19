import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");

        if (userid == null) {
            response.sendRedirect("index.html");
            return;
        }

        try {
            String name           = (String) session.getAttribute("pending_name");
            String age            = (String) session.getAttribute("pending_age");
            String passengerEmail = (String) session.getAttribute("pending_passengerEmail");
            String passengerPhone = (String) session.getAttribute("pending_passengerPhone");
            String trainNo        = (String) session.getAttribute("pending_trainNo");
            String trainName      = (String) session.getAttribute("pending_trainName");
            String classType      = (String) session.getAttribute("pending_classType");
            String journeyDate    = (String) session.getAttribute("pending_journeyDate");
            String fromPlace      = (String) session.getAttribute("pending_fromPlace");
            String toPlace        = (String) session.getAttribute("pending_toPlace");
            String travelType     = (String) session.getAttribute("pending_travelType");
            String fare           = (String) session.getAttribute("pending_fare");

            String paymentMethod = request.getParameter("paymentMethod");
            String cardName      = request.getParameter("cardName");

            // ✅ Fallback to form params if session somehow lost (extra safety)
            if (passengerEmail == null) passengerEmail = request.getParameter("passengerEmail");
            if (passengerPhone == null) passengerPhone = request.getParameter("passengerPhone");

            String pnr = "KP" + (100000 + new Random().nextInt(900000));

            Connection con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try {
                // ✅ Save passenger email/phone in reservations table too (optional but useful)
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO reservations (pnr, userid, name, age, trainNo, trainName, classType, journeyDate, fromPlace, toPlace, travel_type, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED')"
                );
                ps.setString(1,  pnr);
                ps.setString(2,  userid);
                ps.setString(3,  name);
                ps.setInt   (4,  Integer.parseInt(age != null ? age : "0"));
                ps.setString(5,  trainNo);
                ps.setString(6,  trainName);
                ps.setString(7,  classType);
                ps.setString(8,  journeyDate);
                ps.setString(9,  fromPlace);
                ps.setString(10, toPlace);
                ps.setString(11, travelType != null ? travelType : "train");
                ps.executeUpdate();
                ps.close();

                con.commit();
                con.close();

                // ✅ Clear pending session data
                session.removeAttribute("pending_name");
                session.removeAttribute("pending_age");
                session.removeAttribute("pending_passengerEmail");
                session.removeAttribute("pending_passengerPhone");
                session.removeAttribute("pending_trainNo");
                session.removeAttribute("pending_trainName");
                session.removeAttribute("pending_classType");
                session.removeAttribute("pending_journeyDate");
                session.removeAttribute("pending_fromPlace");
                session.removeAttribute("pending_toPlace");
                session.removeAttribute("pending_travelType");
                session.removeAttribute("pending_fare");

                // ✅ Send Email to PASSENGER (not logged-in user)
                final String fe   = passengerEmail;
                final String fp   = passengerPhone;
                final String fn   = name;
                final String fpnr = pnr;
                final String ffrom = fromPlace;
                final String fto   = toPlace;
                final String fdate = journeyDate;
                final String ftype = travelType;
                final String fcls  = classType;
                final String ftrn  = trainName;
                final String ffare = fare;
                final String ftrainNo = trainNo;
                final String fage      = age;
                final String fpayMethod = paymentMethod;

                new Thread(() -> {
                    if (fe != null && !fe.isEmpty()) {
                        try {
                            EmailService.sendBookingConfirmationWithPdf(
                                fe, fn, fpnr,
                                ffrom, fto, fdate,
                                ftype, fcls, ftrn, ffare,
                                ftrainNo, fage, fpayMethod
                            );
                        } catch (Exception e) {
                            System.err.println("Email error: " + e.getMessage());
                        }
                    }
                    // SMS to passenger phone (if you have SmsService set up)
                    if (fp != null && !fp.isEmpty()) {
                        try {
                            // SmsService.sendBookingConfirmation(fp, fn, fpnr, ffrom, fto, fdate, ftype, ffare);
                        } catch (Exception e) {
                            System.err.println("SMS error: " + e.getMessage());
                        }
                    }
                }).start();

                request.setAttribute("pnr",            pnr);
                request.setAttribute("name",           name);
                request.setAttribute("age",            age);
                request.setAttribute("passengerEmail", passengerEmail);
                request.setAttribute("passengerPhone", passengerPhone);
                request.setAttribute("trainNo",        trainNo);
                request.setAttribute("trainName",      trainName);
                request.setAttribute("classType",      classType);
                request.setAttribute("journeyDate",    journeyDate);
                request.setAttribute("fromPlace",      fromPlace);
                request.setAttribute("toPlace",        toPlace);
                request.setAttribute("travelType",     travelType);
                request.setAttribute("fare",           fare);
                request.setAttribute("paymentMethod",  paymentMethod);
                request.setAttribute("cardName",       cardName);

                request.getRequestDispatcher("confirmation.jsp")
                       .forward(request, response);

            } catch (Exception dbEx) {
                try { con.rollback(); } catch (Exception re) {}
                try { con.close();   } catch (Exception ce) {}
                throw dbEx;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println(
                "<h2 style='color:red;font-family:Arial;padding:30px;'>" +
                "Error: " + e.getMessage() +
                "<br><br><a href='reservation.html'>Try Again</a></h2>"
            );
        }
    }
}