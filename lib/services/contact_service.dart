import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add Emergency Contact
  Future<void> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergencyContacts')
        .add({
      'name': name,
      'phone': phone,
      'relation': relation,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get Emergency Contacts
  Stream<QuerySnapshot> getContacts() {
    final user = _auth.currentUser;

    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('emergencyContacts')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Update Emergency Contact
  Future<void> updateContact({
    required String docId,
    required String name,
    required String phone,
    required String relation,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergencyContacts')
        .doc(docId)
        .update({
      'name': name,
      'phone': phone,
      'relation': relation,
    });
  }

  /// Delete Emergency Contact
  Future<void> deleteContact(String docId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergencyContacts')
        .doc(docId)
        .delete();
  }
}