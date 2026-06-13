import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  final List<Map<String, Object>> _alerts = const [
    {
      'icon': Icons.warning_rounded,
      'title': 'Unauthorized entry detected',
      'time': '2 min ago',
      'status': 'Investigating',
      'color': Color(0xFFFB923C),
    },
    {
      'icon': Icons.location_on_rounded,
      'title': 'Suspicious movement near Main St.',
      'time': '14 min ago',
      'status': 'Resolved',
      'color': Color(0xFF22C55E),
    },
    {
      'icon': Icons.traffic_rounded,
      'title': 'Road hazard reported',
      'time': '38 min ago',
      'status': 'Pending',
      'color': Color(0xFF3B82F6),
    },
    {
      'icon': Icons.shield_rounded,
      'title': 'Safety check complete',
      'time': '1 hr ago',
      'status': 'Safe',
      'color': Color(0xFF0EA5E9),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent incident alerts',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View the latest activity and status updates for your safety network.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 22),
                    isWide
                        ? Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _alerts
                                .map((alert) => SizedBox(
                                      width: (constraints.maxWidth - 60) / 2,
                                      child: _buildAlertCard(context, alert),
                                    ))
                                .toList(),
                          )
                        : Column(
                            children: _alerts
                                .map((alert) => Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _buildAlertCard(context, alert),
                                    ))
                                .toList(),
                          ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, Object> alert) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: (alert['color'] as Color).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                width: 52,
                height: 52,
                child: Icon(
                  alert['icon'] as IconData,
                  color: alert['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['time'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  alert['status'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'The system will notify your trusted contacts and keep track of response activity for this alert. Tap to review the incident details.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
