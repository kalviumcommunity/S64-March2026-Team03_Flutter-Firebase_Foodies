import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

/// Handles all Firestore mutations for addresses.
/// The UI reads are done via StreamBuilder in AddressScreen directly.
class AddressService with ChangeNotifier {

  // ─── Direct Firestore reference ────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>>? _addressesRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses');
  }

  // ─── Real-time stream (used by AddressScreen via StreamBuilder) ────────────

  Stream<List<Address>> addressesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Address.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ─── Add ───────────────────────────────────────────────────────────────────

  Future<void> addAddress(Address address) async {
    final ref = _addressesRef();
    if (ref == null) throw Exception('User not logged in.');

    // Check if this is the first address — make it default
    final existing = await ref.get();
    final isFirst = existing.docs.isEmpty;

    final data = address.copyWith(isDefault: isFirst).toFirestoreMap();
    await ref.add(data);
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteAddress(String addressId) async {
    final ref = _addressesRef();
    if (ref == null) throw Exception('User not logged in.');
    await ref.doc(addressId).delete();
  }

  // ─── Set Default ───────────────────────────────────────────────────────────

  Future<void> setDefaultAddress(String addressId) async {
    final ref = _addressesRef();
    if (ref == null) throw Exception('User not logged in.');

    final batch = FirebaseFirestore.instance.batch();
    final all = await ref.get();

    for (final doc in all.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    await batch.commit();
    notifyListeners();
  }
}
