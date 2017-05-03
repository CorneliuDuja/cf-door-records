#region Using

using System;
using System.Linq;
using System.ServiceModel;
using System.ServiceProcess;
using System.Threading;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Logic;
using Microsoft.AspNet.SignalR;
using Microsoft.Owin.Hosting;

#endregion Using

namespace AccessControl.Service.Windows
{
    public class Manager : ServiceBase
    {
        #region Protected

        #region Property

        protected static readonly object semaphore = new object();
        protected static readonly Thread thread = new Thread(Execute);
        protected static bool isActive = true;

        #endregion Property

        #region Method

        protected static void Execute(object parameter)
        {
            var waitCallback = (WaitCallback)parameter;
            if (waitCallback == null) return;
            while (isActive)
            {
                ThreadPool.QueueUserWorkItem(waitCallback);
                Thread.Sleep(Kernel.Instance.ServiceConfiguration.SleepInterval);
            }
        }

        private static void Process(object target)
        {
            lock (semaphore)
            {
                var fileSources = ModelLogic.Instance.SourceProcess();
                var message = "No files/dates processed.";
                if (fileSources != null)
                {
                    var source = fileSources.FirstOrDefault();
                    if (source != null &&
                        source.Date.HasValue &&
                        fileSources.Count == 1)
                    {
                        message = string.Format("{0} date processed.", source.Date.Value.ToString(Kernel.Instance.ServiceConfiguration.DateFormat));
                    }
                    else
                    {
                        message = string.Format("{0} files/dates processed.", fileSources.Count);
                    }
                }
                HostHub.LastProcessedOn = DateTimeOffset.Now;
                HostHub.Message = message;
                HostHub.Send(GlobalHost.ConnectionManager.GetHubContext<HostHub>().Clients);
            }
        }

        protected override void OnStart(string[] args)
        {
            Kernel.Instance.Start();
            if (!string.IsNullOrEmpty(Kernel.Instance.ServiceConfiguration.SignalRUrl))
            {
                WebApp.Start(Kernel.Instance.ServiceConfiguration.SignalRUrl);
                Kernel.Instance.Logging.Information("Start Access Control SignalR Service...");
            }
            thread.Start(new WaitCallback(Process));
            if (Host != null)
            {
                Host.Close();
            }
            Host = new ServiceHost(typeof(Host));
            Host.Open();
        }

        protected override void OnStop()
        {
            isActive = false;
            Kernel.Instance.Stop();
            if (Host == null) return;
            Host.Close();
            Host = null;
        }

        #endregion Method

        #endregion Protected

        #region Public

        #region Property

        public ServiceHost Host { get; set; }

        #endregion Property

        #region Method

        public void OnDebug()
        {
            OnStart(new string[0]);
        }

        #endregion Method

        #endregion Public
    }
}
