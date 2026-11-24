import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  late final Future<Map<String, dynamic>> policy = loadPolicy();

  Future<Map<String, dynamic>> loadPolicy() async {
    final text = await rootBundle.loadString('assets/data/privacy_policy.json');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Widget buildSection(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              section['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            section['text'] as String,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Privacy policy'),
      content: FutureBuilder<Map<String, dynamic>>(
        future: policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Unable to open the privacy policy. Please try again.',
            );
          }
          if (!snapshot.hasData) {
            return const Text('Loading privacy policy...');
          }
          final data = snapshot.data!;
          final sections = data['sections'] as List;
          return SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('Effective date: ${data['effective_date']}'),
                const SizedBox(height: 8),
                SelectableText(data['contact_email'] as String),
                for (final section in sections)
                  buildSection(section as Map<String, dynamic>),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
