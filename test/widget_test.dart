import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jump_game/src/game/jump_game.dart';

void main() {
  testWidgets('Game widget boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      GameWidget<JumpGame>(
        game: JumpGame(),
      ),
    );

    expect(find.byType(GameWidget<JumpGame>), findsOneWidget);
  });
}
