import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new active alert for the currently logged-in user.
  Future<String> createAlert() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final alertDoc = await _firestore.collection('alerts').add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'status': 'ACTIVE',
      'createdAt': FieldValue.serverTimestamp(),
      'resolved': false,
      'location': 'Location Pending',
      'latitude': 0,
      'longitude': 0,
    });

    return alertDoc.id;
  }

  /// Listens to a single alert document by id.
  Stream<DocumentSnapshot> getAlert(String alertId) {
    return _firestore.collection('alerts').doc(alertId).snapshots();
  }

  /// Returns all active SOS alerts ordered by newest first.
  Stream<QuerySnapshot> getActiveAlerts() {
    return _firestore
        .collection('alerts')
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Accept an SOS alert as a volunteer/helper.
  Future<void> acceptAlert({
    required String alertId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('alerts').doc(alertId).update({
      'status': 'ACCEPTED',
      'acceptedBy': user.uid,
      'acceptedEmail': user.email ?? '',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }
}