#region Using

using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using AccessControl.Business.Library.Data;
using AccessControl.Business.Library.Model.Feed;
using AccessControl.Business.Library.Model.Slice;
using AccessControl.Business.Library.Report;

#endregion Using

namespace AccessControl.Service.Windows.Interface
{
    [ServiceContract]
    public interface IHost
    {
        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        GenericOutput<Source> SourceSelect(SourcePredicate sourcePredicate);

        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        GenericOutput<Person> PersonSelect(PersonPredicate personPredicate);

        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        GenericOutput<Point> PointSelect(PointPredicate pointPredicate);

        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        GenericOutput<Event> EventSelect(EventPredicate eventPredicate);

        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        GenericOutput<Day> DaySelect(DayPredicate dayPredicate);

        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, ResponseFormat = WebMessageFormat.Json, RequestFormat = WebMessageFormat.Json)]
        List<DayResume> DayResumeSelect(DayPredicate dayPredicate);
    }
}
