import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

Widget _wrap(MosaicFormController controller, Widget child) =>
    MosaicTheme.test(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MosaicForm(controller: controller, child: child),
      ),
    );

void main() {
  testWidgets('field setValue updates the controller value', (tester) async {
    final controller = MosaicFormController();
    await tester.pumpWidget(_wrap(
      controller,
      MosaicFormField<String>(
        name: 'email',
        builder: (_, value, setValue, error) {
          return GestureDetector(
            onTap: () => setValue('a@b.com'),
            child: Text('value=${value ?? ''}'),
          );
        },
      ),
    ));
    expect(find.text('value='), findsOneWidget);
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(controller.value<String>('email'), 'a@b.com');
  });

  testWidgets('validate marks submitted and surfaces errors',
      (tester) async {
    final controller = MosaicFormController();
    await tester.pumpWidget(_wrap(
      controller,
      MosaicFormField<String>(
        name: 'email',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        builder: (_, value, setValue, error) =>
            Text('error=${error ?? '<none>'}'),
      ),
    ));
    expect(find.text('error=<none>'), findsOneWidget);
    expect(controller.validate(), isFalse);
    await tester.pump();
    expect(controller.error('email'), 'Required');
  });

  testWidgets('valid form passes validate', (tester) async {
    final controller = MosaicFormController();
    await tester.pumpWidget(_wrap(
      controller,
      MosaicFormField<String>(
        name: 'name',
        initialValue: 'jonny',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        builder: (_, value, setValue, error) => const SizedBox.shrink(),
      ),
    ));
    await tester.pump();
    expect(controller.validate(), isTrue);
  });
}
