import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/theme.dart';
import '../shared/widgets/glass_card.dart';
import 'tutorial_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _loading = false;

  Future<void> _requestPermissions() async {
    setState(() => _loading = true);
    
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    
    setState(() => _loading = false);

    if (state.isAuth || state == PermissionState.limited) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TutorialScreen()),
        );
      }
    } else {
      // Show custom permission denied screen with Settings deep-link
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1030),
            title: Text('Permission Denied', style: AppTheme.headingStyle),
            content: Text(
              'Gallery Reels needs photo access to help you clean your gallery. Please enable it in settings.',
              style: AppTheme.bodyStyle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  PhotoManager.openSetting();
                  Navigator.pop(context);
                },
                child: const Text('Settings', style: TextStyle(color: AppTheme.accentColor)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Hero(
              tag: 'app_logo',
              child: Icon(Icons.photo_library_outlined, size: 80, color: AppTheme.accentColor),
            ),
            const SizedBox(height: 40),
            GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Photo Access',
                    style: AppTheme.headingStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To start cleaning your gallery, we need permission to view and organize your photos directly on your device.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyStyle,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Allow Access',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
