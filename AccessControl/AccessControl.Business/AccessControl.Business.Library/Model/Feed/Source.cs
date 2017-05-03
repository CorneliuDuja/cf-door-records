#region Using

using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;
using AccessControl.Business.Library.Model.Slice;

#endregion Using

namespace AccessControl.Business.Library.Model.Feed
{
    [DataContract]
    public enum SourceFileType
    {
        [EnumMember]
        None,
        [EnumMember]
        Csv,
        [EnumMember]
        Database
    }

    [DataContract]
    public class SourcePredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> Date { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<SourceFileType>> SourceFileType { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> LoadedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> ExtractedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> TransformedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> AnalysedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<AmountInterval> Length { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Source>> Source { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<int> Weekdays { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Source : GenericEntity
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
        public DateTimeOffset? Date { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public SourceFileType SourceFileType { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? LoadedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? ExtractedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? TransformedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public DateTimeOffset? AnalysedOn { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public long? Length { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public List<Person> Persons { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public List<Point> Points { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public List<Event> Events { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public List<Day> Days { get; set; }

        public string Path { get; set; }

        public StreamReader StreamReader { get; set; }

        public List<List<string>> Lines { get; set; }

        public Dictionary<string, Person> KeyPersons { get; set; }

        public Dictionary<string, Point> KeyPoints { get; set; }

        public Point DefaultPointIn { get; set; }

        public Point DefaultPointOut { get; set; }

        public Dictionary<Person, Dictionary<DateTimeOffset, Dictionary<DateTimeOffset, Event>>> KeyEvents { get; set; }

        #endregion Property

        #region Method

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "SourceId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapDate = Map<DateTimeOffset?>(keyValues, "SourceDate");
            Date = mapDate.Item1;
            undefined = undefined && mapDate.Item2;

            var mapSourceFileType = Map<SourceFileType>(keyValues, "SourceFileType");
            SourceFileType = mapSourceFileType.Item1;
            undefined = undefined && mapSourceFileType.Item2;

            var mapLoadedOn = Map<DateTimeOffset?>(keyValues, "SourceLoadedOn");
            LoadedOn = mapLoadedOn.Item1;
            undefined = undefined && mapLoadedOn.Item2;

            var mapExtractedOn = Map<DateTimeOffset?>(keyValues, "SourceExtractedOn");
            ExtractedOn = mapExtractedOn.Item1;
            undefined = undefined && mapExtractedOn.Item2;

            var mapTransformedOn = Map<DateTimeOffset?>(keyValues, "SourceTransformedOn");
            TransformedOn = mapTransformedOn.Item1;
            undefined = undefined && mapTransformedOn.Item2;

            var mapAnalysedOn = Map<DateTimeOffset?>(keyValues, "SourceAnalysedOn");
            AnalysedOn = mapAnalysedOn.Item1;
            undefined = undefined && mapAnalysedOn.Item2;

            var mapLength = Map<long?>(keyValues, "SourceLength");
            Length = mapLength.Item1;
            undefined = undefined && mapLength.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
