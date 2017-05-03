#region Using

using System;
using System.Diagnostics;
using AccessControl.Business.Library.Common;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class Logging
    {
        #region Private

        #region Property

        private string ApplicationEventLogSource { get; set; }

        #endregion Property

        #endregion Private

        #region Public

        #region Method

        public Logging(string applicationEventLogSource)
        {
            ApplicationEventLogSource = applicationEventLogSource;
        }

        public void Error(string message, bool rethrow)
        {
            if (string.IsNullOrEmpty(ApplicationEventLogSource) ||
                string.IsNullOrEmpty(message)) return;
            EventLog.WriteEntry(ApplicationEventLogSource, message, EventLogEntryType.Error);
            if (rethrow)
            {
                throw new Exception(message);
            }
        }

        public void Error(Exception exception, bool rethrow)
        {
            if (exception == null) return;
            Error(string.Format(Constant.EXCEPTION_LOG_FORMAT, exception.Source, exception.Message, exception.StackTrace), false);
            if (rethrow)
            {
                throw new Exception(exception.Message);
            }
        }

        public void Error(Exception exception, string message)
        {
            if (exception == null) return;
            Error(string.Format(Constant.EXCEPTION_LOG_FORMAT, exception.Source, exception.Message, exception.StackTrace), false);
            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
        }

        public void Information(string message, params object[] parameters)
        {
            if (!string.IsNullOrEmpty(ApplicationEventLogSource) &&
                !string.IsNullOrEmpty(message))
            {
                EventLog.WriteEntry(ApplicationEventLogSource, string.Format(message, parameters), EventLogEntryType.Information);
            }
        }

        public void Warning(string message)
        {
            if (!string.IsNullOrEmpty(ApplicationEventLogSource) &&
                !string.IsNullOrEmpty(message))
            {
                EventLog.WriteEntry(ApplicationEventLogSource, message, EventLogEntryType.Warning);
            }
        }

        #endregion Method

        #endregion Public
    }
}
