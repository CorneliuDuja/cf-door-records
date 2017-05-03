(function () {

    var eventController = function ($scope, $routeParams, accessControlService) {

        function init() {
            $scope.personName = $routeParams.personName;
            $scope.weekdays = $routeParams.weekdays;
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.eventSelect($scope.personName, dateFrom, dateTo, $scope.weekdays).then(function (response) {
                    $scope.events = response.data.Entities;
                    angular.forEach($scope.events, function (event) {
                        event.RegisteredOn = $scope.formatDateTime($scope.getWcfJsonDateOffset(event.RegisteredOn));
                        switch (event.Point.PointActionType) {
                            case 1:
                                {
                                    event.Point.PointActionType = "In";
                                    break;
                                }
                            case 2:
                                {
                                    event.Point.PointActionType = "Out";
                                    break;
                                }
                        }
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

    eventController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("eventController", eventController);

}());