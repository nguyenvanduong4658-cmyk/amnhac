import 'package:flutter/material.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        SizedBox(height: 20),
        ListTile(leading: Icon(Icons.person), title: Text("Nguyen Van Duong")),
        ListTile(leading: Icon(Icons.email), title: Text("admin@gmail.com")),
        ListTile(leading: Icon(Icons.phone), title: Text("0909999999")),
      ],
    );
  }
}