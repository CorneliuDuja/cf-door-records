#region Using

using System;
using System.ServiceModel.Configuration;

#endregion Using

namespace AccessControl.Business.Engine.Common
{
    public class CorsBehaviorExtensionElement : BehaviorExtensionElement
    {
        #region Protected

        #region Method

        protected override object CreateBehavior()
        {
            return new CorsWebHttpBehavior();
        }

        #endregion Method

        #endregion Protected

        #region Public

        #region Property

        public override Type BehaviorType
        {
            get
            {
                return typeof(CorsWebHttpBehavior);
            }
        }

        #endregion Property

        #endregion Public
    }
}
