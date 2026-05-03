import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_TutorialItem> _items = const [
    _TutorialItem(
      icon: Icons.video_collection_outlined,
      title: 'Reels-like cleaning',
      description: 'Swipe through your gallery like a reel.',
    ),
    _TutorialItem(
      icon: Icons.swipe,
      title: 'Fast gestures',
      description: 'Swipe left to delete, right to keep.',
    ),
    _TutorialItem(
      icon: Icons.folder_outlined,
      title: 'Pick folders',
      description: 'Choose exactly which folders to clean.',
    ),
  ];

  Future<void> _finish() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'onboarding_complete', value: 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Skip'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final item = _items[i];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 96),
                      const SizedBox(height: 24),
                      Text(item.title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(item.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(value: (_page + 1) / _items.length),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      if (_page < _items.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(_page < _items.length - 1 ? 'Next' : 'Start'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialItem {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialItem({required this.icon, required this.title, required this.description});
}

