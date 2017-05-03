#region Using

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Library.Model.State
{
    [DataContract]
    public class SchedulePredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> StartedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> EndedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Duration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Weekdays { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Schedule>> Schedule { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public PersonPredicate PersonPredicate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateTimeOffset?> AppliedOn { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Schedule : GenericEntity
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
        public Person Person { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? StartedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? EndedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Duration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int? Weekdays { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? AppliedOn { get; set; }

        #endregion Property

        #region Method

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "ScheduleId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapPerson = Map<Person>(keyValues);
            Person = mapPerson.Item1;
            undefined = undefined && mapPerson.Item2;

            var mapStartedOn = Map<DateTimeOffset?>(keyValues, "ScheduleStartedOn");
            StartedOn = mapStartedOn.Item1;
            undefined = undefined && mapStartedOn.Item2;

            var mapEndedOn = Map<DateTimeOffset?>(keyValues, "ScheduleEndedOn");
            EndedOn = mapEndedOn.Item1;
            undefined = undefined && mapEndedOn.Item2;

            var mapDuration = Map<double?>(keyValues, "ScheduleDuration");
            Duration = mapDuration.Item1;
            undefined = undefined && mapDuration.Item2;

            var mapWeekdays = Map<int?>(keyValues, "ScheduleWeekdays");
            Weekdays = mapWeekdays.Item1;
            undefined = undefined && mapWeekdays.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
