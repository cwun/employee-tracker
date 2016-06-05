(function() {
    'use strict';

    var app = angular
        .module('employeeApp', ['app.layout', 'ui.router', 'trNgGrid', 'nvd3']);

    app.config(['$stateProvider', '$urlRouterProvider',

        function($stateProvider, $urlRouterProvider) {

            $urlRouterProvider.otherwise("/home/dashboard");

            $stateProvider
                .state('home', {
                        url: "/home",
                        templateUrl: "app/layout/shell.html",
                        controller: "ShellController",
                        controllerAs: "vm",
                        abstract: true
                    })
                .state('home.dashboard', {
                        url: '/dashboard',
                        templateUrl: 'app/dashboard/dashboard.html',
                        controller: 'DashboardController',
                        controllerAs: 'vm',
                        resolve: {
                            initialData: ['dashboardService', function(dashboardService) {
                                return dashboardService.getSetting();
                        }]
                    }})
                .state('home.employees', {
                        url: "/employees",
                        templateUrl: "app/employee/employee.html",
                        controller: 'EmployeeController',
                        controllerAs: 'vm',
                        resolve: {
                            initialData: ['employeeService', function(employeeService) {
                                return employeeService.getList();
                        }]
                    }})

        }
    ]);

})();
