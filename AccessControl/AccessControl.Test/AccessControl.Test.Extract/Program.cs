using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Common;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace AccessControl.Test.Extract
{
    class Program
    {
        static void Main(string[] args)
        {
//            const string connectionString1 =
//            @"
//                Driver={{Microsoft Paradox Driver (*.db )}};
//                Uid={0};
//                ParadoxUserName={0};
//                ParadoxNetStyle=4.x;
//                ParadoxNetPath={1};
//                DriverID=538;
//                Fil=Paradox 7.X;
//                DefaultDir={2};
//                Dbq={2}
//            ";
            const string connectionString =
            @"
                Driver={{Microsoft Paradox Driver (*.db )}};
                DriverID=538;
                Fil=Paradox 5.X;
                DefaultDir={0};
                Dbq={0}
            ";
            //string userName = "ADMIN";
            string databasePath = ConfigurationManager.AppSettings.Get("DatabasePath");
            string tempPath = ConfigurationManager.AppSettings.Get("TempPath");
            var paths = Directory.GetFiles(databasePath);
            foreach (var path in paths)
            {
                File.Copy(path, string.Format(@"{0}\{1}", tempPath, Path.GetFileName(path)), true);
            }
            Thread.Sleep(2000);
            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.Odbc");
            using (DbConnection connection = factory.CreateConnection())
            {
                //connection.ConnectionString = String.Format(connectionString, databasePath);
                connection.ConnectionString = String.Format(connectionString, tempPath);
                //connection.ConnectionString = String.Format(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0};Extended Properties=Paradox 5.x;", tempPath);
                connection.Open();
                using (DbCommand command = connection.CreateCommand())
                {
                    var lines = new List<List<string>>();
                    command.CommandText =
                    @"
                        SELECT 
                            EC.[ECDate],
                            EC.[ECTime],
                            '[001]: Access granted',
                            R.[Name],
                            U.[LastName]
                        FROM [EventsCache] EC, [Readers] R, [Users] U
                        WHERE  
                            (EC.[ECDate] = {d '2014-10-14'})    AND
                            (EC.[ECCode] = 1)                   AND
                            (EC.[ECReaderID] = R.[ReaderID])    AND
                            (EC.[ECUserID]   = U.[UserID])
                    ";
                    //command.CommandText = "SELECT COUNT(*) FROM [EventsCache] EC";
                    using (var dataReader = command.ExecuteReader())
                    {
                        while (dataReader.Read())
                        {
                            var values = new List<string>();
                            for (var index = 0; index < dataReader.FieldCount; index++)
                            {
                                values.Add(dataReader.GetString(index).Replace(" 00:00:00", string.Empty).Replace("1899-12-30 ", string.Empty));
                            }
                            lines.Add(values);
                        }
                    }
                    Console.WriteLine("Order items: {0}", lines.Count);
                    Console.ReadKey();
                }
            }
        }
    }
}
