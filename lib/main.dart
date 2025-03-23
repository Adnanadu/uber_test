import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uber_app/feature/homePage/view/pages/home_page.dart';

void main() {
  runApp(ProviderScope(child: const UberApp()));
}

class UberApp extends StatelessWidget {
  const UberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
