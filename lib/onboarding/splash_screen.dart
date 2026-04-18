import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'permission_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final onboardingComplete = await storage.read(key: 'onboarding_complete');

    if (!mounted) return;

    if (onboardingComplete == 'true') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PermissionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder icon (Using Phosphor style)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.accentColor, AppTheme.shareColor],
                  ),
                ),
                child: const Icon(Icons.auto_fix_high, size: 50, color: Colors.white),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.easeOutBack)
              .shimmer(delay: 1.seconds, duration: 2.seconds),
              
              const SizedBox(height: 24),
              
              Text(
                'Gallery Reels',
                style: AppTheme.headingStyle.copyWith(fontSize: 32),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 8),
              
              Text(
                'Swipe. Clean. Keep what matters.',
                style: AppTheme.bodyStyle,
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
