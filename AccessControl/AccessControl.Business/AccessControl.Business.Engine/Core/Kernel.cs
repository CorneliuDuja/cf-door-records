#region Using

using System.Data.SqlClient;
using AccessControl.Business.Engine.Common;

#endregion Using

namespace AccessControl.Business.Engine.Core
{
    public sealed class Kernel
    {
        #region Private

        #region Property

        private static readonly Kernel instance = new Kernel();

        #endregion Property

        #endregion Private

        #region Public

        #region Property

        public static Kernel Instance
        {
            get { return instance; }
        }

        public ServiceConfiguration ServiceConfiguration { get; set; }

        public Logging Logging { get; set; }

        #endregion Property

        #region Method

        public void Start()
        {
            ServiceConfiguration = new ServiceConfiguration();
            Logging = new Logging(ServiceConfiguration.ApplicationEventLogSource);
            Logging.Information("Start Access Control Web Service...");
        }

        public void Stop()
        {
            Logging.Information("Stop Access Control Web Service...");
            Logging = null;
            ServiceConfiguration = null;
        }

        public static void SetDatabaseTimeout(SqlCommand sqlCommand)
        {
            if (Instance.ServiceConfiguration.DatabaseCommandTimeout.HasValue)
            {
                sqlCommand.CommandTimeout = Instance.ServiceConfiguration.DatabaseCommandTimeout.Value;
            }
        }

        #endregion Method

        #endregion Public
    }
}