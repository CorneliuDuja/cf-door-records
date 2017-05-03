(function () {

    var dayController = function ($scope, $routeParams, accessControlService) {

        function init() {
            $scope.personName = $routeParams.personName;
            $scope.weekdays = $routeParams.weekdays;
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.daySelect($scope.personName, dateFrom, dateTo, $scope.weekdays).then(function (response) {
                    $scope.days = response.data.Entities;
                    angular.forEach($scope.days, function (day) {
                        day.Date = $scope.formatDate($scope.getWcfJsonDateOffset(day.Date));
                        day.FirstIn = $scope.formatTime($scope.getWcfJsonDateOffset(day.FirstIn));
                        day.LastOut = $scope.formatTime($scope.getWcfJsonDateOffset(day.LastOut));
                        day.dateFrom = $scope.formatDate(day.Date);
                        day.dateTo = $scope.formatDate(day.Date);
                    });
                });
            }
            catch (exception) {
                $scope.dateFrom = null;
                $scope.dateTo = null;
            }
        }

        init();
    };

    dayController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("dayController", dayController);

}());
