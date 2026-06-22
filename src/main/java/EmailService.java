import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

public class EmailService {

    private static final String FROM_EMAIL = System.getenv("FROM_EMAIL");
    private static final String BREVO_API_KEY = System.getenv("BREVO_API_KEY");

    // Old method still works — calls new method with defaults
    public static void sendBookingConfirmation(
            String toEmail,
            String passengerName,
            String pnr,
            String fromPlace,
            String toPlace,
            String journeyDate,
            String travelType,
            String classType,
            String trainName,
            String fare) {

        sendBookingConfirmationWithPdf(
                toEmail, passengerName, pnr, fromPlace, toPlace,
                journeyDate, travelType, classType, trainName, fare,
                null, null, "Online"
        );
    }

    // Booking confirmation with PDF ticket attachment
    public static void sendBookingConfirmationWithPdf(
            String toEmail,
            String passengerName,
            String pnr,
            String fromPlace,
            String toPlace,
            String journeyDate,
            String travelType,
            String classType,
            String trainName,
            String fare,
            String trainNo,
            String age,
            String paymentMethod) {

        System.out.println("================================");
        System.out.println("EmailService Started");
        System.out.println("Recipient: " + toEmail);
        System.out.println("PNR: " + pnr);
        System.out.println("================================");

        try {
            String icon = "flight".equalsIgnoreCase(travelType)
                    ? "Flight"
                    : "bus".equalsIgnoreCase(travelType)
                    ? "Bus"
                    : "Train";

            String htmlBody =
                    "<html><body style='font-family:Arial,sans-serif;'>"
                            + "<h2>KP Travels - Booking Confirmation (" + icon + ")</h2>"
                            + "<p>Hello <b>" + passengerName + "</b>,</p>"
                            + "<p>Your booking has been confirmed. Your e-ticket PDF is attached.</p>"
                            + "<hr>"
                            + "<p><b>PNR:</b> " + pnr + "</p>"
                            + "<p><b>From:</b> " + fromPlace + "</p>"
                            + "<p><b>To:</b> " + toPlace + "</p>"
                            + "<p><b>Date:</b> " + journeyDate + "</p>"
                            + "<p><b>Travel Type:</b> " + travelType + "</p>"
                            + "<p><b>Class:</b> " + classType + "</p>"
                            + "<p><b>Service:</b> " + (trainName == null ? "-" : trainName) + "</p>"
                            + "<p><b>Fare:</b> ₹" + fare + "</p>"
                            + "<hr>"
                            + "<p>Please find your downloadable ticket attached as PDF.</p>"
                            + "<p>Please carry a valid ID proof during the journey.</p>"
                            + "<p>Support: kptravels19@gmail.com</p>"
                            + "<p><b>KP Travels</b></p>"
                            + "</body></html>";

            // Generate PDF ticket
            byte[] pdfBytes = PdfTicketGenerator.generateTicketPdf(
                    pnr, passengerName, age, fromPlace, toPlace, journeyDate,
                    travelType, classType, trainName, trainNo, fare, paymentMethod
            );

            sendBrevoEmailWithPdf(
                    toEmail,
                    passengerName,
                    "Booking Confirmed - PNR: " + pnr + " | KP Travels",
                    htmlBody,
                    pdfBytes,
                    "KPTravels_Ticket_" + pnr + ".pdf"
            );

            System.out.println("================================");
            System.out.println("EMAIL SENT SUCCESSFULLY WITH PDF");
            System.out.println("Sent To: " + toEmail);
            System.out.println("================================");

        } catch (Exception e) {
            System.out.println("================================");
            System.out.println("EMAIL FAILED");
            System.out.println("Reason: " + e.getMessage());
            System.out.println("================================");
            e.printStackTrace();
        }
    }

