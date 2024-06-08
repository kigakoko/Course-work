namespace ETL.Entities
{
    public class Order
    {
        public int Id { get; set; }
        public int User_Id { get; set; }
        public decimal Total_Amount { get; set; }
        public DateTime Created_At { get; set; }
    }
}
