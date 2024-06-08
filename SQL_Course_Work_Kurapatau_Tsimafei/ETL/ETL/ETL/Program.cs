using System.Data;
using Dapper;
using Npgsql;
using ETL.Entities;

namespace ETL
{
    static class EtlProcess
    {
        private const string OltpConnectionString = "Host=localhost;Username=admin_user;Password=adminpassword;Database=WashingMachine";
        private const string OlapConnectionString = "Host=localhost;Username=admin_user;Password=adminpassword;Database=olap_wm";

        static void Main()
        {
            try
            {
                var usersData = ExtractDataFromOltp<User>("SELECT id, username, email, role, created_at FROM users");
                var categoryData = ExtractDataFromOltp<Category>("SELECT id, name, description, created_at FROM categories");
                var reviewsData = ExtractDataFromOltp<Review>("SELECT id, user_id, washing_machine_id, rating, created_at FROM reviews");
                var addressesData = ExtractDataFromOltp<Address>("SELECT id, user_id, address_line1, address_line2, city, state, postal_code, country, created_at FROM addresses");
                var washingMachinesData = ExtractDataFromOltp<WashingMachine>("SELECT id, brand, model, price, COALESCE(energy_rating, '') AS energy_rating, capacity, created_at FROM washing_machines");
                var ordersData = ExtractDataFromOltp<Order>("SELECT id, user_id, total_amount, created_at FROM orders");
                var orderItemsData = ExtractDataFromOltp<OrderItem>("SELECT order_id, washing_machine_id, quantity, unit_price FROM order_items");
                var washingMachinesСategoriesData = ExtractDataFromOltp<WashingMachinesСategories>("SELECT washing_machine_id, category_id, created_at FROM washing_machine_categories");


                LoadDataToOlap(washingMachinesData, "dim_washing_machines", "id");
                Console.WriteLine($"Inserting dim_washing_machines: {washingMachinesData.Count}");
                LoadDataToOlap(categoryData, "dim_categories", "id");
                Console.WriteLine($"Inserting dim_categories: {categoryData.Count}");
                LoadDataToOlap(usersData, "dim_users", "id");
                Console.WriteLine($"Inserting dim_user: {usersData.Count}");
                LoadDataToOlap(addressesData, "dim_addresses", "id");
                Console.WriteLine($"Inserting dim_addresses: {addressesData.Count}");
                LoadDataToOlap(washingMachinesСategoriesData, "dim_washing_machine_categories", "washing_machine_id");
                Console.WriteLine($"Inserting washing_machine_categories: {washingMachinesСategoriesData.Count}");
                LoadDataToOlap(reviewsData, "fact_reviews", "id");
                Console.WriteLine($"Inserting fact_reviews: {reviewsData.Count}");

                foreach (var order in ordersData)
                {
                    var orderItems = orderItemsData.FindAll(item => item.Order_Id == order.Id);
                    foreach (var item in orderItems)
                    {
                        var factOrder = new FactOrder
                        {
                            User_Id = order.User_Id,
                            Order_Id = item.Order_Id,
                            Washing_Machine_Id = item.Washing_Machine_Id,
                            Total_Amount = order.Total_Amount,
                            Quantity = item.Quantity,
                            Unit_Price = item.Unit_Price,
                            Created_At = order.Created_At
                        };
                        LoadDataToOlap(new List<FactOrder> { factOrder }, "fact_orders", "order_id");
                    }
                }

                Console.WriteLine($"Inserting fact_order: {ordersData.Count}, {orderItemsData.Count}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static List<T> ExtractDataFromOltp<T>(string query) where T : new()
        {
            using (var connection = new NpgsqlConnection(OltpConnectionString))
            {
                connection.Open();
                var data = connection.Query<T>(query).AsList();
                Console.WriteLine($"Extracted {data.Count} records from OLTP for {typeof(T).Name}");
                return data;
            }
        }

        private static void LoadDataToOlap<T>(List<T> data, string tableName, string uniqueField)
        {
            using (var connection = new NpgsqlConnection(OlapConnectionString))
            {
                connection.Open();

                using (var transaction = connection.BeginTransaction())
                {
                    foreach (var item in data)
                    {
                        string upsertCommand = GenerateUpsertCommand(tableName, item, uniqueField);

                        using (var cmd = new NpgsqlCommand(upsertCommand, connection))
                        {
                            foreach (var prop in typeof(T).GetProperties())
                            {
                                var value = prop.GetValue(item);
                                cmd.Parameters.AddWithValue("@" + prop.Name, value ?? DBNull.Value);
                            }

                            cmd.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();
                }
            }
        }

        private static string GenerateUpsertCommand<T>(string tableName, T item, string uniqueField)
        {
            var columns = string.Join(", ", typeof(T).GetProperties().Select(p => p.Name));
            var parameters = string.Join(", ", typeof(T).GetProperties().Select(p => "@" + p.Name));
            var updates = string.Join(", ", typeof(T).GetProperties().Select(p => $"{p.Name} = EXCLUDED.{p.Name}"));

            return $"INSERT INTO {tableName} ({columns}) VALUES ({parameters}) ON CONFLICT ({uniqueField}) DO UPDATE SET {updates};";
        }
    }
}
