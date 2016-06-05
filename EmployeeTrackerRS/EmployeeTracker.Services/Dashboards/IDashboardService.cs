using System.Threading.Tasks;

namespace EmployeeTracker.Services.Dashboards
{
    public interface IDashboardService
    {
        Task<Dashboard> GetDashboardSettingAsync();
    }
}
