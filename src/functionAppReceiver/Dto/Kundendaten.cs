namespace functionApp.Dto;

public class Kundendaten
    {
        public required string Kundennummer { get; set; }
        public required string Artikel { get; set; }
        public required decimal Preis { get; set; }
    }