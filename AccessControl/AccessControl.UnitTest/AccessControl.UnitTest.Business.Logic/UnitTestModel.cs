using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Globalization;
using System.IO;
using AccessControl.Business.Engine.Common;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Library.Common;
using AccessControl.Business.Library.Model;
using AccessControl.Business.Library.Model.Feed;
using AccessControl.Business.Library.Model.Slice;
using AccessControl.Business.Logic;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace AccessControl.UnitTest.Business.Logic
{
    [TestClass]
    public class UnitTestModel
    {
        [TestMethod]
        public void TestMethodExtractTransformAnalyse()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var source = new Source
                {
                    Date = DateTimeOffset.Now,
                    SourceFileType = SourceFileType.Csv,
                    LoadedOn = DateTimeOffset.Now
                };
            using (source.StreamReader = new StreamReader(@"..\..\Data\online_export.txt"))
            {
                modelLogic.Extract(source);
                modelLogic.Transform(source);
                modelLogic.Analyse(source);
                var serialized = EngineStatic.PortableXmlSerialize(source);
            }
        }

        [TestMethod]
        public void TestMethodSourceCreate()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var source = new Source
                {
                    SourceFileType = SourceFileType.Csv,
                    LoadedOn = DateTimeOffset.Now
                };
            var fileInfo = new FileInfo(@"..\..\Data\online_export.txt");
            using (source.StreamReader = new StreamReader(@"..\..\Data\online_export.txt"))
            {
                source = modelLogic.SourceCreate(source);
            }
        }

        [TestMethod]
        public void TestMethodSourceCreateDate()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var source = new Source
                {
                    Date = DateTimeOffset.ParseExact("2015-01-12", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None),
                    SourceFileType = SourceFileType.Csv,
                    LoadedOn = DateTimeOffset.Now
                };
            using (source.StreamReader = new StreamReader(@"..\..\Data\2015-01\2015-01-12.csv"))
            {
                source = modelLogic.SourceCreate(source);
            }
        }

        [TestMethod]
        public void TestMethodSourceProcess()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            modelLogic.SourceProcess();
        }

        [TestMethod]
        public void TestMethodSourceSelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var genericOutput = modelLogic.SourceSelect(new SourcePredicate
                {
                    Pager = new Pager
                        {
                            Index = 1,
                            Size = 2
                        }
                });
        }

        [TestMethod]
        public void TestMethodPersonSelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var genericOutput = modelLogic.PersonSelect(new PersonPredicate
                {
                    Name = new Criteria<List<string>>(new List<string>
                        {
                            "%Duja%"
                        })
                });
        }

        [TestMethod]
        public void TestMethodPointSelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var genericOutput = modelLogic.PointSelect(new PointPredicate
                {
                    PointActionType = new Criteria<List<PointActionType>>(new List<PointActionType>
                        {
                            PointActionType.In
                        })
                });
        }

        [TestMethod]
        public void TestMethodEventSelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var genericOutput = modelLogic.EventSelect(new EventPredicate
                {
                    Pager = new Pager
                        {
                            Index = 1,
                            Size = 20
                        },
                    PersonPredicate = new PersonPredicate
                        {
                            Name = new Criteria<List<string>>(new List<string>
                                {
                                    "%Duja%"
                                })
                        }
                });
        }

        [TestMethod]
        public void TestMethodDaySelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var genericOutput = modelLogic.DaySelect(new DayPredicate
                {
                    Pager = new Pager
                        {
                            Index = 1,
                            Size = 20
                        },
                    Date = new Criteria<DateInterval>(new DateInterval
                        {
                            DateFrom = new DateTimeOffset(2014, 10, 27, 0, 0, 0, 0, DateTimeOffset.Now.Offset),
                            DateTo = new DateTimeOffset(2014, 10, 28, 0, 0, 0, 0, DateTimeOffset.Now.Offset)
                        })
                });
        }

        [TestMethod]
        public void TestMethodDayResumeSelect()
        {
            Kernel.Instance.Start();
            var modelLogic = new ModelLogic();
            var dayPredicate = new DayPredicate
                {
                    Date = new Criteria<DateInterval>(new DateInterval(DateIntervalType.CurrentYear))
                };
            var serialized = EngineStatic.PortableXmlSerialize(dayPredicate);
            var genericOutput = modelLogic.DayResumeSelect(dayPredicate);
        }

        [TestMethod]
        public void TestTicks()
        {
            var timeSpan = TimeSpan.FromTicks(258500000000);
        }

        [TestMethod]
        public void TestMethod()
        {
            const string ConnectionStringFormat =
                "Driver={{Microsoft Paradox Driver (*.db )}};Uid={0};UserCommitSync=Yes;Threads=3;SafeTransactions=0;" +
                "ParadoxUserName={0};ParadoxNetStyle=4.x;ParadoxNetPath={1};PageTimeout=5;MaxScanRows=8;" +
                "MaxBufferSize=65535;DriverID=538;Fil=Paradox 7.X;DefaultDir={2};Dbq={2}";

            DbProviderFactory factory = DbProviderFactories.GetFactory("System.Data.Odbc");
            using (DbConnection connection = factory.CreateConnection())
            {
                string userName = "ADMIN";
                //string paradoxNetPath = @"C:\Programs\cf-door-records\AccessControl\Data\NET";
                string databasePath = @"C:\Programs\cf-door-records\AccessControl\Data";
                //string collatingSequence = "Norwegian-Danish";
                connection.ConnectionString = String.Format(ConnectionStringFormat, userName, databasePath, databasePath);
                connection.Open();
                using (DbCommand command = connection.CreateCommand())
                {
                    command.CommandText = "select Count(*) from [EventsCache]";
                    object itemCount = command.ExecuteScalar();
                }
            }
        }

        [TestMethod]
        public void TestFlag()
        {
            var a = 1 << 2;
            var dateTimeOffset = DateTimeOffset.Now;
            var dayOfWeek = (int)dateTimeOffset.DayOfWeek;
            dayOfWeek = (int)DayOfWeek.Sunday;
            var b = (62 | 1 << 2) == 62;
        }

        [TestMethod]
        public void TestCast()
        {
            object a = null;
            string b = (string) a;
        }

        [TestMethod]
        public void TestDateTimeOffset()
        {
            var timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById("GTB Standard Time");
            DateTimeOffset dateTimeOffset;
            if (DateTimeOffset.TryParseExact("2015-10-26", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateTimeOffset))
            {

                var timeSpan = timeZoneInfo.GetUtcOffset(dateTimeOffset);
                dateTimeOffset = new DateTimeOffset(dateTimeOffset.Ticks, timeSpan);
                var timeZone = dateTimeOffset.ToString("zzz");
            }
            foreach (var item in TimeZoneInfo.GetSystemTimeZones())
            {
                var timeSpan = item.GetUtcOffset(dateTimeOffset);
                dateTimeOffset = new DateTimeOffset(dateTimeOffset.Ticks, timeSpan);
            }
            if (!DateTimeOffset.TryParseExact(string.Format("2015-10-28 21:16:50 {0}", DateTimeOffset.Now.ToString("zzz")), "yyyy-MM-dd HH:mm:ss zzz", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateTimeOffset))
            {
                dateTimeOffset = dateTimeOffset.Add(TimeSpan.Parse("00:00:01"));
            }
            if (DateTimeOffset.TryParseExact("2014-09-06 08:06:40 +03:00", "yyyy-MM-dd HH:mm:ss zzz", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateTimeOffset))
            {
                dateTimeOffset = dateTimeOffset.Add(-TimeSpan.Parse("00:00:01"));
                var eventEntity = new Event
                    {
                        RegisteredOn = new DateTimeOffset(dateTimeOffset.Date.Add(TimeSpan.Parse("09:00:00")), dateTimeOffset.Offset)
                    };
                var serialized = EngineStatic.PortableXmlSerialize(eventEntity);
            }
        }
    }
}
