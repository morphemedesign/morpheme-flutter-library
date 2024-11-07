import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:morpheme_cached_network_image/morpheme_cached_network_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugInvertOversizedImages = kDebugMode;

  await MorphemeCachedNetworkImageManager.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Morpheme Cached Network Image Example'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (var i = 0; i < 1000; i++)
            MorphemeCachedNetworkImage(
              imageUrl: 'https://picsum.photos/id/$i/1000/1000',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }
}
