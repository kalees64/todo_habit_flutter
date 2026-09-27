import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app/app.dart';
import 'package:taskflow/core/providers/database_providers.dart';
import 'package:taskflow/data/local/database.dart';

void main() {
  testWidgets('TaskFlowApp builds successfully', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const TaskFlowApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TaskFlowApp), findsOneWidget);

    await db.close();
  });
}
