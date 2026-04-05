import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? name,
    String? phone,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Used when saving to Firestore — excludes 'id' (Firestore uses doc.id)
  /// Adds a server-side createdAt timestamp
  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Used when updating a field (no id, no timestamp override)
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromFirestore(String docId, Map<String, dynamic> map) {
    return Address(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      addressLine: map['addressLine'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}
