using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EmployeeTracker.Services.Common;

namespace EmployeeTracker.Services.SqlServer
{
    public class Repository: IRepository
    {
        private readonly string _connectionString;

        public Repository(IConnection db)
        {
            _connectionString = db.ConnectionString;
        }

        // use for buffered queries that return a type
        public async Task<T> WithConnection<T>(Func<IDbConnection, Task<T>> getData)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    return await getData(connection);
                }
            }
            catch (TimeoutException ex)
            {
                throw new TimeoutException("Timeout Exception", ex);
            }
            catch (SqlException ex)
            {
                throw new DBConcurrencyException("Sql Exception", ex);
            }
        }

        public SqlConnection GetConnection(bool multipleActiveResultSets = false)
        {
            try
            {
                var cs = _connectionString;
                if (multipleActiveResultSets)
                {
                    var scsb = new SqlConnectionStringBuilder(cs) { MultipleActiveResultSets = true };
                    if (scsb.ConnectionString != null) cs = scsb.ConnectionString;
                }
                var connection = new SqlConnection(cs);
                connection.Open();
                return connection;
            }
            catch (TimeoutException ex)
            {
                throw new TimeoutException("Timeout Exception", ex);
            }
            catch (SqlException ex)
            {
                throw new DBConcurrencyException("Sql Exception", ex);
            }
        }

    }
}
