(function () {
    'use strict';
 
    angular
        .module('employeeApp')
        .factory('employeeService', employeeService);
 
    employeeService.$inject = ['common', 'EmployeeModel', 'RESOURCE_SERVER'];
 
    function employeeService(common, EmployeeModel, RESOURCE_SERVER) {
        var service = {
            getList: getList
        };
 
        return service;
 
        ////////////////
 
        function getList() {
            //var url = 'api/employees.json';
            var url = RESOURCE_SERVER + 'api/employees';
            // issue a http get request to the Web API service
            return common.$http.get(url)
                .then(function (response) {
                    // transforms the JSON response to a list of EmployeeModel
                    var data = response.data.length === 0 ? [] : common.transform(response.data, EmployeeModel);
                    return {
                        employees: data
                    };
                });
        }
    }
 
})();