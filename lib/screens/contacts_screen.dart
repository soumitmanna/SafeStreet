import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final List<Map<String, String>> _contacts = [
    {
      'name': 'Ariana Patel',
      'role': 'Family',
      'phone': '+1 555 283 910',
      'initials': 'AP',
    },
    {
      'name': 'Noah Chen',
      'role': 'Friend',
      'phone': '+1 555 721 844',
      'initials': 'NC',
    },
    {
      'name': 'Ethan Reid',
      'role': 'Safety Team',
      'phone': '+1 555 110 332',
      'initials': 'ER',
    },
    {
      'name': 'Sofia Martinez',
      'role': 'Family',
      'phone': '+1 555 445 667',
      'initials': 'SM',
    },
    {
      'name': 'James Wilson',
      'role': 'Emergency',
      'phone': '+1 555 998 221',
      'initials': 'JW',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your trusted contacts',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick access to call or message your emergency contacts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _buildContactsList(theme),
              const SizedBox(height: 24),
              _buildAddContactButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _contacts.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 70,
          endIndent: 16,
          color: Color(0xFFE5E7EB),
        ),
        itemBuilder: (context, index) => _buildContactCard(theme, _contacts[index], index),
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme, Map<String, String> contact, int index) {
    final colors = [
      const Color(0xFFDBEAFE),
      const Color(0xFFECE4F8),
      const Color(0xFFFEF3F2),
      const Color(0xFFDCFCE7),
      const Color(0xFFFEF3C7),
    ];
    final textColors = [
      const Color(0xFF1D4ED8),
      const Color(0xFF6D28D9),
      const Color(0xFFB91C1C),
      const Color(0xFF166534),
      const Color(0xFF92400E),
    ];

    final colorIndex = index % colors.length;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: colors[colorIndex],
        child: Text(
          contact['initials']!,
          style: TextStyle(
            color: textColors[colorIndex],
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        contact['name']!,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${contact['role']} • ${contact['phone']}',
        style: const TextStyle(color: Colors.black54, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.call_rounded, color: Color(0xFF0EA5E9)),
              onPressed: () {},
              tooltip: 'Call',
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.message_rounded, color: Color(0xFF2563EB)),
              onPressed: () {},
              tooltip: 'Message',
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddContactButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('Add Contact'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
