class Prizes {
  final int prizeId;
  final String prizeUrl;
  final DateTime? wonAt;

  Prizes({required this.prizeId, required this.prizeUrl, this.wonAt});

  Map<String, dynamic> toJson() {
    return {
      'prizeId': prizeId,
      'prizeUrl': prizeUrl,
      if (wonAt != null) 'wonAt': wonAt!.toIso8601String(),
    };
  }

  factory Prizes.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    try {
      if (json['wonAt'] is String) parsed = DateTime.parse(json['wonAt']);
    } catch (_) {}
    return Prizes(
      prizeId: json['prizeId'],
      prizeUrl: json['prizeUrl'],
      wonAt: parsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prizeId': prizeId,
      'prizeUrl': prizeUrl,
      if (wonAt != null) 'wonAt': wonAt!.toIso8601String(),
    };
  }

  factory Prizes.fromMap(Map<String, dynamic> map) {
    DateTime? parsed;
    final raw = map['wonAt'];
    try {
      if (raw is String) {
        parsed = DateTime.parse(raw);
      } else if (raw != null) {
        // Firestore Timestamp
        try {
          parsed = (raw as dynamic).toDate();
        } catch (_) {}
      }
    } catch (_) {}
    return Prizes(
      prizeId: map['prizeId'],
      prizeUrl: map['prizeUrl'],
      wonAt: parsed,
    );
  }
}
