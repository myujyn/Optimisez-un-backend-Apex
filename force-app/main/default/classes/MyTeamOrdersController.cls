public without sharing class MyTeamOrdersController {

    // Méthode pour afficher le chiffre d'affaires total sur la page MyTeamOrders
    public decimal sumOrders {
        get {
            AggregateResult aggregateResults = OrderSelector.getSumOfTotalAmountOfActivatedOrders();
            return (decimal) aggregateResults.get('total');
        }
        set;
    }

    // Liste pour afficher les résultats agrégés
    public List<AggregateResult> aggregateResults { get; set; }
    public List<AggregateResultWrapper> displayAggregates { get; set; }

    // Constructeur
    public MyTeamOrdersController() {
        displayAggregates = new List<AggregateResultWrapper>();
        
        // Création de données fictives pour 3 utilisateurs et leurs montants
        displayAggregates.add(new AggregateResultWrapper('John Doe', 12000));
        displayAggregates.add(new AggregateResultWrapper('Jane Smith', 15000));
        displayAggregates.add(new AggregateResultWrapper('Jim Brown', 18000));
    }

    // Classe wrapper pour encapsuler les résultats agrégés
    public class AggregateResultWrapper {
        public Decimal total { get; set; }
        public String ownerName { get; set; }
        
        public AggregateResultWrapper(String ownerName, Decimal total) {
            this.total = total;
            this.ownerName = ownerName;
        }
    }
}
