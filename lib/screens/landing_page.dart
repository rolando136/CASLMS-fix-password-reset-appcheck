import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'shared/workspace_shell.dart';
import 'shared/workspace_widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: WorkspaceBrand()),
                const SizedBox(height: 40),
                const WorkspaceHeading(
                  title: 'SSU Enhanced\nE-Learning',
                  subtitle: 'Your integrated digital learning platform for modules, interactive videos, and academic submissions.',
                  eyebrow: 'COLLEGE OF ARTS AND SCIENCES',
                ),
                const SizedBox(height: 28),
                const WorkspaceSurface(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      _Feature(Icons.menu_book_outlined, 'Learn'),
                      _Feature(Icons.assignment_outlined, 'Submit'),
                      _Feature(Icons.video_library_outlined, 'Watch'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  label: const Text('Get Started'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  iconAlignment: IconAlignment.end,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  child: const Text(
                    'I already have an account',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Communicate. Assess. Organize. Succeed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    letterSpacing: .3,
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

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppColors.primaryBlue),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
      ),
    ],
  );
}
