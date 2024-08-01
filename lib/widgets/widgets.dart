import 'package:chesshub/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlayerColorRadioButton extends StatelessWidget {
  const PlayerColorRadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final PlayerColor value;
  final PlayerColor? groupValue;
  final Function(PlayerColor?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PlayerColor>(
      title: Text(title),
      value: value,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.grey[300],
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

class GameDifficultyRadioButton extends StatelessWidget {
  const GameDifficultyRadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final GameDifficulty value;
  final GameDifficulty? groupValue;
  final Function(GameDifficulty?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final capitalizedTitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile<GameDifficulty>(
      title: Text(
        capitalizedTitle,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      value: value,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.grey[300],
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

class BuildCustomTime extends StatelessWidget {
  const BuildCustomTime({
    super.key,
    required this.time,
    required this.onLeftArrowClicked,
    required this.onRightArrowClicked,
  });

  final String time;
  final Function() onLeftArrowClicked;
  final Function() onRightArrowClicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: time == '0' ? null : onLeftArrowClicked,
          child: const Icon(
            (Icons.arrow_back),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onRightArrowClicked,
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}

class HaveAccoutWidget extends StatelessWidget {
  const HaveAccoutWidget({
    super.key,
    required this.label,
    required this.labelAction,
    required this.onPressed,
    required this.labelFontSize,
    required this.actionFontSize,
  });

  final String label;
  final String labelAction;
  final Function() onPressed;
  final double labelFontSize;
  final double actionFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            labelAction,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: actionFontSize,
            ),
          ),
        ),
      ],
    );
  }
}

showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
