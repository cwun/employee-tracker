(function () {
    'use strict';
 
    angular
        .module('employeeApp')
        .controller('EmployeeController', EmployeeController);
 
    EmployeeController.$inject = ['initialData'];
 
    function EmployeeController(initialData) {
        var vm = this;
 
        vm.title = 'Employees';
        /* Initialize vm.* bindable members with initialData.* members */
        vm.employees = initialData.employees;
 
        activate();
 
        ////////////////
 
        function activate() {
            console.log(vm.title + ' loaded!');
        }
 
    }
})();