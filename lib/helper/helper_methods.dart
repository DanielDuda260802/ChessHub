import 'dart:io';

import 'package:bishop/bishop.dart';
import 'package:chesshub/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squares/squares.dart';

Widget buildGameType(
    {required String label,
    String? gameTime,
    IconData? icon,
    required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null
              ? Icon(icon)
              : gameTime! == '60+0'
                  ? const SizedBox.shrink()
                  : Text(gameTime!),
          const SizedBox(
            height: 15,
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    ),
  );
}

final List<String> gameTempos = [
  'Bullet 1+0',
  'Bullet 2+1',
  'Blitz 3+0',
  'Blitz 3+2',
  'Blitz 5+0',
  'Blitz 5+3',
  'Rapid 10+0',
  'Rapid 10+5',
  'Rapid 15+10',
  'Classical 30+0',
  'Classical 30+20',
  'Custom 60+0'
];

String getTimerToDisplay({
  required GameProvider gameProvider,
  required bool isUser,
}) {
  String timer = '';
  if (isUser) {
    if (gameProvider.player == Squares.white) {
      timer = gameProvider.whiteTime.toString().substring(2, 7);
    } else {
      timer = gameProvider.blackTime.toString().substring(2, 7);
    }
  } else {
    // opponent
    if (gameProvider.player == Squares.white) {
      timer = gameProvider.blackTime.toString().substring(2, 7);
    } else {
      timer = gameProvider.whiteTime.toString().substring(2, 7);
    }
  }
  return timer;
}

var textFormDecoration = InputDecoration(
  hintText: 'enter your password',
  labelText: 'enter your password',
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.black, width: 2),
    borderRadius: BorderRadius.circular(12),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey, width: 2),
    borderRadius: BorderRadius.circular(12),
  ),
);

Future<File?> pickImage({
  required BuildContext context,
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    try {
      final takenPhoto =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (takenPhoto != null) {
        fileImage = File(takenPhoto.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    try {
      final choosenImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (choosenImage != null) {
        fileImage = File(choosenImage.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }
  return fileImage;
}
