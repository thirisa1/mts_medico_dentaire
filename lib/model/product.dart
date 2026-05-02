// ─────────────────────────────────────────────
// Catégories produits médico-dentaires
// ─────────────────────────────────────────────
enum ProductCategory {
  anesthesieDentaire,
  blanchiment,
  boucheProthese,
  chirurgie,
  detartrage,
  endodontie,
  fraises,
  hygieneDesinfection,
  instruments,
  materiel,
  orthodontie,
  parapharmacie,
  prothese,
  restauration,
  scellement,
  tenon,
  usageUnique,
  medical,
}

extension ProductCategoryLabel on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.anesthesieDentaire:
        return 'Anesthésie dentaire';
      case ProductCategory.blanchiment:
        return 'Blanchiment';
      case ProductCategory.boucheProthese:
        return 'Bouche (prothèse)';
      case ProductCategory.chirurgie:
        return 'Chirurgie';
      case ProductCategory.detartrage:
        return 'Détartrage & Polissage';
      case ProductCategory.endodontie:
        return 'Endodontie';
      case ProductCategory.fraises:
        return 'Fraises';
      case ProductCategory.hygieneDesinfection:
        return 'Hygiène & Désinfection';
      case ProductCategory.instruments:
        return 'Instruments';
      case ProductCategory.materiel:
        return 'Matériel';
      case ProductCategory.orthodontie:
        return 'Orthodontie';
      case ProductCategory.parapharmacie:
        return 'Parapharmacie';
      case ProductCategory.prothese:
        return 'Prothèse';
      case ProductCategory.restauration:
        return 'Restauration';
      case ProductCategory.scellement:
        return 'Scellement';
      case ProductCategory.tenon:
        return 'Tenon';
      case ProductCategory.usageUnique:
        return 'Usage unique';
      case ProductCategory.medical:
        return 'Médical';
    }
  }
}

// ─────────────────────────────────────────────
// Types d'acheteurs autorisés
// ─────────────────────────────────────────────
enum BuyerType { professionnel, autre }

extension BuyerTypeLabel on BuyerType {
  String get label {
    switch (this) {
      case BuyerType.professionnel:
        return 'Professionnel';
      case BuyerType.autre:
        return 'Autre';
    }
  }
}

// ─────────────────────────────────────────────
// Modèle Produit
// ─────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String brand;
  final ProductCategory category;
  final int quantity;
  final double price;
  final String description;
  final List<BuyerType> allowedBuyers;
  final String? imagePath; // chemin local ou URL de la photo
  final bool deleted; // ← soft delete flag

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.price,
    required this.description,
    required this.allowedBuyers,
    this.imagePath,
    this.deleted = false, // ← false par défaut
  });
}

// ─────────────────────────────────────────────
// Liste des produits (vide — données réelles via API)
// ─────────────────────────────────────────────
List<Product> kProducts = [];
