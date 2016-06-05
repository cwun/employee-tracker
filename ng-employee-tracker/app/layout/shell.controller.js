(function () {
    'use strict';

    angular
        .module('app.layout')
        .controller('ShellController', ShellController);

    ShellController.$inject = ['$rootScope'];

    /* @ngInject */
    function ShellController($rootScope) {
        /* jshint validthis: true */
        var vm = this;

        vm.activate = activate;
        vm.title = 'Employee Tracker';
        
        vm.showSpinner = false;
        vm.spinnerMessage = 'Retrieving data...';
        vm.spinnerOptions = {
            radius: 40,
            lines: 8,
            length: 0,
            width: 30,
            speed: 1.7,
            corners: 1.0,
            trail: 100,
            color: '#428bca'
        };

        activate();

        ////////////////

        function activate() {
            console.log(vm.title + ' loaded!');
        }
        
        $rootScope.$on('spinner.toggle', function (event, args) {
            vm.showSpinner = args.show;
            if (args.message) {
                vm.spinnerMessage = args.message;
            }
        });

    }
})();