import '../shared/notification_destination_page.dart';

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../services/instructor_workspace_context.dart';

import 'instructor_teaching_assistant_page.dart';
import '../shared/workspace_tour.dart';
import '../shared/authenticated_workspace.dart';
import '../shared/workspace_shell.dart';
import '../shared/calendar_page.dart';
import 'instructor_messages_page.dart';

import 'instructor_dashboard_page.dart';
import 'instructor_grading_page.dart';
import 'instructor_analytics_page.dart';
import 'instructor_classes_page.dart';
import 'instructor_profile_page.dart';

class InstructorMainScreen extends StatefulWidget {
  const InstructorMainScreen({super.key, this.notificationId});
  final String? notificationId;

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  final Map<int, GlobalKey> _tourTargets = {
    for (final index in [0, 1, 2, 3, 4, 5, 6, 7, -2]) index: GlobalKey(),
    -1: GlobalKey(),
    -3: GlobalKey(),
  };

  void _showTour({bool automatic = false}) => WorkspaceTour.show(
    context,
    role: 'instructor',
    selectedIndex: _selectedIndex,
    targets: _tourTargets,
    onNavigate: _onItemTapped,
    automatic: automatic,
  );
  StreamSubscription<User?>? _contextAuth;
  @override
  void initState() {
    super.initState();
    InstructorWorkspaceContext.instance.bindUser(
      FirebaseAuth.instance.currentUser?.uid,
    );
    _contextAuth = FirebaseAuth.instance.authStateChanges().listen((user) {
      InstructorWorkspaceContext.instance.bindUser(user?.uid);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.notificationId == null) _showTour(automatic: true);
    });
  }

  int _selectedIndex = 0;
  @override
  void dispose() {
    _contextAuth?.cancel();
    InstructorWorkspaceContext.instance.bindUser(null);
    super.dispose();
  }

  int _destinationIndex = 0;
  bool _destinationVisible = true;
  final _notificationKey = GlobalKey();
  late final Widget? _notificationDestination = widget.notificationId == null
      ? null
      : NotificationDestinationScreen(
          key: _notificationKey,
          notificationId: widget.notificationId!,
          onTab: (index) {
            if (mounted) {
              setState(() {
                _selectedIndex = index;
                _destinationIndex = index;
              });
            }
          },
        );
  final Set<int> _openedTabs = <int>{0};

  void _onItemTapped(int index) {
    setState(() {
      _destinationVisible = false;
      _selectedIndex = index;
      _openedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<WidgetBuilder> pages = [
      (_) => InstructorDashboardScreen(
        onNavigateToTab: _onItemTapped,
        onTour: () => _showTour(),
        createTourKey: _tourTargets[-3],
      ),
      (_) => const InstructorClassesScreen(),
      (_) => const InstructorGradingScreen(),
      (_) => const InstructorAnalyticsScreen(),
      (_) => const InstructorProfileScreen(),
      (_) => const InstructorMessagesScreen(),
      (_) => const InstructorTeachingAssistantScreen(),
      (_) => const CalendarScreen(role: 'instructor'),
    ];

    return AuthenticatedWorkspace(
      role: 'Instructor',
      destinations: instructorDestinations,
      selectedIndex: _selectedIndex,
      onSelected: _onItemTapped,
      tourTargets: _tourTargets,
      onTour: () => _showTour(),
      child: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          pages.length,
          (index) =>
              _destinationVisible &&
                  _notificationDestination != null &&
                  index == _destinationIndex
              ? _notificationDestination
              : TickerMode(
                  enabled: index == _selectedIndex,
                  child: _openedTabs.contains(index) || index == _selectedIndex
                      ? pages[index](context)
                      : const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}
