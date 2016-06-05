using System.Reflection;
using System.Web.Http;
using Autofac;
using Autofac.Integration.WebApi;
using EmployeeTracker.Api.Autofac;
using Newtonsoft.Json.Serialization;
using System.Web.Http.Cors;

namespace EmployeeTracker.Api
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            /* Allow Cross Domain Access
            var cors = new EnableCorsAttribute("http://employee-tracker.azurewebsites.net", "*", "*");
            config.EnableCors(cors);
            */

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Formatters.JsonFormatter.SerializerSettings.ContractResolver =
              new CamelCasePropertyNamesContractResolver();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );

            var builder = new ContainerBuilder(); // yes, it is a different container here

            // register Web API Controllers
            builder.RegisterAssemblyTypes(Assembly.GetExecutingAssembly());

            // register your graph - shared
            builder.RegisterModule(new StandardModule()); // same as with ASP.NET MVC Controllers

            var container = builder.Build();
            config.DependencyResolver = new AutofacWebApiDependencyResolver(container);
        }
    }
}
