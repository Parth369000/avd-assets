class ApiResponse {
  bool? errorStatus;
  productModel? data;

  ApiResponse({this.errorStatus, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      errorStatus: json['errorStatus'],
      data: json['data'] != null ? productModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorStatus': errorStatus,
      'data': data?.toJson(),
    };
  }
}

class productModel {
  int? productId;
  String? name;
  String? locationName;
  String? categoryName;
  String? quantity;
  String? dimensions;
  String? org;
  int? cid;
  String? description;
  String? departmentName;
  String? createdAt;
  String? updatedAt;
  String? category;
  List<AssignMaster>? assignMasters;
  List<PurchaseMaster>? purchaseMasters;
  List<Storage>? storage;
  List<String>? images;

  productModel({
    this.productId,
    this.name,
    this.locationName,
    this.categoryName,
    this.quantity,
    this.dimensions,
    this.org,
    this.cid,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.assignMasters,
    this.purchaseMasters,
    this.storage,
    this.departmentName,
    this.images,
  });

  factory productModel.fromJson(Map<String, dynamic> json) {
    return productModel(
      productId: json['productId'],
      name: json['name'],
      locationName: json['locationName'],
      categoryName: json['categoryName'],
      quantity: json['quantity'],
      dimensions: json['dimensions'],
      cid: json['cid'],
      org: json['org'],
      description: json['description'],
      departmentName: json['departmentName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'],
      assignMasters: json['assign_masters'] != null
          ? List<AssignMaster>.from(json['assign_masters'].map((x) => AssignMaster.fromJson(x)))
          : null,
      purchaseMasters: json['purchase_masters'] != null
          ? List<PurchaseMaster>.from(json['purchase_masters'].map((x) => PurchaseMaster.fromJson(x)))
          : null,
      storage: json['storage'] != null
          ? List<Storage>.from(json['storage'].map((x) => Storage.fromJson(x)))
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'locationName': locationName,
      'categoryName': categoryName,
      'quantity': quantity,
      'dimensions': dimensions,
      'cid': cid,
      'org': org,
      'description': description,
      'departmentName': departmentName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category,
      'assign_masters': assignMasters?.map((x) => x.toJson()).toList(),
      'purchase_masters': purchaseMasters?.map((x) => x.toJson()).toList(),
      'storage': storage?.map((x) => x.toJson()).toList(),
      'images': images,
    };
  }
}

class AssignMaster {
  int? assignId;
  int? productId;
  int? dId;
  String? quantity;
  String? createdAt;
  String? updatedAt;
  DeptMaster? deptMaster;

  AssignMaster({
    this.assignId,
    this.productId,
    this.dId,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.deptMaster,
  });

  factory AssignMaster.fromJson(Map<String, dynamic> json) {
    return AssignMaster(
      assignId: json['assignId'],
      productId: json['productId'],
      dId: json['dId'],
      quantity: json['quantity'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deptMaster: json['dept_master'] != null ? DeptMaster.fromJson(json['dept_master']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignId': assignId,
      'productId': productId,
      'dId': dId,
      'quantity': quantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dept_master': deptMaster?.toJson(),
    };
  }
}

class DeptMaster {
  int? dId;
  String? name;
  String? remark;

  DeptMaster({this.dId, this.name, this.remark});

  factory DeptMaster.fromJson(Map<String, dynamic> json) {
    return DeptMaster(
      dId: json['dId'],
      name: json['name'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dId': dId,
      'name': name,
      'remark': remark,
    };
  }
}

class PurchaseMaster {
  int? purchaseId;
  String? date;
  String? purcaseFrom;
  String? warranty;
  String? prize;
  String? purchasedBy;
  String? createdBy;
  String? description;

  PurchaseMaster({
    this.purchaseId,
    this.date,
    this.purcaseFrom,
    this.warranty,
    this.prize,
    this.purchasedBy,
    this.createdBy,
    this.description,
  });

  factory PurchaseMaster.fromJson(Map<String, dynamic> json) {
    return PurchaseMaster(
      purchaseId: json['purchaseId'],
      date: json['date'],
      purcaseFrom: json['purcaseFrom'],
      warranty: json['warranty'],
      prize: json['prize'],
      purchasedBy: json['purchasedBy'],
      createdBy: json['createdBy'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseId': purchaseId,
      'date': date,
      'purcaseFrom': purcaseFrom,
      'warranty': warranty,
      'prize': prize,
      'purchasedBy': purchasedBy,
      'createdBy': createdBy,
      'description': description,
    };
  }
}

class Storage {
  int? storageId;
  int? productId;
  int? lId;
  int? quantity;
  dynamic desc;
  String? createdAt;
  String? updatedAt;
  String? location;
  String? department;

  Storage({
    this.storageId,
    this.productId,
    this.lId,
    this.quantity,
    this.desc,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.department,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      storageId: json['storageId'],
      productId: json['productId'],
      lId: json['lId'],
      quantity: json['quantity'],
      desc: json['desc'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      location: json['locationName'],
      department: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageId': storageId,
      'productId': productId,
      'lId': lId,
      'quantity': quantity,
      'desc': desc,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'locationName': location,
      'departmentName': department,
    };
  }
}

class Location {
  String? name;

  Location({this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
