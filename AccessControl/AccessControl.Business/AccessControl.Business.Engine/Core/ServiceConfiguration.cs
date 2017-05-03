#region Using

using System;
using System.Configuration;

#endregion Using

namespace AccessControl.Business.Engine.Core
{
    public class ServiceConfiguration
    {
        #region Public

        #region Property

        public char LineSeparator { get; set; }

        public string LineMatch { get; set; }

        public string RegexDigits { get; set; }

        public int LineValuesCount { get; set; }

        public int DateIndex { get; set; }

        public int TimeIndex { get; set; }

        public int PersonNameIndex { get; set; }

        public int PointNameIndex { get; set; }

        public int EventNameIndex { get; set; }

        public int ModeNameIndex { get; set; }

        public string DateFormat { get; set; }

        public string TimeFormat { get; set; }

        public string OffsetFormat { get; set; }

        public TimeZoneInfo TimeZoneInfo { get; set; }

        public TimeSpan FirstInTime { get; set; }

        public TimeSpan LastOutTime { get; set; }

        public TimeSpan MinDuration { get; set; }

        public TimeSpan DayDuration { get; set; }

        public int Weekdays { get; set; }

        public string FeedPath { get; set; }

        public bool IncludeDateNow { get; set; }

        public TimeSpan SleepInterval { get; set; }

        public string SignalRUrl { get; set; }

        public string SignalRPathMatch { get; set; }

        public string RealIpHeaderKey { get; set; }

        public int? DatabaseCommandTimeout { get; set; }

        public string DateTimeOffsetFormat { get; set; }

        public string ApplicationEventLogSource { get; set; }

        public string ExtractImplementation { get; set; }

        public ConnectionStringSettings DatabaseConnectionString { get; set; }

        public ConnectionStringSettings ExtractDatabaseConnectionString { get; set; }

        #endregion Property

        #region Method

        public ServiceConfiguration()
        {
            var appSetting = ConfigurationManager.AppSettings["LineSeparator"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                LineSeparator = appSetting.ToCharArray()[0];
            }
            appSetting = ConfigurationManager.AppSettings["LineMatch"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                LineMatch = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["RegexDigits"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                RegexDigits = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["LineValuesCount"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                LineValuesCount = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["DateIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                DateIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["TimeIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                TimeIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["PersonNameIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                PersonNameIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["PointNameIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                PointNameIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["EventNameIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                EventNameIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["ModeNameIndex"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                ModeNameIndex = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["DateFormat"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                DateFormat = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["TimeFormat"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                TimeFormat = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["OffsetFormat"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                OffsetFormat = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["TimeZoneInfo"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                TimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["FirstInTime"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                FirstInTime = TimeSpan.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["LastOutTime"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                LastOutTime = TimeSpan.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["MinDuration"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                MinDuration = TimeSpan.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["DayDuration"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                DayDuration = TimeSpan.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["Weekdays"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                Weekdays = int.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["FeedPath"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                FeedPath = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["IncludeDateNow"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                IncludeDateNow = bool.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["SleepInterval"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                SleepInterval = TimeSpan.Parse(appSetting);
            }
            appSetting = ConfigurationManager.AppSettings["SignalRUrl"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                SignalRUrl = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["SignalRPathMatch"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                SignalRPathMatch = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["RealIpHeaderKey"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                RealIpHeaderKey = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["DatabaseCommandTimeout"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                DatabaseCommandTimeout = int.Parse(appSetting);
            }
            DateTimeOffsetFormat = string.Format("{0} {1} {2}", DateFormat, TimeFormat, OffsetFormat);
            appSetting = ConfigurationManager.AppSettings["ApplicationEventLogSource"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                ApplicationEventLogSource = appSetting;
            }
            appSetting = ConfigurationManager.AppSettings["ExtractImplementation"];
            if (!string.IsNullOrEmpty(appSetting))
            {
                ExtractImplementation = appSetting;
            }
            var connectionString = ConfigurationManager.ConnectionStrings["AccessControl"];
            if (connectionString != null)
            {
                DatabaseConnectionString = connectionString;
            }
            connectionString = ConfigurationManager.ConnectionStrings["AccessControlSystem"];
            if (connectionString != null)
            {
                ExtractDatabaseConnectionString = connectionString;
            }
        }

        #endregion Method

        #endregion Public
    }
}
