#region Using

using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class JsonWebHttpBehavior : WebHttpBehavior
    {
        #region Protected

        #region Method

        protected override void AddServerErrorHandlers(ServiceEndpoint endpoint, EndpointDispatcher endpointDispatcher)
        {
            endpointDispatcher.ChannelDispatcher.ErrorHandlers.Clear();
            endpointDispatcher.ChannelDispatcher.ErrorHandlers.Add(new JsonErrorHandler());
        }

        #endregion Method

        #endregion Protected
    }
}
