using System.Configuration;
using Autofac;
using EmployeeTracker.Services.Common;
using EmployeeTracker.Services.Dashboards;
using EmployeeTracker.Services.Employees;
using EmployeeTracker.Services.SqlServer;

namespace EmployeeTracker.Api.Autofac
{
    public class StandardModule: Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            base.Load(builder);

            // obtain conn string once and reuse for all required
            var conn = ConfigurationManager.ConnectionStrings["DBConnection"];

            // bindings here
            builder.RegisterType<Connection>() // concrete type
                .As<IConnection>() // abstraction
                .WithParameter("settings", conn)
                .InstancePerLifetimeScope();

            builder.RegisterType<Repository>() 
                .As<IRepository>() 
                .InstancePerLifetimeScope();

            builder.RegisterType<EmployeeService>() 
                .As<IEmployeeService>() 
                .InstancePerLifetimeScope();

            builder.RegisterType<DashboardService>()
                .As<IDashboardService>()
                .InstancePerLifetimeScope();
        }
    }
}