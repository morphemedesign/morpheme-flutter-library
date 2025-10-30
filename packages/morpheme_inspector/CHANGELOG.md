## 3.1.0

feat(inspector): add curl command generation and display in UI

- Implement generateCurlCommand method to produce curl representation of requests
- Include curl command in the message share output for easier debugging
- Display curl command in the overview section widget for quick inspection
- Add a floating action button in example app to navigate to inspector page
- Update example app dependencies and iOS deployment target to 13.0
- Add ObjectBox package dependencies in iOS Podfile and Podfile.lock for data persistence
- Update example app .gitignore to include .build and .swiftpm directories

## 3.0.0

- chore(morpheme_inspector): bump version to 3.0.0 and update dependencies
- feat: support minimal flutter 3.32

## 2.0.2

- refactor(inspector_service): wrap database operations in transactions for improved reliability

## 2.0.2

- fix pagination list inspector

## 2.0.0

- bump minimal flutter version 3.24.0
- add pagination for list inspector
- add icon button copy to clipboard for items inspector
- bump dependencies to sqflite: ^2.4.0
- bump dependencies to sensors_plus: ^6.1.0
- bump dependencies to flutter_local_notifications: ^18.0.0
- bump dependencies to share_plus: ^10.1.1

## 1.2.1

- add other selected notification
- add other background selected notification

## 1.2.0

- bump intl to 0.19.0

## 1.1.0

- bump sqflite to 2.3.3+1
- bump sensors_plus to 5.0.1
- bump flutter_local_notifications to 17.1.2
- bump share_plus to 9.0.0

## 1.0.1

- update documentation and homepage link.

## 1.0.0

- Initial Open Source release.
