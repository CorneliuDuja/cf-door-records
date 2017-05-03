#region Using

using System.Runtime.Serialization;

#endregion Using

namespace AccessControl.Business.Library.Common
{
    [DataContract]
    public class AmountInterval
    {
        #region Public Members

        #region Properties

        [DataMember(EmitDefaultValue = false)]
        public double? AmountFrom { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AmountTo { get; set; }

        #endregion Properties

        #region Methods

        public AmountInterval()
        {
            
        }

        public AmountInterval(double? amountFrom, double? amountTo)
        {
            AmountFrom = amountFrom;
            AmountTo = amountTo;
        }

        #endregion Methods

        #endregion Public Members
    }
}