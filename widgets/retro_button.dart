import 'package:flutter/material.dart';

class RetroButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const RetroButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffffd888),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(0, 0),
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle ??
              const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.black,
              ),
        ),
      ),
    );
  }
}
