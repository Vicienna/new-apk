import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const ZenNotesApp(),
    ),
  );
}

class ZenNotesApp extends StatelessWidget {
  const ZenNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenNotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}      home: const HomePage(),
    );
  }
}