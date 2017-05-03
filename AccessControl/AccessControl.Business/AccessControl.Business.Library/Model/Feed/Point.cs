#region Using

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;

#endregion Using

namespace AccessControl.Business.Library.Model.Feed
{
    [DataContract]
    public enum PointActionType
    {
        [EnumMember]
        None,
        [EnumMember]
        In,
        [EnumMember]
        Out
    }

    [DataContract]
    public class PointPredicate : GenericPredicate
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<string>> Name { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<PointActionType>> PointActionType { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<List<Point>> Point { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Criteria<DateInterval> RegisteredOn { get; set; }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Point : GenericEntity
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
        public PointActionType PointActionType { get; set; }

        #endregion Property

        #region Method

        public void SetPointActionType(string eventName, string modeName)
        {
            if (PointActionType == PointActionType.None &&
                !string.IsNullOrEmpty(Name))
            {
                if (Name.IndexOf("_in", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    PointActionType = PointActionType.In;
                }
                if (Name.IndexOf("_out", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    PointActionType = PointActionType.Out;
                }
                if (Name.IndexOf("-In", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    PointActionType = PointActionType.In;
                }
                if (Name.IndexOf("-Exit", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    PointActionType = PointActionType.Out;
                }
            }
            if (PointActionType == PointActionType.None &&
                !string.IsNullOrEmpty(eventName))
            {
                PointActionType pointActionType;
                if (Enum.TryParse(eventName, true, out pointActionType))
                {
                    PointActionType = pointActionType;
                }
            }
            if (PointActionType == PointActionType.None &&
                !string.IsNullOrEmpty(modeName))
            {
                switch (modeName)
                {
                    case "Entry":
                        {
                            PointActionType = PointActionType.In;
                            break;
                        }
                    case "Exit":
                        {
                            PointActionType = PointActionType.Out;
                            break;
                        }
                }
            }
        }

        public override string ToString()
        {
            return PointActionType.ToString();
        }

        public override bool Map(Dictionary<string, object> keyValues)
        {
            var mapId = Map<Guid?>(keyValues, "PointId");
            Id = mapId.Item1;
            var undefined = mapId.Item2;

            var mapName = Map<string>(keyValues, "PointName");
            Name = mapName.Item1;
            undefined = undefined && mapName.Item2;

            var mapPointActionType = Map<PointActionType>(keyValues, "PointActionType");
            PointActionType = mapPointActionType.Item1;
            undefined = undefined && mapPointActionType.Item2;

            return undefined;
        }

        #endregion Method

        #endregion Public
    }
}
