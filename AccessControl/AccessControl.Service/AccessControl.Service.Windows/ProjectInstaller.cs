#region Using

using System.ComponentModel;
using System.Configuration.Install;
using System.Diagnostics;

#endregion Using

namespace AccessControl.Service.Windows
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : Installer
    {
        #region Public

        #region Method

        public ProjectInstaller()
        {
            InitializeComponent();
            var eventLogInstaller = new EventLogInstaller
                {
                    Source = "Access Control Service",
                    Log = "Application"
                };
            if (!EventLog.SourceExists(eventLogInstaller.Source))
            {
                Installers.Add(eventLogInstaller);
            }
        }

        #endregion Method

        #endregion Public
    }
}
