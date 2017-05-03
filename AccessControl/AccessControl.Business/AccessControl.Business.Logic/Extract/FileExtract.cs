#region Using

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using AccessControl.Business.Engine.Core;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Logic.Extract
{
    public class FileExtract : IExtract
    {
        #region Public

        #region Method

        public Dictionary<string, Source> GetDaySources()
        {
            var daySources = new Dictionary<string, Source>();
            Kernel.Instance.Logging.Information(string.Format("Extract from '{0}' folder...", Kernel.Instance.ServiceConfiguration.FeedPath));
            var paths = new List<string>(Directory.GetFiles(Kernel.Instance.ServiceConfiguration.FeedPath));
            paths.Sort();
            foreach (var path in paths)
            {
                var fileName = Path.GetFileNameWithoutExtension(path);
                if (string.IsNullOrWhiteSpace(fileName))
                {
                    continue;
                }
                DateTimeOffset date;
                if (!DateTimeOffset.TryParseExact(fileName, Kernel.Instance.ServiceConfiguration.DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out date))
                {
                    continue;
                }
                var fileInfo = new FileInfo(path);
                daySources.Add(fileName, new Source
                    {
                        Date = date,
                        Length = fileInfo.Length,
                        Path = path
                    });
            }
            return daySources;
        }

        public void ExtractDaySource(KeyValuePair<string, Source> daySource)
        {
            daySource.Value.SourceFileType = SourceFileType.Csv;
            daySource.Value.LoadedOn = DateTimeOffset.Now;
            using (daySource.Value.StreamReader = new StreamReader(daySource.Value.Path))
            {
                daySource.Value.Lines = new List<List<string>>();
                while (!daySource.Value.StreamReader.EndOfStream)
                {
                    var line = daySource.Value.StreamReader.ReadLine();
                    if (string.IsNullOrEmpty(line) ||
                        line.IndexOf(Kernel.Instance.ServiceConfiguration.LineMatch, StringComparison.Ordinal) < 0)
                    {
                        continue;
                    }
                    var values = line.Split(Kernel.Instance.ServiceConfiguration.LineSeparator);
                    if (values.Length < Kernel.Instance.ServiceConfiguration.LineValuesCount)
                    {
                        continue;
                    }
                    daySource.Value.Lines.Add(new List<string>(values));
                }
                daySource.Value.ExtractedOn = DateTimeOffset.Now;
            }
        }

        #endregion Public

        #endregion Method
    }
}
