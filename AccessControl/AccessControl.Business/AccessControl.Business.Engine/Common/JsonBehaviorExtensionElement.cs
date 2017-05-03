#region Using

using System;
using System.ServiceModel.Configuration;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class JsonBehaviorExtensionElement : BehaviorExtensionElement
    {
        #region Protected

        #region Method

        protected override object CreateBehavior()
        {
            return new JsonWebHttpBehavior();
        }

        #endregion Method

        #endregion Protected

        #region Public

        #region Property

        public override Type BehaviorType
        {
            get
            {
                return typeof(JsonWebHttpBehavior);
            }
        }

        #endregion Property

        #endregion Public Member
    }
}
