#region Using

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;

#endregion Using

namespace AccessControl.Business.Library.Model.Feed
{
    [DataContract]
    public class EventPredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> RegisteredOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool? IsEnforced { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool? IsObsolete { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Interval { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Duration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Event>> Event { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public SourcePredicate SourcePredicate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public PersonPredicate PersonPredicate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public PointPredicate PointPredicate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<int> Weekdays { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Event : GenericEntity, IComparable<Event>
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
        public Source Source { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Person Person { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Point Point { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? RegisteredOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool IsEnforced { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public bool IsObsolete { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int? Interval { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Duration { get; set; }

        #endregion Property

        #region Method

        public int CompareTo(Event entity)
        {
            return Nullable.Compare(RegisteredOn, entity == null ? null : entity.RegisteredOn);
        }

        public override string ToString()
        {
            return string.Format("{0} {1}", RegisteredOn, Point);
        }

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "EventId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapSource = Map<Source>(keyValues);
            Source = mapSource.Item1;
            undefined = undefined && mapSource.Item2;

            var mapPerson = Map<Person>(keyValues);
            Person = mapPerson.Item1;
            undefined = undefined && mapPerson.Item2;

            var mapPoint = Map<Point>(keyValues);
            Point = mapPoint.Item1;
            undefined = undefined && mapPoint.Item2;

            var mapRegisteredOn = Map<DateTimeOffset?>(keyValues, "EventRegisteredOn");
            RegisteredOn = mapRegisteredOn.Item1;
            undefined = undefined && mapRegisteredOn.Item2;

            var mapIsEnforced = Map<bool>(keyValues, "EventIsEnforced");
            IsEnforced = mapIsEnforced.Item1;
            undefined = undefined && mapIsEnforced.Item2;

            var mapIsObsolete = Map<bool>(keyValues, "EventIsObsolete");
            IsObsolete = mapIsObsolete.Item1;
            undefined = undefined && mapIsObsolete.Item2;

            var mapInterval = Map<int?>(keyValues, "EventInterval");
            Interval = mapInterval.Item1;
            undefined = undefined && mapInterval.Item2;

            var mapDuration = Map<double?>(keyValues, "EventDuration");
            Duration = mapDuration.Item1;
            undefined = undefined && mapDuration.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
