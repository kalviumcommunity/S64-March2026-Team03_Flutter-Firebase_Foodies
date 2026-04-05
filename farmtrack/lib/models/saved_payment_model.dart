import 'package:cloud_firestore/cloud_firestore.dart';

enum SavedPaymentType { card, upi }

class SavedPaymentMethod {
  final String id;
  final SavedPaymentType type;
  final String label; // e.g., "Visa **** 1234" or "user@upi"
  final String? lastFour;
  final String? cardHolder;
  final String? expiryDate;
  final String? upiId;
  final DateTime createdAt;

  SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
    this.cardHolder,
    this.expiryDate,
    this.upiId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name, // card or upi
      'label': label,
      'lastFour': lastFour,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'upiId': upiId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SavedPaymentMethod.fromMap(Map<String, dynamic> map, String docId) {
    return SavedPaymentMethod(
      id: docId,
      type: SavedPaymentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SavedPaymentType.card,
      ),
      label: map['label'] ?? '',
      lastFour: map['lastFour'],
      cardHolder: map['cardHolder'],
      expiryDate: map['expiryDate'],
      upiId: map['upiId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
