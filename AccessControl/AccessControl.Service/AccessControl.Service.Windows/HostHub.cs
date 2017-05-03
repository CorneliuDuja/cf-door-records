#region Using

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AccessControl.Business.Engine.Core;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using Microsoft.Owin.Cors;
using Owin;

#endregion Using

namespace AccessControl.Service.Windows
{
    public class Startup
    {
        public void Configuration(IAppBuilder appBuilder)
        {
            appBuilder.Map(Kernel.Instance.ServiceConfiguration.SignalRPathMatch, map =>
            {
                map.UseCors(CorsOptions.AllowAll);
                var hubConfiguration = new HubConfiguration
                    {
                        EnableJSONP = true
                    };
                map.RunSignalR(hubConfiguration);
            }); 
        }
    }

    public class ConnectionContext
    {
        #region Public

        #region Property

        public DateTimeOffset? ConnectedOn { get; private set; }

        public Dictionary<string, object> RequestEnvironment { get; private set; }

        public string ServerRemoteIpAddress
        {
            get
            {
                var serverRemoteIpAddress = (string)GetRequestEnvironmentValue(Kernel.Instance.ServiceConfiguration.RealIpHeaderKey);
                if (string.IsNullOrEmpty(serverRemoteIpAddress))
                {
                    serverRemoteIpAddress = (string)GetRequestEnvironmentValue("server.RemoteIpAddress");
                }
                return serverRemoteIpAddress;
            }
        }

        public string ServerRemotePort
        {
            get
            {
                return (string)GetRequestEnvironmentValue("server.RemotePort");
            }
        }

        public string ServerRemoteHost
        {
            get
            {
                string serverRemoteHost = null;
                var serverRemoteIpAddress = ServerRemoteIpAddress;
                var serverRemotePort = ServerRemotePort;
                if (!string.IsNullOrEmpty(serverRemoteIpAddress))
                {
                    serverRemoteHost = serverRemoteIpAddress;
                    if (!string.IsNullOrEmpty(serverRemotePort))
                    {
                        serverRemoteHost = string.Format("{0}:{1}", serverRemoteHost, serverRemotePort);
                    }
                }
                return serverRemoteHost;
            }
        }

        #endregion Property

        #region Method

        public ConnectionContext(HubCallerContext hubCallerContext)
        {
            ConnectedOn = DateTimeOffset.Now;
            RequestEnvironment = new Dictionary<string, object>();
            if (hubCallerContext == null) return;
            foreach (var key in hubCallerContext.Request.Environment.Keys)
            {
                object environmentValue;
                hubCallerContext.Request.Environment.TryGetValue(key, out environmentValue);
                RequestEnvironment.Add(key, environmentValue);
            }
            var realIpAddress = hubCallerContext.Request.Headers.Get(Kernel.Instance.ServiceConfiguration.RealIpHeaderKey);
            if (!string.IsNullOrEmpty(realIpAddress))
            {
                RequestEnvironment.Add(Kernel.Instance.ServiceConfiguration.RealIpHeaderKey, realIpAddress);
            }
        }

        public object GetRequestEnvironmentValue(string key)
        {
            object value = null;
            if (RequestEnvironment != null &&
                RequestEnvironment.ContainsKey(key))
            {
                value = RequestEnvironment[key];
            }
            return value;
        }

        #endregion Method

        #endregion Public
    }

    public class HostHub : Hub
    {
        #region Private

        #region Property

        private static Dictionary<string, ConnectionContext> connectionContexts = new Dictionary<string, ConnectionContext>();

        #endregion Property

        #endregion Private

        #region Public

        #region Property

        public static DateTimeOffset LastProcessedOn { get; set; }

        public static string Message { get; set; }

        #endregion Property

        #region Method

        public override Task OnConnected()
        {
            if (!connectionContexts.ContainsKey(Context.ConnectionId))
            {
                connectionContexts.Add(Context.ConnectionId, new ConnectionContext(Context));
                Send(Clients);
            }
            return base.OnConnected();
        }

        public override Task OnDisconnected(bool stopCalled)
        {
            if (connectionContexts.ContainsKey(Context.ConnectionId))
            {
                connectionContexts.Remove(Context.ConnectionId);
                Send(Clients);
            }
            return base.OnDisconnected(stopCalled);
        }

        public static void Send(IHubConnectionContext<dynamic> clients)
        {
            var serverRemoteInfo = new List<KeyValuePair<DateTimeOffset, string>>();
            foreach (var connectionContext in connectionContexts)
            {
                if (!connectionContext.Value.ConnectedOn.HasValue) continue;
                var serverRemoteHost = connectionContext.Value.ServerRemoteHost;
                if (string.IsNullOrEmpty(serverRemoteHost)) continue;
                serverRemoteInfo.Add(new KeyValuePair<DateTimeOffset, string>(connectionContext.Value.ConnectedOn.Value, serverRemoteHost));
            }
            serverRemoteInfo.Sort((x, y) => x.Key.CompareTo(y.Key));
            clients.All.sendServerRemoteInfo(serverRemoteInfo);
            clients.All.sendLastProcessedOn(LastProcessedOn);
            clients.All.sendMessage(Message);
        }

        #endregion Method

        #endregion Public
    }
}
