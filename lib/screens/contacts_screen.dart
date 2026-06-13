import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final relation = _relationController.text.trim();

    if (name.isEmpty || phone.isEmpty || relation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await ContactService().addContact(
      name: name,
      phone: phone,
      relation: relation,
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  void _showAddContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _relationController,
                decoration: InputDecoration(
                  hintText: 'Relation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

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
    return StreamBuilder<QuerySnapshot>(
      stream: _contactService.getContacts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong while loading contacts.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 48, color: Colors.black45),
                  SizedBox(height: 12),
                  Text(
                    'No Emergency Contacts Yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 70,
              endIndent: 16,
              color: Color(0xFFE5E7EB),
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final contact = {
                'name': (data['name'] ?? '').toString(),
                'relation': (data['relation'] ?? '').toString(),
                'phone': (data['phone'] ?? '').toString(),
                'initials': _getInitials((data['name'] ?? '').toString()),
              };

              return _buildContactCard(theme, contact, index);
            },
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
        '${contact['relation']} • ${contact['phone']}',
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
      onPressed: _showAddContactSheet,
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