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

        private EventLog eventLog;

        #endregion Property

        #endregion Private

        #region Public

        #region Method

        public Logging(string source, OverflowAction? overflowAction = null, int? retentionDays = null)
        {
            if (!string.IsNullOrEmpty(source))
            {
                eventLog = new EventLog
                {
                    Source = source
                };
                if (overflowAction.HasValue &&
                    retentionDays.HasValue)
                {
                    eventLog.ModifyOverflowPolicy(overflowAction.Value, retentionDays.Value);
                }
            }
        }

        public void Error(string message, bool rethrow)
        {
            if (eventLog == null ||
                string.IsNullOrEmpty(message)) return;
            eventLog.WriteEntry(message, EventLogEntryType.Error);
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
            if (eventLog != null &&
                !string.IsNullOrEmpty(message))
            {
                eventLog.WriteEntry(string.Format(message, parameters), EventLogEntryType.Information);
            }
        }

        public void Warning(string message, params object[] parameters)
        {
            if (eventLog != null &&
                !string.IsNullOrEmpty(message))
            {
                eventLog.WriteEntry(string.Format(message, parameters), EventLogEntryType.Warning);
            }
        }

        #endregion Method

        #endregion Public
    }
}
