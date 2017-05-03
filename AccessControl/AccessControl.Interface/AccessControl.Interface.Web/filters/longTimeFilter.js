(function () {

    var longTimeFilter = function () {

        return function (seconds) {
            return DayOfWeek.getTimeSpan(seconds, 3).toString;
        };

    };

    angular.module("accessControl").filter("longTimeFilter", longTimeFilter);

}());