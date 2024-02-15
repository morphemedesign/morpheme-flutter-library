# Morpheme HTTP

Morpheme HTTP uses the [http](https://pub.dev/packages/http) library which has been modified as needed. first we store `MorphemeHttp` into `locator`. `locator` is the service locator from [get_it](https://pub.dev/packages/get_it).

```dart
final locator = GetIt.instance;

locator.registerLazySingleton(
  () => MorphemeHttp(
    timeout: 30000,
    showLog: true,
    morphemeInspector: locator(),
    authTokenOption: AuthTokenOption(
      typeHeader: 'Authorization',
      prefixHeader: 'Bearer',
      getToken: () => locator<FlutterSecureStorage>().read(key: 'token'),
      authCondition: (request, response) =>
          request.url == MorphemeEndpoints.login,
      onAuthTokenResponse: (response) async {
        final map = jsonDecode(response.body);
        await locator<FlutterSecureStorage>().write(
          key: 'token',
          value: map['token'],
        );
        await locator<FlutterSecureStorage>().write(
          key: 'refresh_token',
          value: map['refresh_token'],
        );
      },
      clearCondition: (request, response) =>
          request.url == MorphemeEndpoints.logout,
      onClearToken: () =>
          locator<FlutterSecureStorage>().delete(key: 'token'),
      excludeEndpointUsageToken: [
        MorphemeEndpoints.login,
        MorphemeEndpoints.register,
      ],
    ),
    refreshTokenOption: RefreshTokenOption(
      method: RefreshTokenMethod.post,
      url: MorphemeEndpoints.refreshToken,
      condition: (request, response) =>
          request.url != MorphemeEndpoints.login && response.statusCode == 401,
      getBody: () async {
        final refreshToken =
            await locator<FlutterSecureStorage>().read(key: 'refresh_token');

        return {
          'refresh_token': refreshToken ?? '',
        };
      },
      onResponse: (response) async {
        // handle response refresh token
        final map = jsonDecode(response.body);
        locator<FlutterSecureStorage>().write(
          key: 'token',
          value: map['token'],
        );
      },
    ),
  );
```

and to enable http inspector need to add dependency [morpheme_inspector](https://pub.dev/packages/morpheme_inspector) and put in `locator`.

```dart
locator.registerLazySingleton(
    () => MorphemeInspector(
      showNotification: true, // default true
      showInspectorOnShake: true, // default true
      saveInspectorToLocal: true, // default true
      notificationIcon: '@mipmap/ic_launcher', // default '@mipmap/ic_launcher' just for android
    ),
  );
```

## Auth Token

To set the token, it is done after authorization and getting the token. the token is stored to local and setup on `MorphemeHttp`.

```dart
MorphemeHttp(
  ...
  authTokenOption:AuthTokenOption(
    typeHeader: 'Authorization',
    prefixHeader: 'Bearer',
    getToken: () => locator<FlutterSecureStorage>().read(key: 'token'),
    authCondition: (request, response) =>
        request.url == MorphemeEndpoints.login,
    onAuthTokenResponse: (response) async {
      final map = jsonDecode(response.body);
      await locator<FlutterSecureStorage>().write(
        key: 'token',
        value: map['token'],
      );
      await locator<FlutterSecureStorage>().write(
        key: 'refresh_token',
        value: map['refresh_token'],
      );
    },
    clearCondition: (request, response) =>
        request.url == MorphemeEndpoints.logout,
    onClearToken: () =>
        locator<FlutterSecureStorage>().delete(key: 'token'),
    excludeEndpointUsageToken: [
      MorphemeEndpoints.login,
      MorphemeEndpoints.register,
    ],
  ),
  ...
);
```

After we set the token, every API call will add an `Authorization` header with a default value of `Bearer $token`.

## Refresh Token

To set the token, it is done after authorization and getting the token. the token is stored to local and setup on `MorphemeHttp`.

```dart
MorphemeHttp(
  ...
  refreshTokenOption: RefreshTokenOption(
    method: RefreshTokenMethod.post,
    url: MorphemeEndpoints.refreshToken,
    condition: (request, response) =>
        request.url != MorphemeEndpoints.login && response.statusCode == 401,
    getBody: () async {
      final refreshToken =
          await locator<FlutterSecureStorage>().read(key: 'refresh_token');

      return {
        'refresh_token': refreshToken ?? '',
      };
    },
    onResponse: (response) async {
      // handle response refresh token
      final map = jsonDecode(response.body);
      locator<FlutterSecureStorage>().write(
        key: 'token',
        value: map['token'],
      );
    },
  ),
  ...
);
```

## Get

```dart
final MorphemeHttp http = locator();

final response = await http.get(Uri.parse('https://api.morpheme.id'), body: body.toMap());
```

## Post

```dart
final MorphemeHttp http = locator();

final response = await http.post(Uri.parse('https://api.morpheme.id'), body: body.toMap());
```

## Put

```dart
final MorphemeHttp http = locator();

final response = await http.put(Uri.parse('https://api.morpheme.id'), body: body.toMap());
```

## Patch

```dart
final MorphemeHttp http = locator();

final response = await http.patch(Uri.parse('https://api.morpheme.id'), body: body.toMap());
```

## Delete

```dart
final MorphemeHttp http = locator();

final response = await http.delete(Uri.parse('https://api.morpheme.id'), body: body.toMap());
```

## Post Multipart

```dart
final MorphemeHttp http = locator();
final File file = getImage();

final response = await http.postMultipart(Uri.parse('https://api.morpheme.id'), files: {'image': file}, body: body.toMap());
```
