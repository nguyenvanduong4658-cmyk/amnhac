import 'package:flutter/material.dart';

class GeneralTab extends StatefulWidget {
  const GeneralTab({super.key});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  bool darkMode = false;
  bool autoLogin = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text("Dark Mode"),
          value: darkMode,
          onChanged: (value) {
            setState(() {
              darkMode = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text("Auto Login"),
          value: autoLogin,
          onChanged: (value) {
            setState(() {
              autoLogin = value;
            });
          },
        ),
      ],
    );
  }
}