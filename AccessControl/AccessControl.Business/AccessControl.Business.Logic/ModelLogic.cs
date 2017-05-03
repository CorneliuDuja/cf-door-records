#region Using

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Linq;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Library.Common;
using AccessControl.Business.Library.Data;
using AccessControl.Business.Library.Model;
using AccessControl.Business.Library.Model.Feed;
using AccessControl.Business.Library.Model.Slice;
using AccessControl.Business.Library.Report;
using AccessControl.Business.Logic.Extract;
using AccessControl.Data.MsSql2012;

#endregion Using

namespace AccessControl.Business.Logic
{
    public class ModelLogic
    {
        #region Private

        #region Property

        private static readonly ModelLogic instance = new ModelLogic();
        private static IExtract extractImplementation;

        #endregion Property

        #region Method

        private static void DayComplement(Day day, Source source)
        {
            var firstEvent = day.Events[0];
            if (firstEvent.Point.PointActionType == PointActionType.Out &&
                firstEvent.RegisteredOn.HasValue)
            {
                var entity = new Event
                    {
                        Person = firstEvent.Person,
                        Point = source.DefaultPointIn,
                        RegisteredOn = firstEvent.RegisteredOn,
                        IsEnforced = true
                    };
                var firstIn = new DateTimeOffset(firstEvent.RegisteredOn.Value.Date.Add(Kernel.Instance.ServiceConfiguration.FirstInTime), firstEvent.RegisteredOn.Value.Offset);
                if (firstEvent.RegisteredOn.Value > firstIn)
                {
                    entity.RegisteredOn = firstIn;
                }
                else if (entity.RegisteredOn.HasValue)
                {
                    entity.RegisteredOn = entity.RegisteredOn.Value.Add(-Kernel.Instance.ServiceConfiguration.MinDuration);
                }
                day.Events.Insert(0, entity);
                if (entity.RegisteredOn.HasValue)
                {
                    source.KeyEvents[entity.Person][entity.RegisteredOn.Value.Date].Add(entity.RegisteredOn.Value, entity);
                    source.Events.Add(entity);
                }
            }
            var lastEvent = day.Events[day.Events.Count - 1];
            if (lastEvent.Point.PointActionType == PointActionType.In &&
                lastEvent.RegisteredOn.HasValue)
            {
                var entity = new Event
                    {
                        Person = lastEvent.Person,
                        Point = source.DefaultPointOut,
                        RegisteredOn = lastEvent.RegisteredOn,
                        IsEnforced = true
                    };
                var lastOut = new DateTimeOffset(lastEvent.RegisteredOn.Value.Date.Add(Kernel.Instance.ServiceConfiguration.LastOutTime), lastEvent.RegisteredOn.Value.Offset);
                if (lastEvent.RegisteredOn.Value < lastOut)
                {
                    entity.RegisteredOn = lastOut;
                }
                else if (entity.RegisteredOn.HasValue)
                {
                    entity.RegisteredOn = entity.RegisteredOn.Value.Add(Kernel.Instance.ServiceConfiguration.MinDuration);
                }
                day.Events.Insert(day.Events.Count, entity);
                if (entity.RegisteredOn.HasValue)
                {
                    source.KeyEvents[entity.Person][entity.RegisteredOn.Value.Date].Add(entity.RegisteredOn.Value, entity);
                    source.Events.Add(entity);
                }
            }
        }

