(function () {

    //var accessControlEndpoint = "http://10.102.2.131:50004/AccessControl.Service.Windows/Web/";
    //var accessControlEndpoint = "http://zamolxis.cloudapp.net:58083/AccessControl.Service.Windows/Web/";
    //var accessControlEndpoint = "/AccessControl.Service.Windows/Web/";
    //var accessControlEndpoint = "http://10.102.0.110:50004/AccessControl.Service.Windows/Web/";
    var accessControlEndpoint = "http://localhost:50004/AccessControl.Service.Windows/Web/";

    //var signalREndpoint = "http://10.102.2.131:50005/AccessControl.Service.Windows";
    //var signalREndpoint = "http://zamolxis.cloudapp.net:58086/AccessControl.Service.Windows";
    //var signalREndpoint = "/AccessControl.Service.Windows";
    //var signalREndpoint = "http://10.102.0.110:50005/AccessControl.Service.Windows";
    var signalREndpoint = "http://localhost:50005/AccessControl.Service.Windows";

    var accessControlService = function ($http) {

        var factory = {};

        function onStart() {
            $("body").addClass("loading");
        }

        function onSuccess() {
            $("body").removeClass("loading");
        }

        function onError() {
            $("body").removeClass("loading");
        }

        factory.dayResumeSelect = function (dateFrom, dateTo, weekdays) {
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "DayResumeSelect",
                data: JSON.stringify({
                    dayPredicate: {
                        Date: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        },
                        Weekdays: {
                            Value: weekdays
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        factory.daySelect = function (personName, dateFrom, dateTo, weekdays) {
            var person = null;
            if (personName !== undefined) {
                person = {
                    Value: [
                        { Name: personName }
                    ]
                };
            }
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "DaySelect",
                data: JSON.stringify({
                    dayPredicate: {
                        Date: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        },
                        PersonPredicate: {
                            Person: person
                        },
                        Weekdays: {
                            Value: weekdays
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        factory.eventSelect = function (personName, dateFrom, dateTo, weekdays) {
            var person = null;
            if (personName !== undefined) {
                person = {
                    Value: [
                        { Name: personName }
                    ]
                };
            }
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "EventSelect",
                data: JSON.stringify({
                    eventPredicate: {
                        RegisteredOn: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        },
                        PersonPredicate: {
                            Person: person
                        },
                        Weekdays: {
                            Value: weekdays
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        factory.sourceSelect = function (dateFrom, dateTo, weekdays) {
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "SourceSelect",
                data: JSON.stringify({
                    sourcePredicate: {
                        Date: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        },
                        Weekdays: {
                            Value: weekdays
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        factory.personSelect = function (dateFrom, dateTo) {
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "PersonSelect",
                data: JSON.stringify({
                    personPredicate: {
                        RegisteredOn: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        factory.pointSelect = function (dateFrom, dateTo) {
            onStart();
            return $http({
                method: "POST",
                url: accessControlEndpoint + "PointSelect",
                data: JSON.stringify({
                    pointPredicate: {
                        RegisteredOn: {
                            Value: {
                                DateFrom: dateFrom.setWcfJsonDateOffset(),
                                DateTo: dateTo.setWcfJsonDateOffset()
                            }
                        }
                    }
                })
            }).success(function (response) {
                onSuccess();
                return response;
            }).error(function () {
                onError();
            });
        };

        return factory;

    };

    accessControlService.$inject = ["$http"];

    var app = angular.module("accessControl");

    app.factory("accessControlService", accessControlService);

    app.value("$", $);
    app.factory("signalR", function ($, $rootScope) {
        return {
            proxy: null,
            initialize: function (sendLastProcessedOn, sendMessage, sendServerRemoteInfo) {
                var connection = $.hubConnection(signalREndpoint);
                this.proxy = connection.createHubProxy("hostHub");
                connection.start({
                    jsonp: true
                });
                this.proxy.on("sendLastProcessedOn", function (value) {
                    $rootScope.$apply(function () {
                        sendLastProcessedOn(value);
                    });
                });
                this.proxy.on("sendMessage", function (value) {
                    $rootScope.$apply(function () {
                        sendMessage(value);
                    });
                });
                this.proxy.on("sendServerRemoteInfo", function (value) {
                    $rootScope.$apply(function () {
                        sendServerRemoteInfo(value);
                    });
                });
            }
        };
    });

}());