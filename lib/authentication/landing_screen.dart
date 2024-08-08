import 'package:chesshub/constants.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // check authenticationState - if isIsginedIn or not
  void checkAuthenticationState() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (await authProvider.checkIfSignedIn()) {
      // Get user data from firestore
      await authProvider.getUserDataFromFirestore();

      // Save user data to shared preferences
      await authProvider.saveUserToSharedPreferences();

      // Navigate to home screen
      navigate(isSignIn: true);
    } else {
      // Navigate to the sign screen
      navigate(isSignIn: false);
    }
  }

  @override
  void initState() {
    checkAuthenticationState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(AssetsManager.logo),
      ),
    ));
  }

  void navigate({required bool isSignIn}) {
    if (isSignIn) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }
}
