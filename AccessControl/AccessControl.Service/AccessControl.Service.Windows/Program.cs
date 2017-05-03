#region Using

using System.Diagnostics;
using System.ServiceProcess;
using System.Threading;

#endregion Using

namespace AccessControl.Service.Windows
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            var start = true;
#if (DEBUG)
            if (Debugger.IsAttached)
            {
                start = false;
                // Debug code: this allows the process to run as a non-service.
                // It will kick off the service start point, but never kill it.
                // Shut down the debugger to exit
                var service = new Manager();
                service.OnDebug();
                Thread.Sleep(Timeout.Infinite);
            }
#endif
            if (!start) return;
            // More than one user Service may run within the same process. To add
            // another service to this process, change the following line to
            // create a second service object. For example,
            //
            //   ServicesToRun = new ServiceBase[] {new MyService(), new MySecondUserService()};
            //
            var servicesToRun = new ServiceBase[]
                                    {
                                        new Manager()
                                    };
            ServiceBase.Run(servicesToRun);
        }
    }
}
