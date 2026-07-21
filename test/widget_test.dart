import 'package:flutter_test/flutter_test.dart';
import 'package:ai_store_assistant/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AiStoreAssistantApp());
    // Verify the app renders without throwing
    expect(find.byType(AiStoreAssistantApp), findsOneWidget);
  });
}
