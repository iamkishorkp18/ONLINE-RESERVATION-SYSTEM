import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");

        if (userid == null) {
            response.sendRedirect("index.html");
            return;
        }

        String name           = request.getParameter("name");
        String age            = request.getParameter("age");
        String passengerEmail = request.getParameter("passengerEmail");
        String passengerPhone = request.getParameter("passengerPhone");
        String trainNo        = request.getParameter("trainNo");
        String trainName      = request.getParameter("trainName");
        String classType      = request.getParameter("classType");
        String journeyDate    = request.getParameter("journeyDate");
        String fromPlace      = request.getParameter("fromPlace");
        String toPlace        = request.getParameter("toPlace");
        String travelType     = request.getParameter("travelType");
        if (travelType == null) travelType = "train";

        int fare = 0;
        if      ("flight".equals(travelType)) fare = 5000;
        else if ("bus".equals(travelType))    fare = 800;
        else                                  fare = 1500;

        if      ("First Class".equals(classType) || "Business".equals(classType)) fare += 1000;
        else if ("AC".equals(classType))          fare += 500;
        else if ("Sleeper".equals(classType))     fare += 200;

        // ✅ Save passenger contact details to session too
        session.setAttribute("pending_name",            name);
        session.setAttribute("pending_age",             age);
        session.setAttribute("pending_passengerEmail",  passengerEmail);
        session.setAttribute("pending_passengerPhone",  passengerPhone);
        session.setAttribute("pending_trainNo",         trainNo);
        session.setAttribute("pending_trainName",       trainName);
        session.setAttribute("pending_classType",       classType);
        session.setAttribute("pending_journeyDate",     journeyDate);
        session.setAttribute("pending_fromPlace",       fromPlace);
        session.setAttribute("pending_toPlace",         toPlace);
        session.setAttribute("pending_travelType",      travelType);
        session.setAttribute("pending_fare",            String.valueOf(fare));

        request.setAttribute("name",            name);
        request.setAttribute("age",             age);
        request.setAttribute("passengerEmail",  passengerEmail);
        request.setAttribute("passengerPhone",  passengerPhone);
        request.setAttribute("trainNo",         trainNo);
        request.setAttribute("trainName",       trainName);
        request.setAttribute("classType",       classType);
        request.setAttribute("journeyDate",     journeyDate);
        request.setAttribute("fromPlace",       fromPlace);
        request.setAttribute("toPlace",         toPlace);
        request.setAttribute("travelType",      travelType);
        request.setAttribute("fare",            fare);

        request.getRequestDispatcher("payment.jsp")
               .forward(request, response);
    }
}