using System.Collections;
using System.Collections.Generic;
using EmployeeTracker.Services.Charts;

namespace EmployeeTracker.Services.Dashboards
{
    public class Dashboard: IDashboard
    {
        public int TotalPositions { get; set; }
        public int TotalOffices { get; set; }
        public int TotalEmployees { get; set; }
        public IEnumerable<ChartData> EmployeesPerYear { get; set; }
        public IEnumerable<ChartData> EmployeesPerOffice { get; set; } 
    }
}
