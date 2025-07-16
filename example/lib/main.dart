import 'package:flutter/material.dart';
import 'package:flutter_runtime_localization/flutter_runtime_localization.dart';
import 'package:path_provider/path_provider.dart';

class SomeRuntimeLocalization extends RuntimeLocalizationBase {
  const SomeRuntimeLocalization({
    required super.locale,
    this.test1 = const LocalizationString("test1"),
    this.test2 = const LocalizationString("test2"),
    this.test3 = const LocalizationString("test3"),
    this.test4 = const LocalizationString("test4"),
    this.test5 = const LocalizationString("test5"),
  });

  factory SomeRuntimeLocalization.fromMap(
    Map<String, dynamic> map,
  ) =>
      SomeRuntimeLocalization(
        locale: localeFromString(map["locale"] as String),
        test1: LocalizationString(map["test1"] as String),
        test2: LocalizationString(map["test2"] as String),
        test3: LocalizationString(map["test3"] as String),
        test4: LocalizationString(map["test4"] as String),
        test5: LocalizationString(map["test5"] as String),
      );

  static const keys = (
    test1: "test1",
    test2: "test2",
    test3: "test3",
    test4: "test4",
    test5: "test5",
  );

  final LocalizationString test1;
  final LocalizationString test2;
  final LocalizationString test3;
  final LocalizationString test4;
  final LocalizationString test5;

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        keys.test1: "$test1",
        keys.test2: "$test2",
        keys.test3: "$test3",
        keys.test4: "$test4",
        keys.test5: "$test5",
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localizationService =
      FileRuntimeLocalizationService<SomeRuntimeLocalization>(
    directory: await getApplicationSupportDirectory(),
    serializer: (value) => value.toMap(),
    deserializer: SomeRuntimeLocalization.fromMap,
    onEmpty: (service) async {
      await service.addLocalization(
        SomeRuntimeLocalization.fromMap(
          {
            RuntimeLocalizationBase.keys.locale: "nl_NL",
            SomeRuntimeLocalization.keys.test1: "A",
            SomeRuntimeLocalization.keys.test2: "B",
            SomeRuntimeLocalization.keys.test3: "C",
            SomeRuntimeLocalization.keys.test4: "D",
            SomeRuntimeLocalization.keys.test5: "E",
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
        RuntimeLocalizationScope.of<SomeRuntimeLocalization>(context)
            .getLocalizationDelegate();

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
        RuntimeLocalizationScope.of<SomeRuntimeLocalization>(context)
            as FileRuntimeLocalizationService<SomeRuntimeLocalization>;
    final localizations = context.localizations;

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Text(Localizations.localeOf(context).toString()),
            Text(localizations.test1()),
            Text(localizations.test2()),
            Text(localizations.test3()),
            Text(localizations.test4()),
            Text(localizations.test5()),
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
