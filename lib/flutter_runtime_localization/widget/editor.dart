import "package:flutter/material.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/model/model.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/service/service.dart";
import "package:flutter_runtime_localization/flutter_runtime_localization/widget/scope.dart";
// TODO(Quirille): This editor is not great, this should be improved.

/// An editor to easily edit your localizations.
class RuntimeLocalizationEditor<T extends RuntimeLocalizationBase>
    extends StatefulWidget {
  /// [RuntimeLocalizationEditor] constructor
  const RuntimeLocalizationEditor({
    required this.runtimeLocalization,
    required this.onUpdate,
    this.builder1 = _DefaultView.builder,
    this.builder2 = _DefaultDetail.builder,
    super.key,
  });

  /// The localization that is being edited.
  final T runtimeLocalization;

  /// Called when on update is pressed.
  final void Function(T updatedLocalization) onUpdate;

  ///
  final Widget Function(
    BuildContext, {
    required List<Widget> children,
    required VoidCallback onUpdate,
  }) builder1;

  ///
  final Widget Function(
    BuildContext, {
    required MapEntry<String, dynamic> entry,
    required void Function(String? value) onSave,
  }) builder2;

  @override
  State<RuntimeLocalizationEditor> createState() =>
      _RuntimeLocalizationEditorState<T>();
}

class _DefaultView extends StatelessWidget {
  const _DefaultView({
    required this.onUpdate,
    required this.children,
  });

  final VoidCallback onUpdate;
  final List<Widget> children;

  static Widget builder(
    BuildContext context, {
    required List<Widget> children,
    required VoidCallback onUpdate,
  }) =>
      _DefaultView(
        onUpdate: onUpdate,
        children: children,
      );

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          ...children,
          ElevatedButton(
            onPressed: onUpdate,
            child: const Text("update"),
          ),
        ],
      );
}

class _DefaultDetail extends StatelessWidget {
  const _DefaultDetail({
    required this.entry,
    required this.onSave,
  });

  final MapEntry<String, dynamic> entry;
  final void Function(String?) onSave;

  static Widget builder(
    BuildContext context, {
    required MapEntry<String, dynamic> entry,
    required void Function(String?) onSave,
  }) =>
      _DefaultDetail(
        entry: entry,
        onSave: onSave,
      );

  @override
  Widget build(BuildContext context) {
    if (entry.key == RuntimeLocalizationBase.keys.locale) {
      return Text(
        "${entry.key} ${entry.value}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(entry.key),
        TextFormField(
          initialValue: entry.value,
          decoration: InputDecoration(hintText: entry.key),
          validator: (value) => (value ?? "").isEmpty ? "required" : null,
          onSaved: onSave,
        ),
      ],
    );
  }
}

class _RuntimeLocalizationEditorState<T extends RuntimeLocalizationBase>
    extends State<RuntimeLocalizationEditor<T>> {
  late RuntimeLocalizationServiceInterface<T> service;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> stateMap = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    service = RuntimeLocalizationScope.of<T>(context);
    stateMap = service.serializer(widget.runtimeLocalization);
  }

  void update() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();
    widget.onUpdate(service.deserializer(stateMap));
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: widget.builder1(
          context,
          children: [
            for (var entry in stateMap.entries) ...[
              widget.builder2(
                context,
                entry: entry,
                onSave: (newValue) =>
                    stateMap[entry.key] = newValue ?? stateMap[entry.key],
              ),
            ],
          ],
          onUpdate: update,
        ),
      );
}
