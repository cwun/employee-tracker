using System.Collections.Generic;
using EmployeeTracker.Services.Charts;

namespace EmployeeTracker.Services.Dashboards
{
    public interface IDashboard
    {
        int TotalPositions { get; set; }
        int TotalOffices { get; set; }
        int TotalEmployees { get; set; }
        IEnumerable<ChartData> EmployeesPerYear { get; set; }
        IEnumerable<ChartData> EmployeesPerOffice { get; set; } 
    }
}
