(function () {

    var indexController = function ($scope, signalR) {

        function init() {
            var sendLastProcessedOn = function (value) {
                $scope.lastProcessedOn = value;
                process();
            };
            var sendMessage = function (value) {
                $scope.message = value;
                process();
            };
            var sendServerRemoteInfo = function (value) {
                $scope.serverRemoteInfo = value;
                process();
            };
            signalR.initialize(sendLastProcessedOn, sendMessage, sendServerRemoteInfo);
            process();
        }

        function process() {
            $scope.dayResume = $scope.dayResumeTitle = "Day Resume";
            if ($scope.serverRemoteInfo !== undefined) {
                $scope.dayResume = " Connections : " + $scope.serverRemoteInfo.length;
                if ($scope.lastProcessedOn !== undefined &&
                    $scope.message !== undefined) {
                    $scope.dayResume += " Status : " + $scope.formatDateTime(new Date($scope.lastProcessedOn)) + " - " + $scope.message;
                }
                $scope.dayResumeTitle = "";
                angular.forEach($scope.serverRemoteInfo, function (keyValuePair) {
                    $scope.dayResumeTitle += $scope.formatDateTime(new Date(keyValuePair.Key)) + " - " + keyValuePair.Value + "\n";
                });
            }
        };

        init();
    };

    indexController.$inject = ["$scope", "signalR"];

    angular.module("accessControl").controller("indexController", indexController);

}());