        private static void DayAnalyse(Day day)
        {
            var interval = 0;
            for (var firstIndex = 0; firstIndex < day.Events.Count; firstIndex++)
            {
                var firstEvent = day.Events[firstIndex];
                firstEvent.Interval = interval;
                var lastIndex = FindLastIndex(day.Events, firstIndex + 1, interval);
                if (lastIndex < 0)
                {
                    continue;
                }
                var lastEvent = day.Events[lastIndex];
                firstEvent.Duration = (lastEvent.RegisteredOn - firstEvent.RegisteredOn).Value.TotalSeconds;
                day.Duration += firstEvent.Duration;
                lastEvent.Duration = day.Duration;
                if (lastIndex - firstIndex > 1 ||
                    firstEvent.IsEnforced ||
                    lastEvent.IsEnforced)
                {
                    day.Doubtful = day.Doubtful + 1;
                }
                else
                {
                    day.Trusted = day.Trusted + 1;
                }
                firstIndex = lastIndex;
                interval++;
            }
            day.Deviation = day.Duration;
            if (day.Date.HasValue &&
                (Kernel.Instance.ServiceConfiguration.Weekdays | 1 << (int)day.Date.Value.DayOfWeek) == Kernel.Instance.ServiceConfiguration.Weekdays)
            {
                day.Deviation -= Kernel.Instance.ServiceConfiguration.DayDuration.TotalSeconds;
            }
            var intervals = day.Trusted + day.Doubtful;
            if (intervals > 0)
            {
                day.Reliability = day.Trusted/intervals;
            }
        }

        private static int FindLastIndex(IReadOnlyList<Event> events, int start, int interval)
        {
            var eventIndex = -1;
            var found = false;
            for (var index = start; index < events.Count; index++)
            {
                if (events[index].Point.PointActionType == PointActionType.Out)
                {
                    if (found)
                    {
                        events[eventIndex].IsObsolete = true;
                    }
                    else
                    {
                        found = true;
                    }
                    eventIndex = index;
                }
                if (events[index].Point.PointActionType == PointActionType.In)
                {
                    if (found)
                    {
                        break;
                    }
                    events[index].IsObsolete = true;
                }
                events[index].Interval = interval;
            }
            return eventIndex;
        }

        private static PersonPredicate PersonPredicate(PersonPredicate personPredicate)
        {
            if (personPredicate == null)
            {
                personPredicate = new PersonPredicate();
            }
            personPredicate.IsPrivate = false;
            return personPredicate;
        }

        private static string GetLineValue(IReadOnlyList<string> line, int index)
        {
            var value = string.Empty;
            if (line != null &&
                index >= 0 &&
                index < line.Count)
            {
                value = line[index];
                if (!string.IsNullOrEmpty(value))
                {
                    value = value.Trim();
                }
            }
            return value;
        }

        private static Dictionary<Guid?, Event> GetInsidePersons()
        {
            var events = ModelData.Instance.EventSelect(new EventPredicate
            {
                RegisteredOn = new Criteria<DateInterval>(new DateInterval(DateIntervalType.Today)),
                IsEnforced = true,
                PointPredicate = new PointPredicate
                {
                    PointActionType = new Criteria<List<PointActionType>>(new List<PointActionType>
                                {
                                    PointActionType.Out
                                })
                }
            }).Entities;
            var insidePersons = new Dictionary<Guid?, Event>();
            foreach (var eventEntity in events)
            {
                if (eventEntity == null ||
                    eventEntity.Person == null ||
                    !eventEntity.Person.Id.HasValue) continue;
                insidePersons.Add(eventEntity.Person.Id, eventEntity);
            }
            return insidePersons;
        }

        #endregion Method

        #endregion Private

        #region Public

        #region Property

        public static ModelLogic Instance
        {
            get { return instance; }
        }

        #endregion Property

        #region Method

        public ModelLogic()
        {
            try
            {
                var extractType = Type.GetType(Kernel.Instance.ServiceConfiguration.ExtractImplementation);
                if (extractType != null)
                {
                    extractImplementation = (IExtract)Activator.CreateInstance(extractType);
                    Kernel.Instance.Logging.Information("{0} extract implementation instantiated.", Kernel.Instance.ServiceConfiguration.ExtractImplementation);
                }
            }
            catch (Exception exception)
            {
                Kernel.Instance.Logging.Warning(string.Format("No extract implementation defined in configuration file - error [{0}].", exception.Message));
            }
        }

        #region Source

