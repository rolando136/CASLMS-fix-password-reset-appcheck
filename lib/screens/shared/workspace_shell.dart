import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/theme_notifier.dart';
import 'workspace_widgets.dart';

typedef WorkspaceDestination = ({int index, String label, IconData icon});

Future<bool> confirmWorkspaceLogout(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your CASLMS account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    ) ??
    false;

const studentDestinations = <WorkspaceDestination>[
  (index: 0, label: 'Home', icon: Icons.space_dashboard_outlined),
  (index: 6, label: 'AI Assistant', icon: Icons.auto_awesome_rounded),
  (index: 1, label: 'Courses', icon: Icons.menu_book_outlined),
  (index: 2, label: 'Tasks', icon: Icons.assignment_outlined),
  (index: 3, label: 'Results', icon: Icons.insights_outlined),
  (index: 4, label: 'Profile', icon: Icons.person_outline_rounded),
  (index: 5, label: 'Messages', icon: Icons.chat_bubble_outline_rounded),
  (index: 9, label: 'Inbox', icon: Icons.notifications_none_rounded),
];

const instructorDestinations = <WorkspaceDestination>[
  (index: 0, label: 'Overview', icon: Icons.space_dashboard_outlined),
  (index: 1, label: 'Courses', icon: Icons.menu_book_outlined),
  (index: 2, label: 'Grading', icon: Icons.assignment_outlined),
  (index: 4, label: 'Profile', icon: Icons.person_outline_rounded),
  (index: 3, label: 'Analytics', icon: Icons.insights_outlined),
  (index: 5, label: 'Chat', icon: Icons.chat_bubble_outline_rounded),
  (index: 6, label: 'AI Assistant', icon: Icons.smart_toy_outlined),
];

