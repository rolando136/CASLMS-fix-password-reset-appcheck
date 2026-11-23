import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import 'workspace_shell.dart';

typedef _TourStep = ({int tab, String title, String description});

/// Highlights the real workspace navigation instead of showing a separate guide.
class WorkspaceTour {
  static const _instructor = <_TourStep>[
    (
      tab: 0,
      title: 'Your dashboard',
      description: 'Start here for a snapshot of your courses and teaching activity. Use the create actions to start a course or add content.',
    ),
    (
      tab: -3,
      title: 'Create course content',
      description: 'Use Create to start a course or add a module, assessment, or learning material. Open a course to manage its sections and invite students.',
    ),
    (
      tab: 1,
      title: 'My Courses',
      description: 'Create or open a course here. Add sections, invite students, and organize modules, materials, and assessments inside it.',
    ),
    (
      tab: 2,
      title: 'Grading',
      description: 'Open an assessment to review submissions, assign scores, and give students feedback.',
    ),
    (
      tab: 7,
      title: 'Calendar',
      description: 'Track your teaching schedule and upcoming activities.',
    ),
    (
      tab: 3,
      title: 'Insights',
      description: 'Explore course activity and student progress.',
    ),
    (
      tab: 5,
      title: 'Messages',
      description: 'Keep in touch with your students from the Messages tab.',
    ),
    (
      tab: 6,
      title: 'Teaching AI',
      description: 'Open the teaching assistant from the top bar to help plan lessons and activities. Review its suggestions before using them.',
    ),
    (
      tab: -2,
      title: 'Notifications',
      description:
          'Check the bell for invitations, messages, and other updates.',
    ),
    (
      tab: 4,
      title: 'Your profile',
      description: 'Manage your account from the profile menu. You can replay this tour at any time with the help icon in the top bar.',
    ),
  ];
  static const _student = <_TourStep>[
    (
      tab: 0,
      title: 'Your home',
      description: 'See your classes and recent activity here. Check course invitations on the dashboard to join a new section.',
    ),
    (
      tab: -4,
      title: 'Join a class',
      description: 'Open Course invitations here, review the section, and accept an invitation to join. You can complete and submit assessments from Tasks.',
    ),
    (
      tab: 6,
      title: 'AI Assistant',
      description: 'Ask for study help from the AI Assistant, and double-check its answers against your course materials.',
    ),
    (
      tab: 1,
      title: 'Courses',
      description: 'Open an enrolled course to explore its modules, lessons, and learning materials.',
    ),
    (
      tab: 2,
      title: 'Tasks',
      description: 'Check assignments and deadlines, open a task to read its instructions, then submit your work.',
    ),
    (
      tab: 11,
      title: 'Notes',
      description: 'Keep your own study notes in one place.',
    ),
    (
      tab: 10,
      title: 'Calendar',
      description: 'Keep track of upcoming classes and deadlines.',
    ),
    (
      tab: 3,
      title: 'Results',
      description: 'See your grades and instructor feedback here.',
    ),
    (
      tab: 5,
      title: 'Messages',
      description: 'Contact your instructors and classmates from Messages.',
    ),
    (
      tab: -2,
      title: 'Notifications',
      description:
          'Check the bell to see course invitations and important updates.',
    ),
    (
      tab: 4,
      title: 'Your profile',
      description: 'Update your account details here. Use the help icon in the top bar to replay this tour later.',
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    required String role,
    required int selectedIndex,
    required Map<int, GlobalKey> targets,
    required ValueChanged<int> onNavigate,
    bool automatic = false,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !context.mounted) return;
    final prefs = SharedPreferencesAsync();
    final optOutKey = 'caslms_tour_opt_out_${role}_$uid';
    if (automatic) {
      try {
        if (await prefs.getBool(optOutKey) == true) return;
      } catch (_) {
        // Local storage is optional; still let the user skip the tour.
      }
    }
    if (!context.mounted || FirebaseAuth.instance.currentUser?.uid != uid) {
      return;
    }
    onNavigate(0);
    if (!context.mounted) return;
    final optedOut = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => WorkspaceTourOverlay(
        role: role,
        targets: targets,
        onNavigate: onNavigate,
      ),
    );
    if (context.mounted && FirebaseAuth.instance.currentUser?.uid == uid) {
      onNavigate(selectedIndex);
    }
    if (optedOut == true) {
      try {
        await prefs.setBool(optOutKey, true);
      } catch (_) {
        // Replaying the tour is always possible from the help button.
      }
    }
  }
}

class WorkspaceTourOverlay extends StatefulWidget {
  const WorkspaceTourOverlay({
    super.key,
    required this.role,
    required this.targets,
    required this.onNavigate,
  });
  final String role;
  final Map<int, GlobalKey> targets;
  final ValueChanged<int> onNavigate;

