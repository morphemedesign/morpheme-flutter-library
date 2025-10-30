import 'package:flutter/material.dart';
import 'package:morpheme_http/morpheme_http.dart' hide MorphemeInspector;
import 'package:morpheme_inspector/morpheme_inspector.dart';

final inspector = MorphemeInspector(
  notificationIcon: '@mipmap/ic_launcher',
  saveInspectorToLocal: true,
  showInspectorOnShake: true,
  showNotification: true,
);

final http = MorphemeHttp(
  morphemeInspector: inspector,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  void initState() {
    super.initState();
    inspector.setNavigatorState(Navigator.of(context));
  }

  bool isLoading = false;
  String? error;
  Response? response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('Inspect'),
        onPressed: () {
          inspector.navigateToInspectorPage();
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Send HTTP call',
            ),
            if (isLoading)
              const CircularProgressIndicator()
            else if (response != null || error != null)
              Text(
                error ?? response?.body ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.get(
                    Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
                  );
                  setState(() {
                    this.response = response;
                    error = null;
                  });
                } on MorphemeException catch (e) {
                  setState(() {
                    error = e.toMorphemeFailure().toString();
                  });
                } catch (e) {
                  setState(() {
                    error = e.toString();
                  });
                }
              },
              child: const Text('Send HTTP'),
            ),
          ],
        ),
      ),
    );
  }
}
