class Prizes {
  final int prizeId;
  final String prizeUrl;

  Prizes({required this.prizeId, required this.prizeUrl});

  Map<String, dynamic> toJson() {
    return {'prizeId': prizeId, 'prizeUrl': prizeUrl};
  }

  factory Prizes.fromJson(Map<String, dynamic> json) {
    return Prizes(prizeId: json['prizeId'], prizeUrl: json['prizeUrl']);
  }

  Map<String, dynamic> toMap() {
    return {'prizeId': prizeId, 'prizeUrl': prizeUrl};
  }

  factory Prizes.fromMap(Map<String, dynamic> map) {
    return Prizes(prizeId: map['prizeId'], prizeUrl: map['prizeUrl']);
  }
}
