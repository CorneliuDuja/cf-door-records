(function () {

    var personController = function ($scope, $routeParams, accessControlService) {

        function init() {
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.personSelect(dateFrom, dateTo).then(function (response) {
                    $scope.persons = response.data.Entities;
                });
            }
            catch (exception) {
                $scope.dateFrom = null;
                $scope.dateTo = null;
            }
        }

        init();
    };

    personController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("personController", personController);

}());
