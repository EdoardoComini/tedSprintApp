
Dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/watch_next_provider.dart';

class WatchNextScreen extends ConsumerWidget {
  final String currentTalkIdx;
  const WatchNextScreen({super.key, required this.currentTalkIdx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchNextAsync = ref.watch(watchNextProvider(currentTalkIdx));
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('MyTEDx Watch Next', style: TextStyle(color: Colors.red))),
      body: watchNextAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (err, stack) => Center(child: Text('Errore: \$err', style: const TextStyle(color: Colors.white))),
        data: (data) => Center(child: Text(data.mainTitle, style: const TextStyle(color: Colors.white, fontSize: 18))),
      ),
    );
  }
}
