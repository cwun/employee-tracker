using EmployeeTracker.Services.Employees;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace EmployeeTracker.Api.Controllers.Employees
{
    [RoutePrefix("api/employees")]
    public class EmployeesController : ApiController
    {
        private readonly IEmployeeService _service;

        public EmployeesController(IEmployeeService service)
        {
            _service = service;
        }

        [Route("")]
        [HttpGet]
        [ResponseType(typeof (IEmployee))]
        public async Task<IHttpActionResult> GetEmployees()
        {
            var result = await _service.GetEmployeesAsync();
            return Ok(result);
        }
    }
}
