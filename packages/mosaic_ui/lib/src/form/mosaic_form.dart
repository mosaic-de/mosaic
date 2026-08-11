import 'package:flutter/widgets.dart';

import '../state/mosaic_inline_error.dart';

/// Validator for a single form field. Returns null for valid, or an
/// error message string to render via [MosaicInlineError].
typedef MosaicFormValidator<T> = String? Function(T? value);

/// Owns mutable per-field state for a [MosaicForm]. Built so the form
/// itself owns nothing — the controller is the source of truth so it
/// can outlive a single rebuild and be inspected from tests.
class MosaicFormController extends ChangeNotifier {
  final Map<String, Object?> _values = <String, Object?>{};
  final Map<String, String?> _errors = <String, String?>{};
  bool _submitted = false;

  T? value<T>(String name) => _values[name] as T?;
  String? error(String name) => _submitted ? _errors[name] : null;
  bool get isSubmitted => _submitted;

  /// True when no field is currently in error and the form has been
  /// submitted at least once.
  bool get isValid => _errors.values.every((e) => e == null);

  void set<T>(String name, T? value, {MosaicFormValidator<T>? validator}) {
    _values[name] = value;
    if (validator != null) {
      _errors[name] = validator(value);
    }
    notifyListeners();
  }

  void register<T>(String name, MosaicFormValidator<T>? validator) {
    if (validator != null) {
      _errors[name] = validator(value<T>(name));
    } else {
      _errors[name] = null;
    }
  }

  /// Validate every registered field. Marks the form submitted so
  /// subsequent reads of [error] return non-null. Returns [isValid].
  bool validate() {
    _submitted = true;
    notifyListeners();
    return isValid;
  }

  void reset() {
    _values.clear();
    _errors.clear();
    _submitted = false;
    notifyListeners();
  }
}

/// Container that exposes a [MosaicFormController] to descendants via
/// [MosaicFormScope]. [MosaicFormField]s register themselves with the
/// controller so [MosaicFormController.validate] sees the full set.
class MosaicForm extends StatefulWidget {
  const MosaicForm({super.key, required this.controller, required this.child});

  final MosaicFormController controller;
  final Widget child;

  @override
  State<MosaicForm> createState() => _MosaicFormState();
}

class _MosaicFormState extends State<MosaicForm> {
  @override
  Widget build(BuildContext context) {
    return MosaicFormScope(controller: widget.controller, child: widget.child);
  }
}

/// Inherited handle so descendant fields can find the controller.
class MosaicFormScope extends InheritedWidget {
  const MosaicFormScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final MosaicFormController controller;

  static MosaicFormController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MosaicFormScope>();
    assert(scope != null, 'No MosaicFormScope in context.');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(MosaicFormScope oldWidget) =>
      oldWidget.controller != controller;
}

/// Wraps a single field widget so its value flows through the form
/// controller and its validator runs alongside [MosaicForm.validate].
///
/// The [builder] receives the current value and a setter; pass both to
/// the underlying input (e.g. `MosaicInput.onChanged: setValue`).
class MosaicFormField<T> extends StatefulWidget {
  const MosaicFormField({
    super.key,
    required this.name,
    required this.builder,
    this.validator,
    this.initialValue,
  });

  final String name;
  final T? initialValue;
  final MosaicFormValidator<T>? validator;
  final Widget Function(
    BuildContext context,
    T? value,
    void Function(T? value) setValue,
    String? error,
  )
  builder;

  @override
  State<MosaicFormField<T>> createState() => _MosaicFormFieldState<T>();
}

class _MosaicFormFieldState<T> extends State<MosaicFormField<T>> {
  MosaicFormController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MosaicFormScope.of(context);
    if (!identical(next, _controller)) {
      _controller = next;
      if (widget.initialValue != null) {
        next.set<T>(
          widget.name,
          widget.initialValue,
          validator: widget.validator,
        );
      } else {
        next.register<T>(widget.name, widget.validator);
      }
    }
  }

  void _set(T? value) {
    _controller!.set<T>(widget.name, value, validator: widget.validator);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final value = controller.value<T>(widget.name);
        final error = controller.error(widget.name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.builder(context, value, _set, error),
            if (error != null) ...[
              const SizedBox(height: 4),
              MosaicInlineError(error),
            ],
          ],
        );
      },
    );
  }
}
