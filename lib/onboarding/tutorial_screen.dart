import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../app.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialItem> _items = [
    TutorialItem(
      title: 'Luminous Design',
      description: 'A high-performance interface built for speed and beauty. Pure Flutter power.',
      imagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCEFo4OI6IQkNElR9SC5ofm94NfAuI6o2qx64aX8Ms8QLvzKjnJ7vy4b2lO1sXCKtT_QBdYosthp-C3DKmvbMZj9ETmh2Dri8DvSN1W_1tkQQkT4TOHIbnjCek-GE6Su1D8pipTDMFk3HMc-iI9DjeZDZ-3SfbZ3NFBUNSYg8WV0PMrDaLB2tfCEFNRD1bq4In68fThGvFXvKLJQ2gidZgj8AM237bLxkDs4Vcvu0JvPuFBHN1GlnesvnEaN-JyM95ady5b4dIP6sM',
    ),
    TutorialItem(
      title: 'Swipe to Sort',
      description: 'Clean up your library with intuitive gestures. Swipe right to keep, left to trash.',
      imagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjKy4RXg5W3mcoe3XyOm3ub2T2JcjQNJD4M1FpjflZDuL-dmgrcbItcylNUTL3Y7otS0sO3Jk2EaOf2DI3CT9ww3uGtE13qorgxhhO-Jsa_IqvirIizRjRePLMsN_BLE2uwjAOTxqGb82ZkGrL52bEN4T8BPlVTE9hNORwwerjG_AiOOXE-AD-w0I5RKJ7_-XUyToz9SIWPIRfv2AWGOKhEzsLNFFwoMvKN_bEXkAotZkIvidSOrsVnFn0r7ebmAYi7dyOhbFdMf8',
    ),
  ];

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'onboarding_complete', value: 'true');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Action
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0, top: 16.0),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.onSurfaceVariant,
                      ),
                      child: Text('Skip', style: AppTheme.labelStyle.copyWith(color: AppTheme.onSurfaceVariant)),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Card Representation
                            Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              width: MediaQuery.of(context).size.width * 0.75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    if (index == 1) // Hint for swipe
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withValues(alpha: 0.8),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  const Icon(Icons.swipe_left, color: AppTheme.onSurface, size: 24),
                                                  Text('TRASH', style: AppTheme.labelStyle.copyWith(color: AppTheme.onSurfaceVariant, fontSize: 10)),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  const Icon(Icons.swipe_right, color: AppTheme.primary, size: 24),
                                                  Text('KEEP', style: AppTheme.labelStyle.copyWith(color: AppTheme.primary, fontSize: 10)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOutBack),

                            const SizedBox(height: 64),

                            // Text Info
                            Text(
                              item.title,
                              style: AppTheme.headingStyle.copyWith(
                                fontSize: 40,
                                letterSpacing: -1.0,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                            const SizedBox(height: 16),

                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyStyle.copyWith(fontSize: 16),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => Container(
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _currentPage == index
                                  ? AppTheme.primary
                                  : AppTheme.surfaceVariant,
                              boxShadow: _currentPage == index ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ] : [],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next/Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _items.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _completeOnboarding();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _items.length - 1 ? 'Next' : 'Get Started',
                                style: AppTheme.labelStyle.copyWith(
                                  color: AppTheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: AppTheme.onSurface, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialItem {
  final String title;
  final String description;
  final String imagePath;

  TutorialItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
