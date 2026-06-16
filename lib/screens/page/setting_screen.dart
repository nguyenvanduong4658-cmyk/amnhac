import 'package:flutter/material.dart';
import '../tabs/general_tab.dart';
import '../tabs/account_tab.dart';
import '../tabs/notification_tab.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Please choose a settings tab."),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: "General"),
              Tab(icon: Icon(Icons.person), text: "Account"),
              Tab(icon: Icon(Icons.notifications), text: "Notification"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [GeneralTab(), AccountTab(), NotificationTab()],
        ),
      ),
    );
  }
}
