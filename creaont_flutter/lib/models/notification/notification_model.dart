class NotificationModel {
  final String id;
  final String
  type; // order_placed | rating_received | progress_updated | new_message
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  int? get orderId => data['order_id'] as int?;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    return NotificationModel(
      id: json['id'] as String,
      type: rawData['type'] as String? ?? '',
      title: rawData['title'] as String? ?? '',
      body: rawData['body'] as String? ?? '',
      data: rawData,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
