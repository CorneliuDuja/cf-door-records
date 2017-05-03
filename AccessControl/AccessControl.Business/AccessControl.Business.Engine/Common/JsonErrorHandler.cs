#region Using

using System;
using System.Net;
using System.Runtime.Serialization.Json;
using System.ServiceModel.Channels;
using System.ServiceModel.Dispatcher;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class JsonErrorHandler : IErrorHandler
    {
        #region Public

        #region Method

        public bool HandleError(Exception error)
        {
            return true;
        }

        public void ProvideFault(Exception error, MessageVersion version, ref Message fault)
        {
            fault = Message.CreateMessage(
                version, 
                string.Empty, 
                error,
                new DataContractJsonSerializer(typeof(Exception)));
            fault.Properties.Add(WebBodyFormatMessageProperty.Name, new WebBodyFormatMessageProperty(WebContentFormat.Json));
            fault.Properties.Add(HttpResponseMessageProperty.Name, new HttpResponseMessageProperty
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    StatusDescription = string.Empty
                });
        }

        #endregion Method

        #endregion Public
    }
}