        public void Extract(Source source)
        {
            if (!source.Date.HasValue) return;
            var daySource = new KeyValuePair<string, Source>(source.Date.Value.Date.ToString(Kernel.Instance.ServiceConfiguration.DateFormat), source);
            extractImplementation.ExtractDaySource(daySource);
        }

        public void Transform(Source source)
        {
            if (source == null)
            {
                throw new Exception("Source not defined.");
            }
            if (source.Lines == null)
            {
                throw new Exception("Lines not defined.");
            }
            source.Persons = new List<Person>();
            source.Points = new List<Point>();
            source.Events = new List<Event>();
            source.KeyPersons = new Dictionary<string, Person>();
            source.KeyPoints = new Dictionary<string, Point>();
            source.KeyEvents = new Dictionary<Person, Dictionary<DateTimeOffset, Dictionary<DateTimeOffset, Event>>>();
            foreach (var line in source.Lines)
            {
                if (line == null)
                {
                    continue;
                }
                var sourceDate = source.Date.HasValue ? source.Date.Value.ToString(Kernel.Instance.ServiceConfiguration.DateFormat) : string.Empty;
                var lineValue = string.Join(Kernel.Instance.ServiceConfiguration.LineSeparator.ToString(CultureInfo.InvariantCulture), line);
                var point = new Point
                    {
                        Name = GetLineValue(line, Kernel.Instance.ServiceConfiguration.PointNameIndex)
                    };
                if (string.IsNullOrEmpty(point.Name))
                {
                    Kernel.Instance.Logging.Error(string.Format("No point name defined: source date - [{0}]; line value - [{1}].", sourceDate, lineValue), false);
                    continue;
                }
                point.SetPointActionType(GetLineValue(line, Kernel.Instance.ServiceConfiguration.EventNameIndex), GetLineValue(line, Kernel.Instance.ServiceConfiguration.ModeNameIndex));
                switch (point.PointActionType)
                {
                    case PointActionType.None:
                        {
                            Kernel.Instance.Logging.Error(string.Format("No point action type defined: source date - [{0}]; point name - [{1}]; line value - [{2}].", sourceDate, point.Name, lineValue), false);
                            continue;
                        }
                    case PointActionType.In:
                        {
                            if (source.DefaultPointIn == null)
                            {
                                source.DefaultPointIn = point;
                            }
                            break;
                        }
                    case PointActionType.Out:
                        {
                            if (source.DefaultPointOut == null)
                            {
                                source.DefaultPointOut = point;
                            }
                            break;
                        }
                }
                if (source.KeyPoints.ContainsKey(point.Name))
                {
                    point = source.KeyPoints[point.Name];
                }
                else
                {
                    source.KeyPoints.Add(point.Name, point);
                    source.Points.Add(source.KeyPoints[point.Name]);
                }
                var person = new Person
                    {
                        Name = Regex.Replace(GetLineValue(line, Kernel.Instance.ServiceConfiguration.PersonNameIndex), Kernel.Instance.ServiceConfiguration.RegexDigits, string.Empty).Trim()
                    };
                if (string.IsNullOrEmpty(person.Name))
                {
                    Kernel.Instance.Logging.Error(string.Format("No person name defined: source date - [{0}]; line value - [{1}].", sourceDate, lineValue), false);
                    continue;
                }
                if (source.KeyPersons.ContainsKey(person.Name))
                {
                    person = source.KeyPersons[person.Name];
                }
                else
                {
                    source.KeyPersons.Add(person.Name, person);
                    source.Persons.Add(source.KeyPersons[person.Name]);
                }
                var dateTime = GetLineValue(line, Kernel.Instance.ServiceConfiguration.DateIndex);
                DateTimeOffset registeredOn;
                if (!DateTimeOffset.TryParseExact(dateTime, Kernel.Instance.ServiceConfiguration.DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out registeredOn))
                {
                    continue;
                }
                registeredOn = new DateTimeOffset(registeredOn.Ticks, Kernel.Instance.ServiceConfiguration.TimeZoneInfo.GetUtcOffset(registeredOn));
                var dateTimeOffset = string.Format("{0} {1} {2}", dateTime, GetLineValue(line, Kernel.Instance.ServiceConfiguration.TimeIndex), registeredOn.ToString(Kernel.Instance.ServiceConfiguration.OffsetFormat));
                if (!DateTimeOffset.TryParseExact(dateTimeOffset, Kernel.Instance.ServiceConfiguration.DateTimeOffsetFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out registeredOn) ||
                    (source.Date.HasValue &&
                    source.Date.Value.Date != registeredOn.Date))
                {
                    continue;
                }
                if (!source.KeyEvents.ContainsKey(person))
                {
                    source.KeyEvents.Add(person, new Dictionary<DateTimeOffset, Dictionary<DateTimeOffset, Event>>());
                }
                if (!source.KeyEvents[person].ContainsKey(registeredOn.Date))
                {
                    source.KeyEvents[person].Add(registeredOn.Date, new Dictionary<DateTimeOffset, Event>());
                }
                if (source.KeyEvents[person][registeredOn.Date].ContainsKey(registeredOn))
                {
                    continue;
                }
                source.KeyEvents[person][registeredOn.Date].Add(registeredOn, new Event
                    {
                        Person = person,
                        Point = point,
                        RegisteredOn = registeredOn
                    });
                source.Events.Add(source.KeyEvents[person][registeredOn.Date][registeredOn]);
            }
            if (source.DefaultPointIn == null ||
                source.DefaultPointOut == null)
            {
                var points = ModelData.Instance.PointSelect(new PointPredicate()).Entities;
                if (source.DefaultPointIn == null)
                {
                    var point = points.FirstOrDefault(item => item.PointActionType == PointActionType.In);
                    if (point == null)
                    {
                        point = new Point
                            {
                                PointActionType = PointActionType.In
                            };
                        source.Points.Add(point);
                    }
                    source.DefaultPointIn = point;
                }
                if (source.DefaultPointOut == null)
                {
                    var point = points.FirstOrDefault(item => item.PointActionType == PointActionType.Out);
                    if (point == null)
                    {
                        point = new Point
                            {
                                PointActionType = PointActionType.Out
                            };
                        source.Points.Add(point);
                    }
                    source.DefaultPointOut = point;
                }
            }
            source.TransformedOn = DateTimeOffset.Now;
        }