    // OTP email
    public static void sendOtpEmail(String toEmail, String fullname, String otp) {

        System.out.println("================================");
        System.out.println("Sending OTP Email");
        System.out.println("Recipient: " + toEmail);
        System.out.println("OTP: " + otp);
        System.out.println("================================");

        try {
            String htmlBody =
                    "<html><body style='font-family:Arial,sans-serif;'>"
                            + "<h2>KP Travels - Password Reset OTP</h2>"
                            + "<p>Hello <b>" + (fullname != null ? fullname : "User") + "</b>,</p>"
                            + "<p>You requested to reset your password. Use the OTP below to proceed:</p>"
                            + "<div style='background:#f0f6ff;border:2px dashed #00c6ff;border-radius:10px;padding:20px;text-align:center;margin:20px 0;'>"
                            + "<span style='font-size:32px;font-weight:bold;letter-spacing:8px;color:#0072ff;'>" + otp + "</span>"
                            + "</div>"
                            + "<p>This OTP is valid for <b>10 minutes</b> only.</p>"
                            + "<p>If you did not request this, please ignore this email or contact support.</p>"
                            + "<hr>"
                            + "<p>Support: kptravels19@gmail.com</p>"
                            + "<p><b>KP Travels Team</b></p>"
                            + "</body></html>";

            sendBrevoEmail(
                    toEmail,
                    fullname != null ? fullname : "User",
                    "Your OTP for Password Reset - KP Travels",
                    htmlBody
            );

            System.out.println("================================");
            System.out.println("OTP EMAIL SENT SUCCESSFULLY");
            System.out.println("Sent To: " + toEmail);
            System.out.println("================================");

        } catch (Exception e) {
            System.out.println("================================");
            System.out.println("OTP EMAIL FAILED");
            System.out.println("Reason: " + e.getMessage());
            System.out.println("================================");
            e.printStackTrace();
        }
    }

    // Send normal email using Brevo API
    private static void sendBrevoEmail(String toEmail, String toName, String subject, String htmlBody) throws Exception {
        String json =
                "{"
                        + "\"sender\":{\"name\":\"KP Travels\",\"email\":\"" + escapeJson(FROM_EMAIL) + "\"},"
                        + "\"to\":[{\"email\":\"" + escapeJson(toEmail) + "\",\"name\":\"" + escapeJson(toName) + "\"}],"
                        + "\"subject\":\"" + escapeJson(subject) + "\","
                        + "\"htmlContent\":\"" + escapeJson(htmlBody) + "\""
                        + "}";

        callBrevoApi(json);
    }

    // Send email with PDF attachment using Brevo API
    private static void sendBrevoEmailWithPdf(
            String toEmail,
            String toName,
            String subject,
            String htmlBody,
            byte[] pdfBytes,
            String fileName) throws Exception {

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"sender\":{\"name\":\"KP Travels\",\"email\":\"").append(escapeJson(FROM_EMAIL)).append("\"},");
        json.append("\"to\":[{\"email\":\"").append(escapeJson(toEmail)).append("\",\"name\":\"").append(escapeJson(toName)).append("\"}],");
        json.append("\"subject\":\"").append(escapeJson(subject)).append("\",");
        json.append("\"htmlContent\":\"").append(escapeJson(htmlBody)).append("\"");

        if (pdfBytes != null && pdfBytes.length > 0) {
            String base64Pdf = Base64.getEncoder().encodeToString(pdfBytes);
            json.append(",\"attachment\":[{")
                    .append("\"name\":\"").append(escapeJson(fileName)).append("\",")
                    .append("\"content\":\"").append(base64Pdf).append("\"")
                    .append("}]");
        }

        json.append("}");

        callBrevoApi(json.toString());
    }

    // Common Brevo API caller
    private static void callBrevoApi(String jsonBody) throws Exception {
        URL url = new URL("https://api.brevo.com/v3/smtp/email");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("accept", "application/json");
        conn.setRequestProperty("api-key", BREVO_API_KEY);
        conn.setRequestProperty("content-type", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(20000);
        conn.setReadTimeout(20000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonBody.getBytes("UTF-8"));
        }

        int responseCode = conn.getResponseCode();

        if (responseCode != 201) {
            throw new RuntimeException("Brevo API failed. HTTP code: " + responseCode);
        }
    }

    // Escape JSON special chars
    private static String escapeJson(String text) {
        if (text == null) return "";
        return text
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
}