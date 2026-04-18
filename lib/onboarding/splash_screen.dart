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
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    setState(() => _isNavigating = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final onboardingComplete = await storage.read(key: 'onboarding_complete');

    if (!mounted) return;

    if (onboardingComplete == 'true') {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: 800.ms,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PermissionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: 800.ms,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient Background Lights
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF70aaff).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF70aaff).withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _isNavigating ? 0.0 : 1.0,
              duration: 600.ms,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container mimicking the "Lens" effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          const Color(0xFF599cf9).withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lens_blur, size: 60, color: AppTheme.primary),
                  )
                  .animate()
                  .scale(duration: 1.seconds, curve: Curves.elasticOut)
                  .shimmer(delay: 1200.ms, duration: 2.seconds),

                  const SizedBox(height: 48),

                  Text(
                    'Welcome to\nthe Archive',
                    textAlign: TextAlign.center,
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 40,
                      letterSpacing: -1.0,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  const SizedBox(height: 16),

                  Text(
                    'Experience your memories through\na modern, reels-style lens.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
