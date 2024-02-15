# Morpheme Inspector

Morpheme Inspector is a simple in-app for Morpheme HTTP inspector. Morpheme Inspector intercepts and persists all HTTP requests and responses inside your application, and provides a UI for inspecting their content. It is inspired from [Alice](https://pub.dev/packages?q=alice), [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

## Supported

- [Morpheme HTTP](https://pub.dev/packages/morpheme_http)

## Feature

- Detailed logs for each HTTP calls (HTTP Request, HTTP Response)
- Inspector UI for viewing HTTP calls
- Save HTTP calls to Sqflite
- Notification on HTTP call
- Support for top used HTTP clients in Dart
- Shake to open inspector
- HTTP calls search

## How to Usage

```dart
locator.registerLazySingleton(
    () => MorphemeInspector(
      showNotification: true, // default true
      showInspectorOnShake: true, // default true
      saveInspectorToLocal: true, // default true
      notificationIcon: '@mipmap/ic_launcher', // default '@mipmap/ic_launcher' just for android
    ),
  );
  locator.registerLazySingleton(
    () => MorphemeHttp(
      timeout: 30000,
      showLog: true,
      morphemeInspector: locator(), // add this for activate inspector in Morpheme HTTP
    ),
  );
```

to help navigate without context to the morpheme inspector page it is necessary to setup the navigator state with the method `setNavigatorState(Navigator.of(context))` and is recommended on start pages like `SplashPage`.

```dart
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    locator<MorphemeInspector>().setNavigatorState(Navigator.of(context)); // add this to navigate from local notification or on shake 
    ...
  }
  ...
}
```
