import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/reservationdb?useSSL=false&serverTimezone=UTC";

    private static final String USER = "root";
    private static final String PASSWORD = "1911";

    public static Connection getConnection() {

        Connection con = null;

        try {
            System.out.println("Loading MySQL Driver...");
            Class.forName("com.mysql.cj.jdbc.Driver");

            System.out.println("Connecting to Database...");

            con = DriverManager.getConnection(URL, USER, PASSWORD);

            System.out.println("Database Connected Successfully!");

        } catch (ClassNotFoundException e) {

            System.out.println("MySQL JDBC Driver Not Found!");
            e.printStackTrace();

        } catch (SQLException e) {

            System.out.println("Database Connection Failed!");
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            System.out.println("Message: " + e.getMessage());
            e.printStackTrace();

        } catch (Exception e) {

            System.out.println("Unexpected Error!");
            e.printStackTrace();
        }

        return con;
    }
}