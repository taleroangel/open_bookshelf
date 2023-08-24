DARTC = dart
PUBSPEC = pubspec.yaml

all: pub build_runner slang flutter_native_splash flutter_launcher_icons

pub: $(PUBSPEC)
	$(DARTC) pub get

build_runner:
	$(DARTC) run build_runner build

slang:
	$(DARTC) run slang build

flutter_native_splash: pub assets/icons/icon.png
	$(DARTC) run flutter_native_splash:create

flutter_launcher_icons: pub assets/icons/icon.png assets/icons/padding.png
	$(DARTC) run flutter_launcher_icons