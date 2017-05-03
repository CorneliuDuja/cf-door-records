#region Using

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Logic.Extract
{
    public class DatabaseExtract : IExtract
    {
        public const string GET_DAY_SOURCES = @"
            SELECT 
	            X.[Date]	[Date],
	            COUNT(*)    [Length]
            FROM 
            (
	            SELECT DATEADD(DAY, 0, DATEDIFF(DAY, 0, SR.[f_ReadDate])) [Date]
	            FROM [dbo].[t_d_SwipeRecord] SR
            ) X
            GROUP BY X.[Date]
            ORDER BY X.[Date]
        ";

        public const string EXTRACT_DAY_SOURCES = @"
            SELECT
	            LEFT(X.[DateTime],	10)	[Date],
	            RIGHT(X.[DateTime],  9)	[Time],
	            X.*
            FROM (
	            SELECT 
		            CONVERT(NVARCHAR(MAX), SR.[f_ReadDate], 120)	[DateTime],
		            C.[f_ConsumerName]								[PersonName],
		            R.[f_ReaderName]	                            [PointName],
		            CASE
		                WHEN	SR.[f_InOut] = 0	THEN 'In'
		                WHEN	SR.[f_InOut] = 1	THEN 'Out'
		            END												[EventName]
	            FROM [dbo].[t_d_SwipeRecord]		SR 
	            INNER JOIN	[dbo].[t_b_Consumer]	C	ON	SR.[f_ConsumerID]	= C.[f_ConsumerID]
	            INNER JOIN	[dbo].[t_b_Reader]		R	ON	SR.[f_ReaderID]		= R.[f_ReaderID]
	            WHERE DATEADD(DAY, 0, DATEDIFF(DAY, 0, SR.[f_ReadDate])) = '{0}'
            ) X
            ORDER BY X.[DateTime]
        ";

        #region Public

        #region Method

        public Dictionary<string, Source> GetDaySources()
        {
            var daySources = new Dictionary<string, Source>();
            Kernel.Instance.Logging.Information(string.Format("Extract from '{0}' database...", Kernel.Instance.ServiceConfiguration.ExtractDatabaseConnectionString.Name));
            var sqlCommand = new SqlCommand
                {
                    CommandText = GET_DAY_SOURCES,
                    CommandType = CommandType.Text
                };
            using (var sqlConnection = new SqlConnection(Kernel.Instance.ServiceConfiguration.ExtractDatabaseConnectionString.ConnectionString))
            {
                sqlConnection.Open();
                sqlCommand.Connection = sqlConnection;
                Kernel.SetDatabaseTimeout(sqlCommand);
                using (var dataReader = sqlCommand.ExecuteReader())
                {
                    while (dataReader.Read())
                    {
                        var date = (DateTime)dataReader["Date"];
                        daySources.Add(date.ToString(Kernel.Instance.ServiceConfiguration.DateFormat), new Source
                            {
                                Date = date,
                                Length = (int) dataReader["Length"]
                            });
                    }
                }
                sqlConnection.Close();
            }
            return daySources;
        }

        public void ExtractDaySource(KeyValuePair<string, Source> daySource)
        {
            daySource.Value.SourceFileType = SourceFileType.Database;
            daySource.Value.LoadedOn = DateTimeOffset.Now;
            daySource.Value.Lines = new List<List<string>>();
            var sqlCommand = new SqlCommand
                {
                    CommandText = string.Format(EXTRACT_DAY_SOURCES, daySource.Key),
                    CommandType = CommandType.Text
                };
            using (var sqlConnection = new SqlConnection(Kernel.Instance.ServiceConfiguration.ExtractDatabaseConnectionString.ConnectionString))
            {
                sqlConnection.Open();
                sqlCommand.Connection = sqlConnection;
                Kernel.SetDatabaseTimeout(sqlCommand);
                using (var dataReader = sqlCommand.ExecuteReader())
                {
                    while (dataReader.Read())
                    {
                        daySource.Value.Lines.Add(new List<string>
                            {
                                dataReader["Date"].ToString(),
                                dataReader["Time"].ToString(),
                                dataReader["PersonName"].ToString(),
                                dataReader["PointName"].ToString(),
                                dataReader["EventName"].ToString()
                            });
                    }
                }
                sqlConnection.Close();
            }
            daySource.Value.ExtractedOn = DateTimeOffset.Now;
        }

        #endregion Public

        #endregion Method
    }
}
