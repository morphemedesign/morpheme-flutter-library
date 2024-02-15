import 'dart:io';

/// Override http client for bad certificate callback force to true
///
/// this methode is not secure for your apps
class MorphemeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
