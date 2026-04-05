import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';

/// Service responsible for managing the selected payment method state.
///
/// Uses [ChangeNotifier] so the UI can react to selection changes via Provider.
class PaymentService extends ChangeNotifier {
  PaymentMethodType? _selectedMethod;

  /// The currently selected payment method, or `null` if none selected.
  PaymentMethodType? get selectedMethod => _selectedMethod;

  /// Whether a payment method has been selected.
  bool get hasSelection => _selectedMethod != null;

  /// Select a payment method and notify listeners.
  void selectMethod(PaymentMethodType method) {
    if (_selectedMethod != method) {
      _selectedMethod = method;
      notifyListeners();
    }
  }

  /// Clear the current selection (e.g. after an order is placed).
  void clearSelection() {
    _selectedMethod = null;
    notifyListeners();
  }
}
