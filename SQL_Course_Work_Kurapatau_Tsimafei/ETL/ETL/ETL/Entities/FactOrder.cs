namespace ETL.Entities
{
    public class FactOrder
    {
        public int User_Id { get; set; }
        public int Order_Id { get; set; }
        public int Washing_Machine_Id { get; set; }
        public decimal Total_Amount { get; set; }
        public int Quantity { get; set; }
        public decimal Unit_Price { get; set; }
        public DateTime Created_At { get; set; }
    }
}
