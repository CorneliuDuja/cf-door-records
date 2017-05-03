#region Using

using System.Collections.Generic;
using AccessControl.Business.Library.Model.Feed;

#endregion Using

namespace AccessControl.Business.Logic.Extract
{
    interface IExtract
    {
        Dictionary<string, Source> GetDaySources();

        void ExtractDaySource(KeyValuePair<string, Source> daySource);
    }
}