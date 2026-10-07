/// User and system timeline activity model.
class ActivityModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String iconName;
  final String? trendId;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.iconName = 'timeline',
    this.trendId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'iconName': iconName,
        'trendId': trendId,
      };

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        iconName: json['iconName'] as String? ?? 'timeline',
        trendId: json['trendId'] as String?,
      );
}
