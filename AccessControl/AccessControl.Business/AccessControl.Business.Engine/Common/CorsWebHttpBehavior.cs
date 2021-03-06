﻿#region Using

using System.Collections.Generic;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class CorsWebHttpBehavior : WebHttpBehavior
    {
        #region Protected

        #region Method

        public override void ApplyDispatchBehavior(ServiceEndpoint endpoint, EndpointDispatcher endpointDispatcher)
        {
            var headers = new Dictionary<string, string>
                {
                    {"Access-Control-Allow-Origin", "*"},
                    {"Access-Control-Allow-Headers", "Cache-Control, Pragma, Authorization, Content-Type, Accept, Origin, User-Agent, DNT, X-Mx-ReqToken, Keep-Alive, X-Requested-With, If-Modified-Since, EmplacementCode, ApplicationCode, CultureCode, TokenCode"},
                    {"Access-Control-Allow-Methods", "GET, POST, PUT, DELETE"},
                    {"Access-Control-Max-Age", "1728000"}
                };
            endpointDispatcher.DispatchRuntime.MessageInspectors.Add(new CorsDispatchMessageInspector(headers));
        }

        #endregion Method

        #endregion Protected
    }
}
