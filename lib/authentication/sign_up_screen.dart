import 'dart:io';
import 'package:chesshub/constants.dart';
import 'package:chesshub/helper/helper_methods.dart';
import 'package:chesshub/service/assetsManager.dart';
import 'package:chesshub/widgets/main_authentication_button.dart';
import 'package:chesshub/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? finalFileImage;
  String fileImageUrl = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

      print('imagePath: $finalFileImage');
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
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Gallery"),
                  onTap: () {
                    // choose image from gallery
                    selectImage(fromCamera: false);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  controller: nameController,
                  decoration: textFormDecoration.copyWith(
                    hintText: 'Enter your name',
                    labelText: 'Enter your name',
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: textFormDecoration.copyWith(
                    hintText: 'Enter your email',
                    labelText: 'Enter your email',
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: textFormDecoration.copyWith(
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                MainAuthenticationButton(
                  label: 'SIGN UP',
                  onPressed: () {
                    // register user with email and password
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
    );
  }
}
