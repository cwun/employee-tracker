using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using EmployeeTracker.Services.SqlServer;

namespace EmployeeTracker.Services.Employees
{
    public class EmployeeService: IEmployeeService
    {
        private readonly IRepository _repo;

        public EmployeeService(IRepository repo)
        {
            _repo = repo;
        }

        public async Task<IEnumerable<Employee>> GetEmployeesAsync()
        {
            // execute the stored procedure called GetEmployees
            return await _repo.WithConnection(async c =>
            {
                // map the result from stored procedure to Employee data model
                var results = await c.QueryAsync<Employee>("GetEmployees", commandType: CommandType.StoredProcedure);
                return results;
            });
        }
    }
}
