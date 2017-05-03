#region Usings

using System.Runtime.Serialization;
using AccessControl.Business.Library.Model;

#endregion Usings

namespace AccessControl.Business.Library.Data
{
    [DataContract]
    public enum ActionType
    {
        [EnumMember]
        None,
        [EnumMember]
        SourceCreate,
        [EnumMember]
        SourceRead,
        [EnumMember]
        SourceSelect,
        [EnumMember]
        PersonSelect,
        [EnumMember]
        PointSelect,
        [EnumMember]
        EventSelect,
        [EnumMember]
        DaySelect,
        [EnumMember]
        DayResumeSelect,
        [EnumMember]
        ScheduleRead
    }

    [DataContract]
    public class GenericInput<T, P> where T : GenericEntity where P : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public ActionType ActionType { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public T Entity { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public P Predicate { get; set; }

        #endregion Property

        #endregion Public
    }
}