import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _addContact(
    BuildContext context,
    String uid,
    List<Map<String, dynamic>> currentContacts,
  ) async {
    String name = '';
    String phone = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Color(0xFFFFFFFF),
          title: Text(
            'Acil durum kişisi ekle',
            style: AppTextStyles.h1.copyWith(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => phone = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(color: AppColors.tertiary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.trim().isEmpty || phone.trim().isEmpty) {
                  return;
                }
                final updated = [
                  ...currentContacts,
                  {'name': name.trim(), 'phone': phone.trim()},
                ];
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set(
                  {'emergencyContacts': updated},
                  SetOptions(merge: true),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Ekle',
                style: TextStyle(color: AppColors.tertiary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arama başlatılamadı')),
      );
    }
  }

  Future<void> _sendSms(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj başlatılamadı')),
      );
    }
  }

  void _showContactActions(BuildContext context, String name, String phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[500],
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                  title: const Text('Ara'),
                  subtitle: Text(phone),
                  onTap: () async {
                    Navigator.pop(context);
                    await _callNumber(context, phone);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[500],
                    child: const Icon(Icons.message, color: Colors.white),
                  ),
                  title: const Text('Mesaj Gönder'),
                  subtitle: Text(phone),
                  onTap: () async {
                    Navigator.pop(context);
                    await _sendSms(context, phone);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: Text(
          'Acil Durum',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.secondary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? Center(
              child: Text(
                'Oturum bulunamadı',
                style: AppTextStyles.body,
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Text(
                      'Profil bilgileri bulunamadı.',
                      style: AppTextStyles.body,
                    ),
                  );
                }

                final data = snapshot.data!.data();
                final contactsRaw = data?['emergencyContacts'];

                final contacts = (contactsRaw is List)
                    ? contactsRaw.whereType<Map<String, dynamic>>().toList()
                    : <Map<String, dynamic>>[];

                if (contacts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_emergency,
                            size: 64,
                            color: AppColors.tertiary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kayıtlı acil durum kişisi yok.',
                            style: AppTextStyles.h1.copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buradan acil durum kişilerini ekleyebilirsin.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final name =
                        (contact['name'] ?? 'Acil Durum Kişisi').toString();
                    final phone = (contact['phone'] ?? '').toString().trim();

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.tertiary.withOpacity(0.15),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.tertiary,
                          ),
                        ),
                        title: Text(
                          name,
                          style: AppTextStyles.h1.copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          phone.isEmpty ? 'Telefon belirtilmemiş' : phone,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecLight,
                          ),
                        ),
                        onTap: phone.isEmpty
                            ? null
                            : () => _showContactActions(context, name, phone),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!phone.isEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: AppColors.secondary,
                                ),
                                onPressed: () => _callNumber(context, phone),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.tertiary,
                              ),
                              onPressed: () async {
                                final updated =
                                    List<Map<String, dynamic>>.from(contacts);
                                updated.removeAt(index);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set(
                                  {'emergencyContacts': updated},
                                  SetOptions(merge: true),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final snap = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
                final data = snap.data();
                final raw = data?['emergencyContacts'];
                final current = (raw is List)
                    ? raw.whereType<Map<String, dynamic>>().toList()
                    : <Map<String, dynamic>>[];
                // ignore: use_build_context_synchronously
                await _addContact(context, user.uid, current);
              },
              backgroundColor: AppColors.secondary,
              icon: const Icon(Icons.add),
              label: const Text('Kişi Ekle'),
            ),
    );
  }
}
