import 'package:chesshub/constants.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationProvider>().signOut().whenComplete(() {
                Navigator.pushNamedAndRemoveUntil(
                    context, Constants.loginScreen, (route) => false);
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Settings screen')),
    );
  }
}
