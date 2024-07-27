import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:chesshub/widgets/main_authentication_button.dart';
import 'package:chesshub/widgets/social_buttons.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.02,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.2,
                  backgroundImage: AssetImage(AssetsManager.logo),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: screenHeight * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                TextFormField(
                  decoration: textFormDecoration.copyWith(
                    hintText: 'Enter your email',
                    labelText: 'Enter your email',
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                TextFormField(
                  decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // zaboravljena lozinka
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: screenHeight * 0.02),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                MainAuthenticationButton(
                  label: 'LOGIN',
                  onPressed: () {
                    // login user with email and password
                  },
                  fontSize: screenHeight * 0.03,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  '- OR - \n Sign in With',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.025,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SocialButton(
                      label: 'Guest',
                      assetImage: AssetsManager.user_image,
                      height: screenWidth * 0.12,
                      width: screenWidth * 0.12,
                      onTap: () {},
                    ),
                    SocialButton(
                      label: 'Google',
                      assetImage: AssetsManager.google_image,
                      height: screenWidth * 0.12,
                      width: screenWidth * 0.12,
                      onTap: () {},
                    ),
                    SocialButton(
                      label: 'Facebook',
                      assetImage: AssetsManager.facebook_image,
                      height: screenWidth * 0.12,
                      width: screenWidth * 0.12,
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                HaveAccoutWidget(
                  label: 'Don\'t have account?',
                  labelAction: 'Sign Up',
                  onPressed: () {
                    Navigator.pushNamed(context, Constants.signUpScreen);
                  },
                  labelFontSize: screenHeight * 0.02,
                  actionFontSize: screenHeight * 0.025,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
