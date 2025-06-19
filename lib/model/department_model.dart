class getDept {
  final int dId;
  final String name;
  final int userId;
  final String remark;
  final DateTime createdAt;
  final DateTime updatedAt;

  getDept({
    required this.dId,
    required this.name,
    required this.userId,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a getDept object from JSON
  factory getDept.fromJson(Map<String, dynamic> json) {
    return getDept(
      dId: json['dId'],
      name: json['name'],
      userId: json['userId'],
      remark: json['remark'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a getDept object to JSON
  Map<String, dynamic> toJson() {
    return {
      'dId': dId,
      'name': name,
      'userId': userId,
      'remark': remark,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
