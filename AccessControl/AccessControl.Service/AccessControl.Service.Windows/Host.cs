#region Using

using System.Collections.Generic;
using System.ServiceModel.Activation;
using AccessControl.Business.Library.Data;
using AccessControl.Business.Library.Model.Feed;
using AccessControl.Business.Library.Model.Slice;
using AccessControl.Business.Library.Report;
using AccessControl.Business.Logic;
using AccessControl.Service.Windows.Interface;

#endregion Using

namespace AccessControl.Service.Windows
{
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    public class Host : IHost
    {
        public GenericOutput<Source> SourceSelect(SourcePredicate sourcePredicate)
        {
            return ModelLogic.Instance.SourceSelect(sourcePredicate);
        }

        public GenericOutput<Person> PersonSelect(PersonPredicate personPredicate)
        {
            return ModelLogic.Instance.PersonSelect(personPredicate);
        }

        public GenericOutput<Point> PointSelect(PointPredicate pointPredicate)
        {
            return ModelLogic.Instance.PointSelect(pointPredicate);
        }

        public GenericOutput<Event> EventSelect(EventPredicate eventPredicate)
        {
            return ModelLogic.Instance.EventSelect(eventPredicate);
        }

        public GenericOutput<Day> DaySelect(DayPredicate dayPredicate)
        {
            return ModelLogic.Instance.DaySelect(dayPredicate);
        }

        public List<DayResume> DayResumeSelect(DayPredicate dayPredicate)
        {
            return ModelLogic.Instance.DayResumeSelect(dayPredicate);
        }
    }
}
