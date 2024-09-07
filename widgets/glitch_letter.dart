import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GlitchLetter extends StatefulWidget {
  final String letter;
  final TextStyle style;

  const GlitchLetter({required this.letter, required this.style, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GlitchLetterState createState() => _GlitchLetterState();
}

class _GlitchLetterState extends State<GlitchLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glitchAnimation;
  bool _isGlitched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glitchAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _startRandomGlitchTimer();
  }

  void _startRandomGlitchTimer() {
    final random = Random();
    Timer.periodic(Duration(seconds: random.nextInt(6) + 1), (timer) {
      if (mounted) {
        setState(() {
          _isGlitched = !_isGlitched;
        });
        _controller.forward(from: 0);

        timer.cancel();
        _startRandomGlitchTimer();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_isGlitched ? _glitchAnimation.value : 0, 0),
          child: Text(
            widget.letter,
            style: widget.style,
          ),
        );
      },
    );
  }
}
