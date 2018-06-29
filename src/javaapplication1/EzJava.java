import java.sql.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

// Commentaire francois a valider Vincent:

public class EzJava
{
    public static Statement stmt;
    public static ResultSet rs;
    public static int       waited_intervals;
    public static int       MaxIntervals  = 60 ;
    public static int       TaskLookPeriod= 60;

    public static void main(String[] args)
    {
        //String urlPrefix = "jdbc:db2:";  // Changed to accept Oracle
        String urlPrefix = "jdbc:";
        String sgbdType;
        String url;
        String user;
        String password;
        String empNo;
        String showMode = "no";
        Connection con;

        System.out.println ("**** Enter class EzJava");

      /* Check the that first argument has the correct form for the portion
        of the URL that follows jdbc:db2:,
        as described in the connection to a data source using the DriverManager
        interface with the IBM Data Server Driver for JDBC and SQLJ topic.
        For example,  for IBM Data Server Driver for
        JDBC and SQLJ type 2 connectivity, args[0] might be: MVS1DB2M. 
        For type 4 connectivity,   args[0] might be: //stlmvs1:10110/MVS1DB2M.    
        For oracle                 args[0] might be: oracle:thin@stlmvs1:1521:   */

        if (args.length < 3 )
        {
            System.err.println ("Invalid arguments nb. First argument will be appended to "+
            "\"jdbc:\" Specify a valid URL. Ex: db2:\\servername:50000/DBU or oracle:thin:@servername:1521:DBU ");
            //       "jdbc:db2: must specify a valid URL.");
            System.err.println ("Second argument must be a valid database user.");
            System.err.println ("Third argument must be the password for the user .");
            System.err.println ("Optional 4th argument is the idle time in minutes before stop, [Default: 60].");
            System.exit(1);
        }
        user = args[1];
        password = args[2];
        url = urlPrefix + args[0];
        if (args.length > 3 )
        {
              if ( args[3].startsWith("show") ){
                  showMode="yes";
              }
              else
              {
                    MaxIntervals = Integer.parseInt(args[3]) ;
                    System.out.println ("**** Changed idle time to " + MaxIntervals );
              }
        }

        try
        {
            waited_intervals = 0;
            // Load the driver
            if ( args[0].startsWith("oracle") )
            {
                // Ex Argsuments: oracle:thin:@mancswgtb0012:1521:fbti    TIZONE14   TIZONE14
                Class.forName("oracle.jdbc.driver.OracleDriver");
                System.out.println("**** Loading Oracle JDBC driver (" + url + user + ")..." );
            }
            else
            {
                if ( args[0].startsWith("db2") )
                {
                    //ARGS:    db2://C1WC1WC1229:50000/TIPLUS2     TIZONE28   T!Z0N3123
                    Class.forName("com.ibm.db2.jcc.DB2Driver");
                    System.out.println("**** Ok Loading DB2 JDBC driver (" + url + user + ")..." );
                }
                else
                {
                    // ARGS:    C1WC1WC1229:50000/TIPLUS2 TIZONE28 T!Z0N3123
                    // lets says its the old db2 syntax without db2:// 
                    url="jdbc:db2://" + args[0];
                    Class.forName("com.ibm.db2.jcc.DB2Driver");
                    System.out.println("WARNING: unfair  syntax ! Trying DB2 JDBC driver (" + url + user + ")..." );
                }
            }

            // Create the connection using the IBM Data Server Driver for JDBC and SQLJ
            con = DriverManager.getConnection (url, user, password);
            // Commit changes manually
            con.setAutoCommit(false);
            System.out.println("**** JDBC connected to the data source: " + url +")" );

            // Create the Statement
            stmt = con.createStatement();
            System.out.println("**** JDBC Statement object");

            // Start the loop calling task myTask each time
            final ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
            executorService.scheduleAtFixedRate(EzJava::myTask, 0, TaskLookPeriod, TimeUnit.SECONDS);

            System.out.println("**** Loop started for " + MaxIntervals + " minutes" );

        }

        catch (ClassNotFoundException e)
        {
            System.err.println("Could not load JDBC driver");
            System.out.println("Exception: " + e);
            e.printStackTrace();
            System.exit(992);
        }

        catch(SQLException ex)
        {
            System.err.println("SQLException information");
            while(ex!=null) 
            {
                System.err.println ("Error msg: " + ex.getMessage());
                System.err.println ("SQLSTATE: " + ex.getSQLState());
                System.err.println ("Error code: " + ex.getErrorCode());
                ex.printStackTrace();
                ex = ex.getNextException(); // For drivers that support chained exceptions
            }
            System.exit(993);
        }
    }  // End main


    private static void myTask()
    {
        System.out.println("Running");

        try
        {
            rs = stmt.executeQuery("select count(*) from TIGLOBAL28.local_Session_details  where ZONE_ID <> ''  and ENDED IS NULL");

            System.out.println("**** Created JDBC ResultSet object");

            // Print all of the employee numbers to standard output device
            while (rs.next()) 
            {
                //empNo = rs.getI
                //empNo = rs.getInt(1);
                System.out.println("Count of users logged on TIzone1 = " + rs.getString(1));

                int nUsers = Integer.parseInt(rs.getString(1));
                if (nUsers > 0)
                {
                    System.out.println("someone is logged in ");
                    //we wait 1 more minute
                    waited_intervals = 0;
                }
                else
                {
                    if (waited_intervals >= MaxIntervals)
                    {
                        //we can shutdown now
                        System.out.println("no users logged in for  " + waited_intervals + " minutes, we can shutdown. Stopping tests...");
                        System.exit(999);
                    }
                    else
                    {
                        int still_to_wait = MaxIntervals -waited_intervals;
                        System.out.println("No user logged since " + waited_intervals + " minutes." + still_to_wait + " minutes idle to allow stop.");

                        //we wait 1 more minute
                        waited_intervals = waited_intervals +1;
                    }
                }
            }
        }


        catch(SQLException ex)
        {
            System.err.println("SQLException information");
            while(ex!=null)
            {
                System.err.println ("Error msg: " + ex.getMessage());
                System.err.println ("SQLSTATE: " + ex.getSQLState());
                System.err.println ("Error code: " + ex.getErrorCode());
                ex.printStackTrace();
                ex = ex.getNextException(); // For drivers that support chained exceptions
            }
            System.exit(991);
        }
    }

}    // End EzJava
// END OF FILE
