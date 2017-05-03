#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using AccessControl.Business.Library.Common;

#endregion Usings

namespace AccessControl.Business.Library.Model
{
    [DataContract]
    public enum SortType
    {
        [EnumMember]
        None,
        [EnumMember]
        Ascending,
        [EnumMember]
        Descending
    }

    [DataContract]
    public class Sort : IComparable<Sort>
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public int Index { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public string Name { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public SortType SortType { get; set; }

        #endregion Property

        #region Method

        public int CompareTo(Sort sort)
        {
            return Index.CompareTo(sort.Index);
        }

        public override string ToString()
        {
            return string.Format("{0} {1}", Name, (SortType == SortType.Ascending) ? "ASC" : "DESC");
        }

        #endregion Method

        #endregion Public
    }

    [DataContract]
    public class Pager
    {
        #region Private

        #region Property

        private int? pages;

        #endregion Property

        #endregion Private

        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public int? Index { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int? Size { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int StartLag { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int Count { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int Number { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public int? Pages 
        { 
            get
            {
                if (Size.HasValue && 
                    Size.Value > 0)
                {
                    pages = Number/Size.Value + Math.Sign(Number%Size.Value);
                }
                else
                {
                    pages = null;
                }
                return pages;
            }
            set
            {
                pages = value;
            }
        }

        #endregion Property

        #endregion Public
    }

    [DataContract]
    public class Criteria<T>
    {
        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public bool IsExcluded { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public T Value { get; set; }

        #endregion Property

        #region Method

        public Criteria(){}

        public Criteria(T value)
        {
            Value = value;
        }

        #endregion Method

        #endregion Public
    }

    [DataContract]
    public abstract class GenericPredicate
    {
        #region Private

        #region Property

        private string order;

        #endregion Property

        #endregion Private

        #region Public

        #region Property

        [DataMember(EmitDefaultValue = false)]
        public bool IsExcluded { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public Pager Pager { get; set; }

        [DataMember(EmitDefaultValue = false)]
        public string Order
        {
            get
            {
                order = null;
                if (Sorts != null &&
                    Sorts.Count > 0)
                {
                    var indexes = new List<int>();
                    for (var index = 0; index < Sorts.Count; index++)
                    {
                        if (Sorts[index] == null ||
                            Sorts[index].Name == null)
                        {
                            indexes.Add(index);
                            continue;
                        }
                        if (string.IsNullOrEmpty(Sorts[index].Name.Trim()))
                        {
                            indexes.Add(index);
                        }
                    }
                    foreach (var index in indexes)
                    {
                        Sorts.RemoveAt(index);
                    }
                    Sorts.Sort();
                    order = " ORDER BY " + string.Join(Constant.COMMA.ToString(), Sorts.Select(sort => sort.ToString()).ToArray());
                }
                return order;
            }
            set
            {
                order = value;
            }
        }

        [DataMember(EmitDefaultValue = false)]
        public List<Sort> Sorts { get; set; }

        #endregion Property

        #endregion Public
    }
}