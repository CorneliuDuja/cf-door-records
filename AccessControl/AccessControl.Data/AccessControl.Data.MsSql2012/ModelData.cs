#region Using

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using AccessControl.Business.Engine.Common;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Library.Data;
using AccessControl.Business.Library.Model;
using AccessControl.Business.Library.Model.Feed;
using AccessControl.Business.Library.Model.Slice;
using AccessControl.Business.Library.Model.State;
using AccessControl.Business.Library.Report;

#endregion Using

namespace AccessControl.Data.MsSql2012
{
    public class ModelData
    {
        #region Private

        #region Property

        private static readonly ModelData instance = new ModelData();

        #endregion Property

        #region Method

        private static GenericOutput<T> Action<T, P>(string storedProcedureName, GenericInput<T, P> genericInput)
            where T : GenericEntity
            where P : GenericPredicate
        {
            var genericOutput = new GenericOutput<T>
                {
                    ActionType = genericInput.ActionType,
                    Pager = new Pager(),
                    Entities = new List<T>()
                };
            if (genericInput.Predicate != null &&
                genericInput.Predicate.Pager != null)
            {
                genericOutput.Pager = genericInput.Predicate.Pager;
            }
            var sqlCommand = new SqlCommand
                {
                    CommandText = storedProcedureName,
                    CommandType = CommandType.StoredProcedure
                };
            sqlCommand.Parameters.AddWithValue("@genericInput", EngineStatic.PortableXmlSerialize(genericInput));
            var number = new SqlParameter
                {
                    ParameterName = "@number",
                    Direction = ParameterDirection.Output,
                    DbType = DbType.Int32
                };
            sqlCommand.Parameters.Add(number);
            using (var sqlConnection = new SqlConnection(Kernel.Instance.ServiceConfiguration.DatabaseConnectionString.ConnectionString))
            {
                sqlConnection.Open();
                sqlCommand.Connection = sqlConnection;
                Kernel.SetDatabaseTimeout(sqlCommand);
                using (var dataReader = sqlCommand.ExecuteReader())
                {
                    while (dataReader.Read())
                    {
                        var keyValues = new Dictionary<string, object>();
                        for (var index = 0; index < dataReader.FieldCount; index++)
                        {
                            if (dataReader.IsDBNull(index))
                            {
                                continue;
                            }
                            keyValues.Add(dataReader.GetName(index), dataReader.GetValue(index));
                        }
                        var genericEntity = (T)Activator.CreateInstance(typeof(T));
                        var undefined = genericEntity.Map(keyValues);
                        if (!undefined)
                        {
                            genericOutput.Entities.Add(genericEntity);
                        }
                    }
                }
                sqlConnection.Close();
            }
            if (number.Value != DBNull.Value)
            {
                genericOutput.Pager.Number = (int)number.Value;
            }
            if (genericOutput.Entities.Count > 0)
            {
                genericOutput.Entity = genericOutput.Entities[0];
                genericOutput.Pager.Count = genericOutput.Entities.Count;
            }
            return genericOutput;
        }

        #endregion Method

        #endregion Private

        #region Public

        #region Property

        public static ModelData Instance
        {
            get { return instance; }
        }

        #endregion Property

        #region Method

        #region Source

        public Source SourceCreate(Source source)
        {
            return Action("[Feed].[Source.Action]", new GenericInput<Source, SourcePredicate>
                {
                    ActionType = ActionType.SourceCreate,
                    Entity = source
                }).Entity;
        }

        public Source SourceRead(Source source)
        {
            return Action("[Feed].[Source.Action]", new GenericInput<Source, SourcePredicate>
                {
                    ActionType = ActionType.SourceRead,
                    Entity = source
                }).Entity;
        }

        public GenericOutput<Source> SourceSelect(SourcePredicate sourcePredicate)
        {
            return Action("[Feed].[Source.Action]", new GenericInput<Source, SourcePredicate>
                {
                    ActionType = ActionType.SourceSelect,
                    Predicate = sourcePredicate
                });
        }

        #endregion Source

        #region Person

        public GenericOutput<Person> PersonSelect(PersonPredicate personPredicate)
        {
            return Action("[Feed].[Person.Action]", new GenericInput<Person, PersonPredicate>
                {
                    ActionType = ActionType.PersonSelect,
                    Predicate = personPredicate
                });
        }

        #endregion Person

        #region Point

        public GenericOutput<Point> PointSelect(PointPredicate pointPredicate)
        {
            return Action("[Feed].[Point.Action]", new GenericInput<Point, PointPredicate>
                {
                    ActionType = ActionType.PointSelect,
                    Predicate = pointPredicate
                });
        }

        #endregion Point

        #region Event

        public GenericOutput<Event> EventSelect(EventPredicate eventPredicate)
        {
            return Action("[Feed].[Event.Action]", new GenericInput<Event, EventPredicate>
                {
                    ActionType = ActionType.EventSelect,
                    Predicate = eventPredicate
                });
        }

        #endregion Event

        #region Day

        public GenericOutput<Day> DaySelect(DayPredicate dayPredicate)
        {
            return Action("[Slice].[Day.Action]", new GenericInput<Day, DayPredicate>
                {
                    ActionType = ActionType.DaySelect,
                    Predicate = dayPredicate
                });
        }

        #endregion Day

        #region DayResume

        public List<DayResume> DayResumeSelect(DayPredicate dayPredicate)
        {
            return Action("[Slice].[Day.Action]", new GenericInput<DayResume, DayPredicate>
                {
                    ActionType = ActionType.DayResumeSelect,
                    Predicate = dayPredicate
                }).Entities;
        }

        #endregion DayResume

        #region Schedule

        public Schedule ScheduleRead(Schedule schedule)
        {
            return Action("[State].[Schedule.Action]", new GenericInput<Schedule, SchedulePredicate>
                {
                    ActionType = ActionType.ScheduleRead,
                    Entity = schedule
                }).Entity;
        }

        #endregion Schedule

        #endregion Method

        #endregion Public
    }
}
