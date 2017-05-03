(function () {

    var pointController = function ($scope, $routeParams, accessControlService) {

        function init() {
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.pointSelect(dateFrom, dateTo).then(function (response) {
                    $scope.points = response.data.Entities;
                    angular.forEach($scope.points, function (point) {
                        switch (point.PointActionType) {
                            case 1:
                                {
                                    point.PointActionType = "In";
                                    break;
                                }
                            case 2:
                                {
                                    point.PointActionType = "Out";
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

    pointController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("pointController", pointController);

}());
