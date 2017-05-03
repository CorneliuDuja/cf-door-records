#region Usings

using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Model;

#endregion Usings

namespace AccessControl.Business.Library.Data
{
    [DataContract]
    public class GenericOutput<T> where T : GenericEntity
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public ActionType ActionType { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public T Entity { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public List<T> Entities { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Pager Pager { get; set; }

        #endregion Property

        #endregion Public
    }
}