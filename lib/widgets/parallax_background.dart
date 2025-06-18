// widgets/parallax_background.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ParallaxBackground extends StatefulWidget {
  const ParallaxBackground({Key? key}) : super(key: key);

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Música de fondo
    _player = AudioPlayer();
    _player
      ..setAsset('assets/audio/menu_music.mp3')
      ..setLoopMode(LoopMode.one)
      ..play();

    // Animación sutil de opacidad
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _opacityAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (_, child) =>
          Opacity(opacity: _opacityAnimation.value, child: child),
      child: Image.asset(
        'assets/background/app_background.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
