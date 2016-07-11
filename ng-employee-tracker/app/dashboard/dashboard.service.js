(function () {
    'use strict';
 
    angular
        .module('employeeApp')
        .factory('dashboardService', dashboardService);
 
    dashboardService.$inject = ['common', 'RESOURCE_SERVER'];
 
    function dashboardService(common, RESOURCE_SERVER) {
        var service = {
            getSetting: getSetting
        };
 
        return service;
 
        ////////////////
 
        function getSetting() {
            //var url = 'api/dashboard.json';
            var url = RESOURCE_SERVER + 'api/dashboards';
            // issue a http get request to the Web API service
            return common.$http.get(url)
                .then(function (response) {
                    return response.data;
                });
        }
    }
 
})();