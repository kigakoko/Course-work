namespace ETL.Entities
{
    public class Address
    {
        public int Id { get; set; }
        public int User_Id { get; set; }
        public string? Address_Line1 { get; set; }
        public string? Address_Line2 { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? Postal_Code { get; set; }
        public string? Country { get; set; }
        public DateTime Created_At { get; set; }
    }

}
