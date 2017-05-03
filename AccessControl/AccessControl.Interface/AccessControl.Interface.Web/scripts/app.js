(function () {

    var app = angular.module("accessControl", ["ngRoute", "isteven-multi-select"]);

    app.config(["$routeProvider", function ($routeProvider) {

        $routeProvider
            .when("/dayResume", {
                controller: "dayResumeController",
                templateUrl: "views/dayResume.html"
            })
            .when("/dayResume/:dateIntervalType/:dateFrom/:dateTo/:weekdays", {
                controller: "dayResumeController",
                templateUrl: "views/dayResume.html"
            })
            .when("/dayResume/:dateIntervalType/:dateFrom/:dateTo/:weekdays/:columns", {
                controller: "dayResumeController",
                templateUrl: "views/dayResume.html"
            })
            .when("/day/:personName/:dateFrom/:dateTo/:weekdays", {
                controller: "dayController",
                templateUrl: "views/day.html"
            })
            .when("/dayReport/:dateFrom/:dateTo/:weekdays", {
                controller: "dayController",
                templateUrl: "views/dayReport.html"
            })
            .when("/event/:personName/:dateFrom/:dateTo/:weekdays", {
                controller: "eventController",
                templateUrl: "views/event.html"
            })
            .when("/eventReport/:dateFrom/:dateTo/:weekdays", {
                controller: "eventController",
                templateUrl: "views/eventReport.html"
            })
            .when("/sourceReport/:dateFrom/:dateTo/:weekdays", {
                controller: "sourceController",
                templateUrl: "views/sourceReport.html"
            })
            .when("/personReport/:dateFrom/:dateTo", {
                controller: "personController",
                templateUrl: "views/personReport.html"
            })
            .when("/pointReport/:dateFrom/:dateTo", {
                controller: "pointController",
                templateUrl: "views/pointReport.html"
            })
            .otherwise({ redirectTo: "/dayResume" });

    }]);

    app.run(["$rootScope", "$filter", function ($rootScope, $filter) {

        $rootScope.$on("$routeChangeStart", function (event, next, current) {
            if (next && next.$$route) {
                //if user is not authenticated redirect to login page
            }
        });

        DayOfWeek.setFirst("Monday");

        $rootScope.formatDate = function (date) {
            return $filter("date")(date, "yyyy-MM-dd");
        };

        $rootScope.formatTime = function (date) {
            return $filter("date")(date, "HH:mm:ss Z");
        };

        $rootScope.formatDateTime = function (date) {
            return $filter("date")(date, "yyyy-MM-dd HH:mm:ss Z");
        };

        $rootScope.getWcfJsonDateOffset = function (dateOffset) {
            var date = null;
            if (dateOffset.hasOwnProperty("DateTime")) {
                date = dateOffset.DateTime.getWcfJsonDate();
            }
            return date;
        };

    }]);

    app.directive("formatDate", function () {
        return {
            require: "ngModel",
            link: function (scope, elem, attr, modelCtrl) {
                modelCtrl.$formatters.push(function (modelValue) {
                    return new Date(modelValue);
                });
            }
        };
    });

}());
