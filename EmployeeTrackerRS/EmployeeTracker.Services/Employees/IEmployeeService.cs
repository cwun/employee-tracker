using System.Collections.Generic;
using System.Threading.Tasks;

namespace EmployeeTracker.Services.Employees
{
    public interface IEmployeeService
    {
        Task<IEnumerable<Employee>> GetEmployeesAsync();
    }
}
