class AddressModel {
  final String id;
  final String name;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.address,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? address,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
