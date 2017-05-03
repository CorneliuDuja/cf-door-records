#region Using

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;

#endregion Using

namespace AccessControl.Business.Library.Model.Feed
{
    [DataContract]
    public class PersonPredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<string>> Name { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool? IsPrivate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Person>> Person { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> RegisteredOn { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Person : GenericEntity
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Guid? Id
        {
            get { return id; }
            set { id = value; }
        }

        [DataMember(EmitDefaultValue = false)]
        public string Name { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool IsPrivate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool IsInside { get; set; }

        #endregion Property

        #region Method

        public override string ToString()
        {
            return Name;
        }

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "PersonId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapName = Map<string>(keyValues, "PersonName");
            Name = mapName.Item1;
            undefined = undefined && mapName.Item2;

            var mapIsPrivate = Map<bool>(keyValues, "PersonIsPrivate");
            IsPrivate = mapIsPrivate.Item1;
            undefined = undefined && mapIsPrivate.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
