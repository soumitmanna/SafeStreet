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
}
