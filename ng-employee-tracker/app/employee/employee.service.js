(function () {
    'use strict';

    angular
        .module('employeeApp')
        .factory('employeeService', employeeService);

    employeeService.$inject = ['common', 'EmployeeModel'];

    /* @ngInject */
    function employeeService(common, EmployeeModel) {
        var service = {
            getList: getList
        };

        return service;

        ////////////////

        function getList() {
            //var url = 'api/employees.json';
            var url = 'http://localhost/employee-tracker-apis/api/employees';
            return common.$http.get(url)
                .then(function (response) {
                    var data = response.data.length === 0 ? [] : common.transform(response.data, EmployeeModel);
                    return data;
                });
        }
    }

})();

