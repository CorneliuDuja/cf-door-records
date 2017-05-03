(function () {

    var shortTimeFilter = function () {

        return function (seconds) {
            return DayOfWeek.getTimeSpan(seconds, 2).toString;
        };

    };

    angular.module("accessControl").filter("shortTimeFilter", shortTimeFilter);

}());