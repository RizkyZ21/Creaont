class OrderModel {
  final int id;
  final String title;
  final double totalPrice;
  final String status;

  OrderModel({
    required this.id,
    required this.title,
    required this.totalPrice,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      title: json['title'],
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
    );
  }
}