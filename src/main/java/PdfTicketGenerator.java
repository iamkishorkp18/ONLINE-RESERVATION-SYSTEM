import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import java.awt.Color;
import java.io.ByteArrayOutputStream;

public class PdfTicketGenerator {

    public static byte[] generateTicketPdf(
            String pnr, String passengerName, String age,
            String fromPlace, String toPlace, String journeyDate,
            String travelType, String classType, String trainName,
            String trainNo, String fare, String paymentMethod) {

        try {
            Document document = new Document(PageSize.A5);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PdfWriter.getInstance(document, baos);
            document.open();

            Color navy = new Color(7, 23, 57);
            Color sky  = new Color(0, 198, 255);
            Color gray = new Color(120, 120, 120);

            Font titleFont  = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, navy);
            Font labelFont  = FontFactory.getFont(FontFactory.HELVETICA, 9, gray);
            Font valueFont  = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, navy);
            Font pnrFont    = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, sky);
            Font smallFont  = FontFactory.getFont(FontFactory.HELVETICA, 9, gray);

            Paragraph header = new Paragraph("KP TRAVELS", titleFont);
            header.setAlignment(Element.ALIGN_CENTER);
            document.add(header);

            Paragraph subHeader = new Paragraph("E-Ticket / Booking Confirmation", smallFont);
            subHeader.setAlignment(Element.ALIGN_CENTER);
            subHeader.setSpacingAfter(15);
            document.add(subHeader);

            PdfPTable pnrTable = new PdfPTable(1);
            pnrTable.setWidthPercentage(100);
            PdfPCell pnrCell = new PdfPCell();
            pnrCell.setBackgroundColor(navy);
            pnrCell.setPadding(12);
            pnrCell.setBorder(Rectangle.NO_BORDER);

            Font pnrLabelFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.LIGHT_GRAY);
            Paragraph pnrLabel = new Paragraph("PNR NUMBER", pnrLabelFont);
            Paragraph pnrValue = new Paragraph(pnr, pnrFont);
            pnrCell.addElement(pnrLabel);
            pnrCell.addElement(pnrValue);
            pnrTable.addCell(pnrCell);
            document.add(pnrTable);

            document.add(new Paragraph(" "));

            PdfPTable routeTable = new PdfPTable(3);
            routeTable.setWidthPercentage(100);
            routeTable.setWidths(new float[]{4, 1, 4});

            PdfPCell fromCell = new PdfPCell(new Phrase(fromPlace, valueFont));
            fromCell.setBorder(Rectangle.NO_BORDER);
            fromCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            routeTable.addCell(fromCell);

            PdfPCell arrowCell = new PdfPCell(new Phrase("->", valueFont));
            arrowCell.setBorder(Rectangle.NO_BORDER);
            arrowCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            routeTable.addCell(arrowCell);

            PdfPCell toCell = new PdfPCell(new Phrase(toPlace, valueFont));
            toCell.setBorder(Rectangle.NO_BORDER);
            toCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            routeTable.addCell(toCell);

            document.add(routeTable);
            document.add(new Paragraph(" "));

            document.add(new Paragraph("--------------------------------------------------", smallFont));

            PdfPTable detailsTable = new PdfPTable(2);
            detailsTable.setWidthPercentage(100);
            detailsTable.setSpacingBefore(10);

            addDetailRow(detailsTable, "Passenger Name", passengerName, labelFont, valueFont);
            addDetailRow(detailsTable, "Age",             age,           labelFont, valueFont);
            addDetailRow(detailsTable, "Journey Date",    journeyDate,   labelFont, valueFont);
            addDetailRow(detailsTable, "Class / Seat",    classType,     labelFont, valueFont);
            addDetailRow(detailsTable, "Travel Type",     travelType != null ? travelType.toUpperCase() : "-", labelFont, valueFont);
            addDetailRow(detailsTable, "Train/Flight No",  trainNo != null && !trainNo.isEmpty() ? trainNo : "-", labelFont, valueFont);
            addDetailRow(detailsTable, "Service Name",     trainName != null && !trainName.isEmpty() ? trainName : "-", labelFont, valueFont);
            addDetailRow(detailsTable, "Payment Method",   paymentMethod != null ? paymentMethod : "Online", labelFont, valueFont);

            document.add(detailsTable);

            document.add(new Paragraph("--------------------------------------------------", smallFont));

            int fareInt = 0;
            try { fareInt = Integer.parseInt(fare != null ? fare : "0"); } catch (Exception e) {}
            int gst   = (int) (fareInt * 0.05);
            int total = fareInt + gst;

            PdfPTable fareTable = new PdfPTable(2);
            fareTable.setWidthPercentage(100);
            fareTable.setSpacingBefore(8);

            addDetailRow(fareTable, "Base Fare", "Rs. " + fareInt, labelFont, valueFont);
            addDetailRow(fareTable, "GST (5%)",  "Rs. " + gst,     labelFont, valueFont);

            Font totalLabelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, navy);
            Font totalValueFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, sky);
            addDetailRow(fareTable, "TOTAL PAID", "Rs. " + total, totalLabelFont, totalValueFont);

            document.add(fareTable);

            document.add(new Paragraph(" "));

            Font statusFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, new Color(0, 166, 81));
            Paragraph status = new Paragraph("STATUS: CONFIRMED", statusFont);
            status.setSpacingBefore(10);
            document.add(status);

            Paragraph note = new Paragraph(
                "\nPlease carry a valid photo ID during your journey.\n" +
                "Support: kptravels19@gmail.com | +91 7416243708",
                smallFont
            );
            note.setSpacingBefore(20);
            document.add(note);

            Paragraph footer = new Paragraph("\n(c) 2026 KP Travels | All Rights Reserved", smallFont);
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);

            document.close();
            return baos.toByteArray();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static void addDetailRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPaddingBottom(6);
        table.addCell(labelCell);

        PdfPCell valueCell = new PdfPCell(new Phrase(value != null ? value : "-", valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        valueCell.setPaddingBottom(6);
        table.addCell(valueCell);
    }
}