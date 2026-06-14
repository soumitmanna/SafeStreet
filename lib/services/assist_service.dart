import 'package:cloud_firestore/cloud_firestore.dart';

class AssistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns all active SOS alerts
  Stream<QuerySnapshot> getActiveAlerts() {
    return _firestore
        .collection('alerts')
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}