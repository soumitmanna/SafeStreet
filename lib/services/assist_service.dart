import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// DEVELOPMENT MODE
// Set to false before production/demo with multiple users.
const bool kDeveloperMode = true;

class AssistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getActiveAlerts() {
    return _firestore
        .collection('alerts')
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> acceptAlert(String alertId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('alerts').doc(alertId).update({
      'status': 'ACCEPTED',
      'acceptedBy': user.uid,
      'acceptedEmail': user.email,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }
}