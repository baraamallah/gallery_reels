import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/log_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _tapCount = 0;

  void _handleSecretTap() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      _showPinDialog();
    }
  }

  void _showPinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the security PIN to view system logs and debug data.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text == '8888') {
                Navigator.pop(context);
                _showLogs();
              } else {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied')));
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _showLogs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          appBar: AppBar(
            title: const Text('System Logs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  LogService.instance.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs cleared')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: LogService.instance.allLogs));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs copied to clipboard')));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              LogService.instance.allLogs.isEmpty ? 'No logs yet.' : LogService.instance.allLogs,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _handleSecretTap,
            child: const Text(
              'Gallery Reels',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Offline-first gallery cleaner with a reels-like experience.\nNo ads. No accounts.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              subtitle: const Text('Runs on-device. No analytics/trackers by default.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text('Open source friendly'),
              subtitle: const Text('Keep the code simple, readable, and safe.'),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version 1.0.0+1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

