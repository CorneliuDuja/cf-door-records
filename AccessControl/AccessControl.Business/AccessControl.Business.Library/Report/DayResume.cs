#region Using

using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Model;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Library.Report
{
    [DataContract]
    public class DayResume : GenericEntity
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Person Person { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int? Days { get; set; }

        #region FirstIn

        [DataMember(EmitDefaultValue = false)]
        public double? MinFirstIn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxFirstIn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgFirstIn { get; set; }

        #endregion FirstIn

        #region LastOut

        [DataMember(EmitDefaultValue = false)]
        public double? MinLastOut { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxLastOut { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgLastOut { get; set; }

        #endregion LastOut

        #region Duration

        [DataMember(EmitDefaultValue = false)]
        public double? MinDuration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxDuration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgDuration { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? SumDuration { get; set; }

        #endregion Duration

        #region Deviation

        [DataMember(EmitDefaultValue = false)]
        public double? MinDeviation { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxDeviation { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgDeviation { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? SumDeviation { get; set; }

        #endregion Deviation

        #region Trusted

        [DataMember(EmitDefaultValue = false)]
        public double? MinTrusted { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxTrusted { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgTrusted { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? SumTrusted { get; set; }

        #endregion Trusted

        #region Doubtful

        [DataMember(EmitDefaultValue = false)]
        public double? MinDoubtful { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxDoubtful { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgDoubtful { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? SumDoubtful { get; set; }

        #endregion Doubtful

        #region Reliability

        [DataMember(EmitDefaultValue = false)]
        public double? MinReliability { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? MaxReliability { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public double? AvgReliability { get; set; }

        #endregion Reliability

        #endregion Property

        #region Method

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapPerson = Map<Person>(keyValues);
            Person = mapPerson.Item1;
            var undefined = mapPerson.Item2;

            var mapDays = Map<int?>(keyValues, "Days");
            Days = mapDays.Item1;
            undefined = undefined && mapDays.Item2;

            var mapMinFirstIn = Map<double?>(keyValues, "DayMinFirstIn");
            MinFirstIn = mapMinFirstIn.Item1;
            undefined = undefined && mapMinFirstIn.Item2;

            var mapMaxFirstIn = Map<double?>(keyValues, "DayMaxFirstIn");
            MaxFirstIn = mapMaxFirstIn.Item1;
            undefined = undefined && mapMaxFirstIn.Item2;

            var mapAvgFirstIn = Map<double?>(keyValues, "DayAvgFirstIn");
            AvgFirstIn = mapAvgFirstIn.Item1;
            undefined = undefined && mapAvgFirstIn.Item2;

            var mapMinLastOut = Map<double?>(keyValues, "DayMinLastOut");
            MinLastOut = mapMinLastOut.Item1;
            undefined = undefined && mapMinLastOut.Item2;

            var mapMaxLastOut = Map<double?>(keyValues, "DayMaxLastOut");
            MaxLastOut = mapMaxLastOut.Item1;
            undefined = undefined && mapMaxLastOut.Item2;

            var mapAvgLastOut = Map<double?>(keyValues, "DayAvgLastOut");
            AvgLastOut = mapAvgLastOut.Item1;
            undefined = undefined && mapAvgLastOut.Item2;

            var mapMinDuration = Map<double?>(keyValues, "DayMinDuration");
            MinDuration = mapMinDuration.Item1;
            undefined = undefined && mapMinDuration.Item2;

            var mapMaxDuration = Map<double?>(keyValues, "DayMaxDuration");
            MaxDuration = mapMaxDuration.Item1;
            undefined = undefined && mapMaxDuration.Item2;

            var mapAvgDuration = Map<double?>(keyValues, "DayAvgDuration");
            AvgDuration = mapAvgDuration.Item1;
            undefined = undefined && mapAvgDuration.Item2;

            var mapSumDuration = Map<double?>(keyValues, "DaySumDuration");
            SumDuration = mapSumDuration.Item1;
            undefined = undefined && mapSumDuration.Item2;

            var mapMinDeviation = Map<double?>(keyValues, "DayMinDeviation");
            MinDeviation = mapMinDeviation.Item1;
            undefined = undefined && mapMinDeviation.Item2;

            var mapMaxDeviation = Map<double?>(keyValues, "DayMaxDeviation");
            MaxDeviation = mapMaxDeviation.Item1;
            undefined = undefined && mapMaxDeviation.Item2;

            var mapAvgDeviation = Map<double?>(keyValues, "DayAvgDeviation");
            AvgDeviation = mapAvgDeviation.Item1;
            undefined = undefined && mapAvgDeviation.Item2;

            var mapSumDeviation = Map<double?>(keyValues, "DaySumDeviation");
            SumDeviation = mapSumDeviation.Item1;
            undefined = undefined && mapSumDeviation.Item2;

            var mapMinTrusted = Map<double?>(keyValues, "DayMinTrusted");
            MinTrusted = mapMinTrusted.Item1;
            undefined = undefined && mapMinTrusted.Item2;

            var mapMaxTrusted = Map<double?>(keyValues, "DayMaxTrusted");
            MaxTrusted = mapMaxTrusted.Item1;
            undefined = undefined && mapMaxTrusted.Item2;

            var mapAvgTrusted = Map<double?>(keyValues, "DayAvgTrusted");
            AvgTrusted = mapAvgTrusted.Item1;
            undefined = undefined && mapAvgTrusted.Item2;

            var mapSumTrusted = Map<double?>(keyValues, "DaySumTrusted");
            SumTrusted = mapSumTrusted.Item1;
            undefined = undefined && mapSumTrusted.Item2;

            var mapMinDoubtful = Map<double?>(keyValues, "DayMinDoubtful");
            MinDoubtful = mapMinDoubtful.Item1;
            undefined = undefined && mapMinDoubtful.Item2;

            var mapMaxDoubtful = Map<double?>(keyValues, "DayMaxDoubtful");
            MaxDoubtful = mapMaxDoubtful.Item1;
            undefined = undefined && mapMaxDoubtful.Item2;

            var mapAvgDoubtful = Map<double?>(keyValues, "DayAvgDoubtful");
            AvgDoubtful = mapAvgDoubtful.Item1;
            undefined = undefined && mapAvgDoubtful.Item2;

            var mapSumDoubtful = Map<double?>(keyValues, "DaySumDoubtful");
            SumDoubtful = mapSumDoubtful.Item1;
            undefined = undefined && mapSumDoubtful.Item2;

            var mapMinReliability = Map<double?>(keyValues, "DayMinReliability");
            MinReliability = mapMinReliability.Item1;
            undefined = undefined && mapMinReliability.Item2;

            var mapMaxReliability = Map<double?>(keyValues, "DayMaxReliability");
            MaxReliability = mapMaxReliability.Item1;
            undefined = undefined && mapMaxReliability.Item2;

            var mapAvgReliability = Map<double?>(keyValues, "DayAvgReliability");
            AvgReliability = mapAvgReliability.Item1;
            undefined = undefined && mapAvgReliability.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
