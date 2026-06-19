import javax.mail.*;
import javax.mail.internet.*;
import javax.mail.util.ByteArrayDataSource;
import javax.activation.DataHandler;
import java.util.Properties;

public class EmailService {

    private static final String FROM_EMAIL = "peacelover0181@gmail.com";
    private static final String EMAIL_PASSWORD = "zbujsqrtkvkgxzot";

    // ✅ Old method still works — calls new method with defaults
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

    // ✅ New method — sends email WITH PDF ticket attached
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

            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props,
                    new Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(
                                    FROM_EMAIL,
                                    EMAIL_PASSWORD
                            );
                        }
                    });

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
                    + "<p><b>Service:</b> "
                    + (trainName == null ? "-" : trainName)
                    + "</p>"
                    + "<p><b>Fare:</b> ₹" + fare + "</p>"
                    + "<hr>"
                    + "<p>📎 Please find your downloadable ticket attached as PDF.</p>"
                    + "<p>Please carry a valid ID proof during the journey.</p>"
                    + "<p>Support: kptravels19@gmail.com</p>"
                    + "<p><b>KP Travels</b></p>"
                    + "</body></html>";

            // ✅ Generate PDF ticket
            byte[] pdfBytes = PdfTicketGenerator.generateTicketPdf(
                pnr, passengerName, age, fromPlace, toPlace, journeyDate,
                travelType, classType, trainName, trainNo, fare, paymentMethod
            );

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "KP Travels"));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );
            message.setSubject(
                    "Booking Confirmed - PNR: " + pnr + " | KP Travels"
            );

            // ✅ HTML body part
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(htmlBody, "text/html; charset=UTF-8");

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(htmlPart);

            // ✅ PDF attachment part
            if (pdfBytes != null) {
                MimeBodyPart attachPart = new MimeBodyPart();
                ByteArrayDataSource ds = new ByteArrayDataSource(pdfBytes, "application/pdf");
                attachPart.setDataHandler(new DataHandler(ds));
                attachPart.setFileName("KPTravels_Ticket_" + pnr + ".pdf");
                multipart.addBodyPart(attachPart);
                System.out.println("PDF attached successfully, size: " + pdfBytes.length + " bytes");
            } else {
                System.out.println("PDF generation failed, sending email without attachment");
            }

            message.setContent(multipart);

            Transport.send(message);

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
 // ✅ Add this method inside EmailService.java
    public static void sendOtpEmail(String toEmail, String fullname, String otp) {

        System.out.println("================================");
        System.out.println("Sending OTP Email");
        System.out.println("Recipient: " + toEmail);
        System.out.println("OTP: " + otp);
        System.out.println("================================");

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props,
                    new Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
                        }
                    });

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

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "KP Travels"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Your OTP for Password Reset - KP Travels");
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);

            System.out.println("OTP EMAIL SENT SUCCESSFULLY to: " + toEmail);

        } catch (Exception e) {
            System.out.println("OTP EMAIL FAILED: " + e.getMessage());
            e.printStackTrace();
        }
    }
}