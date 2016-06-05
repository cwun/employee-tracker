(function () {
    'use strict';

    angular
        .module('employeeApp')
        .factory('dashboardService', dashboardService);

    dashboardService.$inject = ['common'];

    /* @ngInject */
    function dashboardService(common) {
        var service = {
            getSetting: getSetting
        };

        return service;

        ////////////////

        function getSetting() {
            //var url = 'api/dashboard.json';
            var url = 'http://localhost/employee-tracker-apis/api/dashboards';
            return common.$http.get(url)
                .then(function (response) {
                    return response.data;
                });
        }
    }

})();
