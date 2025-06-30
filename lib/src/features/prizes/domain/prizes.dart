class Prizes {
  final int prizeId;
  final String prizeUrl;

  Prizes({required this.prizeId, required this.prizeUrl});

  Map<String, dynamic> toJson() => {
    'prizeId': prizeId,
    'prizeUrl': prizeUrl,
  };

  factory Prizes.fromJson(Map<String, dynamic> json) => Prizes(
    prizeId: json['prizeId'],
    prizeUrl: json['prizeUrl'],
  );
}