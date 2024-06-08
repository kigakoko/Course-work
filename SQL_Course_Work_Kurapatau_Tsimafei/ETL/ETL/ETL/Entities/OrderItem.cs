namespace ETL.Entities
{
    public class OrderItem
    {
        public int Order_Id { get; set; }
        public int Washing_Machine_Id { get; set; }
        public int Quantity { get; set; }
        public decimal Unit_Price { get; set; }
    }
}
