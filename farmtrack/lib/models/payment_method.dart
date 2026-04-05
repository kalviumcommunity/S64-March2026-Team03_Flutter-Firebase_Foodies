/// Enum representing the available payment methods in the app.
enum PaymentMethodType {
  cashOnDelivery,
  card,
  upi,
}

/// Extension to add display-friendly properties to [PaymentMethodType].
extension PaymentMethodTypeExtension on PaymentMethodType {
  /// Returns a human-readable label for display in the UI.
  String get label {
    switch (this) {
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.upi:
        return 'UPI';
    }
  }

  /// Returns a short key suitable for storing in Firestore.
  String get firestoreKey {
    switch (this) {
      case PaymentMethodType.cashOnDelivery:
        return 'cod';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.upi:
        return 'upi';
    }
  }

  /// Returns a subtitle / description shown below the payment option.
  String get description {
    switch (this) {
      case PaymentMethodType.cashOnDelivery:
        return 'Pay when your order is delivered';
      case PaymentMethodType.card:
        return 'Visa, Mastercard, RuPay & more';
      case PaymentMethodType.upi:
        return 'Google Pay, PhonePe, Paytm & more';
    }
  }
}
