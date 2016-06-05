using System;

namespace EmployeeTracker.Services.Employees
{
    public class Employee: IEmployee
    {
        public int Id { get; set;  }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Position { get; set; }
        public string Office { get; set; }
        public char Sex { get; set; }
        public int Age { get; set; }
        public DateTime StartDate { get; set; }
        public decimal Salary { get; set; }
    }
}
