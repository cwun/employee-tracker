using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using EmployeeTracker.Services.Charts;
using EmployeeTracker.Services.SqlServer;

namespace EmployeeTracker.Services.Dashboards
{
    public class DashboardService: IDashboardService
    {
    private readonly IRepository _repo;

        public DashboardService(IRepository repo)
        {
            _repo = repo;
        }

        public async Task<Dashboard> GetDashboardSettingAsync()
        {
            return await _repo.WithConnection(async c =>
            {
                var reader = await c.QueryMultipleAsync("GetDashboardSetting", commandType: CommandType.StoredProcedure);
                var results = new Dashboard
                {
                    TotalPositions = reader.ReadAsync<int>().Result.SingleOrDefault(),
                    TotalOffices = reader.ReadAsync<int>().Result.SingleOrDefault(),
                    TotalEmployees = reader.ReadAsync<int>().Result.SingleOrDefault(),
                    EmployeesPerYear = reader.ReadAsync<ChartData>().Result.AsEnumerable(),
                    EmployeesPerOffice = reader.ReadAsync<ChartData>().Result.AsEnumerable()
                };
                return results;
            });
        }
    }
}