        public void Analyse(Source source)
        {
            if (source == null)
            {
                throw new Exception("Source not defined.");
            }
            if (source.KeyEvents != null && 
                source.KeyEvents.Count != 0)
            {
                source.Days = new List<Day>();
                foreach (var personDate in source.KeyEvents)
                {
                    foreach (var dateEvents in personDate.Value)
                    {
                        if (dateEvents.Value.Values.Count == 0)
                        {
                            continue;
                        }
                        var events = new Event[dateEvents.Value.Values.Count];
                        dateEvents.Value.Values.CopyTo(events, 0);
                        var day = new Day
                            {
                                Person = personDate.Key,
                                Date = dateEvents.Key,
                                Duration = 0,
                                Trusted = 0,
                                Doubtful = 0,
                                Events = new List<Event>(events)
                            };
                        day.Events.Sort();
                        DayComplement(day, source);
                        DayAnalyse(day);
                        day.FirstIn = day.Events[0].RegisteredOn;
                        day.LastOut = day.Events[day.Events.Count - 1].RegisteredOn;
                        source.Days.Add(day);
                    }
                }
            }
            source.AnalysedOn = DateTimeOffset.Now;
        }

        public Source SourceCreate(Source source)
        {
            try
            {
                Extract(source);
                Transform(source);
                Analyse(source);
                source = ModelData.Instance.SourceCreate(source);
            }
            catch (Exception exception)
            {
                Kernel.Instance.Logging.Error(exception, false);
            }
            return source;
        }

        public GenericOutput<Source> SourceSelect(SourcePredicate sourcePredicate)
        {
            return ModelData.Instance.SourceSelect(sourcePredicate);
        }

