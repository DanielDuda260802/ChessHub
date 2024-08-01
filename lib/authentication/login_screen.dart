import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:chesshub/widgets/main_authentication_button.dart';
import 'package:chesshub/widgets/social_buttons.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      // Save the form
      formKey.currentState!.save();

      UserCredential? userCredential =
          await authProvider.signInUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        // check if this user exist in firestore
        bool user_exist = await authProvider.checkUserExist();
        if (user_exist) {
          // get user information from firestore
          await authProvider.getUserDataFromFirestore();

          // save user data to shared preferences - local storage
          await authProvider.saveUserToSharedPreferences();

          // save user as signed in
          await authProvider.setSignedIn();

          formKey.currentState!.reset();

          authProvider.setIsLoading(value: false);
          // navigate to home screen
          navigate(isSignedIn: true);
        } else {
          // navigate to user information
          navigate(isSignedIn: false);
        }
      }
    } else {
      showSnackBar(context: context, content: 'Please fill all fields');
    }
  }

  navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushNamedAndRemoveUntil(
          context, Constants.homeScreen, (route) => false);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
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
            child: Form(
              key: formKey,
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (!validateEmail(email)) {
                        return 'Please enter a valid email';
                      } else if (validateEmail(email)) {
                        return null;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value.trim();
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  TextFormField(
                    decoration: textFormDecoration.copyWith(
                      labelText: 'Enter your password',
                      hintText: 'Enter your password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                    obscureText: obscureText,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      } else if (value.length < 7) {
                        return 'Password must be at least 8 character';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                    },
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
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : MainAuthenticationButton(
                          label: 'LOGIN',
                          onPressed: () {
                            // login user with email and password
                            signInUser();
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
      ),
    );
  }
}
