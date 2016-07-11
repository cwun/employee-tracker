(function () {
    'use strict';
 
    angular
        .module('employeeApp')
        .controller('DashboardController', DashboardController);
 
    DashboardController.$inject = ['initialData'];
 
    function DashboardController(initialData) {
        var vm = this;
 
        vm.title = 'Dashboard';
        /* Initialize vm.* bindable members with initialData.* members */
        vm.positions = initialData.totalPositions;
        vm.offices = initialData.totalOffices;
        vm.employees = initialData.totalEmployees;
 
        // Configure options for the bar chart
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
 
        // Bind data to the bar chart
        vm.lineChartData = [{
            values: initialData.employeesPerYear,
            color: '#7777ff',
            area: true
 
        }];
 
        // Configure options for the pie chart
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
 
        // Bind data to the pie chart
        vm.pieChartData = initialData.employeesPerOffice;

        activate();
 
        ////////////////
 
        function activate() {
            console.log(vm.title + ' loaded!');
        }
 
    }
})();