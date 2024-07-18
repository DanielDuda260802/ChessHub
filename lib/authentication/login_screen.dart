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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 120,
                backgroundImage: AssetImage(AssetsManager.logo),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                decoration: textFormDecoration.copyWith(
                  hintText: 'Enter your email',
                  labelText: 'Enter your email',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your password',
                    hintText: 'Enter your password'),
                obscureText: true,
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // zaboravljena lozinka
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              MainAuthenticationButton(
                label: 'LOGIN',
                onPressed: () {
                  // login user with email and password
                },
                fontSize: 30,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '- OR - \n Sign in With',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialButton(
                    label: 'Guest',
                    assetImage: AssetsManager.user_image,
                    height: 70,
                    width: 70,
                    onTap: () {},
                  ),
                  SocialButton(
                    label: 'Google',
                    assetImage: AssetsManager.google_image,
                    height: 70,
                    width: 70,
                    onTap: () {},
                  ),
                  SocialButton(
                    label: 'Facebook',
                    assetImage: AssetsManager.facebook_image,
                    height: 70,
                    width: 70,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              HaveAccoutWidget(
                label: 'Don\'t have account?',
                labelAction: 'Sign Up',
                onPressed: () {
                  Navigator.pushNamed(context, Constants.signUpScreen);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
