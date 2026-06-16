import 'package:flutter/material.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  bool emailNotify = true;
  bool pushNotify = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CheckboxListTile(
          title: const Text("Email Notification"),
          value: emailNotify,
          onChanged: (value) {
            setState(() {
              emailNotify = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text("Push Notification"),
          value: pushNotify,
          onChanged: (value) {
            setState(() {
              pushNotify = value!;
            });
          },
        ),
      ],
    );
  }
}