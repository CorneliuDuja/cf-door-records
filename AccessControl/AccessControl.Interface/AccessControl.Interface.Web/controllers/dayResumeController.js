(function () {

    var dayResumeController = function ($scope, $routeParams, accessControlService) {

        function getColumnHeaders() {
            $scope.columnHeaders = [];
            $scope.columnHeaders.push("Person Name");
            $scope.columnHeaders.push("Days");
            $scope.columnHeaders.push("Min First In");
            $scope.columnHeaders.push("Max First In");
            $scope.columnHeaders.push("Avg First In");
            $scope.columnHeaders.push("Min Last Out");
            $scope.columnHeaders.push("Max Last Out");
            $scope.columnHeaders.push("Avg Last Out");
            $scope.columnHeaders.push("Min Duration");
            $scope.columnHeaders.push("Max Duration");
            $scope.columnHeaders.push("Avg Duration");
            $scope.columnHeaders.push("Sum Duration");
            $scope.columnHeaders.push("Min Deviation");
            $scope.columnHeaders.push("Max Deviation");
            $scope.columnHeaders.push("Avg Deviation");
            $scope.columnHeaders.push("Sum Deviation");
            $scope.columnHeaders.push("Min Trusted");
            $scope.columnHeaders.push("Max Trusted");
            $scope.columnHeaders.push("Avg Trusted");
            $scope.columnHeaders.push("Sum Trusted");
            $scope.columnHeaders.push("Min Doubtful");
            $scope.columnHeaders.push("Max Doubtful");
            $scope.columnHeaders.push("Avg Doubtful");
            $scope.columnHeaders.push("Sum Doubtful");
            $scope.columnHeaders.push("Min Reliability");
            $scope.columnHeaders.push("Max Reliability");
            $scope.columnHeaders.push("Avg Reliability");
        }

        function init() {
            getColumnHeaders();
            $scope.dateIntervalType = DateIntervalType.Undefined.description;
            $scope.dateIntervalTypes = [];
            for (var item in DateIntervalType) {
                var description = DateIntervalType[item].description;
                $scope.dateIntervalTypes.push(description);
                if (description == $routeParams.dateIntervalType) {
                    $scope.dateIntervalType = $routeParams.dateIntervalType;
                }
            }
            $scope.setWeekdays(false);
            $scope.setColumns(false);
            if ($routeParams.dateFrom === undefined ||
                $routeParams.dateTo === undefined) {
                return;
            }
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.dayResumeSelect(dateFrom, dateTo, $scope.weekdays).then(function (response) {
                    $scope.dayResumes = response.data;
                });
            }
            catch (exception) {
                $scope.dateFrom = null;
                $scope.dateTo = null;
            }
        }

        $scope.setDateIntervalType = function () {
            var dateInterval = new DateInterval();
            for (var item in DateIntervalType) {
                if (DateIntervalType[item].description == $scope.dateIntervalType) {
                    dateInterval.dateIntervalType = DateIntervalType[item];
                    dateInterval.setDateInterval();
                    $scope.dateFrom = $scope.formatDate(dateInterval.getDateFrom());
                    $scope.dateTo = $scope.formatDate(dateInterval.getDateTo());
                    break;
                }
            }
        };

        $scope.setWeekdays = function (reset) {
            if (reset ||
                $routeParams.weekdays === undefined ||
                isNaN($routeParams.weekdays)) {
                $scope.weekdays = 62;// from monday to friday
            } else {
                $scope.weekdays = parseInt($routeParams.weekdays);
            }
            $scope.weekdaysInput = [];
            var weekdays = DayOfWeek.getWeekdays();
            for (var index = 0; index < weekdays.length; index++) {
                $scope.weekdaysInput.push({
                    weekday: weekdays[index].code,
                    name: weekdays[index].value,
                    ticked: ($scope.weekdays | 1 << weekdays[index].code) == $scope.weekdays
                });
            }
        };

        $scope.getWeekdays = function () {
            $scope.weekdays = 0;
            for (var index = 0; index < $scope.weekdaysOutput.length; index++) {
                $scope.weekdays += (1 << $scope.weekdaysOutput[index].weekday);
            }
        };

        $scope.setColumns = function (reset) {
            if (reset ||
                $routeParams.columns === undefined) {
                $scope.columns = "110010010011001100000000001";// usual columns
            } else {
                $scope.columns = $routeParams.columns;
            }
            $scope.columnsInput = [];
            for (var index = 0; index < $scope.columnHeaders.length; index++) {
                $scope.columnsInput.push({
                    index: index,
                    name: $scope.columnHeaders[index],
                    ticked: $scope.columns.substring(index, index + 1) === "1"
                });
            }
        };

        $scope.getColumns = function () {
            $scope.columns = "";
            for (var index = 0; index < $scope.columnsInput.length; index++) {
                $scope.columns += ($scope.columnsInput[index].ticked ? "1" : "0");
            }
        };

        $scope.hideColumn = function (columnIndex) {
            var hide = true;
            for (var index = 0; index < $scope.columnsOutput.length; index++) {
                if ($scope.columnsOutput[index].index === columnIndex) {
                    hide = false;
                    break;
                }
            }
            return hide;
        };

        init();

    };

    dayResumeController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("dayResumeController", dayResumeController);

}());