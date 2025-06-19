class GetLocation {
  final int lId;
  final int dId;
  final String name;
  final String desc;
  final DateTime createdAt;
  final DateTime updatedAt;

  GetLocation({
    required this.lId,
    required this.dId,
    required this.name,
    required this.desc,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a GetLocation object from JSON
  factory GetLocation.fromJson(Map<String, dynamic> json) {
    return GetLocation(
      lId: json['lId'],
      dId: json['dId'],
      name: json['name'],
      desc: json['desc'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a GetLocation object to JSON
  Map<String, dynamic> toJson() {
    return {
      'lId': lId,
      'dId': dId,
      'name': name,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
