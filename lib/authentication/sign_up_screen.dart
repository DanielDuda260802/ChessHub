import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:chesshub/widgets/main_authentication_button.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.blue,
                    backgroundImage: AssetImage(AssetsManager.user_image),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          border: Border.all(width: 3, color: Colors.black),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            onPressed: () {
                              // pick image from galery
                            },
                          ),
                        )),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: textFormDecoration.copyWith(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                ),
              ),
              const SizedBox(
                height: 30,
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
                height: 30,
              ),
              MainAuthenticationButton(
                label: 'SIGN UP',
                onPressed: () {
                  // login user with email and password
                },
                fontSize: 30,
              ),
              const SizedBox(
                height: 30,
              ),
              HaveAccoutWidget(
                label: 'Have an account?',
                labelAction: 'Login',
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
