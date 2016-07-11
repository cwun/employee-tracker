(function () {
    'use strict';
 
    angular
        .module('employeeApp')
        .value('EmployeeModel', EmployeeModel);
 
    function EmployeeModel() {
        this.id = 0;
        this.name = '';
        this.position = '';
        this.office = '';
        this.sex = '';
        this.age = '';
        this.startDate = '';
        this.salary = '';
    }
 
    EmployeeModel.prototype = {
        toObject: function (data) {
            this.id = data.id;
            this.name = data.firstName + ' ' + data.lastName;
            this.position = data.position;
            this.office = data.office;
            this.sex = data.sex;
            this.age = data.age;
            this.startDate = data.startDate;
            this.salary = data.salary;
            return this;
        }
    }
 
})();
