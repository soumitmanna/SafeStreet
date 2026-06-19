import 'package:flutter/material.dart';

import '../services/sos_service.dart';
import 'assist_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final SosService _sosService = SosService();

  bool _emergencyActive = false;
  bool _isSending = false;
  bool _alertCreated = false;
  String _status = 'Ready to help';
  String _location = 'Waiting for SOS activation';

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
    setState(() {
      _isSending = true;
      _alertCreated = false;
      _status = 'Sending SOS alert...';
    });

    try {
      final result = await _sosService.createActiveAlert();

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _emergencyActive = true;
        _alertCreated = true;
        _status = 'Emergency Active';
        _location = result.location;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert created successfully.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssistScreen(alertId: result.alertId),
        ),
      );
    } on SosException catch (error) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _alertCreated = false;
        _status = 'Ready to help';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _alertCreated = false;
        _status = 'Ready to help';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOS failed: $error'),
          backgroundColor: const Color(0xFFDC2626),
        ),
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
                    const SizedBox(height: 18),
                    _buildAlertCreatedBanner(theme),
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
            onPressed: _isSending ? null : _confirmEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSending ? const Color(0xFF991B1B) : const Color(0xFFDC2626),
              disabledBackgroundColor: const Color(0xFF991B1B),
              shape: const CircleBorder(),
              elevation: 8,
              shadowColor: Colors.redAccent.withOpacity(0.35),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSending)
                  const SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                  )
                else
                  Text(
                    'SOS',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _isSending
                      ? 'Sharing location'
                      : _emergencyActive
                          ? 'Alert active'
                          : 'Tap to send alert',
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

  Widget _buildAlertCreatedBanner(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _alertCreated ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      child: AnimatedScale(
        scale: _alertCreated ? 1 : 0.96,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: IgnorePointer(
          ignoring: !_alertCreated,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF3),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Created',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF14532D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your live location was saved to Firestore.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
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
          _buildStatusDetail('Firestore alert', _emergencyActive ? 'Created' : 'Not sent'),
          const SizedBox(height: 14),
          _buildStatusDetail(
            'Response status',
            _isSending
                ? 'Getting location'
                : _emergencyActive
                    ? 'Awaiting confirmation'
                    : 'Ready to activate',
          ),
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
