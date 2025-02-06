// File: lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/clothing_item.dart';
import 'screens/home_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive.
  await Hive.initFlutter();
  Hive.registerAdapter(ClothingCategoryAdapter());
  Hive.registerAdapter(ClothingItemAdapter());
  await Hive.openBox<ClothingItem>('wardrobeBox');
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  const initialSize = Size(480, 820);
  setWindowTitle('OOTD Generator');
  setWindowMinSize(initialSize);
  setWindowMaxSize(initialSize);
  setWindowFrame(const Rect.fromLTWH(100, 100, 480, 820));
}

  
  runApp(const OOTDRandomizerApp());
}

class OOTDRandomizerApp extends StatelessWidget {
  const OOTDRandomizerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOTD Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFB29C70),      // Caramel (AppBar/Accent)
          onPrimary: Color(0xFF7B6D47),    // Mocha Brown (Icons on light surfaces)
          secondary: Color(0xFFD9CBA3),      // Tan (Card surface)
          onSecondary: Color(0xFF443B2A),    // Dark Brown (Main text)
          background: Color(0xFFEFE6DD),     // Beige (Background)
          onBackground: Color(0xFF443B2A),   // Dark Brown (Text)
          surface: Color(0xFFD9CBA3),        // Tan (Cards)
          onSurface: Color(0xFF443B2A),      // Dark Brown
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      home: const HomeScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
