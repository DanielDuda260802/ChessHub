import 'dart:io';
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/providers/authentication_provider.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:chesshub/widgets/main_authentication_button.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? finalFileImage;
  String fileImageUrl = '';
  late String name;
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void selectImage({required bool fromCamera}) async {
    finalFileImage = await pickImage(
        context: context,
        fromCamera: fromCamera,
        onFail: (e) {
          // show error message
          showSnackBar(context: context, content: e.toString());
        });

    if (finalFileImage != null) {
      cropImage(finalFileImage!.path);
    } else {
      popCropDialog();
    }
  }

  void cropImage(String path) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      maxHeight: 800,
      maxWidth: 800,
    );

    popCropDialog();

    if (croppedFile != null) {
      setState(() {
        finalFileImage = File(croppedFile.path);
      });
    } else {
      popCropDialog();
    }
  }

  void popCropDialog() {
    Navigator.pop(context);
  }

  void showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  // choose image from camera
                  selectImage(fromCamera: true);
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  // choose image from gallery
                  selectImage(fromCamera: false);
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void signUpUserToFirebase() async {
    if (formKey.currentState!.validate()) {
      // Save the form
      formKey.currentState!.save();

      // Ispisi email i password za provjeru
      print('Email: $email, Password: $password');

      // Provjeri jesu li email ili password prazni ili null
      if (email.isEmpty || password.isEmpty) {
        print('Email ili password su prazni!');
        showSnackBar(context: context, content: 'Molimo popunite sva polja');
        return;
      }

      UserCredential? userCredential = await context
          .read<AuthenticationProvider>()
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      if (userCredential != null) {
        // user has been created
        print('user created: ${userCredential.user!.uid}');
      }
    } else {
      showSnackBar(context: context, content: 'Please fill all fields');
    }
  }

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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: screenHeight * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  finalFileImage != null
                      ? Stack(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.2,
                              backgroundColor: Colors.blue,
                              backgroundImage:
                                  FileImage(File(finalFileImage!.path)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  border:
                                      Border.all(width: 3, color: Colors.black),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // pick image from gallery
                                      showImagePickerDialog();
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Stack(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.2,
                              backgroundColor: Colors.blue,
                              backgroundImage:
                                  AssetImage(AssetsManager.user_image),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  border:
                                      Border.all(width: 3, color: Colors.black),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // pick image from gallery
                                      showImagePickerDialog();
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  TextFormField(
                    textInputAction:
                        TextInputAction.next, // done button postavljen na next
                    textCapitalization: TextCapitalization.words,
                    maxLength: 25,
                    maxLines: 1,
                    decoration: textFormDecoration.copyWith(
                      counterText: '',
                      hintText: 'Enter your name',
                      labelText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      } else if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      name = value.trim();
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
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
                    textInputAction: TextInputAction.done,
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
                    height: screenHeight * 0.03,
                  ),
                  MainAuthenticationButton(
                    label: 'SIGN UP',
                    onPressed: () {
                      // register user with email and password
                      signUpUserToFirebase();
                    },
                    fontSize: screenHeight * 0.03,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  HaveAccoutWidget(
                    label: 'Have an account?',
                    labelAction: 'Login',
                    onPressed: () {
                      Navigator.pop(context);
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
