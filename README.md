# open_bookshelf
Digital bookshelf application that utilizes the OpenLibrary API to help users manage their reading lists. The app provides an interface for users to search for books by ISBN and add them to their shelves, whether it be read, reading, or wishlist.

## 🛠️ Code Generation
Run the following commands in separate terminals and leave them running while coding so code generations happen when files change:

	flutter pub run slang watch
	flutter pub run build_runner watch

## 🏗️ Compilation

__'flutter_native_splash'__ and __'flutter_launcher_icons'__ require building before running the application, use the following commands:

```sh
flutter pub get
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons
```

__slang__ and __freezed__ packages require code generation before building the application, use the following commands:
```sh
flutter pub run slang build
flutter pub run build_runner build
```

### Release Build
In order to relese build the app you need to precompile the SKSL shaders, you can use the provided __'flutter_01.sksl.json'__ file or provide your own via the command:
```sh
flutter run --profile --cache-sksl --purge-persistent-cache --dump-skp-on-shader-compilation
```
Trigger as much animations as you can and then press __M__ inside the command-line to export the __'flutter_01.sksl.json'__ file

Then compile the __.apk__ application using the following command
```sh
flutter build apk --obfuscate --split-debug-info=build/app/output/symbols --no-track-widget-creation --release --bundle-sksl-path flutter_01.sksl.json --no-tree-shake-icons -v
```