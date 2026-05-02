@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('list with subtitle and trailing', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'list_default',
      size: const Size(360, 320),
      builder: (tokens) => SizedBox(
        width: 320,
        height: 280,
        child: MosaicList(
          rows: [
            MosaicListRow(
              title: 'Java House',
              subtitle: '2h ago',
              trailing: Text(
                '-450',
                style: tokens.typography.body.copyWith(
                  color: tokens.color.textPrimary,
                ),
              ),
            ),
            MosaicListRow(
              title: 'Salary — Acme',
              subtitle: '1d ago',
              trailing: Text(
                '+8,500',
                style: tokens.typography.body.copyWith(
                  color: tokens.color.success,
                ),
              ),
            ),
            MosaicListRow(
              title: 'Uber',
              subtitle: '1d ago',
              trailing: Text(
                '-280',
                style: tokens.typography.body.copyWith(
                  color: tokens.color.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}
