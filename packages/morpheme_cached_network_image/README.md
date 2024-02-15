# Morpheme Cached Network Image

A flutter library to show images from the internet and keep them in the cache directory powered with Hive.

## How to use

The MorphemeCachedNetworkImage can be used directly or through the ImageProvider.

Need to Hive.init in first main.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);

  runApp(const MyApp());
}
```

With a loading:

```dart
MorphemeCachedNetworkImage(
  imageUrl: 'https://picsum.photos/id/2/200',
  loadingBuilder: (context) => const CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
);
```

```dart
Image(image: MorphemeCachedNetworkImageProvider(url))
```

When you want to set as background you can do with container:

```dart
Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: MorphemeCachedNetworkImageProvider(
            'https://picsum.photos/id/2/200',
            ),
        ),
    ),
),
```
