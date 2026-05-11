import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/presentation/screens/startup_gatekeeper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: Add your Supabase Anon Key here
  // Go to: https://supabase.com/dashboard/project/rcxlrumrhsclppnfdwzk/settings/api
  // Copy the "anon public" key and paste it below
  await Supabase.initialize(
    url: 'https://rcxlrumrhsclppnfdwzk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjeGxydW1yaHNjbHBwbmZkd3prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4ODExOTYsImV4cCI6MjA5MzQ1NzE5Nn0.4QjL1Xh2JqQh6nCqN1tRk3x7l8y9z0a1b2c3d4e5f6',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StartupGatekeeper(), // Immediate auth check at app startup
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
