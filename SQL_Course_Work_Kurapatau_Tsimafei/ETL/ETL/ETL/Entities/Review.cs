namespace ETL.Entities
{
    public class Review
    {
        public int Id { get; set; }
        public int User_Id { get; set; }
        public int Washing_Machine_Id { get; set; }
        public int Rating { get; set; }
        public DateTime Created_At { get; set; }
    }
}
