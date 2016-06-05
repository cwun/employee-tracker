(function () {
    'use strict';

    angular
        .module('employeeApp')
        .controller('EmployeeController', EmployeeController);

    EmployeeController.$inject = ['initialData'];

    function EmployeeController(initialData) {
        var vm = this;

        vm.title = 'Employees';
        vm.employees = initialData;

        activate();

        ////////////////

        function activate() {
            console.log(vm.title + ' loaded!');
        }

    }
})();
