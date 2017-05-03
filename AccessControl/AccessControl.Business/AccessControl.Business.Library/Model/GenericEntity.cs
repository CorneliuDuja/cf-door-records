#region Usings

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

#endregion Usings

namespace AccessControl.Business.Library.Model
{
    [DataContract]
    public abstract class GenericEntity
    {
        #region Protected

        #region Property

        protected Guid? id;

        #endregion Property

        #endregion Protected

        #region Public

        #region Method

        public bool Equals(GenericEntity genericEntity)
        {
            var equals = false;
            if (id.HasValue &&
                HasValue(genericEntity) &&
                GetType() == genericEntity.GetType())
            {
                equals = id.Equals(genericEntity.id);
            }
            return equals;
        }

        public static bool HasValue(GenericEntity genericEntity)
        {
            return genericEntity != null && genericEntity.id.HasValue;
        }

        public virtual Guid? GetId()
        {
            return id;
        }

        public virtual void SetId(Guid? guid)
        {
            id = guid;
        }

        public virtual string GetIdCode()
        {
            return id.HasValue ? id.Value.ToString() : string.Empty;
        }

        public virtual bool Map(Dictionary<string, object> keyValues)
        {
            return true;
        }

        public static Tuple<T, bool> Map<T>(Dictionary<string, object> keyValues, string key)
        {
            var map = new Tuple<T, bool>(default(T), true);
            if (keyValues.ContainsKey(key))
            {
                if (map.Item1 is Enum)
                {
                    map = new Tuple<T, bool>((T)Enum.Parse(typeof(T), keyValues[key].ToString(), false), false);
                }
                else
                {
                    map = new Tuple<T, bool>((T)keyValues[key], false);
                }
            }
            return map;
        }

        public static Tuple<T, bool> Map<T>(Dictionary<string, object> keyValues) where T : GenericEntity, new()
        {
            var entity = new T();
            var undefined = entity.Map(keyValues);
            if (undefined)
            {
                entity = null;
            }
            return new Tuple<T, bool>(entity, undefined);
        }

        #endregion Method

        #endregion Public
    }
}