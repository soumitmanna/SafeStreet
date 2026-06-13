import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/alert_service.dart';
import '../services/location_service.dart';
import 'assist_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _emergencyActive = false;
  String _status = 'Ready to help';
  String _location = '23.7808875, 90.2792371';

  Future<void> _confirmEmergency() async {
    final shouldActivate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Emergency'),
          content: const Text(
            'Emergency mode will activate in 3 seconds.\nDo you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Activate'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (shouldActivate == true) {
      await _activateEmergency();
    }
  }

  Future<void> _activateEmergency() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final alertId = await AlertService().createAlert();

      final Position position = await LocationService().getCurrentLocation();

      await FirebaseFirestore.instance.collection('alerts').doc(alertId).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': 'Location Shared',
      });

      if (!mounted) return;

      setState(() {
        _emergencyActive = true;
        _status = 'Emergency Active';
        _location = '${position.latitude}, ${position.longitude}';
      });

      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssistScreen(alertId: alertId),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    if (isWide) _buildWideLayout(theme) else _buildNarrowLayout(theme),
                    const SizedBox(height: 24),
                    _buildLiveLocationCard(theme),
                    const SizedBox(height: 18),
                    _buildEmergencyContactsCard(theme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stay safe, stay ready',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'One tap alert for your trusted contacts and responders.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStatusCard(theme)),
        const SizedBox(width: 18),
        Expanded(child: _buildSOSButton(theme, height: 360)),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSOSButton(theme),
        const SizedBox(height: 20),
        _buildStatusCard(theme),
      ],
    );
  }

  Widget _buildSOSButton(ThemeData theme, {double height = 320}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFEEDEE),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: ElevatedButton(
            onPressed: _confirmEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: const CircleBorder(),
              elevation: 8,
              shadowColor: Colors.redAccent.withOpacity(0.35),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SOS',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _emergencyActive ? 'Cancel' : 'Tap to send alert',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _emergencyActive ? const Color(0xFFFEF3F2) : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _emergencyActive ? Icons.warning_amber_rounded : Icons.health_and_safety_rounded,
                  color: _emergencyActive ? const Color(0xFFB91C1C) : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _status,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Current emergency state, alerts sent to your saved contacts, and estimated response readiness.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 22),
          _buildStatusDetail('Alerts sent', '5 contacts notified'),
          const SizedBox(height: 14),
          _buildStatusDetail('Response status', _emergencyActive ? 'Awaiting confirmation' : 'Ready to activate'),
          const SizedBox(height: 14),
          _buildStatusDetail('Last update', 'Just now'),
        ],
      ),
    );
  }

  Widget _buildStatusDetail(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLiveLocationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFEF4444)),
              const SizedBox(width: 10),
              Text('Live location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Latitude / Longitude',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            _location,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text('Map view'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsCard(ThemeData theme) {
    final contacts = [
      {'name': 'Ariana Patel', 'role': 'Family'},
      {'name': 'Noah Chen', 'role': 'Friend'},
      {'name': 'Ethan Reid', 'role': 'Safety Team'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_circle_rounded, color: Color(0xFF0F172A)),
              const SizedBox(width: 10),
              Text('Emergency contacts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ...contacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        contact['name']!.split(' ').map((word) => word[0]).take(2).join(),
                        style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(contact['role']!, style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.message_rounded, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Manage contacts', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
