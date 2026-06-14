import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

enum SosFailureType {
  unauthenticated,
  permissionDenied,
  permissionPermanentlyDenied,
  gpsDisabled,
  locationTimeout,
  firestoreFailure,
  unknown,
}

class SosException implements Exception {
  const SosException(
    this.message, {
    required this.type,
    this.cause,
  });

  final String message;
  final SosFailureType type;
  final Object? cause;

  @override
  String toString() => message;
}

class SosAlertResult {
  const SosAlertResult({
    required this.alertId,
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  final String alertId;
  final double latitude;
  final double longitude;
  final String location;
}

class SosService {
  SosService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<SosAlertResult> createActiveAlert() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const SosException(
        'Please sign in before sending an SOS alert.',
        type: SosFailureType.unauthenticated,
      );
    }

    await _ensureLocationPermission();
    await _ensureGpsEnabled();

    final position = await _getCurrentPosition();
    final location = _formatLocation(position);
    final alertRef = _firestore.collection('alerts').doc();

    try {
      await alertRef.set({
        'alertId': alertRef.id,
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': location,
        'status': 'ACTIVE',
        'resolved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw SosException(
        'SOS alert could not be saved. Please try again.',
        type: SosFailureType.firestoreFailure,
        cause: error,
      );
    } catch (error) {
      throw SosException(
        'SOS alert could not be created. Please try again.',
        type: SosFailureType.firestoreFailure,
        cause: error,
      );
    }

    return SosAlertResult(
      alertId: alertRef.id,
      latitude: position.latitude,
      longitude: position.longitude,
      location: location,
    );
  }

  Future<void> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const SosException(
        'Location permission denied. Please allow location access to send SOS.',
        type: SosFailureType.permissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const SosException(
        'Location permission is permanently denied. Enable it from app settings.',
        type: SosFailureType.permissionPermanentlyDenied,
      );
    }
  }

  Future<void> _ensureGpsEnabled() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const SosException(
        'GPS is disabled. Turn on location services and try again.',
        type: SosFailureType.gpsDisabled,
      );
    }
  }

  Future<Position> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException catch (error) {
      throw SosException(
        'Location request timed out. Move to an open area and try again.',
        type: SosFailureType.locationTimeout,
        cause: error,
      );
    } on LocationServiceDisabledException catch (error) {
      throw SosException(
        'GPS is disabled. Turn on location services and try again.',
        type: SosFailureType.gpsDisabled,
        cause: error,
      );
    } on PermissionDeniedException catch (error) {
      throw SosException(
        'Location permission denied. Please allow location access to send SOS.',
        type: SosFailureType.permissionDenied,
        cause: error,
      );
    } catch (error) {
      throw SosException(
        'Could not fetch your current location. Please try again.',
        type: SosFailureType.unknown,
        cause: error,
      );
    }
  }

  String _formatLocation(Position position) {
    final latitude = position.latitude.toStringAsFixed(6);
    final longitude = position.longitude.toStringAsFixed(6);
    return '$latitude, $longitude';
  }
}