        public List<Source> SourceProcess()
        {
            var sources = new List<Source>();
            if (extractImplementation != null)
            {
                Dictionary<string, Source> daySources;
                GenericOutput<Source> genericOutput = null;
                try
                {
                    daySources = extractImplementation.GetDaySources();
                    var dateNow = DateTimeOffset.Now.Date.ToString(Kernel.Instance.ServiceConfiguration.DateFormat);
                    if (!Kernel.Instance.ServiceConfiguration.IncludeDateNow &&
                        daySources.ContainsKey(dateNow))
                    {
                        daySources.Remove(dateNow);
                    }
                    genericOutput = ModelData.Instance.SourceSelect(new SourcePredicate
                    {
                        Source = new Criteria<List<Source>>(new List<Source>(daySources.Values.ToList()))
                    });
                }
                catch (Exception exception)
                {
                    Kernel.Instance.Logging.Error(exception, false);
                    daySources = null;
                }
                if (daySources != null &&
                    genericOutput != null)
                {
                    foreach (var daySource in daySources)
                    {
                        try
                        {
                            var source = genericOutput.Entities.Find(item => item.Date == daySource.Value.Date);
                            if (source != null &&
                                source.Length >= daySource.Value.Length)
                            {
                                continue;
                            }
                            Kernel.Instance.Logging.Information(string.Format("Process '{0}' day...", daySource.Key));
                            extractImplementation.ExtractDaySource(daySource);
                            Transform(daySource.Value);
                            Analyse(daySource.Value);
                            sources.Add(ModelData.Instance.SourceCreate(daySource.Value));
                            Kernel.Instance.Logging.Information(string.Format("Day '{0}' processed.", daySource.Key));
                        }
                        catch (Exception exception)
                        {
                            Kernel.Instance.Logging.Error(exception, false);
                        }
                    }
                }
            }
            return sources;
        }

        #endregion Source

        #region Person

        public GenericOutput<Person> PersonSelect(PersonPredicate personPredicate)
        {
            var genericOutput = ModelData.Instance.PersonSelect(personPredicate);
            var insidePersons = GetInsidePersons();
            foreach (var person in genericOutput.Entities)
            {
                if (person == null ||
                    !person.Id.HasValue ||
                    !insidePersons.ContainsKey(person.Id)) continue;
                person.IsInside = true;
            }
            return genericOutput;
        }

        #endregion Person

        #region Point

        public GenericOutput<Point> PointSelect(PointPredicate pointPredicate)
        {
            return ModelData.Instance.PointSelect(pointPredicate);
        }

        #endregion Point

        #region Event

        public GenericOutput<Event> EventSelect(EventPredicate eventPredicate)
        {
            if (eventPredicate != null)
            {
                eventPredicate.PersonPredicate = PersonPredicate(eventPredicate.PersonPredicate);
            }
            return ModelData.Instance.EventSelect(eventPredicate);
        }

        #endregion Event

        #region Day

        public GenericOutput<Day> DaySelect(DayPredicate dayPredicate)
        {
            if (dayPredicate != null)
            {
                dayPredicate.PersonPredicate = PersonPredicate(dayPredicate.PersonPredicate);
            }
            return ModelData.Instance.DaySelect(dayPredicate);
        }

        #endregion Day

        #region DayResume

        public List<DayResume> DayResumeSelect(DayPredicate dayPredicate)
        {
            if (dayPredicate != null)
            {
                dayPredicate.PersonPredicate = PersonPredicate(dayPredicate.PersonPredicate);
            }
            var dayResumes = ModelData.Instance.DayResumeSelect(dayPredicate);
            var insidePersons = GetInsidePersons();
            foreach (var dayResume in dayResumes)
            {
                if (dayResume == null ||
                    dayResume.Person == null ||
                    !dayResume.Person.Id.HasValue ||
                    !insidePersons.ContainsKey(dayResume.Person.Id)) continue;
                dayResume.Person.IsInside = true;
            }
            return dayResumes;
        }

        #endregion DayResume

        #endregion Method

        #endregion Public
    }
}
