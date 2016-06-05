(function () {
    'use strict';

    angular
        .module('employeeApp')
        .controller('DashboardController', DashboardController);

    DashboardController.$inject = ['$scope', 'initialData'];

    function DashboardController($scope, initialData) {
        var vm = this;

        vm.title = 'Dashboard';

        vm.employees = initialData.totalEmployees;
        vm.positions = initialData.totalPositions;
        vm.offices = initialData.totalOffices;

        activate();

        ////////////////

        function activate() {
            console.log(vm.title + ' loaded!');
        }

        vm.lineChartOptions = {
            chart: {
                type: 'historicalBarChart',
                height: 500,
                margin : {
                    top: 40,
                    right: 50,
                    bottom: 60,
                    left: 30
                },
                x: function(d){ return d.key; },
                y: function(d){ return d.value; },
                xAxis: {
                    axisLabel: 'Years',
                    rotateLabels: 30
                },
                yAxis: {
                    axisLabel: 'Employees',
                    axisLabelDistance: -10
                },
                showLegend: false
            }
        };

        vm.lineChartData = [{
            values: initialData.employeesPerYear,
            color: '#7777ff',
            area: true

        }];

        vm.pieChartOptions = {
            chart: {
                type: 'pieChart',
                height: 500,
                x: function(d){return d.key;},
                y: function(d){return d.value;},
                showLabels: true,
                valueFormat: function(d){
                    return d3.format(',.0f')(d) + ' employees';
                },
                duration: 500,
                labelThreshold: 0.01,
                labelSunbeamLayout: true,
                legend: {
                    margin: {
                        top: 5,
                        right: 35,
                        bottom: 5,
                        left: 0
                    }
                }
            }
        };

        vm.pieChartData = initialData.employeesPerOffice;

    }
})();
