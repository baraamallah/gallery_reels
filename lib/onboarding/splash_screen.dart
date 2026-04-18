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
    // Longer delay for more "premium" feel (animations need time)
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    setState(() => _isNavigating = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Entrance to exit transition

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
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: Center(
          child: AnimatedOpacity(
            opacity: _isNavigating ? 0.0 : 1.0,
            duration: 600.ms,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Logo Animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.accentColor, AppTheme.shareColor],
                        ),
                      ),
                      child: const Icon(Icons.auto_fix_high, size: 60, color: Colors.white),
                    )
                    .animate()
                    .scale(duration: 1.seconds, curve: Curves.elasticOut)
                    .shimmer(delay: 1200.ms, duration: 2.seconds),
                    
                    // Rotating outer ring
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor.withValues(alpha: 0.2)),
                      ),
                    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                Text(
                  'Gallery Reels',
                  style: AppTheme.headingStyle.copyWith(fontSize: 40, letterSpacing: 1.2),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 12),
                
                Text(
                  'Curating your memories.',
                  style: AppTheme.bodyStyle.copyWith(color: Colors.white60, letterSpacing: 0.5),
                ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.5),
                
                const SizedBox(height: 60),
                
                // Subtle loading indicator at bottom
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ).animate().fadeIn(delay: 2.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
