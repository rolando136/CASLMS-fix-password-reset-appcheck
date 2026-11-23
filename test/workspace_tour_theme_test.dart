import 'dart:async';

import 'package:caslms/core/app_colors.dart';
import 'package:caslms/core/app_theme.dart';
import 'package:caslms/screens/shared/workspace_tour.dart';
import 'package:caslms/screens/shared/workspace_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Workspace tour uses $mode colors', (tester) async {
      final target = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: SizedBox(key: target, width: 48, height: 48),
                ),
                WorkspaceTourOverlay(
                  role: 'student',
                  targets: {0: target},
                  onNavigate: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      final dark = mode == ThemeMode.dark;
      final accent = dark ? DarkAppColors.primaryBlue : AppColors.primaryBlue;
      final text = dark ? DarkAppColors.darkText : AppColors.darkText;
      expect(
        tester.widget<Card>(find.byType(Card)).color,
        dark ? DarkAppColors.surface : Colors.white,
      );
      expect(
        tester.widget<Text>(find.text('STEP 1 OF 11')).style?.color,
        accent,
      );
      expect(tester.widget<Text>(find.text('Your home')).style?.color, text);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
            .style
            ?.backgroundColor
            ?.resolve({}),
        accent,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Mobile tour opens the real More menu and resumes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.reset);
    final home = GlobalKey();
    final more = GlobalKey();
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WorkspaceShell(
          name: 'Student',
          destinations: studentDestinations,
          selectedIndex: 0,
          onSelected: (index) => selected = index,
          onInbox: () {},
          onLogout: () {},
          tourTargets: {0: home, -1: more},
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      showGeneralDialog<void>(
        context: tester.element(find.byType(WorkspaceShell)),
        pageBuilder: (_, _, _) => WorkspaceTourOverlay(
          role: 'student',
          targets: {0: home, -1: more},
          onNavigate: (index) => selected = index,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('AI Assistant'), findsOneWidget);
    await tester.ensureVisible(find.text('Open More menu'));
    await tester.tap(find.text('Open More menu'));
    await tester.pumpAndSettle();
    expect(find.text('Your workspace'), findsOneWidget);
    await tester.tap(find.text('Results'));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tour announces steps and can be opted out with the keyboard', (
    tester,
  ) async {
    final target = GlobalKey();
    bool? optedOut;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SizedBox(key: target, width: 48, height: 48)),
      ),
    );
    unawaited(
      showGeneralDialog<bool>(
        context: tester.element(find.byType(Scaffold)),
        pageBuilder: (_, _, _) => WorkspaceTourOverlay(
          role: 'student',
          targets: {0: target},
          onNavigate: (_) {},
        ),
      ).then((value) => optedOut = value),
    );
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp('Tour step 1 of 11: Your home')),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('AI Assistant'), findsOneWidget);
    await tester.tap(find.text('Don’t show automatically again'));
    await tester.pumpAndSettle();
    expect(optedOut, true);
    expect(tester.takeException(), isNull);
  });
}