  @override
  State<WorkspaceTourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<WorkspaceTourOverlay> {
  int _index = 0;
  bool _moving = false;
  final _focusNode = FocusNode();
  List<_TourStep> get _steps => widget.role == 'instructor'
      ? WorkspaceTour._instructor
      : WorkspaceTour._student;

  Future<void> _go(int index) async {
    if (_moving) return;
    if (index == _steps.length) {
      Navigator.of(context).pop(false);
      return;
    }
    final step = _steps[index];
    if (step.tab == -3 || step.tab == -4) {
      widget.onNavigate(0);
    } else if (step.tab >= 0) {
      widget.onNavigate(step.tab);
    }
    setState(() => _moving = true);
    await WidgetsBinding.instance.endOfFrame;
    final target = widget.targets[step.tab]?.currentContext;
    if (target == null && step.tab < -2) {
      if (mounted) setState(() => _moving = false);
      await _go(index + 1);
      return;
    }
    if (target != null && target.mounted && mounted) {
      await Scrollable.ensureVisible(target, duration: Duration.zero);
    }
    if (mounted) {
      setState(() {
        _index = index;
        _moving = false;
      });
      _focusNode.requestFocus();
    }
  }

  Future<void> _openMore() async {
    final target = widget.targets[-1]?.currentContext;
    if (target == null || !target.mounted) return;
    await target
        .findAncestorWidgetOfExactType<WorkspaceBottomNavigation>()
        ?.showMore(target);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      final step = _steps[_index];
      final moreAvailable =
          step.tab >= 0 &&
          widget.targets[step.tab]?.currentContext == null &&
          widget.targets[-1]?.currentContext != null;
      final theme = Theme.of(context);
      final surface = AppColors.resolve(context, Colors.white);
      final textColor = AppColors.resolve(context, AppColors.darkText);
      final accent = AppColors.resolve(context, AppColors.primaryBlue);
      final target =
          widget.targets[step.tab]?.currentContext ??
          (step.tab >= 0 ? widget.targets[-1]?.currentContext : null);
      Rect? hole;
      final render = target?.findRenderObject();
      final origin = context.findRenderObject();
      if (render is RenderBox && render.hasSize && origin is RenderBox) {
        final offset = origin.globalToLocal(render.localToGlobal(Offset.zero));
        hole = (offset & render.size).inflate(5);
      }
      final width = (size.width - 32).clamp(0.0, 360.0);
      final mobileNav = hole != null && hole.center.dy > size.height * .65;
      final left =
          hole != null && !mobileNav && hole.right + width + 28 < size.width
          ? hole.right + 16
          : (size.width - width) / 2;
      final cardHeight = moreAvailable ? 380.0 : 320.0;
      final maxTop = (size.height - cardHeight - 16).clamp(
        16.0,
        double.infinity,
      );
      final top = mobileNav
          ? (hole.top - cardHeight - 12).clamp(16.0, maxTop).toDouble()
          : (size.height * .38).clamp(16.0, maxTop).toDouble();

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  hole,
                  accent,
                  theme.brightness == Brightness.dark ? .54 : .72,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: SafeArea(
                child: Focus(
                  focusNode: _focusNode,
                  autofocus: true,
                  onKeyEvent: (_, event) {
                    if (event is! KeyDownEvent) return KeyEventResult.ignored;
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      Navigator.of(context).pop(false);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      _go(_index + 1);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                        _index > 0) {
                      _go(_index - 1);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    label:
                        'Tour step ${_index + 1} of ${_steps.length}: ${step.title}. ${step.description}',
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: (size.height - top - 16).clamp(
                          80.0,
                          double.infinity,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 16,
                          color: surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: AppColors.resolve(
                                context,
                                AppColors.inputBorder,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STEP ${_index + 1} OF ${_steps.length}',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  step.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${step.description}${moreAvailable ? ' On a phone, find this section under More.' : ''}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.resolve(
                                          context,
                                          AppColors.link,
                                        ),
                                      ),
                                      child: const Text('Skip tour'),
                                    ),
                                    const Spacer(),
                                    if (_index > 0)
                                      TextButton(
                                        onPressed: _moving
                                            ? null
                                            : () => _go(_index - 1),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.resolve(
                                            context,
                                            AppColors.link,
                                          ),
                                        ),
                                        child: const Text('Back'),
                                      ),
                                    FilledButton(
                                      onPressed: _moving
                                          ? null
                                          : () => _go(_index + 1),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                      ),
                                      child: Text(
                                        _index == _steps.length - 1
                                            ? 'Finish'
                                            : 'Next',
                                      ),
                                    ),
                                  ],
                                ),
                                if (moreAvailable)
                                  TextButton.icon(
                                    onPressed: _openMore,
                                    icon: const Icon(Icons.more_horiz_rounded),
                                    label: const Text('Open More menu'),
                                  ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Don’t show automatically again',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter(this.hole, this.accent, this.opacity);
  final Rect? hole;
  final Color accent;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final mask = Path()..addRect(Offset.zero & size);
    if (hole != null) {
      mask.addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(14)));
      mask.fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: opacity),
    );
    if (hole != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hole!, const Radius.circular(14)),
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.hole != hole ||
      oldDelegate.accent != accent ||
      oldDelegate.opacity != opacity;
}
