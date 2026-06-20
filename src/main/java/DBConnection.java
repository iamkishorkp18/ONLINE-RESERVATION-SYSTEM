import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() {

        Connection con = null;

        try {
            System.out.println("Loading MySQL Driver...");
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Read DB details from environment variables
            String URL = System.getenv("DB_URL");
            String USER = System.getenv("DB_USER");
            String PASSWORD = System.getenv("DB_PASSWORD");

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