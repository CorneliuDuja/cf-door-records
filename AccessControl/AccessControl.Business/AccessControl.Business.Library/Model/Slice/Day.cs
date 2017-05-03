#region Using

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Library.Model.Slice
{
    [DataContract]
    public class DayPredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> Date { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> FirstIn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> LastOut { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Duration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Deviation { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Trusted { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Doubtful { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Reliability { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Day>> Day { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public PersonPredicate PersonPredicate { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<int> Weekdays { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Day : GenericEntity
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
        public DateTimeOffset? Date { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? FirstIn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? LastOut { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Duration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Deviation { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Trusted { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Doubtful { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? Reliability { get; set; }

        public List<Event> Events { get; set; }

        #endregion Property

        #region Method

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "DayId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapPerson = Map<Person>(keyValues);
            Person = mapPerson.Item1;
            undefined = undefined && mapPerson.Item2;

            var mapDate = Map<DateTimeOffset?>(keyValues, "DayDate");
            Date = mapDate.Item1;
            undefined = undefined && mapDate.Item2;

            var mapFirstIn = Map<DateTimeOffset?>(keyValues, "DayFirstIn");
            FirstIn = mapFirstIn.Item1;
            undefined = undefined && mapFirstIn.Item2;

            var mapLastOut = Map<DateTimeOffset?>(keyValues, "DayLastOut");
            LastOut = mapLastOut.Item1;
            undefined = undefined && mapLastOut.Item2;

            var mapDuration = Map<double?>(keyValues, "DayDuration");
            Duration = mapDuration.Item1;
            undefined = undefined && mapDuration.Item2;

            var mapDeviation = Map<double?>(keyValues, "DayDeviation");
            Deviation = mapDeviation.Item1;
            undefined = undefined && mapDeviation.Item2;

            var mapTrusted = Map<double?>(keyValues, "DayTrusted");
            Trusted = mapTrusted.Item1;
            undefined = undefined && mapTrusted.Item2;

            var mapDoubtful = Map<double?>(keyValues, "DayDoubtful");
            Doubtful = mapDoubtful.Item1;
            undefined = undefined && mapDoubtful.Item2;

            var mapReliability = Map<double?>(keyValues, "DayReliability");
            Reliability = mapReliability.Item1;
            undefined = undefined && mapReliability.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
