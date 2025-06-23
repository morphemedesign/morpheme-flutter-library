## 4.1.0

- feat(morpheme-http): improve refresh token handling (thanks to [pratamagumilar](https://github.com/pratamagumilar))

## 4.0.1

- feat(morpheme_http): expand HTTP exports to include BaseRequest, Request, MultipartRequest, and BaseResponse

## 4.0.0

- feat(morpheme_http): enhance error handling by adding request context to error responses and refactor multipart methods for consistency

## 3.3.0

- add SSE (Server-Sent Events) stream methods for HTTP methods GET, POST, PUT, PATCH, and DELETE (thanks to [yusupmdl](https://github.com/yusupmdl))

## 3.2.1

- update getMapEntryToken to match against the full URL string

## 3.2.0

- Add support for HEAD requests
- handle inspector to ignore add file to insert sqflite

## 3.1.1

- fix _copyRequest method to include mapEntityToken in headers

## 3.1.0

- disable timeout in post multipart and patch multipart 

## 3.0.2

- remove print when call invokeCache

## 3.0.1

- store to objectbox use sync to increase performance
- bump some depedencies

## 3.0.0

- feat add default mime type for fetch multipart request
- add dependency mime and http_parser

## 2.3.1

- fix condition for re fetch without refresh token in RefreshTokenOption

## 2.3.0

- add condition for re fetch without refresh token in RefreshTokenOption

## 2.2.1

- fix async/await in CacheStorage methods

## 2.2.0

- add onErrorResponse in refresh token option

## 2.1.0

- set to Future all condition in auth_token_option, refresh_token_option and middleware_response_option

## 2.0.1

- bump morpheme_inspector to 2.0.1

## 2.0.0

- bump minimal flutter version 3.24.0
- change cache strategy storage hive to objectbox

## 1.5.0

- change params files from Map<String, File> to Map<String, List<File>> for support multiple files in one key

## 1.4.0

- add method onErrorResponse for handle error response

## 1.3.1

- bump morpheme_inspector to 1.2.1

## 1.3.0

- bump morpheme_inspector to 1.2.0

## 1.2.1

- bump uuid to 4.4.0
- bump logger to 2.3.0
- bump path_provider to 2.1.3
- bump morpheme_inspector to 1.1.0

## 1.2.0

- add fetch patchMultipart

## 1.1.0

- add fetch download with progress
- change excludeEndpointUsageToken to List of RegExp

## 1.0.1

- update documentation and homepage link.

## 1.0.0

- Initial Open Source release.
