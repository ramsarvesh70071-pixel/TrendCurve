/// Individual historical data point entry for a trend curve.
class TrendDataPointModel {
  final String id;
  final String trendId;
  final DateTime date;
  final double value;
  final String? note;
  final DateTime createdAt;

  const TrendDataPointModel({
    required this.id,
    required this.trendId,
    required this.date,
    required this.value,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'trendId': trendId,
        'date': date.toIso8601String(),
        'value': value,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrendDataPointModel.fromJson(Map<String, dynamic> json) =>
      TrendDataPointModel(
        id: json['id'] as String,
        trendId: json['trendId'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        value: (json['value'] as num).toDouble(),
        note: json['note'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  TrendDataPointModel copyWith({
    String? id,
    String? trendId,
    DateTime? date,
    double? value,
    String? note,
    DateTime? createdAt,
  }) =>
      TrendDataPointModel(
        id: id ?? this.id,
        trendId: trendId ?? this.trendId,
        date: date ?? this.date,
        value: value ?? this.value,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
}
