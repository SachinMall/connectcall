import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          ),
        ),
        child: const Center(child: _SplashContent()),
      ),
    );
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent();

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 16)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/applogo.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 28),
            Text('ConnectCall', style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              'Connect with anyone, anywhere.',
              style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 44),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white.withValues(alpha: 0.85),
                strokeWidth: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
