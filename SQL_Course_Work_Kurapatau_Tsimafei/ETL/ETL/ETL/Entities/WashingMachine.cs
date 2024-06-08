namespace ETL.Entities
{
    public class WashingMachine
    {
        public int Id { get; set; }
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public decimal Price { get; set; }
        public string? Energy_Rating { get; set; }
        public int Capacity { get; set; }
        public DateTime Created_At { get; set; }
    }
}
