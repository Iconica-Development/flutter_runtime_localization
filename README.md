# Flutter Runtime Localizations

This package solves the issue of dynamically adding new languages for an app.
TODO: Later on it might be interesting to look at dynamically adding entries.

## Features

- Adding a localization file per locale.

## Getting started

### Installation

```yaml
flutter_runtime_localization:
  hosted: https://forgejo.internal.iconica.nl/api/packages/internal/pub
  version: ...
```

For macos you need to add

```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

to your *.entitlements.

## Usage

1. Create an extension of `RuntimeLocalizationBase`..
2. Create the `FileRuntimeLocalizationService<$YourExtensionOfRuntimeLocalizationBase>`.
3. Initialize the service.
4. Wrap your MainApp widget with the RuntimeLocalizationScope.
5. Set the `supportedLocales` of your `MaterialApp` to `delegate.locales`.
6. Set the `localizationsDelegates` of your `MaterialApp`.
7. For easy of use create and extension on `BuildContext`.
8. Use your localizations.

```dart
class SomeRuntimeLocalization extends RuntimeLocalizationBase {
  const SomeRuntimeLocalization({
    required super.locale,
    this.test1 = const LocalizationString("test1"),
  });

  factory SomeRuntimeLocalization.fromMap(
    Map<String, dynamic> map,
  ) =>
      SomeRuntimeLocalization(
        locale: localeFromString(map["locale"] as String),
        test1: LocalizationString(map["test1"] as String),
      );

  static const keys = (test1: "test1",);

  final LocalizationString test1;

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        keys.test1: "$test1",
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localizationService =
      FileRuntimeLocalizationService<SomeRuntimeLocalization>(
    directory: Directory("files/localizations/"),
    serializer: (value) => value.toMap(),
    deserializer: SomeRuntimeLocalization.fromMap,
    onEmpty: (service) {
      service.addLocalization(
        SomeRuntimeLocalization.fromMap(
          {
            RuntimeLocalization.keys.locale: "nl_NL",
            SomeRuntimeLocalization.keys.test1: "A",
          },
        ),
      );
    },
  );

  await localizationService.initialize();

  runApp(
    RuntimeLocalizationScope(
      service: localizationService,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final delegate =
        RuntimeLocalizationScope.of<SomeRuntimeLocalization>(context);

    return MaterialApp(
      home: const Scaffold(body: Test()),
      supportedLocales: delegate.locales,
      localizationsDelegates: [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

extension ContextLocalizations on BuildContext {
  SomeRuntimeLocalization get localizations =>
      Localizations.of<SomeRuntimeLocalization>(this, SomeRuntimeLocalization)!;
}

class Test extends StatelessWidget {
  const Test({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService =
        RuntimeLocalizationScope.of<SomeRuntimeLocalization>(context);
    final localizations = context.localizations;

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Text(Localizations.localeOf(context).toString()),
            Text(localizations.test1()),
            ElevatedButton(
              onPressed: localizationService.pickLocalizationFile,
              child: const Text("add"),
            ),
            Expanded(
              child: RuntimeLocalizationEditor<SomeRuntimeLocalization>(
                onUpdate: localizationService.updateLocalization,
                runtimeLocalization: localizationService
                    .getLocalization(Localizations.localeOf(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```



## Additional information 
