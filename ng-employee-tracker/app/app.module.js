(function() {
    'use strict';

    // Creating our angular app and inject app.common, app.layout, ui-router, ui.footable, nvd3 
    // =============================================================================
    var app = angular
        .module('employeeApp', ['app.common', 'app.layout', 'ui.router', 'ui.footable', 'nvd3']);

    // Configuring our states 
    // =============================================================================
    app.config(['$stateProvider', '$urlRouterProvider',

        function($stateProvider, $urlRouterProvider) {

            // For any unmatched url, redirect to /home/dashboard
            $urlRouterProvider.otherwise("/home/dashboard");

            $stateProvider
                // TOP LEVEL STATE: HOME STATE
                .state('home', {
                        url: "/home",
                        // This will get automatically plugged into the unnamed ui-view 
                        // of the parent state template. Since this is a top level state, 
                        // its parent state template is index.html.
                        templateUrl: "app/layout/shell.html",
                        controller: "ShellController",
                        controllerAs: "vm",
                        abstract: true
                    })
                // NESTED STATES: child states of 'home' state
                // URL will become '/home/dashboard'
                .state('home.dashboard', {
                        url: '/dashboard',
                        // load into ui-view of the parent's template, shell.html
                        templateUrl: 'app/dashboard/dashboard.html',
                        controller: 'DashboardController',
                        controllerAs: 'vm',
                        resolve: {
                            initialData: ['dashboardService', function(dashboardService) {
                                return dashboardService.getSetting();
                        }]
                    }})
                // URL will become '/home/employees'
                .state('home.employees', {
                        url: "/employees",
                        // load into ui-view of the parent's template, shell.html
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
