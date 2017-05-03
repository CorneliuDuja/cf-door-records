(function () {

    var sourceController = function ($scope, $routeParams, accessControlService) {

        function init() {
            $scope.weekdays = $routeParams.weekdays;
            try {
                var dateFrom = new Date($routeParams.dateFrom);
                var dateTo = new Date($routeParams.dateTo);
                $scope.dateFrom = $scope.formatDate(dateFrom);
                $scope.dateTo = $scope.formatDate(dateTo);
                accessControlService.sourceSelect(dateFrom, dateTo, $scope.weekdays).then(function (response) {
                    $scope.sources = response.data.Entities;
                    angular.forEach($scope.sources, function (source) {
                        source.Date = $scope.formatDate($scope.getWcfJsonDateOffset(source.Date));
                        switch (source.SourceFileType) {
                            case 1:
                                {
                                    source.SourceFileType = "Csv";
                                    break;
                                }
                            case 2:
                                {
                                    source.SourceFileType = "Database";
                                    break;
                                }
                        }
                        source.LoadedOn = $scope.formatDateTime($scope.getWcfJsonDateOffset(source.LoadedOn));
                        source.ExtractedOn = $scope.formatDateTime($scope.getWcfJsonDateOffset(source.ExtractedOn));
                        source.TransformedOn = $scope.formatDateTime($scope.getWcfJsonDateOffset(source.TransformedOn));
                        source.AnalysedOn = $scope.formatDateTime($scope.getWcfJsonDateOffset(source.AnalysedOn));
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

    sourceController.$inject = ["$scope", "$routeParams", "accessControlService"];

    angular.module("accessControl").controller("sourceController", sourceController);

}());
