import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Questo serve per ProviderScope!
import 'screens/watch_next_screen.dart';
void main() {
  runApp(
    const ProviderScope( 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
       home:const WatchNextScreen(), // Schermata temporanea per non fare errori prima del push
      ),
    ),
  );
}


class TempTestScreen extends StatelessWidget {
  const TempTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: const Center(
        child: Text(
          'TEDx Project Setup OK!\nIn attesa del codice del frontend...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}