/// Layout only: authentication, destination indexes and page state stay with
/// the existing role screens. Every decision uses the available container.
class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({
    super.key,
    required this.child,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.onInbox,
    required this.onLogout,
    required this.name,
    this.photoUrl,
    this.role = 'Student',
    this.unreadCount = 0,
    this.profileIndex = 4,
    this.notificationsAvailable = true,
  });
  final Widget child;
  final List<WorkspaceDestination> destinations;
  final int selectedIndex, unreadCount, profileIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onInbox, onLogout;
  final String name, role;
  final String? photoUrl;
  final bool notificationsAvailable;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final desktop = box.maxWidth >= 1100 && scale <= 1.4;
      return Scaffold(
        backgroundColor: AppColors.resolve(context, AppColors.background),
        bottomNavigationBar: desktop
            ? null
            : WorkspaceBottomNavigation(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              ),
        body: Row(
          children: [
            if (desktop) _sidebar(context),
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1450),
                    child: LayoutBuilder(
                      builder: (context, content) {
                        final inset = workspaceInset(content.maxWidth);
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                inset,
                                desktop ? 24 : 10,
                                inset,
                                desktop ? 36 : 12,
                              ),
                              child: _topBar(context, desktop),
                            ),
                            Expanded(child: child),
                          ],
                        );
                      },
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

  String get _destinationLabel {
    for (final destination in destinations) {
      if (destination.index == selectedIndex) return destination.label;
    }
    // The bell can open Inbox even in shells that omit its sidebar entry.
    return selectedIndex == 9 ? 'Inbox' : 'Workspace';
  }

  Widget _topBar(BuildContext context, bool desktop) => Row(
    children: [
      Expanded(
        child: desktop
            ? Row(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 17,
                    color: AppColors.resolve(context, AppColors.secondaryText),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '/',
                      style: TextStyle(color: Color(0xFFCCD3DF)),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _destinationLabel,
                      style: TextStyle(
                        color: AppColors.resolve(
                          context,
                          AppColors.secondaryText,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              )
            : const WorkspaceBrand(compact: true),
      ),
      const SizedBox(width: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.resolve(
                context,
                Colors.white,
              ).withValues(alpha: .8),
              border: Border.all(
                color: AppColors.resolve(context, AppColors.inputBorder),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const ValueKey('header-theme-button'),
                  visualDensity: desktop
                      ? null
                      : const VisualDensity(horizontal: -2, vertical: -2),
                  padding: desktop ? null : EdgeInsets.zero,
                  constraints: desktop
                      ? null
                      : const BoxConstraints.tightFor(width: 40, height: 40),
                  tooltip: Theme.of(context).brightness == Brightness.dark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  onPressed: () => ThemeNotifier.instance.setThemeMode(
                    Theme.of(context).brightness == Brightness.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 21,
                    color: AppColors.resolve(context, AppColors.darkText),
                  ),
                ),
                IconButton(
                  visualDensity: desktop
                      ? null
                      : const VisualDensity(horizontal: -2, vertical: -2),
                  padding: desktop ? null : EdgeInsets.zero,
                  constraints: desktop
                      ? null
                      : const BoxConstraints.tightFor(width: 40, height: 40),
                  tooltip: notificationsAvailable
                      ? 'Notifications${unreadCount > 0 ? ', $unreadCount unread' : ''}'
                      : 'Notifications unavailable',
                  onPressed: onInbox,
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    smallSize: 7,
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 21,
                      color: AppColors.resolve(context, AppColors.darkText),
                    ),
                  ),
                ),
                Container(
                  height: 18,
                  width: 1,
                  color: AppColors.resolve(context, AppColors.inputBorder),
                ),
                IconButton(
                  visualDensity: desktop
                      ? null
                      : const VisualDensity(horizontal: -2, vertical: -2),
                  padding: desktop ? null : EdgeInsets.zero,
                  constraints: desktop
                      ? null
                      : const BoxConstraints.tightFor(width: 40, height: 40),
                  tooltip: 'Logout',
                  onPressed: onLogout,
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: AppColors.resolve(context, AppColors.darkText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _sidebar(BuildContext context) => Container(
    key: const ValueKey('desktop-sidebar'),
    width: 224,
    decoration: BoxDecoration(
      color: AppColors.resolve(context, Colors.white),
      border: Border(
        right: BorderSide(
          color: AppColors.resolve(context, AppColors.inputBorder),
        ),
      ),
    ),
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          key: const ValueKey('sidebar-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, box.maxHeight - 56),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: WorkspaceBrand(),
                    ),
                    const SizedBox(height: 52),
                    const Padding(
                      padding: EdgeInsets.only(left: 14, bottom: 14),
                      child: WorkspaceEyebrow('WORKSPACE'),
                    ),
                    for (final d in destinations.where(
                      (d) => role != 'Student' || d.index != profileIndex,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _SidebarDestination(
                          destination: d,
                          selected: selectedIndex == d.index,
                          count: d.label == 'Inbox' ? unreadCount : 0,
                          onTap: () => onSelected(d.index),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.resolve(
                            context,
                            AppColors.background,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              color: AppColors.resolve(
                                context,
                                AppColors.primaryBlue,
                              ),
                              size: 24,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Keep your curiosity.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your next great idea starts with a little learning.',
                              style: TextStyle(
                                color: AppColors.resolve(
                                  context,
                                  AppColors.secondaryText,
                                ),
                                fontSize: 12,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => onSelected(1),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Explore your workspace',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  Icon(Icons.arrow_outward_rounded, size: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => onSelected(profileIndex),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              WorkspaceAvatar(
                                name: name,
                                photoUrl: photoUrl,
                                size: 36,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$role account',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.resolve(
                                          context,
                                          AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.unfold_more_rounded,
                                color: AppColors.resolve(
                                  context,
                                  AppColors.secondaryText,
                                ),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

double workspaceInset(double width) => width >= 800
    ? 36
    : width >= 600
    ? 28
    : 20;

class WorkspaceBrand extends StatelessWidget {
  const WorkspaceBrand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 28 : 36,
        height: compact ? 28 : 36,
        decoration: BoxDecoration(
          color: AppColors.resolve(context, AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: compact ? 18 : 21,
        ),
      ),
      SizedBox(width: compact ? 7 : 10),
      Flexible(
        child: Text(
          'caslms',
          maxLines: 1,
          style: TextStyle(
            color: AppColors.resolve(context, AppColors.darkText),
            fontSize: compact ? 18 : 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ),
    ],
  );
}

class WorkspaceAvatar extends StatelessWidget {
  const WorkspaceAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    required this.size,
  });
  final String name;
  final String? photoUrl;
  final double size;
  @override
  Widget build(BuildContext context) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    final initials = words.isEmpty
        ? '?'
        : (words.first.characters.first +
                  (words.length > 1 ? words.last.characters.first : ''))
              .toUpperCase();
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: const Color(0xFFECE9E3),
      child: Text(
        initials,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: const Color(0xFF6D675E),
          fontSize: size * .31,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Semantics(
      label: '$name profile',
      image: true,
      child: ClipOval(
        child: photoUrl == null || photoUrl!.isEmpty
            ? fallback
            : Image.network(
                photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, error, trace) => fallback,
              ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.count = 0,
  });
  final WorkspaceDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final int count;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected
          ? AppColors.resolve(context, AppColors.blueTint)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('nav-${destination.index}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Icon(
                destination.icon,
                size: 20,
                color: AppColors.resolve(
                  context,
                  selected ? AppColors.primaryBlue : AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.resolve(
                      context,
                      selected
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
              if (count > 0)
                WorkspacePill(
                  label: count > 99 ? '99+' : '$count',
                  color: AppColors.resolve(context, AppColors.secondaryText),
                  background: selected ? Colors.white : AppColors.background,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class WorkspaceBottomNavigation extends StatelessWidget {
  const WorkspaceBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<WorkspaceDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  bool get _student =>
      destinations.any((d) => d.index == 9) &&
      destinations.any((d) => d.index == 6) &&
      destinations.any((d) => d.index == 2 && d.label == 'Tasks');
  List<WorkspaceDestination> get _primary => _student
      ? [
          for (final index in [0, 1, 6, 2])
            destinations.firstWhere((d) => d.index == index),
        ]
      : destinations.take(4).toList();
  List<WorkspaceDestination> get _secondary => destinations
      .where((d) => !_primary.any((primary) => primary.index == d.index))
      .toList();
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                key: const ValueKey('mobile-navigation'),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.resolve(
                    context,
                    Colors.white,
                  ).withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.resolve(context, AppColors.inputBorder),
                  ),
                ),
                child: Row(
                  children: [
                    for (final d in _primary)
                      _item(
                        context,
                        d.index == 6 && _student ? 'AI' : d.label,
                        d.icon,
                        selectedIndex == d.index,
                        () => onSelected(d.index),
                        ValueKey('nav-${d.index}'),
                      ),
                    if (destinations.length > 4)
                      _item(
                        context,
                        'More',
                        Icons.more_horiz_rounded,
                        _secondary.any((d) => d.index == selectedIndex),
                        () => _more(context),
                        const ValueKey('nav-more'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _item(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback tap,
    Key key,
  ) => Expanded(
    child: Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: selected
              ? AppColors.resolve(context, AppColors.blueTint)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: label == 'AI' && !selected
                ? BorderSide(
                    color: AppColors.resolve(context, AppColors.blueTint),
                    width: 1.2,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            key: key,
            onTap: tap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 23,
                    color: AppColors.resolve(
                      context,
                      selected
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.resolve(
                        context,
                        selected
                            ? AppColors.primaryBlue
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _more(BuildContext context) async {
    final index = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your workspace',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (final d in _secondary)
                  _SidebarDestination(
                    destination: d,
                    selected: selectedIndex == d.index,
                    onTap: () => Navigator.pop(context, d.index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (index != null) onSelected(index);
  }
}
