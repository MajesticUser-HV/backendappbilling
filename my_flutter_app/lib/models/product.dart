class Product {
  final int? id; // nullable for new products
  final String name;
  final String brand;
  final double price;
  final int quantity;

  Product({
    this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'quantity': quantity,
    };
  }
}
